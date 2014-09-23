Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 96A9E6B0038
	for <linux-mm@kvack.org>; Tue, 23 Sep 2014 16:38:38 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id hz1so7320047pad.40
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 13:38:38 -0700 (PDT)
Received: from mail-pd0-x229.google.com (mail-pd0-x229.google.com [2607:f8b0:400e:c02::229])
        by mx.google.com with ESMTPS id gk5si22569834pbc.246.2014.09.23.13.38.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 23 Sep 2014 13:38:37 -0700 (PDT)
Received: by mail-pd0-f169.google.com with SMTP id fp1so3034550pdb.14
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 13:38:37 -0700 (PDT)
Date: Tue, 23 Sep 2014 13:38:32 -0700
From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: mmotm 2014-09-22-16-57 uploaded
Message-ID: <20140923203832.GA1112@roeck-us.net>
References: <5420b8b0.9HdYLyyuTikszzH8%akpm@linux-foundation.org>
 <20140923190222.GA4662@roeck-us.net>
 <20140923130128.79f5931ac03dbb31f53be805@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140923130128.79f5931ac03dbb31f53be805@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Sasha Levin <sasha.levin@oracle.com>, Anish Bhatt <anish@chelsio.com>, David Miller <davem@davemloft.net>, Fabio Estevam <fabio.estevam@freescale.com>, Randy Dunlap <rdunlap@infradead.org>

On Tue, Sep 23, 2014 at 01:01:28PM -0700, Andrew Morton wrote:
> On Tue, 23 Sep 2014 12:02:22 -0700 Guenter Roeck <linux@roeck-us.net> wrote:
> 
> > On Mon, Sep 22, 2014 at 05:02:56PM -0700, akpm@linux-foundation.org wrote:
> > > The mm-of-the-moment snapshot 2014-09-22-16-57 has been uploaded to
> > > 
> > >    http://www.ozlabs.org/~akpm/mmotm/
> > > 
> > > mmotm-readme.txt says
> > > 
> > > README for mm-of-the-moment:
> > > 
> > > http://www.ozlabs.org/~akpm/mmotm/
> > > 
> > > This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> > > more than once a week.
> > > 
> > Sine I started testing this branch, I figure I might as well share the results.
> > 
> > Build results:
> > 	total: 133 pass: 115 fail: 18
> > Failed builds:
> > 	alpha:defconfig
> > 	alpha:allmodconfig
> > 	arm:imx_v6_v7_defconfig
> > 	arm:imx_v4_v5_defconfig
> > 	i386:allyesconfig
> > 	i386:allmodconfig
> > 	m68k:allmodconfig
> > 	mips:nlm_xlp_defconfig
> > 	parisc:a500_defconfig
> > 	powerpc:cell_defconfig
> > 	powerpc:ppc6xx_defconfig
> > 	powerpc:mpc85xx_defconfig
> > 	powerpc:mpc85xx_smp_defconfig
> > 	tile:tilegx_defconfig
> > 
> > Qemu test results:
> > 	total: 24 pass: 23 fail: 1
> > Failed tests:
> > 	alpha:alpha_defconfig
> > 
> > More information is available at http://server.roeck-us.net:8010/builders.
> > Note that powerpc failures are counted twice because they are built twice,
> > once with binutils 2.23 and once with 2.24.
> > 
> > The most scary problem (in my opinion) is the failed mips:nlm_xlp_defconfig
> > build.  It is caused by 'scsi_netlink : Make SCSI_NETLINK dependent on NET
> > instead of selecting NET', which effectively disables CONFIG_NET for around
> > 30 configurations (assuming I found them all). The practical impact is that
> > the affected configurations won't really work anymore, even if they compile. 
> 
> cc'ing Anish Bhatt.
> 
He knows about it, as do David Miller and Randy Dunlap (who proposed it) [1].
There just doesn't seem to be an agreement on how to fix the problem.
A simple revert doesn't work anymore since there are multiple follow-up
patches, and if I understand correctly David is opposed to a revert anyway.

I submitted a set of RFC patches in an attempt to fix the problem for MIPS [2],
but I did not yet get any feedback. Since then I identified 20 more affected
(non-mips) configurations.


> > Guenter
> > 
> > ---
> > Details:
> > 
> > alpha (including qemu)
> > 
> > drivers/tty/serial/8250/8250_core.c: In function 'serial8250_ioctl':
> > drivers/tty/serial/8250/8250_core.c:2874:7: error: 'TIOCSRS485' undeclared
> > 
> > arm:imx_v6_v7_defconfig
> > arm:imx_v4_v5_defconfig
> > 
> > drivers/media/platform/coda/coda-bit.c: In function 'coda_fill_bitstream':
> > drivers/media/platform/coda/coda-bit.c:231:4: error: implicit declaration of function 'kmalloc'
> > drivers/media/platform/coda/coda-bit.c: In function 'coda_alloc_framebuffers':
> > drivers/media/platform/coda/coda-bit.c:312:3: error: implicit declaration of function 'kfree'
> 
> That's odd - it includes slab.h.  Cc Fabio.
> 
Turns out that include is in next-20149023, and the problem is gone there.
Maybe your tree just missed the necessary patch.

> > i386:allyesconfig
> > 
> > drivers/built-in.o: In function `_scsih_qcmd':
> > mpt2sas_scsih.c:(.text+0xf5327d): undefined reference to `__udivdi3'
> > mpt2sas_scsih.c:(.text+0xf532b0): undefined reference to `__umoddi3'
> >
> > i386:allmodconfig
> > 
> > ERROR: "__udivdi3" [drivers/scsi/mpt2sas/mpt2sas.ko] undefined!
> > ERROR: "__umoddi3" [drivers/scsi/mpt2sas/mpt2sas.ko] undefined!
> 
> Sigh.
>  
A patch to fix a problem was submitted. Two times, actually, if I recall
correctly. Should be somewhere in the queue.

> > m68k:allmodconfig
> > 
> > drivers/tty/serial/st-asc.c: In function 'asc_in':
> > drivers/tty/serial/st-asc.c:154:2: error: implicit declaration of function 'readl_relaxed'
> > 
> > mips:nlm_xlp_defconfig
> > 
> > ERROR: "scsi_is_fc_rport" [drivers/scsi/libfc/libfc.ko] undefined!
> > ERROR: "fc_get_event_number" [drivers/scsi/libfc/libfc.ko] undefined!
> > ERROR: "skb_trim" [drivers/scsi/libfc/libfc.ko] undefined!
> > ERROR: "fc_host_post_event" [drivers/scsi/libfc/libfc.ko] undefined!
> > 
> > [and many more]
> > 
> > parisc:a500_defconfig
> > 
> > ERROR: "csum_partial" [drivers/scsi/scsi_debug.ko] undefined!
> > 
> > powerpc:cell_defconfig
> > powerpc:mpc85xx_defconfig
> > powerpc:mpc85xx_smp_defconfig
> > 
> > arch/powerpc/mm/hugetlbpage.c:710:1: error: conflicting types for 'follow_huge_pud'
> >  follow_huge_pud(struct mm_struct *mm, unsigned long address,
> >   ^
> > In file included from arch/powerpc/mm/hugetlbpage.c:14:0: include/linux/hugetlb.h:103:14:
> > 	note: previous declaration of 'follow_huge_pud' was here
> >    struct page *follow_huge_pud(struct mm_struct *mm, unsigned long address,
>                  ^
> 
> Naoya, please check:
> 
> --- a/arch/powerpc/mm/hugetlbpage.c~mm-hugetlb-reduce-arch-dependent-code-around-follow_huge_-fix
> +++ a/arch/powerpc/mm/hugetlbpage.c
> @@ -708,7 +708,7 @@ follow_huge_pmd(struct mm_struct *mm, un
>  
>  struct page *
>  follow_huge_pud(struct mm_struct *mm, unsigned long address,
> -		pmd_t *pmd, int write)
> +		pud_t *pud, int write)
>  {
>  	BUG();
>  	return NULL;
> _
> 
> > powerpc:ppc6xx_defconfig
> > 
> > In file included from include/linux/kernel.h:13:0, from mm/debug.c:8:
> > mm/debug.c: In function 'dump_mm':
> > mm/debug.c:212:5: error: 'const struct mm_struct' has no member named 'owner'
> 
> I fixed that.
> 
> > tile:tilegx_defconfig
> > 
> > mm/debug.c: In function 'dump_mm':
> > mm/debug.c:169:2: error: expected ')' before 'mm'
> 
> Don't have a clue.  In my tree that's
> 
> 	pr_emerg("mm %p mmap %p seqnum %d task_size %lu\n"
> 
Culprit is

+#if defined(CONFIG_NUMA_BALANCING) || defined(CONFIG_COMPACTION)
+               "tlb_flush_pending %d\n",
+#endif

This is due to Sasha Levin's patch 'mm: introduce VM_BUG_ON_MM'. The above
doesn't work if neither CONFIG_NUMA_BALANCING nor CONFIG_COMPACTION are
defined due to the ',' at the end with is missing in that case.

Guenter

---
[1] https://lkml.org/lkml/2014/9/19/558
[2] https://lkml.org/lkml/2014/9/20/215

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
