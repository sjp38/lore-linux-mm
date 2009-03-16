Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 6C5446B003D
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 19:45:26 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2GNjNA9026867
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 17 Mar 2009 08:45:23 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 56CF445DE5D
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 08:45:23 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 32D5B45DE51
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 08:45:23 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 150E01DB803C
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 08:45:23 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id BB2B21DB8038
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 08:45:22 +0900 (JST)
Date: Tue, 17 Mar 2009 08:44:00 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: BUG?: PAGE_FLAGS_CHECK_AT_PREP seems to be cleared too early
 (Was Re: I just got got another Oops
Message-Id: <20090317084400.919c75ae.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0903162101110.13164@blonde.anvils>
References: <200903120133.11583.gene.heskett@gmail.com>
	<49B8C98D.3020309@davidnewall.com>
	<200903121431.49437.gene.heskett@gmail.com>
	<20090316115509.40ea13da.kamezawa.hiroyu@jp.fujitsu.com>
	<20090316170359.858e7a4e.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0903162101110.13164@blonde.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>
Cc: Gene Heskett <gene.heskett@gmail.com>, David Newall <davidn@davidnewall.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 16 Mar 2009 21:44:11 +0000 (GMT)
Hugh Dickins <hugh@veritas.com> wrote:

> On Mon, 16 Mar 2009, KAMEZAWA Hiroyuki wrote:
> > Hi,
> > I'm sorry if I miss something..
> 
> I think it's me who missed something, and needs to say sorry.
> 
> > 
> > >From this patch
> > ==
> > http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=79f4b7bf393e67bbffec807cc68caaefc72b82ee
> > ==
> > #define PAGE_FLAGS_CHECK_AT_PREP       ((1 << NR_PAGEFLAGS) - 1)
> > ...
> > @@ -468,16 +467,16 @@ static inline int free_pages_check(struct page *page)
> >                 (page_count(page) != 0)  |
> >                 (page->flags & PAGE_FLAGS_CHECK_AT_FREE)))
> > ....
> > +       if (PageReserved(page))
> > +               return 1;
> > +       if (page->flags & PAGE_FLAGS_CHECK_AT_PREP)
> > +               page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
> > +       return 0;
> >  }
> > ==
> > 
> > PAGE_FLAGS_CHECK_AT_PREP is cleared by free_pages_check().
> > 
> > This means PG_head/PG_tail(PG_compound) flags are cleared here
> 
> Yes, well spotted.  How embarrassing.  I must have got confused
> about when the checking occurred when freeing a compound page.
> 
> > and Compound page will never be freed in sane way.
> 
> But is that so?  I'll admit I've not tried this out yet, but my
> understanding is that the Compound page actually gets freed fine:
> free_compound_page() should have passed the right order down, and this
> PAGE_FLAGS_CHECK_AT_PREP clearing should remove the Head/Tail/Compound
> flags - doesn't it all work out sanely, without any leaking?
> 
I think it works sanely and pages are freed in valid way.
But bad_page() checking for compound pages (at destroy_compound_page())
is not done.


> What goes missing is all the destroy_compound_page() checks:
> that's at present just dead code.
> 
> There's several things we could do about this.
> 
> 1.  We could regard destroy_compound_page() as legacy debugging code
> from when compound pages were first introduced, and sanctify my error
> by removing it.  Obviously that's appealing to me, makes me look like
> a prophet rather than idiot!  That's not necessarily the right thing to
> do, but might appeal also to those cutting overhead from page_alloc.c.
> 
> 2.  We could do the destroy_compound_page() stuff in free_compound_page()
> before calling __free_pages_ok(), and add the Head/Tail/Compound flags
> into PAGE_FLAGS_CHECK_AT_FREE.  That seems a more natural ordering to
> me, and would remove the PageCompound check from a hotter path; but
> I've a suspicion there's a good reason why it was not done that way,
> that I'm overlooking at this moment.
> 
> 3.  We can define a PAGE_FLAGS_CLEAR_AT_FREE which omits the Head/Tail/
> Compound flags, and lets destroy_compound_page() be called as before
> where it's currently intended.
> 
> What do you think?  I suspect I'm going to have to spend tomorrow
> worrying about something else entirely, and won't return here until
> Wednesday.
> 
I like "2". 


> But as regards the original "I just got got another Oops": my bug
> that you point out here doesn't account for that, does it?  It's
> still a mystery, isn't it, how the PageTail bit came to be set at
> that point?
> 
I never find "who set it/where does it set". But page_alloc.c is an only
file which modifies PageTail bit and I'm the last modifier of it.
So, I'm intersted in this Oops.


> But that Oops does demonstrate that it's a very bad idea to be using
> the deceptive page_count() in those bad_page() checks: we need to be
> checking page->_count directly.
> 
I think so.

> And in looking at this, I notice something else to worry about:
> that CONFIG_HUGETLBFS prep_compound_gigantic_page(), which seems
> to exist for a more general case than "p = page + i" - what happens
> when such a gigantic page is freed, and arrives at the various
> "p = page + i" assumptions on the freeing path?
> 
Ah, I missed that path. I'll look into that today.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
