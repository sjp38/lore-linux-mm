Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 416F36B6A8D
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 13:07:53 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id s12so5859767otc.12
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 10:07:53 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 108si7171623oti.277.2018.12.03.10.07.52
        for <linux-mm@kvack.org>;
        Mon, 03 Dec 2018 10:07:52 -0800 (PST)
From: James Morse <james.morse@arm.com>
Subject: [PATCH v7 21/25] mm/memory-failure: Add memory_failure_queue_kick()
Date: Mon,  3 Dec 2018 18:06:09 +0000
Message-Id: <20181203180613.228133-22-james.morse@arm.com>
In-Reply-To: <20181203180613.228133-1-james.morse@arm.com>
References: <20181203180613.228133-1-james.morse@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Fan Wu <wufan@codeaurora.org>, James Morse <james.morse@arm.com>

The GHES code calls memory_failure_queue() from IRQ context to schedule
work on the current CPU so that memory_failure() can sleep.

For synchronous memory errors the arch code needs to know any signals
that memory_failure() will trigger are pending before it returns to
user-space, possibly when exiting from the IRQ.

Add a helper to kick the memory failure queue, to ensure the scheduled
work has happened. This has to be called from process context, so may
have been migrated from the original cpu. Pass the cpu the work was
queued on.

Change memory_failure_work_func() to permit being called on the 'wrong'
cpu.

Signed-off-by: James Morse <james.morse@arm.com>
---
 include/linux/mm.h  |  1 +
 mm/memory-failure.c | 15 ++++++++++++++-
 2 files changed, 15 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5411de93a363..37b4884b2a1e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2692,6 +2692,7 @@ enum mf_flags {
 };
 extern int memory_failure(unsigned long pfn, int flags);
 extern void memory_failure_queue(unsigned long pfn, int flags);
+extern void memory_failure_queue_kick(int cpu);
 extern int unpoison_memory(unsigned long pfn);
 extern int get_hwpoison_page(struct page *page);
 #define put_hwpoison_page(page)	put_page(page)
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 0cd3de3550f0..ec05e1dfce37 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1480,7 +1480,7 @@ static void memory_failure_work_func(struct work_struct *work)
 	unsigned long proc_flags;
 	int gotten;
 
-	mf_cpu = this_cpu_ptr(&memory_failure_cpu);
+	mf_cpu = container_of(work, struct memory_failure_cpu, work);
 	for (;;) {
 		spin_lock_irqsave(&mf_cpu->lock, proc_flags);
 		gotten = kfifo_get(&mf_cpu->fifo, &entry);
@@ -1494,6 +1494,19 @@ static void memory_failure_work_func(struct work_struct *work)
 	}
 }
 
+/*
+ * Process memory_failure work queued on the specified CPU.
+ * Used to avoid return-to-userspace racing with the memory_failure workqueue.
+ */
+void memory_failure_queue_kick(int cpu)
+{
+	struct memory_failure_cpu *mf_cpu;
+
+	mf_cpu = &per_cpu(memory_failure_cpu, cpu);
+	cancel_work_sync(&mf_cpu->work);
+	memory_failure_work_func(&mf_cpu->work);
+}
+
 static int __init memory_failure_init(void)
 {
 	struct memory_failure_cpu *mf_cpu;
-- 
2.19.2
