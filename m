Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id F12086B7394
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 10:29:55 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id u13-v6so4021550pfm.8
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 07:29:55 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t26-v6sor481731pgn.43.2018.09.05.07.29.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Sep 2018 07:29:54 -0700 (PDT)
Date: Wed, 5 Sep 2018 07:29:51 -0700
From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH 3/3] mm: optimise pte dirty/accessed bit setting by
 demand based pte insertion
Message-ID: <20180905142951.GA15680@roeck-us.net>
References: <20180828112034.30875-1-npiggin@gmail.com>
 <20180828112034.30875-4-npiggin@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180828112034.30875-4-npiggin@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ley Foon Tan <lftan@altera.com>, nios2-dev@lists.rocketboards.org

Hi,

On Tue, Aug 28, 2018 at 09:20:34PM +1000, Nicholas Piggin wrote:
> Similarly to the previous patch, this tries to optimise dirty/accessed
> bits in ptes to avoid access costs of hardware setting them.
> 

This patch results in silent nios2 boot failures, silent meaning that
the boot stalls.

...
Unpacking initramfs...
Freeing initrd memory: 2168K
workingset: timestamp_bits=30 max_order=15 bucket_order=0
jffs2: version 2.2. (NAND) (C) 2001-2006 Red Hat, Inc.
random: fast init done
random: crng init done

[no further activity until the qemu session is aborted]

Reverting the patch fixes the problem. Bisect log is attached.

Guenter

---
# bad: [387ac6229ecf6e012649d4fc409c5352655a4cf0] Add linux-next specific files for 20180905
# good: [57361846b52bc686112da6ca5368d11210796804] Linux 4.19-rc2
git bisect start 'HEAD' 'v4.19-rc2'
# good: [668570e8389bb076bea9b7531553e1362f5abd11] Merge remote-tracking branch 'net-next/master'
git bisect good 668570e8389bb076bea9b7531553e1362f5abd11
# good: [7f2f69ebf0bcf3e9bcff7d560ba92cee960a66a6] Merge remote-tracking branch 'battery/for-next'
git bisect good 7f2f69ebf0bcf3e9bcff7d560ba92cee960a66a6
# good: [c31458d3e03e3a2edeaab225a22eaf68c07c8290] Merge remote-tracking branch 'rpmsg/for-next'
git bisect good c31458d3e03e3a2edeaab225a22eaf68c07c8290
# good: [e0f43dcbe9af8ac72f39fe92c5d0ee1883546427] Merge remote-tracking branch 'nvdimm/libnvdimm-for-next'
git bisect good e0f43dcbe9af8ac72f39fe92c5d0ee1883546427
# bad: [f509e2c0f3cd11df238f0f1b5ba013fe726decdf] of: ignore sub-page memory regions
git bisect bad f509e2c0f3cd11df238f0f1b5ba013fe726decdf
# good: [2f7eebf30b87534f7e4c3982307579d9adc782a5] ocfs2: fix clusters leak in ocfs2_defrag_extent()
git bisect good 2f7eebf30b87534f7e4c3982307579d9adc782a5
# good: [119eb88c9dd23e305939ad748237100078e304a8] mm/swapfile.c: call free_swap_slot() in __swap_entry_free()
git bisect good 119eb88c9dd23e305939ad748237100078e304a8
# good: [21d64d37adf3ab20b4c3a1951018e84bf815c887] mm: remove vm_insert_pfn()
git bisect good 21d64d37adf3ab20b4c3a1951018e84bf815c887
# good: [90cd1a69010844e9dbfc43279d681d798812b962] cramfs: convert to use vmf_insert_mixed
git bisect good 90cd1a69010844e9dbfc43279d681d798812b962
# good: [c7dd91289b4bb4c400a8a71953511991815f8e6f] mm/cow: optimise pte dirty/accessed bits handling in fork
git bisect good c7dd91289b4bb4c400a8a71953511991815f8e6f
# bad: [87d74ae75700a39effcb8c9ed8a8445e719ac369] hexagon: switch to NO_BOOTMEM
git bisect bad 87d74ae75700a39effcb8c9ed8a8445e719ac369
# bad: [3d1d5b26ac5b4d4193dc618a50cd88de1fb0d360] mm: optimise pte dirty/accessed bit setting by demand based pte insertion
git bisect bad 3d1d5b26ac5b4d4193dc618a50cd88de1fb0d360
# first bad commit: [3d1d5b26ac5b4d4193dc618a50cd88de1fb0d360] mm: optimise pte dirty/accessed bit setting by demand based pte insertion
