Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A91AD6B009E
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 12:11:05 -0500 (EST)
Date: Tue, 26 Jan 2010 18:10:33 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 04 of 31] update futex compound knowledge
Message-ID: <20100126171032.GS30452@random.random>
References: <patchbomb.1264513915@v2.random>
 <948638099c17d3da3d6f.1264513919@v2.random>
 <4B5F1460.7030106@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B5F1460.7030106@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 26, 2010 at 11:12:16AM -0500, Rik van Riel wrote:
> On 01/26/2010 08:51 AM, Andrea Arcangeli wrote:
> > From: Andrea Arcangeli<aarcange@redhat.com>
> >
> > Futex code is smarter than most other gup_fast O_DIRECT code and knows about
> > the compound internals. However now doing a put_page(head_page) will not
> > release the pin on the tail page taken by gup-fast, leading to all sort of
> > refcounting bugchecks. Getting a stable head_page is a little tricky.
> >
> > Signed-off-by: Andrea Arcangeli<aarcange@redhat.com>
> > ---
> >
> > diff --git a/kernel/futex.c b/kernel/futex.c
> > --- a/kernel/futex.c
> > +++ b/kernel/futex.c
> > @@ -218,7 +218,7 @@ get_futex_key(u32 __user *uaddr, int fsh
> >   {
> >   	unsigned long address = (unsigned long)uaddr;
> >   	struct mm_struct *mm = current->mm;
> > -	struct page *page;
> > +	struct page *page, *page_head;
> >   	int err;
> >
> >   	/*
> > @@ -250,10 +250,32 @@ again:
> >   	if (err<  0)
> >   		return err;
> >
> > -	page = compound_head(page);
> > -	lock_page(page);
> > -	if (!page->mapping) {
> > -		unlock_page(page);
> > +	page_head = page;
> 
> ...
> 
> > +	if (unlikely(page_head != page)) {
> 
> Should the line above be "page_head = compound_head(page);" or
> am I missing something?

page_head = page is there because if this is not a tail page it's also
the page_head. Only in case this is a tail page, compound_head is
called, otherwise it's guaranteed unnecessary. And if it's a tail page
compound_head has to run atomically inside irq disabled section
__get_user_pages_fast before returning. Otherwise ->first_page won't
be a stable pointer.

> If I am missing something, the changelog message could be a
> little more verbose :)

Ok will add the above comments ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
