Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m5Q9T99q027546
	for <linux-mm@kvack.org>; Thu, 26 Jun 2008 05:29:09 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5Q9T9Hw178754
	for <linux-mm@kvack.org>; Thu, 26 Jun 2008 03:29:09 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5Q9T91U023358
	for <linux-mm@kvack.org>; Thu, 26 Jun 2008 03:29:09 -0600
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Thu, 26 Jun 2008 14:59:06 +0530
Message-Id: <20080626092906.16841.98723.sendpatchset@balbir-laptop>
In-Reply-To: <20080626092815.16841.54817.sendpatchset@balbir-laptop>
References: <20080626092815.16841.54817.sendpatchset@balbir-laptop>
Subject: [4/5] memrlimit improve fork and error handling
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hugh@veritas.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


The fork path of the memrlimit patches adds an additional down_write() of
mmap_sem. Ideally memrlimit should be zero overhead for non users and the
error handling path also needed improvement. This patch fixes both problems.

The accounting has now been moved from copy_mm() to dup_mmap()

Reported-by: Hugh Dickins <hugh@veritas.com>

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 kernel/fork.c |   18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

diff -puN kernel/fork.c~memrlimit-improve-fork-error-handling kernel/fork.c
--- linux-2.6.26-rc5/kernel/fork.c~memrlimit-improve-fork-error-handling	2008-06-26 14:48:23.000000000 +0530
+++ linux-2.6.26-rc5-balbir/kernel/fork.c	2008-06-26 14:48:23.000000000 +0530
@@ -261,7 +261,7 @@ static int dup_mmap(struct mm_struct *mm
 	struct vm_area_struct *mpnt, *tmp, **pprev;
 	struct rb_node **rb_link, *rb_parent;
 	int retval;
-	unsigned long charge;
+	unsigned long charge, uncharged = 0;
 	struct mempolicy *pol;
 
 	down_write(&oldmm->mmap_sem);
@@ -271,6 +271,15 @@ static int dup_mmap(struct mm_struct *mm
 	 */
 	down_write_nested(&mm->mmap_sem, SINGLE_DEPTH_NESTING);
 
+	/*
+	 * Uncharging as a result of failure is done by mmput()
+	 * in dup_mm()
+	 */
+	if (memrlimit_cgroup_charge_as(oldmm, oldmm->total_vm)) {
+		retval = -ENOMEM;
+		goto out;
+	}
+
 	mm->locked_vm = 0;
 	mm->mmap = NULL;
 	mm->mmap_cache = NULL;
@@ -292,6 +301,7 @@ static int dup_mmap(struct mm_struct *mm
 			vm_stat_account(mm, mpnt->vm_flags, mpnt->vm_file,
 								-pages);
 			memrlimit_cgroup_uncharge_as(mm, pages);
+			uncharged += pages;
 			continue;
 		}
 		charge = 0;
@@ -629,12 +639,6 @@ static int copy_mm(unsigned long clone_f
 		atomic_inc(&oldmm->mm_users);
 		mm = oldmm;
 		goto good_mm;
-	} else {
-		down_write(&oldmm->mmap_sem);
-		retval = memrlimit_cgroup_charge_as(oldmm, oldmm->total_vm);
-		up_write(&oldmm->mmap_sem);
-		if (retval)
-			goto fail_nomem;
 	}
 
 	retval = -ENOMEM;
diff -puN kernel/exit.c~memrlimit-improve-fork-error-handling kernel/exit.c
_

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
