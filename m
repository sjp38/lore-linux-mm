Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id B45DD6B0023
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 13:59:26 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id u6so309565oie.18
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 10:59:26 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id t3si893714otf.362.2018.02.15.10.59.25
        for <linux-mm@kvack.org>;
        Thu, 15 Feb 2018 10:59:25 -0800 (PST)
From: James Morse <james.morse@arm.com>
Subject: [PATCH 10/11] mm/memory-failure: increase queued recovery work's priority
Date: Thu, 15 Feb 2018 18:56:05 +0000
Message-Id: <20180215185606.26736-11-james.morse@arm.com>
In-Reply-To: <20180215185606.26736-1-james.morse@arm.com>
References: <20180215185606.26736-1-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, James Morse <james.morse@arm.com>

arm64 can take an NMI-like error notification when user-space steps in
some corrupt memory. APEI's GHES code will call memory_failure_queue()
to schedule the recovery work. We then return to user-space, possibly
taking the fault again.

Currently the arch code unconditionally signals user-space from this
path, so we don't get stuck in this loop, but the affected process
never benefits from memory_failure()s recovery work. To fix this we
need to know the recovery work will run before we get back to user-space.

Increase the priority of the recovery work by scheduling it on the
system_highpri_wq, then try to bump the current task off this CPU
so that the recover work starts immediately.

Reported-by: Xie XiuQi <xiexiuqi@huawei.com>
Signed-off-by: James Morse <james.morse@arm.com>
CC: Xie XiuQi <xiexiuqi@huawei.com>
CC: gengdongjiu <gengdongjiu@huawei.com>
---
 mm/memory-failure.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 4b80ccee4535..14f44d841e8b 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -55,6 +55,7 @@
 #include <linux/hugetlb.h>
 #include <linux/memory_hotplug.h>
 #include <linux/mm_inline.h>
+#include <linux/preempt.h>
 #include <linux/kfifo.h>
 #include <linux/ratelimit.h>
 #include "internal.h"
@@ -1319,6 +1320,7 @@ static DEFINE_PER_CPU(struct memory_failure_cpu, memory_failure_cpu);
  */
 void memory_failure_queue(unsigned long pfn, int flags)
 {
+	int cpu = smp_processor_id();
 	struct memory_failure_cpu *mf_cpu;
 	unsigned long proc_flags;
 	struct memory_failure_entry entry = {
@@ -1328,11 +1330,14 @@ void memory_failure_queue(unsigned long pfn, int flags)
 
 	mf_cpu = &get_cpu_var(memory_failure_cpu);
 	spin_lock_irqsave(&mf_cpu->lock, proc_flags);
-	if (kfifo_put(&mf_cpu->fifo, entry))
-		schedule_work_on(smp_processor_id(), &mf_cpu->work);
-	else
+	if (kfifo_put(&mf_cpu->fifo, entry)) {
+		queue_work_on(cpu, system_highpri_wq, &mf_cpu->work);
+		set_tsk_need_resched(current);
+		preempt_set_need_resched();
+	} else {
 		pr_err("Memory failure: buffer overflow when queuing memory failure at %#lx\n",
 		       pfn);
+	}
 	spin_unlock_irqrestore(&mf_cpu->lock, proc_flags);
 	put_cpu_var(memory_failure_cpu);
 }
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
