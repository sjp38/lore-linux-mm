Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f43.google.com (mail-oi0-f43.google.com [209.85.218.43])
	by kanga.kvack.org (Postfix) with ESMTP id 4D9926B0038
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 17:40:46 -0400 (EDT)
Received: by oies66 with SMTP id s66so55649178oie.1
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 14:40:46 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id jq4si10119581oeb.13.2015.10.22.14.40.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Oct 2015 14:40:45 -0700 (PDT)
Subject: Re: [PATCH] mm, hugetlb: use memory policy when available
References: <20151020195317.ADA052D8@viggo.jf.intel.com>
From: Sasha Levin <sasha.levin@oracle.com>
Message-ID: <5629579B.8050507@oracle.com>
Date: Thu, 22 Oct 2015 17:39:39 -0400
MIME-Version: 1.0
In-Reply-To: <20151020195317.ADA052D8@viggo.jf.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, mike.kravetz@oracle.com, hillf.zj@alibaba-inc.com, rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave.hansen@linux.intel.com

On 10/20/2015 03:53 PM, Dave Hansen wrote:
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> I have a hugetlbfs user which is never explicitly allocating huge pages
> with 'nr_hugepages'.  They only set 'nr_overcommit_hugepages' and then let
> the pages be allocated from the buddy allocator at fault time.
> 
> This works, but they noticed that mbind() was not doing them any good and
> the pages were being allocated without respect for the policy they
> specified.
> 
> The code in question is this:
> 
>> > struct page *alloc_huge_page(struct vm_area_struct *vma,
> ...
>> >         page = dequeue_huge_page_vma(h, vma, addr, avoid_reserve, gbl_chg);
>> >         if (!page) {
>> >                 page = alloc_buddy_huge_page(h, NUMA_NO_NODE);
> dequeue_huge_page_vma() is smart and will respect the VMA's memory policy.
> But, it only grabs _existing_ huge pages from the huge page pool.  If the
> pool is empty, we fall back to alloc_buddy_huge_page() which obviously
> can't do anything with the VMA's policy because it isn't even passed the
> VMA.
> 
> Almost everybody preallocates huge pages.  That's probably why nobody has
> ever noticed this.  Looking back at the git history, I don't think this
> _ever_ worked from when alloc_buddy_huge_page() was introduced in 7893d1d5,
> 8 years ago.
> 
> The fix is to pass vma/addr down in to the places where we actually call in
> to the buddy allocator.  It's fairly straightforward plumbing.  This has
> been lightly tested.
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Mike Kravetz <mike.kravetz@oracle.com>
> Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

Hey Dave,

Trinity seems to be able to hit the newly added warnings pretty easily:

[  339.282065] WARNING: CPU: 4 PID: 10181 at mm/hugetlb.c:1520 __alloc_buddy_huge_page+0xff/0xa80()
[  339.360228] Modules linked in:
[  339.360838] CPU: 4 PID: 10181 Comm: trinity-c291 Not tainted 4.3.0-rc6-next-20151022-sasha-00040-g5ecc711-dirty #2608
[  339.362629]  ffff88015e59c000 00000000e6475701 ffff88015e61f9a0 ffffffff9dd3ef48
[  339.363896]  0000000000000000 ffff88015e61f9e0 ffffffff9c32d1ca ffffffff9c7175bf
[  339.365167]  ffffffffabddc0c8 ffff88015e61faf0 0000000000000000 ffffffffffffffff
[  339.366387] Call Trace:
[  339.366831]  [<ffffffff9dd3ef48>] dump_stack+0x4e/0x86
[  339.367648]  [<ffffffff9c32d1ca>] warn_slowpath_common+0xfa/0x120
[  339.368635]  [<ffffffff9c7175bf>] ? __alloc_buddy_huge_page+0xff/0xa80
[  339.369631]  [<ffffffff9c32d3ca>] warn_slowpath_null+0x1a/0x20
[  339.370574]  [<ffffffff9c7175bf>] __alloc_buddy_huge_page+0xff/0xa80
[  339.371551]  [<ffffffff9c7174c0>] ? return_unused_surplus_pages+0x120/0x120
[  339.372698]  [<ffffffff9dda0327>] ? debug_smp_processor_id+0x17/0x20
[  339.373683]  [<ffffffff9c41574b>] ? get_lock_stats+0x1b/0x80
[  339.374551]  [<ffffffff9c42e901>] ? __raw_callee_save___pv_queued_spin_unlock+0x11/0x20
[  339.375744]  [<ffffffff9c433870>] ? do_raw_spin_unlock+0x1d0/0x1e0
[  339.376728]  [<ffffffff9c718333>] hugetlb_acct_memory+0x193/0x990
[  339.377663]  [<ffffffff9c7181a0>] ? dequeue_huge_page_node+0x260/0x260
[  339.378658]  [<ffffffff9c41c970>] ? trace_hardirqs_on_caller+0x540/0x5e0
[  339.379671]  [<ffffffff9c71e469>] hugetlb_reserve_pages+0x229/0x330
[  339.380738]  [<ffffffff9cba273b>] hugetlb_file_setup+0x54b/0x810
[  339.381689]  [<ffffffff9cba21f0>] ? hugetlbfs_fallocate+0x9e0/0x9e0
[  339.382653]  [<ffffffff9dd669f0>] ? scnprintf+0x100/0x100
[  339.383526]  [<ffffffff9da638af>] newseg+0x49f/0xa70
[  339.384371]  [<ffffffff9dda0327>] ? debug_smp_processor_id+0x17/0x20
[  339.385345]  [<ffffffff9da63410>] ? shm_try_destroy_orphaned+0x190/0x190
[  339.386365]  [<ffffffff9da52cf0>] ? ipcget+0x60/0x510
[  339.387139]  [<ffffffff9da52d1f>] ipcget+0x8f/0x510
[  339.387902]  [<ffffffff9c0046f0>] ? do_audit_syscall_entry+0x2b0/0x2b0
[  339.388931]  [<ffffffff9da64e1a>] SyS_shmget+0x11a/0x160
[  339.389737]  [<ffffffff9da64d00>] ? is_file_shm_hugepages+0x40/0x40
[  339.393268]  [<ffffffff9c006ac2>] ? syscall_trace_enter_phase2+0x462/0x5f0
[  339.395643]  [<ffffffffa55ce0f8>] tracesys_phase2+0x88/0x8d


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
