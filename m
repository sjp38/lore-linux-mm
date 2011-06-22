Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 7914C900185
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 08:06:40 -0400 (EDT)
Date: Wed, 22 Jun 2011 14:06:36 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH] mm: Do not keep page locked during page fault while charging
 it for memcg
Message-ID: <20110622120635.GB14343@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>

Currently we are keeping faulted page locked throughout whole __do_fault
call (except for page_mkwrite code path). If we do early COW we allocate a
new page which has to be charged for a memcg (mem_cgroup_newpage_charge).
This function, however, might block for unbounded amount of time if memcg
oom killer is disabled because the only way out of the OOM situation is
either an external event (kill a process from the group or resize the group
hard limit) or internal event (that would get us under the limit). Many
times the external event is the only chance to move forward, though.
In the end we are keeping the faulted page locked and blocking other
processes from faulting it in which is not good at all because we are
basically punishing potentially an unrelated process for OOM condition
in a different group (I have seen stuck system because of ld-2.11.1.so being
locked).

Let's unlock the faulted page while we are charging a new page and then
recheck whether it wasn't truncated in the mean time. We should retry the
fault in that case.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memory.c |   18 +++++++++++++++++-
 1 files changed, 17 insertions(+), 1 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 87d9353..12e7ccc 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3177,7 +3177,23 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 				ret = VM_FAULT_OOM;
 				goto out;
 			}
-			if (mem_cgroup_newpage_charge(page, mm, GFP_KERNEL)) {
+
+			/* We have to drop the page lock here because memcg
+			 * charging might block for unbound time if memcg oom
+			 * killer is disabled.
+			 */
+			unlock_page(vmf.page);
+			ret = mem_cgroup_newpage_charge(page, mm, GFP_KERNEL);
+			lock_page(vmf.page);
+
+			if (!vmf.page->mapping) {
+				if (!ret)
+					mem_cgroup_uncharge_page(page);
+				page_cache_release(page);
+				ret = 0; /* retry the fault */
+				goto out;
+			}
+			if (ret) {
 				ret = VM_FAULT_OOM;
 				page_cache_release(page);
 				goto out;
-- 
1.7.5.4

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
