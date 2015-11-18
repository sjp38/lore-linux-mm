Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f179.google.com (mail-qk0-f179.google.com [209.85.220.179])
	by kanga.kvack.org (Postfix) with ESMTP id 19A4B6B0253
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 11:24:45 -0500 (EST)
Received: by qkas77 with SMTP id s77so15782420qka.0
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 08:24:44 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id d90si2913021qge.52.2015.11.18.08.24.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Nov 2015 08:24:44 -0800 (PST)
Subject: Re: [PATCHv12 32/37] thp: reintroduce split_huge_page()
References: <1444145044-72349-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1444145044-72349-33-git-send-email-kirill.shutemov@linux.intel.com>
From: Sasha Levin <sasha.levin@oracle.com>
Message-ID: <564CA63C.8090800@oracle.com>
Date: Wed, 18 Nov 2015 11:24:28 -0500
MIME-Version: 1.0
In-Reply-To: <1444145044-72349-33-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 10/06/2015 11:23 AM, Kirill A. Shutemov wrote:
> This patch adds implementation of split_huge_page() for new
> refcountings.
> 
> Unlike previous implementation, new split_huge_page() can fail if
> somebody holds GUP pin on the page. It also means that pin on page
> would prevent it from bening split under you. It makes situation in
> many places much cleaner.
> 
> The basic scheme of split_huge_page():
> 
>   - Check that sum of mapcounts of all subpage is equal to page_count()
>     plus one (caller pin). Foll off with -EBUSY. This way we can avoid
>     useless PMD-splits.
> 
>   - Freeze the page counters by splitting all PMD and setup migration
>     PTEs.
> 
>   - Re-check sum of mapcounts against page_count(). Page's counts are
>     stable now. -EBUSY if page is pinned.
> 
>   - Split compound page.
> 
>   - Unfreeze the page by removing migration entries.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>
> Tested-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> Acked-by: Jerome Marchand <jmarchan@redhat.com>

Hey Kirill,

I saw the following while fuzzing:

[ 3400.024040] ==================================================================
[ 3400.024040] BUG: KASAN: slab-out-of-bounds in unfreeze_page+0x706/0xbf0 at addr ffff880670dbc0c0
[ 3400.024040] Read of size 8 by task run_vmtests/10752
[ 3400.024040] =============================================================================
[ 3400.024040] BUG vm_area_struct (Not tainted): kasan: bad access detected
[ 3400.024040] -----------------------------------------------------------------------------
[ 3400.024040]
[ 3400.024040] Disabling lock debugging due to kernel taint
[ 3400.024040] INFO: Allocated in copy_process+0x2d6d/0x5b00 age=18600 cpu=28 pid=9566
[ 3400.024040]  ___slab_alloc+0x434/0x5b0
[ 3400.024040]  __slab_alloc.isra.37+0x79/0xd0
[ 3400.024040]  kmem_cache_alloc+0x103/0x330
[ 3400.024040]  copy_process+0x2d6d/0x5b00
[ 3400.024040]  _do_fork+0x180/0xbb0
[ 3400.024040]  SyS_clone+0x3c/0x50
[ 3400.024040]  tracesys_phase2+0x88/0x8d
[ 3400.024040] INFO: Freed in remove_vma+0x170/0x180 age=18613 cpu=10 pid=21787
[ 3400.024040]  __slab_free+0x64/0x260
[ 3400.024040]  kmem_cache_free+0x1e1/0x3b0
[ 3400.024040]  remove_vma+0x170/0x180
[ 3400.024040]  exit_mmap+0x30a/0x3c0
[ 3400.024040]  mmput+0x98/0x240
[ 3400.024040]  do_exit+0xbe5/0x2830
[ 3400.024040]  do_group_exit+0x1b5/0x300
[ 3400.024040]  SyS_exit_group+0x22/0x30
[ 3400.024040]  tracesys_phase2+0x88/0x8d
[ 3400.024040] INFO: Slab 0xffffea0019c36f00 objects=33 used=33 fp=0x          (null) flags=0x12fffff80004080
[ 3400.024040] INFO: Object 0xffff880670dbc000 @offset=0 fp=0x00007f6bff4e7000
[ 3400.024040]
[ 3400.024040] Object ffff880670dbc000: 00 70 4e ff 6b 7f 00 00 00 90 80 ff 6b 7f 00 00  .pN.k.......k...
[ 3400.024040] Object ffff880670dbc010: f0 e0 db 70 06 88 ff ff e0 03 80 02 18 88 ff ff  ...p............
[ 3400.024040] Object ffff880670dbc020: 01 04 80 02 18 88 ff ff 00 00 00 00 00 00 00 00  ................
[ 3400.024040] Object ffff880670dbc030: 00 00 00 00 00 00 00 00 00 70 ce 7e 3f 7f 00 00  .........p.~?...
[ 3400.024040] Object ffff880670dbc040: 00 f0 83 a6 06 88 ff ff 25 00 00 00 00 00 00 80  ........%.......
[ 3400.024040] Object ffff880670dbc050: 73 00 10 08 00 00 00 00 00 00 00 00 00 00 00 00  s...............
[ 3400.024040] Object ffff880670dbc060: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[ 3400.024040] Object ffff880670dbc070: 00 00 00 00 00 00 00 00 90 dc cf a4 06 88 ff ff  ................
[ 3400.024040] Object ffff880670dbc080: 10 d8 cf a4 06 88 ff ff b8 d1 ee 24 08 88 ff ff  ...........$....
[ 3400.024040] Object ffff880670dbc090: 00 00 00 00 00 00 00 00 e7 f4 bf f6 07 00 00 00  ................
[ 3400.024040] Object ffff880670dbc0a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[ 3400.024040] Object ffff880670dbc0b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[ 3400.024040] CPU: 20 PID: 10752 Comm: run_vmtests Tainted: G    B           4.3.0-next-20151115-sasha-00042-g0f5ce29 #2641
[ 3400.024040]  0000000000000014 0000000076bf224e ffff880ef1b7ee70 ffffffffabe427db
[ 3400.024040]  ffff880182342000 ffff880670dbc000 ffff880670dbc000 ffff880ef1b7eea0
[ 3400.024040]  ffffffffaa792a7a ffff880182342000 ffffea0019c36f00 ffff880670dbc000
[ 3400.024040] Call Trace:
[ 3400.024040] dump_stack (lib/dump_stack.c:52)
[ 3400.024040] print_trailer (mm/slub.c:655)
[ 3400.024040] object_err (mm/slub.c:662)
[ 3400.024040] kasan_report_error (mm/kasan/report.c:138 mm/kasan/report.c:236)
[ 3400.024040] __asan_report_load8_noabort (mm/kasan/report.c:280)
[ 3400.024040] unfreeze_page (mm/huge_memory.c:3062 mm/huge_memory.c:3099)
[ 3400.024040] split_huge_page_to_list (include/linux/compiler.h:218 mm/huge_memory.c:3208 mm/huge_memory.c:3291)
[ 3400.024040] deferred_split_scan (mm/huge_memory.c:3378)
[ 3400.024040] shrink_slab (mm/vmscan.c:352 mm/vmscan.c:444)
[ 3400.024040] shrink_zone (mm/vmscan.c:2444)
[ 3400.024040] do_try_to_free_pages (mm/vmscan.c:2595 mm/vmscan.c:2645)
[ 3400.024040] try_to_free_pages (mm/vmscan.c:2853)
[ 3400.024040] __alloc_pages_nodemask (mm/page_alloc.c:2864 mm/page_alloc.c:2882 mm/page_alloc.c:3150 mm/page_alloc.c:3261)
[ 3400.024040] alloc_fresh_huge_page (include/linux/gfp.h:415 include/linux/gfp.h:428 mm/hugetlb.c:1330 mm/hugetlb.c:1348)
[ 3400.024040] __nr_hugepages_store_common (include/linux/spinlock.h:302 mm/hugetlb.c:2164 mm/hugetlb.c:2279)
[ 3400.024040] hugetlb_sysctl_handler_common (mm/hugetlb.c:2784)
[ 3400.024040] hugetlb_sysctl_handler (mm/hugetlb.c:2796)
[ 3400.024040] proc_sys_call_handler (fs/proc/proc_sysctl.c:543)
[ 3400.024040] proc_sys_write (fs/proc/proc_sysctl.c:562)
[ 3400.024040] __vfs_write (fs/read_write.c:489)
[ 3400.024040] vfs_write (fs/read_write.c:538)
[ 3400.024040] SyS_write (fs/read_write.c:585 fs/read_write.c:577)
[ 3400.024040] tracesys_phase2 (arch/x86/entry/entry_64.S:273)
[ 3400.024040] Memory state around the buggy address:
[ 3400.024040]  ffff880670dbbf80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[ 3400.024040]  ffff880670dbc000: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[ 3400.024040] >ffff880670dbc080: 00 00 00 00 00 00 00 00 fc fc fc fc fc fc fc fc
[ 3400.024040]                                            ^
[ 3400.024040]  ffff880670dbc100: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
[ 3400.024040]  ffff880670dbc180: fc fc fc fc fc fc fc fc fc fc fc fc fc fc 00 00
[ 3400.024040] ==================================================================


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
