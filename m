Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3E5106B025F
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 04:46:11 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id a47so7992486wra.0
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 01:46:11 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 93sor545637wri.58.2017.08.30.01.46.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 Aug 2017 01:46:09 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH] mm, oom_reaper: skip mm structs with mmu notifiers
Date: Wed, 30 Aug 2017 10:46:00 +0200
Message-Id: <20170830084600.17491-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Argangeli <andrea@kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Andrea has noticed that the oom_reaper doesn't invalidate the range
via mmu notifiers (mmu_notifier_invalidate_range_start,
mmu_notifier_invalidate_range_end) and that can corrupt the memory
of the kvm guest for example. As the callback is allowed to sleep
and the implementation is out of hand of the MM it is safer to simply
bail out if there is an mmu notifier registered. In order to not
fail too early make the mm_has_notifiers check under the oom_lock
and have a little nap before failing to give the current oom victim some
more time to exit.

Fixes: aac453635549 ("mm, oom: introduce oom reaper")
Noticed-by: Andrea Arcangeli <aarcange@redhat.com>
Cc: stable
Signed-off-by: Michal Hocko <mhocko@suse.com>
---

Hi,
Andrea has pointed this out [1] while a different (but similar) bug has been
discussed. This is an ugly hack to plug the potential memory corruption but
we definitely want a better fix longterm.

Does this sound like a viable option for now?

[1] http://lkml.kernel.org/r/20170829140924.GB21615@redhat.com

 include/linux/mmu_notifier.h |  5 +++++
 mm/oom_kill.c                | 15 +++++++++++++++
 2 files changed, 20 insertions(+)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index c91b3bcd158f..947f21b451d2 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -420,6 +420,11 @@ extern void mmu_notifier_synchronize(void);
 
 #else /* CONFIG_MMU_NOTIFIER */
 
+static inline int mm_has_notifiers(struct mm_struct *mm)
+{
+	return 0;
+}
+
 static inline void mmu_notifier_release(struct mm_struct *mm)
 {
 }
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 99736e026712..45f1a0c3dd90 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -40,6 +40,7 @@
 #include <linux/ratelimit.h>
 #include <linux/kthread.h>
 #include <linux/init.h>
+#include <linux/mmu_notifier.h>
 
 #include <asm/tlb.h>
 #include "internal.h"
@@ -488,6 +489,20 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	 */
 	mutex_lock(&oom_lock);
 
+	/*
+	 * If the mm has notifiers then we would need to invalidate them around
+	 * unmap_page_range and that is risky because notifiers can sleep and
+	 * what they do is basically undeterministic. So let's have a short sleep
+	 * to give the oom victim some more time.
+	 * TODO: we really want to get rid of this ugly hack and make sure that
+	 * notifiers cannot block for unbounded amount of time and add
+	 * mmu_notifier_invalidate_range_{start,end} around unmap_page_range
+	 */
+	if (mm_has_notifiers(mm)) {
+		schedule_timeout_idle(HZ);
+		goto unlock_oom;
+	}
+
 	if (!down_read_trylock(&mm->mmap_sem)) {
 		ret = false;
 		trace_skip_task_reaping(tsk->pid);
-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
