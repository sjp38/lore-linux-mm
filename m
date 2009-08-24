Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 191AA6B00D4
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 07:31:21 -0400 (EDT)
Date: Mon, 24 Aug 2009 14:55:38 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: Bad page state (was Re: Linux 2.6.31-rc7)
Message-ID: <20090824135538.GA23707@csn.ul.ie>
References: <alpine.LFD.2.01.0908211810390.3158@localhost.localdomain> <200908212248.40987.gene.heskett@verizon.net> <alpine.LFD.2.01.0908212055140.3158@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.01.0908212055140.3158@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Gene Heskett <gene.heskett@verizon.net>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Sorry about the slow response. I was on holidays for a few days and
didn't have a laptop with me to keep track of mail.

On Fri, Aug 21, 2009 at 09:17:48PM -0700, Linus Torvalds wrote:
> 
> On Fri, 21 Aug 2009, Gene Heskett wrote:
> > 
> > From messages, I already have a problem with lzma too:
> 
> And for this too, can you tell what the last working kernel was?
> 
> Does the problem happen consistently? (And btw, it's not probably so much 
> lzma, but something random that released a page without clearing some of 
> the page flags or something).
> 

This has already been isolated as a memory problem so I won't say
anything more about that.

> Wu - I'm not seeing a lot of changes to compund page handling except for 
> commit 20a0307c0396c2edb651401d2f2db193dda2f3c9 ("mm: introduce PageHuge() 
> for testing huge/gigantic pages").
> 
> That one removed the
> 
> 	set_compound_page_dtor(page, free_compound_page);
> 
> thing from prep_compound_gigantic_page(), which looks a bit odd and 
> suspicious (the commit message only talks about _moving_ it). But I don't 
> know the hugetlb code.
> 

The set_compound_page_dtor() that was there was spurious and was been set
properly later in the initialisation path for gigantic pages.  Wu was going
to fix it up but it made more sense to just delete it. The discussion at
the time is here http://lkml.org/lkml/2009/5/17/83

> But that commit went into -rc1 already.  Gene, I know you sent me email 
> about a later -rc release, but maybe you didn't test it on that machine or 
> with that config?
> 
> > Aug 21 22:37:47 coyote kernel: [ 1030.152737] BUG: Bad page state in process lzma  pfn:a1093
> > Aug 21 22:37:47 coyote kernel: [ 1030.152743] page:c28fc260 flags:80004000 count:0 mapcount:0 mapping:(null) index:0
> > Aug 21 22:37:47 coyote kernel: [ 1030.152747] Pid: 17927, comm: lzma Not tainted 2.6.31-rc7 #1
> > Aug 21 22:37:47 coyote kernel: [ 1030.152750] Call Trace:
> > Aug 21 22:37:47 coyote kernel: [ 1030.152758]  [<c130e363>] ? printk+0x23/0x40
> > Aug 21 22:37:47 coyote kernel: [ 1030.152763]  [<c108404f>] bad_page+0xcf/0x150
> > Aug 21 22:37:47 coyote kernel: [ 1030.152767]  [<c10850ed>] get_page_from_freelist+0x37d/0x480
> > Aug 21 22:37:47 coyote kernel: [ 1030.152771]  [<c10853cf>] __alloc_pages_nodemask+0xdf/0x520
> > Aug 21 22:37:47 coyote kernel: [ 1030.152775]  [<c1096b19>] handle_mm_fault+0x4a9/0x9f0
> > Aug 21 22:37:47 coyote kernel: [ 1030.152780]  [<c1020d61>] do_page_fault+0x141/0x290
> > Aug 21 22:37:47 coyote kernel: [ 1030.152784]  [<c1020c20>] ? do_page_fault+0x0/0x290
> > Aug 21 22:37:47 coyote kernel: [ 1030.152787]  [<c1311bcb>] error_code+0x73/0x78
> > Aug 21 22:37:47 coyote kernel: [ 1030.152789] Disabling lock debugging due to kernel taint
> 
> It looks like 'flags' is the one that causes this problem at allocation 
> time (count, mapcount, mapping and index all look nicely zeroed).
> 
> In particular, it's the 0x4000 bit (the high bit, which is also set, is 
> the upper field bits for page section/node/zone numbers etc), which is 
> either PG_head or PG_compound depending on CONFIG_PAGEFLAGS_EXTENDED.
> 
> And in your case, since you have CONFIG_PAGEFLAGS_EXTENDED=y, it would be 
> PG_head.
> 
> Btw guys, why don't we check PG_head etc at free time when we add the page 
> to the free list? Now we get that annoying error only when it is way too 
> late, and have no way to know who screwed up..
> 

Minimally because the checks for bad bits set in flags can happen before
the compound page is destroyed. Take the most common compound page that
will have it's destructor as free_compound_page(). One free path then
looks like

put_page()
  -> put_compound_page()
    -> free_compound_page()
      -> __free_pages_ok()
         Check every head and tail page with free_pages_check()
        -> __free_one_page()
          -> destroy_compound_page()

So a check for the compound bits here would trigger for all compound pages
freed via put_page().

As the compound bits are always being checked in the free path and handled
accordingly, it's ordinarily considered "impossible" for pages to end up
on the free list with the bits intact which is why we don't have additional
checks for it.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
