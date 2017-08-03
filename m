Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id D08436B06C4
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 09:59:14 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id a186so2281705wmh.9
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 06:59:14 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id g15si2122760edl.279.2017.08.03.06.59.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Aug 2017 06:59:13 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id r77so2317343wmd.2
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 06:59:13 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] mm, oom: fix potential data corruption when oom_reaper races with writer
Date: Thu,  3 Aug 2017 15:59:02 +0200
Message-Id: <20170803135902.31977-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Wenwei Tao <wenwei.tww@alibaba-inc.com>, Oleg Nesterov <oleg@redhat.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Wenwei Tao has noticed that our current assumption that the oom victim
is dying and never doing any visible changes after it dies is not
entirely true. __task_will_free_mem consider a task dying when
SIGNAL_GROUP_EXIT is set but do_group_exit sends SIGKILL to all threads
_after_ the flag is set. So there is a race window when some threads
won't have fatal_signal_pending while the oom_reaper could start
unmapping the address space. generic_perform_write could then write
zero page to the page cache and corrupt data.

The race window is rather small and close to impossible to happen but it
would be better to have it covered.

Fix this by extending the existing MMF_UNSTABLE check in handle_mm_fault
and segfault on any page fault after the oom reaper started its work.
This means that nobody will ever observe a potentially corrupted
content. Formerly we cared only about use_mm users because those can
outlive the oom victim quite easily but having the process itself
protected sounds like a reasonable thing to do as well.

There doesn't seem to be any real life bug report so this is merely a
fix of a theoretical bug.

Noticed-by: Wenwei Tao <wenwei.tww@alibaba-inc.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
Hi,
Wenwei has contacted me off list and this is a result of the dicussion.
I do not think this would be serious enough to warrant a stable backport
even though the description might sound scary. The race is highly unlikely.

 mm/memory.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 0e517be91a89..3d8bfeaca38a 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3874,13 +3874,9 @@ int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 	/*
 	 * This mm has been already reaped by the oom reaper and so the
 	 * refault cannot be trusted in general. Anonymous refaults would
-	 * lose data and give a zero page instead e.g. This is especially
-	 * problem for use_mm() because regular tasks will just die and
-	 * the corrupted data will not be visible anywhere while kthread
-	 * will outlive the oom victim and potentially propagate the date
-	 * further.
+	 * lose data and give a zero page instead e.g.
 	 */
-	if (unlikely((current->flags & PF_KTHREAD) && !(ret & VM_FAULT_ERROR)
+	if (unlikely(!(ret & VM_FAULT_ERROR)
 				&& test_bit(MMF_UNSTABLE, &vma->vm_mm->flags)))
 		ret = VM_FAULT_SIGBUS;
 
-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
