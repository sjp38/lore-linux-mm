Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 73E728E0001
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 18:19:06 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id h9-v6so13793650otj.10
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 15:19:06 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id x64-v6si10328466otb.272.2018.09.21.15.19.04
        for <linux-mm@kvack.org>;
        Fri, 21 Sep 2018 15:19:04 -0700 (PDT)
From: James Morse <james.morse@arm.com>
Subject: [PATCH v6 17/18] mm/memory-failure: increase queued recovery work's priority
Date: Fri, 21 Sep 2018 23:17:04 +0100
Message-Id: <20180921221705.6478-18-james.morse@arm.com>
In-Reply-To: <20180921221705.6478-1-james.morse@arm.com>
References: <20180921221705.6478-1-james.morse@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, jonathan.zhang@cavium.com, James Morse <james.morse@arm.com>

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
so that the recovery work starts immediately.

Reported-by: Xie XiuQi <xiexiuqi@huawei.com>
Signed-off-by: James Morse <james.morse@arm.com>
Reviewed-by: Punit Agrawal <punit.agrawal@arm.com>
Tested-by: Tyler Baicar <tbaicar@codeaurora.org>
Tested-by: gengdongjiu <gengdongjiu@huawei.com>
CC: Xie XiuQi <xiexiuqi@huawei.com>
CC: gengdongjiu <gengdongjiu@huawei.com>
---
 mm/memory-failure.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 0cd3de3550f0..4e7b115cea5a 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -56,6 +56,7 @@
 #include <linux/memory_hotplug.h>
 #include <linux/mm_inline.h>
 #include <linux/memremap.h>
+#include <linux/preempt.h>
 #include <linux/kfifo.h>
 #include <linux/ratelimit.h>
 #include <linux/page-isolation.h>
@@ -1454,6 +1455,7 @@ static DEFINE_PER_CPU(struct memory_failure_cpu, memory_failure_cpu);
  */
 void memory_failure_queue(unsigned long pfn, int flags)
 {
+	int cpu = smp_processor_id();
 	struct memory_failure_cpu *mf_cpu;
 	unsigned long proc_flags;
 	struct memory_failure_entry entry = {
@@ -1463,11 +1465,14 @@ void memory_failure_queue(unsigned long pfn, int flags)
 
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
2.19.0
