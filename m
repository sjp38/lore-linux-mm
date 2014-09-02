Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id D8BF66B0036
	for <linux-mm@kvack.org>; Tue,  2 Sep 2014 13:10:42 -0400 (EDT)
Received: by mail-wg0-f44.google.com with SMTP id m15so7205256wgh.15
        for <linux-mm@kvack.org>; Tue, 02 Sep 2014 10:10:42 -0700 (PDT)
Received: from smtp1-g21.free.fr (smtp1-g21.free.fr. [212.27.42.1])
        by mx.google.com with ESMTPS id q15si15915573wiv.87.2014.09.02.10.10.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Sep 2014 10:10:41 -0700 (PDT)
Date: Tue, 2 Sep 2014 19:10:36 +0200
From: Sabrina Dubroca <sd@queasysnail.net>
Subject: kmemleak: Cannot insert [...] into the object search tree (overlaps
 existing) (mm: use memblock_alloc_range())
Message-ID: <20140902171036.GA12406@kria>
References: <1408892163-8073-1-git-send-email-akinobu.mita@gmail.com>
 <1408892163-8073-2-git-send-email-akinobu.mita@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1408892163-8073-2-git-send-email-akinobu.mita@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Akinobu Mita <akinobu.mita@gmail.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org

Hello,

2014-08-24, 23:56:03 +0900, Akinobu Mita wrote:
> Replace memblock_find_in_range() and memblock_reserve() with
> memblock_alloc_range().
> 
> Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
> Cc: linux-mm@kvack.org

This patch is included in linux-next, and when I boot next-20140901,
on a 32-bit build, I get this message:


kmemleak: Cannot insert 0xf6556000 into the object search tree (overlaps existing)
CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.17.0-rc3-next-20140901 #126
Hardware name: Dell Inc. Latitude D830                   /0UY141, BIOS A02 06/07/2007
 f6556000 00000000 c1891f64 c16226e8 f5c090c0 c1891f98 c11a934c c17f8768
 f6556000 00200282 f5c090e4 00000005 00000010 f5c09124 00000000 c19984e8
 00000002 c19f5800 c1891fb0 c162216d 00000020 c19984e8 00000002 c19f5800
Call Trace:
 [<c16226e8>] dump_stack+0x48/0x69
 [<c11a934c>] create_object+0x23c/0x290
 [<c162216d>] early_alloc+0x98/0x120
 [<c195b10d>] kmemleak_init+0x129/0x226
 [<c19399f7>] start_kernel+0x2d5/0x38d
 [<c19392ab>] i386_start_kernel+0x79/0x7d
kmemleak: Kernel memory leak detector disabled
kmemleak: Object 0xf6556000 (size 16777216):
kmemleak:   comm "swapper/0", pid 0, jiffies 4294877296
kmemleak:   min_count = 0
kmemleak:   count = 0
kmemleak:   flags = 0x1
kmemleak:   checksum = 0
kmemleak:   backtrace:
     [<c1620048>] kmemleak_alloc+0xa8/0xb0
     [<c19595bd>] memblock_alloc_range_nid+0x46/0x50
     [<c195965f>] memblock_virt_alloc_internal+0x89/0xe7
     [<c195978b>] memblock_virt_alloc_try_nid_nopanic+0x58/0x60
     [<c161fc2f>] alloc_node_mem_map.constprop.72+0x4b/0x8c
     [<c195623f>] free_area_init_node+0xee/0x3a1
     [<c1956860>] free_area_init_nodes+0x36e/0x380
     [<c194b8a5>] zone_sizes_init+0x33/0x39
     [<c194c112>] paging_init+0xaa/0xad
     [<c194c169>] native_pagetable_init+0x54/0xe7
     [<c193c9d9>] setup_arch+0xb21/0xc07
     [<c193979b>] start_kernel+0x79/0x38d
     [<c19392ab>] i386_start_kernel+0x79/0x7d
     [<ffffffff>] 0xffffffff
kmemleak: Early log backtrace:
   [<c1620048>] kmemleak_alloc+0xa8/0xb0
   [<c19596a2>] memblock_virt_alloc_internal+0xcc/0xe7
   [<c195978b>] memblock_virt_alloc_try_nid_nopanic+0x58/0x60
   [<c161fc2f>] alloc_node_mem_map.constprop.72+0x4b/0x8c
   [<c195623f>] free_area_init_node+0xee/0x3a1
   [<c1956860>] free_area_init_nodes+0x36e/0x380
   [<c194b8a5>] zone_sizes_init+0x33/0x39
   [<c194c112>] paging_init+0xaa/0xad
   [<c194c169>] native_pagetable_init+0x54/0xe7
   [<c193c9d9>] setup_arch+0xb21/0xc07
   [<c193979b>] start_kernel+0x79/0x38d
   [<c19392ab>] i386_start_kernel+0x79/0x7d
   [<ffffffff>] 0xffffffff



git bisect pointed to this patch:

abc65ff21e61d49269bf8fafd486fff2e3679c21 is the first bad commit
commit abc65ff21e61d49269bf8fafd486fff2e3679c21
Author: Akinobu Mita <akinobu.mita@gmail.com>
Date:   Mon Sep 1 23:48:54 2014 +0100

    mm: use memblock_alloc_range()
    
    Replace memblock_find_in_range() and memblock_reserve() with
    the equivalent memblock_alloc_range().
    
    Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
    Cc: Thomas Gleixner <tglx@linutronix.de>
    Cc: Ingo Molnar <mingo@redhat.com>
    Cc: "H. Peter Anvin" <hpa@zytor.com>
    Cc: Yinghai Lu <yinghai@kernel.org>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>


## git bisect log

git bisect start
# good: [a3793b0cedfc0bc3212e5ebf5b79710c910687c4] Merge remote-tracking branch 'llvmlinux/for-next'
git bisect good a3793b0cedfc0bc3212e5ebf5b79710c910687c4
# bad: [03af78748485f63e8ed21d2e2585b5d1ec862ba6] Add linux-next specific files for 20140901
git bisect bad 03af78748485f63e8ed21d2e2585b5d1ec862ba6
# good: [42330182961e380c6ac85c1482ff8115ddc487dd] mempolicy: unexport get_vma_policy() and remove its "task" arg
git bisect good 42330182961e380c6ac85c1482ff8115ddc487dd
# bad: [2437e4e8841cafe9c086a98d4b0186196c7e10af] MAINTAINERS: remove non existent files
git bisect bad 2437e4e8841cafe9c086a98d4b0186196c7e10af
# bad: [36fb2fa2c928947f728dc8119a7143fe9f61033c] zsmalloc: change return value unit of zs_get_total_size_bytes
git bisect bad 36fb2fa2c928947f728dc8119a7143fe9f61033c
# bad: [658f7da49d34bc6187e6cd1ec57933d1a2a76035] mm: introduce dump_vma
git bisect bad 658f7da49d34bc6187e6cd1ec57933d1a2a76035
# skip: [2090938a202a34e6ea28a40a9b98214795546882] mm: introduce common page state for ballooned memory
git bisect skip 2090938a202a34e6ea28a40a9b98214795546882
# skip: [843cbba246f248585f88dffec89304545d2f3bde] mm-introduce-common-page-state-for-ballooned-memory-fix
git bisect skip 843cbba246f248585f88dffec89304545d2f3bde
# bad: [92a1357eacd714671071871e95bdaf9144aa622a] mm-balloon_compaction-general-cleanup-checkpatch-fixes
git bisect bad 92a1357eacd714671071871e95bdaf9144aa622a
# skip: [b19a479c8ae91329771288310701f996bc100947] selftests/vm/transhuge-stress: stress test for memory compaction
git bisect skip b19a479c8ae91329771288310701f996bc100947
# bad: [e0e398dffe88d10dcda4e41941d677aa337410e5] mm/balloon_compaction: ignore anonymous pages
git bisect bad e0e398dffe88d10dcda4e41941d677aa337410e5
# bad: [15ccb0a452bb0e2f0edb25747110aae73fd9a962] include/linux/migrate.h: remove migrate_page #define
git bisect bad 15ccb0a452bb0e2f0edb25747110aae73fd9a962
# bad: [abc65ff21e61d49269bf8fafd486fff2e3679c21] mm: use memblock_alloc_range()
git bisect bad abc65ff21e61d49269bf8fafd486fff2e3679c21
# first bad commit: [abc65ff21e61d49269bf8fafd486fff2e3679c21] mm: use memblock_alloc_range()



Thanks,

-- 
Sabrina

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
