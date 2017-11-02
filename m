Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 38F2A6B0069
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 05:36:31 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id q196so2629651wmg.15
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 02:36:31 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w51sor1737568edd.54.2017.11.02.02.36.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 Nov 2017 02:36:30 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/2] shmem: drop lru_add_drain_all from shmem_wait_for_pins
Date: Thu,  2 Nov 2017 10:36:12 +0100
Message-Id: <20171102093613.3616-2-mhocko@kernel.org>
In-Reply-To: <20171102093613.3616-1-mhocko@kernel.org>
References: <20171102093613.3616-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, David Herrmann <dh.herrmann@gmail.com>, Hugh Dickins <hughd@google.com>

From: Michal Hocko <mhocko@suse.com>

syzkaller has reported the following lockdep splat
======================================================
WARNING: possible circular locking dependency detected
4.13.0-next-20170911+ #19 Not tainted
------------------------------------------------------
syz-executor5/6914 is trying to acquire lock:
  (cpu_hotplug_lock.rw_sem){++++}, at: [<ffffffff818c1b3e>] get_online_cpus  include/linux/cpu.h:126 [inline]
  (cpu_hotplug_lock.rw_sem){++++}, at: [<ffffffff818c1b3e>] lru_add_drain_all+0xe/0x20 mm/swap.c:729

but task is already holding lock:
  (&sb->s_type->i_mutex_key#9){++++}, at: [<ffffffff818fbef7>] inode_lock include/linux/fs.h:712 [inline]
  (&sb->s_type->i_mutex_key#9){++++}, at: [<ffffffff818fbef7>] shmem_add_seals+0x197/0x1060 mm/shmem.c:2768

more details [1] and dependencies explained [2]. The problem seems to be
the usage of lru_add_drain_all from shmem_wait_for_pins. While the lock
dependency is subtle as hell and we might want to make lru_add_drain_all
less dependent on the hotplug locks the usage of lru_add_drain_all seems
dubious here. The whole function cares only about radix tree tags, page
count and page mapcount. None of those are touched from the draining
context. So it doesn't make much sense to drain pcp caches. Moreover
this looks like a wrong thing to do because it basically induces
unpredictable latency to the call because draining is not for free
(especially on larger machines with many cpus).

Let's simply drop the call to lru_add_drain_all to address both issues.

[1] http://lkml.kernel.org/r/089e0825eec8955c1f055c83d476@google.com
[2] http://lkml.kernel.org/r/http://lkml.kernel.org/r/20171030151009.ip4k7nwan7muouca@hirez.programming.kicks-ass.net

Cc: David Herrmann <dh.herrmann@gmail.com>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/shmem.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index d6947d21f66c..e784f311d4ed 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2668,9 +2668,7 @@ static int shmem_wait_for_pins(struct address_space *mapping)
 		if (!radix_tree_tagged(&mapping->page_tree, SHMEM_TAG_PINNED))
 			break;
 
-		if (!scan)
-			lru_add_drain_all();
-		else if (schedule_timeout_killable((HZ << scan) / 200))
+		if (scan && schedule_timeout_killable((HZ << scan) / 200))
 			scan = LAST_SCAN;
 
 		start = 0;
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
