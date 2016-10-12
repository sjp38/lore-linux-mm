Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 570C66B0069
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 05:57:11 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id hm5so38895063pac.4
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 02:57:11 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id d62si5065026pga.215.2016.10.12.02.57.10
        for <linux-mm@kvack.org>;
        Wed, 12 Oct 2016 02:57:10 -0700 (PDT)
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: [PATCH] mm: kmemleak: Ensure that the task stack is not freed during scanning
Date: Wed, 12 Oct 2016 10:57:03 +0100
Message-Id: <1476266223-14325-1-git-send-email-catalin.marinas@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, CAI Qian <caiqian@redhat.com>

Commit 68f24b08ee89 ("sched/core: Free the stack early if
CONFIG_THREAD_INFO_IN_TASK") may cause the task->stack to be freed
during kmemleak_scan() execution, leading to either a NULL pointer
fault (if task->stack is NULL) or kmemleak accessing already freed
memory. This patch uses the new try_get_task_stack() API to ensure that
the task stack is not freed during kmemleak stack scanning.

Fixes: 68f24b08ee89 ("sched/core: Free the stack early if CONFIG_THREAD_INFO_IN_TASK")
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: CAI Qian <caiqian@redhat.com>
Reported-by: CAI Qian <caiqian@redhat.com>
Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
---

This was reported in a subsequent comment here:

https://bugzilla.kernel.org/show_bug.cgi?id=173901

However, the original bugzilla entry doesn't look related to task stack
freeing as it was first reported on 4.8-rc8. Andy, sorry for cc'ing you
to bugzilla, please feel free to remove your email from the bug above (I
can't seem to be able to do it).

 mm/kmemleak.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index a5e453cf05c4..e5355a5b423f 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -1453,8 +1453,11 @@ static void kmemleak_scan(void)
 
 		read_lock(&tasklist_lock);
 		do_each_thread(g, p) {
-			scan_block(task_stack_page(p), task_stack_page(p) +
-				   THREAD_SIZE, NULL);
+			void *stack = try_get_task_stack(p);
+			if (stack) {
+				scan_block(stack, stack + THREAD_SIZE, NULL);
+				put_task_stack(p);
+			}
 		} while_each_thread(g, p);
 		read_unlock(&tasklist_lock);
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
