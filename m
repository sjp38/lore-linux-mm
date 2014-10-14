Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f54.google.com (mail-oi0-f54.google.com [209.85.218.54])
	by kanga.kvack.org (Postfix) with ESMTP id 161826B0069
	for <linux-mm@kvack.org>; Tue, 14 Oct 2014 07:47:38 -0400 (EDT)
Received: by mail-oi0-f54.google.com with SMTP id v63so16293269oia.27
        for <linux-mm@kvack.org>; Tue, 14 Oct 2014 04:47:37 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [119.145.14.64])
        by mx.google.com with ESMTPS id o130si15732806oia.61.2014.10.14.04.47.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 14 Oct 2014 04:47:37 -0700 (PDT)
From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH resend] cgroup/kmemleak: add kmemleak_free() for cgroup deallocations.
Date: Tue, 14 Oct 2014 19:46:04 +0800
Message-ID: <1413287164-77051-1-git-send-email-wangnan0@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Steven Rostedt <rostedt@goodmis.org>
Cc: lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Commit ff7ee93f4 introduces kmemleak_alloc() for alloc_page_cgroup(),
but corresponding kmemleak_free() is missing, which makes kmemleak be
wrongly disabled after memory offlining. Log is pasted at the end of
this commit message.

This patch add kmemleak_free() into free_page_cgroup(). During page
offlining, this patch removes corresponding entries in kmemleak rbtree.
After that, the freed memory can be allocated again by other subsystems
without killing kmemleak.

bash # for x in 1 2 3 4; do echo offline > /sys/devices/system/memory/memory$x/state ; sleep 1; done ; dmesg | grep leak
[   45.537934] Offlined Pages 32768
[   46.617892] kmemleak: Cannot insert 0xffff880016969000 into the object search tree (overlaps existing)
[   46.617892] CPU: 0 PID: 412 Comm: sleep Not tainted 3.17.0-rc5+ #86
[   46.617892] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   46.617892]  ffff880016823d10 ffff880018bdfc38 ffffffff81725d2c ffff88001780e950
[   46.617892]  ffff880016969000 ffff880018bdfc88 ffffffff8117a9e6 ffff880018bdfc78
[   46.617892]  0000000000000096 ffff880017812800 ffffffff81c2eda0 ffff880016969000
[   46.617892] Call Trace:
[   46.617892]  [<ffffffff81725d2c>] dump_stack+0x46/0x58
[   46.617892]  [<ffffffff8117a9e6>] create_object+0x266/0x2c0
[   46.617892]  [<ffffffff8171d2f6>] kmemleak_alloc+0x26/0x50
[   46.617892]  [<ffffffff8116a3a3>] kmem_cache_alloc+0xd3/0x160
[   46.617892]  [<ffffffff81058e59>] __sigqueue_alloc+0x49/0xd0
[   46.617892]  [<ffffffff8105a41b>] __send_signal+0xcb/0x410
[   46.617892]  [<ffffffff8105a7a5>] send_signal+0x45/0x90
[   46.617892]  [<ffffffff8105a803>] __group_send_sig_info+0x13/0x20
[   46.617892]  [<ffffffff8105bd0b>] do_notify_parent+0x1bb/0x260
[   46.617892]  [<ffffffff81077e7a>] ? sched_move_task+0xaa/0x130
[   46.617892]  [<ffffffff81050917>] do_exit+0x767/0xa40
[   46.617892]  [<ffffffff81050c84>] do_group_exit+0x44/0xa0
[   46.617892]  [<ffffffff81050cf7>] SyS_exit_group+0x17/0x20
[   46.617892]  [<ffffffff8172cd12>] system_call_fastpath+0x16/0x1b
[   46.617892] kmemleak: Kernel memory leak detector disabled
[   46.617892] kmemleak: Object 0xffff880016900000 (size 524288):
[   46.617892] kmemleak:   comm "swapper/0", pid 0, jiffies 4294667296
[   46.617892] kmemleak:   min_count = 0
[   46.617892] kmemleak:   count = 0
[   46.617892] kmemleak:   flags = 0x1
[   46.617892] kmemleak:   checksum = 0
[   46.617892] kmemleak:   backtrace:
[   46.617892]      [<ffffffff81d0a7f0>] log_early+0x63/0x77
[   46.617892]      [<ffffffff8171d31b>] kmemleak_alloc+0x4b/0x50
[   46.617892]      [<ffffffff81720e4f>] init_section_page_cgroup+0x7f/0xf5
[   46.617892]      [<ffffffff81d0a6f0>] page_cgroup_init+0xc5/0xd0
[   46.617892]      [<ffffffff81ce4ed9>] start_kernel+0x333/0x408
[   46.617892]      [<ffffffff81ce45b2>] x86_64_start_reservations+0x2a/0x2c
[   46.617892]      [<ffffffff81ce46a9>] x86_64_start_kernel+0xf5/0xfc
[   46.617892]      [<ffffffffffffffff>] 0xffffffffffffffff

Fixes: ff7ee93f4 (cgroup/kmemleak: Annotate alloc_page() for cgroup allocations)
Cc: <stable@vger.kernel.org> # v3.2+
Cc: Steven Rostedt <rostedt@goodmis.org>
Signed-off-by: Wang Nan <wangnan0@huawei.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Michal Hocko <mhocko@suse.cz>
---

Resend with stable tag.

Please refer to https://lkml.org/lkml/2014/9/17/746

---
 mm/page_cgroup.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
index 3708264..5331c2b 100644
--- a/mm/page_cgroup.c
+++ b/mm/page_cgroup.c
@@ -171,6 +171,7 @@ static void free_page_cgroup(void *addr)
 			sizeof(struct page_cgroup) * PAGES_PER_SECTION;
 
 		BUG_ON(PageReserved(page));
+		kmemleak_free(addr);
 		free_pages_exact(addr, table_size);
 	}
 }
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
