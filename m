From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 2/5] HWPOISON: fix tasklist_lock/anon_vma locking order
Date: Thu, 11 Jun 2009 22:22:41 +0800
Message-ID: <20090611144430.540500784@intel.com>
References: <20090611142239.192891591@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 1EF3D6B005A
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 10:52:17 -0400 (EDT)
Content-Disposition: inline; filename=hwpoison-lock-order.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Wu Fengguang <fengguang.wu@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

To avoid possible deadlock. Proposed by Nick Piggin:

  You have tasklist_lock(R) nesting outside i_mmap_lock, and inside anon_vma
  lock. And anon_vma lock nests inside i_mmap_lock.

  This seems fragile. If rwlocks ever become FIFO or tasklist_lock changes
  type (maybe -rt kernels do it), then you could have a task holding
  anon_vma lock and waiting for tasklist_lock, and another holding tasklist
  lock and waiting for i_mmap_lock, and another holding i_mmap_lock and
  waiting for anon_vma lock.

CC: Nick Piggin <npiggin@suse.de>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/memory-failure.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

--- sound-2.6.orig/mm/memory-failure.c
+++ sound-2.6/mm/memory-failure.c
@@ -215,12 +215,14 @@ static void collect_procs_anon(struct pa
 {
 	struct vm_area_struct *vma;
 	struct task_struct *tsk;
-	struct anon_vma *av = page_lock_anon_vma(page);
+	struct anon_vma *av;
 
+	read_lock(&tasklist_lock);
+
+	av = page_lock_anon_vma(page);
 	if (av == NULL) /* Not actually mapped anymore */
-		return;
+		goto out;
 
-	read_lock(&tasklist_lock);
 	for_each_process (tsk) {
 		if (!tsk->mm)
 			continue;
@@ -230,6 +232,7 @@ static void collect_procs_anon(struct pa
 		}
 	}
 	page_unlock_anon_vma(av);
+out:
 	read_unlock(&tasklist_lock);
 }
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
