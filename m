Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 341656B000D
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 18:26:21 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id s16-v6so15701551plr.22
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 15:26:21 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 141-v6sor1904659pfu.53.2018.07.11.15.26.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Jul 2018 15:26:19 -0700 (PDT)
Date: Wed, 11 Jul 2018 15:26:18 -0700
From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [v6,5/5] mm/sparse: Remove
 CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
Message-ID: <20180711222618.GA29869@roeck-us.net>
References: <20180628062857.29658-6-bhe@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180628062857.29658-6-bhe@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dave.hansen@intel.com, pagupta@redhat.com, Pavel Tatashin <pasha.tatashin@oracle.com>, Oscar Salvador <osalvador@techadventures.net>, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, Michael Ellerman <mpe@ellerman.id.au>

Hi,

On Thu, Jun 28, 2018 at 02:28:57PM +0800, Baoquan He wrote:
> Pavel pointed out that the behaviour of allocating memmap together
> for one node should be defaulted for all ARCH-es. It won't break
> anything because it will drop to the fallback action to allocate
> imemmap for each section at one time if failed on large chunk of
> memory.
> 
> So remove CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER and clean up the
> related codes.
> 

This patch causes several of my qemu boot tests to fail.
	powerpc:mac99:ppc64_book3s_defconfig:initrd:nosmp
	powerpc:mac99:ppc64_book3s_defconfig:initrd:smp4 
	powerpc:mac99:ppc64_book3s_defconfig:rootfs:smp4 
	powerpc:pseries:pseries_defconfig:initrd 
	powerpc:pseries:pseries_defconfig:rootfs 
	powerpc:powernv:powernv_defconfig:initrd 

Bisect points to this patch. Bisect log is attached for reference.
Reverting the patch fixes the problem.

[ Yes, I am aware that Michael already reported the problem at
  https://lkml.org/lkml/2018/7/11/480 ]

Guenter

---
# bad: [98be45067040799a801e6ce52d8bf4659a153893] Add linux-next specific files for 20180711
# good: [1e4b044d22517cae7047c99038abb444423243ca] Linux 4.18-rc4
git bisect start 'HEAD' 'v4.18-rc4'
# good: [ade30e73739a5174bcaee5860fee76c2365548c5] Merge remote-tracking branch 'crypto/master'
git bisect good ade30e73739a5174bcaee5860fee76c2365548c5
# good: [792be221c35d19a1c486789e5b5c91c05279b94d] Merge remote-tracking branch 'tip/auto-latest'
git bisect good 792be221c35d19a1c486789e5b5c91c05279b94d
# good: [1d66737ba99400ab9a79c906a25b2090f4cc8b18] Merge remote-tracking branch 'mux/for-next'
git bisect good 1d66737ba99400ab9a79c906a25b2090f4cc8b18
# good: [c02d5416bd8504866dd80d2129f4648747166b6f] Merge remote-tracking branch 'kspp/for-next/kspp'
git bisect good c02d5416bd8504866dd80d2129f4648747166b6f
# bad: [1e741337a9416010a48c6034855e316ba8057111] ntb: ntb_hw_switchtec: cleanup 64bit IO defines to use the common header
git bisect bad 1e741337a9416010a48c6034855e316ba8057111
# good: [205a106bac127145a4defae7d0d35945001fe924] kernel/memremap, kasan: make ZONE_DEVICE with work with KASAN
git bisect good 205a106bac127145a4defae7d0d35945001fe924
# bad: [e87ebebf76c9ceeaea21a256341d6765c657e550] mm, oom: remove sleep from under oom_lock
git bisect bad e87ebebf76c9ceeaea21a256341d6765c657e550
# good: [9f95e9e87283a578fb676f14fd5e1edd4cb401f7] mm/vmscan.c: iterate only over charged shrinkers during memcg shrink_slab()
git bisect good 9f95e9e87283a578fb676f14fd5e1edd4cb401f7
# bad: [0ba29a108979bdbe3f77094e8b5cc06652e2698b] mm/sparse: Remove CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
git bisect bad 0ba29a108979bdbe3f77094e8b5cc06652e2698b
# good: [ca464c7768574c49f58a5be8962330814262820f] mm/sparse.c: add a static variable nr_present_sections
git bisect good ca464c7768574c49f58a5be8962330814262820f
# good: [4f02f8533cbad406e004b3bfe75f65e6b791efd5] mm/sparse.c: add a new parameter 'data_unit_size' for alloc_usemap_and_memmap
git bisect good 4f02f8533cbad406e004b3bfe75f65e6b791efd5
# good: [110cb339e5d95c77cf83d33de25f6f392d0ca7f6] mm-sparse-optimize-memmap-allocation-during-sparse_init-checkpatch-fixes
git bisect good 110cb339e5d95c77cf83d33de25f6f392d0ca7f6
# first bad commit: [0ba29a108979bdbe3f77094e8b5cc06652e2698b] mm/sparse: Remove CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
