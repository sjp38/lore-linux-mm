Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com [74.125.82.179])
	by kanga.kvack.org (Postfix) with ESMTP id 7B4306B0035
	for <linux-mm@kvack.org>; Thu, 29 May 2014 00:53:04 -0400 (EDT)
Received: by mail-we0-f179.google.com with SMTP id q59so12047718wes.24
        for <linux-mm@kvack.org>; Wed, 28 May 2014 21:53:03 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id lb4si36709073wjb.84.2014.05.28.21.53.01
        for <linux-mm@kvack.org>;
        Wed, 28 May 2014 21:53:02 -0700 (PDT)
Message-ID: <5386bd2e.6478c20a.5839.5e40SMTPIN_ADDED_BROKEN@mx.google.com>
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: BUG at mm/memory.c:1489!
Date: Thu, 29 May 2014 00:52:35 -0400
In-Reply-To: <alpine.LSU.2.11.1405281712310.7156@eggly.anvils>
References: <1401265922.3355.4.camel@concordia> <alpine.LSU.2.11.1405281712310.7156@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: mpe@ellerman.id.au, Andrew Morton <akpm@linux-foundation.org>, benh@kernel.crashing.org, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, trinity@vger.kernel.org

Hi Hugh,

On Wed, May 28, 2014 at 05:33:11PM -0700, Hugh Dickins wrote:
> On Wed, 28 May 2014, Michael Ellerman wrote:
> > Hey folks,
> > 
> > Anyone seen this before? Trinity hit it just now:
> > 
> > Linux Blade312-5 3.15.0-rc7 #306 SMP Wed May 28 17:51:18 EST 2014 ppc64
> > 
> > [watchdog] 27853 iterations. [F:22642 S:5174 HI:1276]
> > ------------[ cut here ]------------
> > kernel BUG at /home/michael/mmk-build/flow/mm/memory.c:1489!
> > cpu 0xc: Vector: 700 (Program Check) at [c000000384eaf960]
> >     pc: c0000000001ad6f0: .follow_page_mask+0x90/0x650
> >     lr: c0000000001ad6d8: .follow_page_mask+0x78/0x650
> >     sp: c000000384eafbe0
> >    msr: 8000000000029032
> >   current = 0xc0000003c27e1bc0
> >   paca    = 0xc000000001dc3000   softe: 0        irq_happened: 0x01
> >     pid   = 20800, comm = trinity-c12
> > kernel BUG at /home/michael/mmk-build/flow/mm/memory.c:1489!
> > enter ? for help
> > [c000000384eafcc0] c0000000001e5514 .SyS_move_pages+0x524/0x7d0
> > [c000000384eafe30] c00000000000a1d8 syscall_exit+0x0/0x98
> > --- Exception: c01 (System Call) at 00003fff795f30a8
> > SP (3ffff958f290) is in userspace
> > 
> > I've left it in the debugger, can dig into it a bit more tomorrow
> > if anyone has any clues.
> 
> Thanks for leaving it overnight, but this one is quite obvious,
> so go ahead and reboot whenever suits you.
> 
> Trinity didn't even need to do anything bizarre to get this: that
> ordinary path simply didn't get tried on powerpc or ia64 before.
> 
> Here's a patch which should fix it for you, but I believe leaves
> a race in common with other architectures.  I must turn away to
> other things, and hope Naoya-san can fix up the locking separately
> (or point out why it's already safe).
> 
> [PATCH] mm: fix move_pages follow_page huge_addr BUG
> 
> v3.12's e632a938d914 ("mm: migrate: add hugepage migration code to
> move_pages()") is okay on most arches, but on follow_huge_addr-style
> arches ia64 and powerpc, it hits my old BUG_ON(flags & FOLL_GET)
> from v2.6.15 deceb6cd17e6 ("mm: follow_page with inner ptlock").
> 
> The point of the BUG_ON was that nothing needed FOLL_GET there at
> the time, and it was not clear that we have sufficient locking to
> use get_page() safely here on the outside - maybe the page found has
> already been freed and even reused when follow_huge_addr() returns.
> 
> I suspect that e632a938d914's use of get_page() after return from
> follow_huge_pmd() has the same problem: what prevents a racing
> instance of move_pages() from already migrating away and freeing
> that page by then?  A reference to the page should be taken while
> holding suitable lock (huge_pte_lockptr?), to serialize against
> concurrent migration.

Right, we need take huge_pte_lockptr() here, I think.

> But I'm not prepared to rework the hugetlb locking here myself;
> so for now just supply a patch to copy e632a938d914's get_page()
> after follow_huge_pmd() to after follow_huge_addr(): removing
> the BUG_ON(flags & FOLL_GET), but probably leaving a race.

This bug was introduced by me, so I'll fix this.
Thank you for reporting.

> Fixes: e632a938d914 ("mm: migrate: add hugepage migration code to move_pages()")
> Reported-by: Michael Ellerman <mpe@ellerman.id.au>
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: stable@vger.kernel.org # 3.12+

This patch looks good to me.

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
> Whether this is a patch that should go in without fixing the locking,
> I don't know.  An unlikely race is better than a triggerable BUG?
> Or perhaps I'm just wrong about there being any such race.
> 
>  mm/memory.c |   12 +++++++++++-
>  1 file changed, 11 insertions(+), 1 deletion(-)
> 
> --- 3.15-rc7/mm/memory.c	2014-04-27 23:55:53.608801152 -0700
> +++ linux/mm/memory.c	2014-05-28 13:05:48.340124615 -0700
> @@ -1486,7 +1486,17 @@ struct page *follow_page_mask(struct vm_
>  
>  	page = follow_huge_addr(mm, address, flags & FOLL_WRITE);
>  	if (!IS_ERR(page)) {
> -		BUG_ON(flags & FOLL_GET);
> +		if (page && (flags & FOLL_GET)) {
> +			/*
> +			 * Refcount on tail pages are not well-defined and
> +			 * shouldn't be taken. The caller should handle a NULL
> +			 * return when trying to follow tail pages.
> +			 */
> +			if (PageHead(page))
> +				get_page(page);
> +			else
> +				page = NULL;
> +		}
>  		goto out;
>  	}
>  
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
