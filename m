Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id CECC66B0037
	for <linux-mm@kvack.org>; Wed, 20 Aug 2014 08:11:16 -0400 (EDT)
Received: by mail-ie0-f178.google.com with SMTP id rd18so2722673iec.37
        for <linux-mm@kvack.org>; Wed, 20 Aug 2014 05:11:16 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id fk8si2214887igb.29.2014.08.20.05.11.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Aug 2014 05:11:16 -0700 (PDT)
From: Chintan Pandya <cpandya@codeaurora.org>
Subject: [PATCH v4 2/2] ksm: provide support to use deferrable timers for scanner thread
Date: Wed, 20 Aug 2014 17:40:28 +0530
Message-Id: <1408536628-29379-2-git-send-email-cpandya@codeaurora.org>
In-Reply-To: <1408536628-29379-1-git-send-email-cpandya@codeaurora.org>
References: <1408536628-29379-1-git-send-email-cpandya@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-arm-msm@vger.kernel.org, linux-kernel@vger.kernel.org, Chintan Pandya <cpandya@codeaurora.org>, Thomas Gleixner <tglx@linutronix.de>, John Stultz <john.stultz@linaro.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Hugh Dickins <hughd@google.com>

KSM thread to scan pages is scheduled on definite timeout. That wakes up
CPU from idle state and hence may affect the power consumption. Provide
an optional support to use deferrable timer which suites low-power
use-cases.

Typically, on our setup we observed, 10% less power consumption with some
use-cases in which CPU goes to power collapse frequently. For example,
playing audio on Soc which has HW based Audio encoder/decoder, CPU
remains idle for longer duration of time. This idle state will save
significant CPU power consumption if KSM don't wakes them up
periodically.

Note that, deferrable timers won't be deferred if any CPU is active and
not in IDLE state.

By default, deferrable timers is enabled. To disable deferrable timers,
$ echo 0 > /sys/kernel/mm/ksm/deferrable_timer

Signed-off-by: Chintan Pandya <cpandya@codeaurora.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: John Stultz <john.stultz@linaro.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Hugh Dickins <hughd@google.com>
---
Changes:

V3-->V4:
	- Use deferrable timers by default

V2-->V3:
	- Handled error case properly
	- Corrected indentation in Documentation
	- Fixed build failure
	- Removed left over process_timeout()
V1-->V2:
	- allowing only valid values to be updated as use_deferrable_timer
	- using only 'deferrable' and not 'deferred'
	- moved out schedule_timeout code for deferrable timer into timer.c


 Documentation/vm/ksm.txt |  6 ++++++
 mm/ksm.c                 | 36 ++++++++++++++++++++++++++++++++++--
 2 files changed, 40 insertions(+), 2 deletions(-)

diff --git a/Documentation/vm/ksm.txt b/Documentation/vm/ksm.txt
index f34a8ee..23e26c3 100644
--- a/Documentation/vm/ksm.txt
+++ b/Documentation/vm/ksm.txt
@@ -87,6 +87,12 @@ pages_sharing    - how many more sites are sharing them i.e. how much saved
 pages_unshared   - how many pages unique but repeatedly checked for merging
 pages_volatile   - how many pages changing too fast to be placed in a tree
 full_scans       - how many times all mergeable areas have been scanned
+deferrable_timer - whether to use deferrable timers or not
+                   e.g. "echo 1 > /sys/kernel/mm/ksm/deferrable_timer"
+                   Default: 1 (means, we are using deferrable timers. Users
+		   might want to clear deferrable_timer option if they want
+		   ksm thread to wakeup CPU to carryout ksm activities thus
+		   loosing on battery while gaining on memory savings.)
 
 A high ratio of pages_sharing to pages_shared indicates good sharing, but
 a high ratio of pages_unshared to pages_sharing indicates wasted effort.
diff --git a/mm/ksm.c b/mm/ksm.c
index fb75902..af90e30 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -223,6 +223,9 @@ static unsigned int ksm_thread_pages_to_scan = 100;
 /* Milliseconds ksmd should sleep between batches */
 static unsigned int ksm_thread_sleep_millisecs = 20;
 
+/* Boolean to indicate whether to use deferrable timer or not */
+static bool use_deferrable_timer = 1;
+
 #ifdef CONFIG_NUMA
 /* Zeroed when merging across nodes is not allowed */
 static unsigned int ksm_merge_across_nodes = 1;
@@ -1725,8 +1728,13 @@ static int ksm_scan_thread(void *nothing)
 		try_to_freeze();
 
 		if (ksmd_should_run()) {
-			schedule_timeout_interruptible(
-				msecs_to_jiffies(ksm_thread_sleep_millisecs));
+			signed long to;
+
+			to = msecs_to_jiffies(ksm_thread_sleep_millisecs);
+			if (use_deferrable_timer)
+				schedule_timeout_deferrable_interruptible(to);
+			else
+				schedule_timeout_interruptible(to);
 		} else {
 			wait_event_freezable(ksm_thread_wait,
 				ksmd_should_run() || kthread_should_stop());
@@ -2175,6 +2183,29 @@ static ssize_t run_store(struct kobject *kobj, struct kobj_attribute *attr,
 }
 KSM_ATTR(run);
 
+static ssize_t deferrable_timer_show(struct kobject *kobj,
+				    struct kobj_attribute *attr, char *buf)
+{
+	return snprintf(buf, 8, "%d\n", use_deferrable_timer);
+}
+
+static ssize_t deferrable_timer_store(struct kobject *kobj,
+				     struct kobj_attribute *attr,
+				     const char *buf, size_t count)
+{
+	unsigned long enable;
+	int err;
+
+	err = kstrtoul(buf, 10, &enable);
+	if (err < 0)
+		return err;
+	if (enable >= 1)
+		return -EINVAL;
+	use_deferrable_timer = enable;
+	return count;
+}
+KSM_ATTR(deferrable_timer);
+
 #ifdef CONFIG_NUMA
 static ssize_t merge_across_nodes_show(struct kobject *kobj,
 				struct kobj_attribute *attr, char *buf)
@@ -2287,6 +2318,7 @@ static struct attribute *ksm_attrs[] = {
 	&pages_unshared_attr.attr,
 	&pages_volatile_attr.attr,
 	&full_scans_attr.attr,
+	&deferrable_timer_attr.attr,
 #ifdef CONFIG_NUMA
 	&merge_across_nodes_attr.attr,
 #endif
-- 
Chintan Pandya

QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
member of the Code Aurora Forum, hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
