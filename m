Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 486E46B0035
	for <linux-mm@kvack.org>; Tue, 23 Sep 2014 15:02:31 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id kx10so7032646pab.5
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 12:02:31 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id f5si22552810pat.14.2014.09.23.12.02.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 23 Sep 2014 12:02:30 -0700 (PDT)
Received: by mail-pa0-f44.google.com with SMTP id eu11so6175621pac.3
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 12:02:29 -0700 (PDT)
Date: Tue, 23 Sep 2014 12:02:22 -0700
From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: mmotm 2014-09-22-16-57 uploaded
Message-ID: <20140923190222.GA4662@roeck-us.net>
References: <5420b8b0.9HdYLyyuTikszzH8%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5420b8b0.9HdYLyyuTikszzH8%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz

On Mon, Sep 22, 2014 at 05:02:56PM -0700, akpm@linux-foundation.org wrote:
> The mm-of-the-moment snapshot 2014-09-22-16-57 has been uploaded to
> 
>    http://www.ozlabs.org/~akpm/mmotm/
> 
> mmotm-readme.txt says
> 
> README for mm-of-the-moment:
> 
> http://www.ozlabs.org/~akpm/mmotm/
> 
> This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> more than once a week.
> 
Sine I started testing this branch, I figure I might as well share the results.

Build results:
	total: 133 pass: 115 fail: 18
Failed builds:
	alpha:defconfig
	alpha:allmodconfig
	arm:imx_v6_v7_defconfig
	arm:imx_v4_v5_defconfig
	i386:allyesconfig
	i386:allmodconfig
	m68k:allmodconfig
	mips:nlm_xlp_defconfig
	parisc:a500_defconfig
	powerpc:cell_defconfig
	powerpc:ppc6xx_defconfig
	powerpc:mpc85xx_defconfig
	powerpc:mpc85xx_smp_defconfig
	tile:tilegx_defconfig

Qemu test results:
	total: 24 pass: 23 fail: 1
Failed tests:
	alpha:alpha_defconfig

More information is available at http://server.roeck-us.net:8010/builders.
Note that powerpc failures are counted twice because they are built twice,
once with binutils 2.23 and once with 2.24.

The most scary problem (in my opinion) is the failed mips:nlm_xlp_defconfig
build.  It is caused by 'scsi_netlink : Make SCSI_NETLINK dependent on NET
instead of selecting NET', which effectively disables CONFIG_NET for around
30 configurations (assuming I found them all). The practical impact is that
the affected configurations won't really work anymore, even if they compile. 

Guenter

---
Details:

alpha (including qemu)

drivers/tty/serial/8250/8250_core.c: In function 'serial8250_ioctl':
drivers/tty/serial/8250/8250_core.c:2874:7: error: 'TIOCSRS485' undeclared

arm:imx_v6_v7_defconfig
arm:imx_v4_v5_defconfig

drivers/media/platform/coda/coda-bit.c: In function 'coda_fill_bitstream':
drivers/media/platform/coda/coda-bit.c:231:4: error: implicit declaration of function 'kmalloc'
drivers/media/platform/coda/coda-bit.c: In function 'coda_alloc_framebuffers':
drivers/media/platform/coda/coda-bit.c:312:3: error: implicit declaration of function 'kfree'

i386:allyesconfig

drivers/built-in.o: In function `_scsih_qcmd':
mpt2sas_scsih.c:(.text+0xf5327d): undefined reference to `__udivdi3'
mpt2sas_scsih.c:(.text+0xf532b0): undefined reference to `__umoddi3'

i386:allmodconfig

ERROR: "__udivdi3" [drivers/scsi/mpt2sas/mpt2sas.ko] undefined!
ERROR: "__umoddi3" [drivers/scsi/mpt2sas/mpt2sas.ko] undefined!

m68k:allmodconfig

drivers/tty/serial/st-asc.c: In function 'asc_in':
drivers/tty/serial/st-asc.c:154:2: error: implicit declaration of function 'readl_relaxed'

mips:nlm_xlp_defconfig

ERROR: "scsi_is_fc_rport" [drivers/scsi/libfc/libfc.ko] undefined!
ERROR: "fc_get_event_number" [drivers/scsi/libfc/libfc.ko] undefined!
ERROR: "skb_trim" [drivers/scsi/libfc/libfc.ko] undefined!
ERROR: "fc_host_post_event" [drivers/scsi/libfc/libfc.ko] undefined!

[and many more]

parisc:a500_defconfig

ERROR: "csum_partial" [drivers/scsi/scsi_debug.ko] undefined!

powerpc:cell_defconfig
powerpc:mpc85xx_defconfig
powerpc:mpc85xx_smp_defconfig

arch/powerpc/mm/hugetlbpage.c:710:1: error: conflicting types for 'follow_huge_pud'
 follow_huge_pud(struct mm_struct *mm, unsigned long address,
  ^
In file included from arch/powerpc/mm/hugetlbpage.c:14:0: include/linux/hugetlb.h:103:14:
	note: previous declaration of 'follow_huge_pud' was here
   struct page *follow_huge_pud(struct mm_struct *mm, unsigned long address,
                 ^

powerpc:ppc6xx_defconfig

In file included from include/linux/kernel.h:13:0, from mm/debug.c:8:
mm/debug.c: In function 'dump_mm':
mm/debug.c:212:5: error: 'const struct mm_struct' has no member named 'owner'

tile:tilegx_defconfig

mm/debug.c: In function 'dump_mm':
mm/debug.c:169:2: error: expected ')' before 'mm'

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
