Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 095B46B0085
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 07:31:27 -0400 (EDT)
Date: Tue, 8 Sep 2009 12:30:39 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 1/8] mm: munlock use follow_page
In-Reply-To: <20090908115825.edb06814.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0909081227010.25652@sister.anvils>
References: <Pine.LNX.4.64.0909072222070.15424@sister.anvils>
 <Pine.LNX.4.64.0909072227140.15430@sister.anvils>
 <20090908115825.edb06814.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hiroaki Wakabayashi <primulaelatior@gmail.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 Sep 2009, KAMEZAWA Hiroyuki wrote:
> On Mon, 7 Sep 2009 22:29:55 +0100 (BST)
> Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:
> >  void munlock_vma_pages_range(struct vm_area_struct *vma,
> > -			   unsigned long start, unsigned long end)
> > +			     unsigned long start, unsigned long end)
> >  {
> > +	unsigned long addr;
> > +
> > +	lru_add_drain();
> >  	vma->vm_flags &= ~VM_LOCKED;
> > -	__mlock_vma_pages_range(vma, start, end, 0);
> > +
> > +	for (addr = start; addr < end; addr += PAGE_SIZE) {
> > +		struct page *page = follow_page(vma, addr, FOLL_GET);
> > +		if (page) {
> > +			lock_page(page);
> > +			if (page->mapping)
> > +				munlock_vma_page(page);
> 
> Could you add "please see __mlock_vma_pages_range() to see why" or some here ?

Why the test on page->mapping?
Right, I'll add some such comment on that.
Waiting a day or two to see what else comes up.

Thanks,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
