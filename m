Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0C9B26B0282
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:29:27 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 202so2570101pgb.13
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:29:27 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f64si6058069pfa.364.2018.02.04.17.28.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:04 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 10/64] kernel/exit: teach exit_mm() about range locking
Date: Mon,  5 Feb 2018 02:27:00 +0100
Message-Id: <20180205012754.23615-11-dbueso@wotan.suse.de>
In-Reply-To: <20180205012754.23615-1-dbueso@wotan.suse.de>
References: <20180205012754.23615-1-dbueso@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mingo@kernel.org
Cc: peterz@infradead.org, ldufour@linux.vnet.ibm.com, jack@suse.cz, mhocko@kernel.org, kirill.shutemov@linux.intel.com, mawilcox@microsoft.com, mgorman@techsingularity.net, dave@stgolabs.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

From: Davidlohr Bueso <dave@stgolabs.net>

... and use mm locking wrappers -- no change is semantics.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 kernel/exit.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/kernel/exit.c b/kernel/exit.c
index 42ca71a44c9a..a9540f157eb2 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -495,6 +495,7 @@ static void exit_mm(void)
 {
 	struct mm_struct *mm = current->mm;
 	struct core_state *core_state;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	mm_release(current, mm);
 	if (!mm)
@@ -507,12 +508,12 @@ static void exit_mm(void)
 	 * will increment ->nr_threads for each thread in the
 	 * group with ->mm != NULL.
 	 */
-	down_read(&mm->mmap_sem);
+        mm_read_lock(mm, &mmrange);
 	core_state = mm->core_state;
 	if (core_state) {
 		struct core_thread self;
 
-		up_read(&mm->mmap_sem);
+	        mm_read_unlock(mm, &mmrange);
 
 		self.task = current;
 		self.next = xchg(&core_state->dumper.next, &self);
@@ -530,14 +531,14 @@ static void exit_mm(void)
 			freezable_schedule();
 		}
 		__set_current_state(TASK_RUNNING);
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, &mmrange);
 	}
 	mmgrab(mm);
 	BUG_ON(mm != current->active_mm);
 	/* more a memory barrier than a real lock */
 	task_lock(current);
 	current->mm = NULL;
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	enter_lazy_tlb(mm, current);
 	task_unlock(current);
 	mm_update_next_owner(mm);
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
