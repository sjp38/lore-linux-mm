Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5C53B6B0038
	for <linux-mm@kvack.org>; Wed, 13 Sep 2017 07:34:33 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id w12so14820901wrc.2
        for <linux-mm@kvack.org>; Wed, 13 Sep 2017 04:34:33 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g66sor300144wmi.73.2017.09.13.04.34.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Sep 2017 04:34:32 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] mm, oom_reaper: skip mm structs with mmu notifiers
Date: Wed, 13 Sep 2017 13:34:27 +0200
Message-Id: <20170913113427.2291-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Argangeli <andrea@kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Andrea has noticed that the oom_reaper doesn't invalidate the range
via mmu notifiers (mmu_notifier_invalidate_range_start,
mmu_notifier_invalidate_range_end) and that can corrupt the memory
of the kvm guest for example.

tlb_flush_mmu_tlbonly already invokes mmu notifiers but that is not
sufficient as per Andrea:
: mmu_notifier_invalidate_range cannot be used in replacement of
: mmu_notifier_invalidate_range_start/end. For KVM
: mmu_notifier_invalidate_range is a noop and rightfully so. A MMU
: notifier implementation has to implement either
: ->invalidate_range method or the invalidate_range_start/end
: methods, not both. And if you implement invalidate_range_start/end
: like KVM is forced to do, calling mmu_notifier_invalidate_range in
: common code is a noop for KVM.
:
: For those MMU notifiers that can get away only implementing
: ->invalidate_range, the ->invalidate_range is implicitly called by
: mmu_notifier_invalidate_range_end(). And only those secondary MMUs
: that share the same pagetable with the primary MMU (like AMD
: iommuv2) can get away only implementing ->invalidate_range.

As the callback is allowed to sleep and the implementation is out
of hand of the MM it is safer to simply bail out if there is an
mmu notifier registered. In order to not fail too early make the
mm_has_notifiers check under the oom_lock and have a little nap before
failing to give the current oom victim some more time to exit.

Changes since v1
- move mm_has_notifiers check after we hold mmap_sem to prevent from
  any potential races as per Andrea

Fixes: aac453635549 ("mm, oom: introduce oom reaper")
Noticed-by: Andrea Arcangeli <aarcange@redhat.com>
Cc: stable
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
Hi,
I have posted this as an RFC previously [1]. I have updated
the changelog to be more clear about the issue and moved the
mm_has_notifiers after the lock has been take based on Andrea's
suggestion.

Can we merge this?

[1] http://lkml.kernel.org/r/20170830084600.17491-1-mhocko@kernel.org

 include/linux/mmu_notifier.h |  5 +++++
 mm/oom_kill.c                | 16 ++++++++++++++++
 2 files changed, 21 insertions(+)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index 7b2e31b1745a..6866e8126982 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -400,6 +400,11 @@ extern void mmu_notifier_synchronize(void);
 
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
index 99736e026712..92804b061e43 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -40,6 +40,7 @@
 #include <linux/ratelimit.h>
 #include <linux/kthread.h>
 #include <linux/init.h>
+#include <linux/mmu_notifier.h>
 
 #include <asm/tlb.h>
 #include "internal.h"
@@ -494,6 +495,21 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 		goto unlock_oom;
 	}
 
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
+		up_read(&mm->mmap_sem);
+		schedule_timeout_idle(HZ);
+		goto unlock_oom;
+	}
+
 	/*
 	 * MMF_OOM_SKIP is set by exit_mmap when the OOM reaper can't
 	 * work on the mm anymore. The check for MMF_OOM_SKIP must run
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
