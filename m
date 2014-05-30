Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 7309C6B0039
	for <linux-mm@kvack.org>; Thu, 29 May 2014 21:35:21 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id jt11so1128436pbb.22
        for <linux-mm@kvack.org>; Thu, 29 May 2014 18:35:21 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id oq10si3313601pac.48.2014.05.29.18.35.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 May 2014 18:35:19 -0700 (PDT)
Message-ID: <1401413716.29324.2.camel@concordia>
Subject: Re: [PATCH] hugetlb: restrict hugepage_migration_support() to
 x86_64 (Re: BUG at mm/memory.c:1489!)
From: Michael Ellerman <mpe@ellerman.id.au>
Date: Fri, 30 May 2014 11:35:16 +1000
In-Reply-To: <1401388474-mqnis5cp@n-horiguchi@ah.jp.nec.com>
References: <1401265922.3355.4.camel@concordia>
	 <alpine.LSU.2.11.1405281712310.7156@eggly.anvils>
	 <1401353983.4930.15.camel@concordia>
	 <1401388474-mqnis5cp@n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, benh@kernel.crashing.org, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, trinity@vger.kernel.org

On Thu, 2014-05-29 at 14:34 -0400, Naoya Horiguchi wrote:
> On Thu, May 29, 2014 at 06:59:43PM +1000, Michael Ellerman wrote:
> > Applying your patch and running trinity pretty immediately results in the
> > following, which looks related (sys_move_pages() again) ?
> >
> > Unable to handle kernel paging request for data at address 0xf2000f80000000
> > Faulting instruction address: 0xc0000000001e29bc
> > cpu 0x1b: Vector: 300 (Data Access) at [c0000003c70f76f0]
> >     pc: c0000000001e29bc: .remove_migration_pte+0x9c/0x320
> >     lr: c0000000001e29b8: .remove_migration_pte+0x98/0x320
> >     sp: c0000003c70f7970
> >    msr: 8000000000009032
> >    dar: f2000f80000000
> >  dsisr: 40000000
> >   current = 0xc0000003f9045800
> >   paca    = 0xc000000001dc6c00   softe: 0        irq_happened: 0x01
> >     pid   = 3585, comm = trinity-c27
> > enter ? for help
> > [c0000003c70f7a20] c0000000001bce88 .rmap_walk+0x328/0x470
> > [c0000003c70f7ae0] c0000000001e2904 .remove_migration_ptes+0x44/0x60
> > [c0000003c70f7b80] c0000000001e4ce8 .migrate_pages+0x6d8/0xa00
> > [c0000003c70f7cc0] c0000000001e55ec .SyS_move_pages+0x5dc/0x7d0
> > [c0000003c70f7e30] c00000000000a1d8 syscall_exit+0x0/0x98
> > --- Exception: c01 (System Call) at 00003fff7b2b30a8
> > SP (3fffe09728a0) is in userspace
> > 1b:mon>
>
> Sorry for inconvenience on your testing.
 
That's fine, it's good to find bugs :)

> Hugepage migration is enabled for archs which have pmd-level hugepage
> (including ppc64,) but not tested except for x86_64.
> hugepage_migration_support() controls this so the following patch should
> help you avoid the problem, I believe.
> Could you try to test with it?

Sure. So this patch, in addition to Hugh's patch to remove the BUG_ON(), does
avoid the crash above (remove_migration_pte()).

I dropped Hugh's patch, as he has decided he doesn't like it, and added the
following hunk instead:

diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
index 3c1b968..f230a97 100644
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -175,6 +175,12 @@ static inline int vma_migratable(struct vm_area_struct *vma)
 {
        if (vma->vm_flags & (VM_IO | VM_PFNMAP))
                return 0;
+
+#ifndef CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION
+       if (vma->vm_flags & VM_HUGETLB)
+               return 0;
+#endif
+
        /*
         * Migration allocates pages in the highest zone. If we cannot
         * do so then migration (at least from node to node) is not


Which seems to be what Hugh was referring to in his mail - correct me if I'm
wrong Hugh.

With your patch and the above hunk I can run trinity happily for a while,
whereas without it crashes almost immediately.

So with the above hunk you can add my tested-by.

cheers


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
