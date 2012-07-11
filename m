Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 4A1226B0068
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 13:02:51 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 02/10] mm: swapfile: clean up unuse_pte race handling
Date: Wed, 11 Jul 2012 19:02:14 +0200
Message-Id: <1342026142-7284-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1342026142-7284-1-git-send-email-hannes@cmpxchg.org>
References: <1342026142-7284-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Wanpeng Li <liwp.linux@gmail.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

The conditional mem_cgroup_cancel_charge_swapin() is a leftover from
when the function would continue to reestablish the page even after
mem_cgroup_try_charge_swapin() failed.  After 85d9fc8 "memcg: fix
refcnt handling at swapoff", the condition is always true when this
code is reached.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Michal Hocko <mhocko@suse.cz>
---
 mm/swapfile.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 64408be..75881ca 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -845,8 +845,7 @@ static int unuse_pte(struct vm_area_struct *vma, pmd_t *pmd,
 
 	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
 	if (unlikely(!pte_same(*pte, swp_entry_to_pte(entry)))) {
-		if (ret > 0)
-			mem_cgroup_cancel_charge_swapin(memcg);
+		mem_cgroup_cancel_charge_swapin(memcg);
 		ret = 0;
 		goto out;
 	}
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
