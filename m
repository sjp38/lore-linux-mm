Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id AA77C6B0261
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 11:05:13 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id o124so109593686pfg.1
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 08:05:13 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id n81si278183pfb.192.2016.08.31.08.05.12
        for <linux-mm@kvack.org>;
        Wed, 31 Aug 2016 08:05:12 -0700 (PDT)
From: James Morse <james.morse@arm.com>
Subject: [PATCH] mm: memcontrol: Make the walk_page_range() limit obvious
Date: Wed, 31 Aug 2016 16:04:57 +0100
Message-Id: <1472655897-22532-1-git-send-email-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, James Morse <james.morse@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Trying to walk all of virtual memory requires architecture specific
knowledge. On x86_64, addresses must be sign extended from bit 48,
whereas on arm64 the top VA_BITS of address space have their own set
of page tables.

mem_cgroup_count_precharge() and mem_cgroup_move_charge() both call
walk_page_range() on the range 0 to ~0UL, neither provide a pte_hole
callback, which causes the current implementation to skip non-vma regions.

As this call only expects to walk user address space, make it walk
0 to  'highest_vm_end'.

Signed-off-by: James Morse <james.morse@arm.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
This is in preparation for a RFC series that allows walk_page_range() to
walk kernel page tables too.

 mm/memcontrol.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2ff0289ad061..bfd54b43beb9 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4712,7 +4712,8 @@ static unsigned long mem_cgroup_count_precharge(struct mm_struct *mm)
 		.mm = mm,
 	};
 	down_read(&mm->mmap_sem);
-	walk_page_range(0, ~0UL, &mem_cgroup_count_precharge_walk);
+	walk_page_range(0, mm->highest_vm_end,
+			&mem_cgroup_count_precharge_walk);
 	up_read(&mm->mmap_sem);
 
 	precharge = mc.precharge;
@@ -5000,7 +5001,8 @@ retry:
 	 * When we have consumed all precharges and failed in doing
 	 * additional charge, the page walk just aborts.
 	 */
-	walk_page_range(0, ~0UL, &mem_cgroup_move_charge_walk);
+	walk_page_range(0, mc.mm->highest_vm_end, &mem_cgroup_move_charge_walk);
+
 	up_read(&mc.mm->mmap_sem);
 	atomic_dec(&mc.from->moving_account);
 }
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
