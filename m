Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A3B2E6B072D
	for <linux-mm@kvack.org>; Fri,  4 Aug 2017 04:34:02 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id d24so4874641wmi.0
        for <linux-mm@kvack.org>; Fri, 04 Aug 2017 01:34:02 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id s7si3946322edj.312.2017.08.04.01.34.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Aug 2017 01:34:01 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id d40so4866349wma.3
        for <linux-mm@kvack.org>; Fri, 04 Aug 2017 01:34:01 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/2] mm, oom: fix potential data corruption when oom_reaper races with writer
Date: Fri,  4 Aug 2017 10:33:50 +0200
Message-Id: <20170804083350.470-2-mhocko@kernel.org>
In-Reply-To: <20170804083350.470-1-mhocko@kernel.org>
References: <20170804083205.GH26029@dhcp22.suse.cz>
 <20170804083350.470-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Wenwei Tao <wenwei.tww@alibaba-inc.com>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

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
 mm/memory.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 4fe5b6254688..e7308e633b52 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3874,15 +3874,10 @@ int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
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
 				&& test_bit(MMF_UNSTABLE, &vma->vm_mm->flags))) {
-
 		/*
 		 * We are going to enforce SIGBUS but the PF path might have
 		 * dropped the mmap_sem already so take it again so that
-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
