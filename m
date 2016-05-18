Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8DA736B0005
	for <linux-mm@kvack.org>; Wed, 18 May 2016 17:53:49 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id yl2so86976381pac.2
        for <linux-mm@kvack.org>; Wed, 18 May 2016 14:53:49 -0700 (PDT)
Received: from mail-pf0-x22c.google.com (mail-pf0-x22c.google.com. [2607:f8b0:400e:c00::22c])
        by mx.google.com with ESMTPS id v80si605519pfj.199.2016.05.18.14.53.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 May 2016 14:53:48 -0700 (PDT)
Received: by mail-pf0-x22c.google.com with SMTP id 206so22698994pfu.0
        for <linux-mm@kvack.org>; Wed, 18 May 2016 14:53:48 -0700 (PDT)
Date: Wed, 18 May 2016 14:53:46 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, thp: khugepaged should scan when sleep value is
 written
Message-ID: <alpine.DEB.2.10.1605181453200.4786@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

If a large value is written to scan_sleep_millisecs, for example, that
period must lapse before khugepaged will wake up for periodic collapsing.

If this value is tuned to 1 day, for example, and then re-tuned to its
default 10s, khugepaged will still wait for a day before scanning again.

This patch causes khugepaged to wakeup immediately when the value is
changed and then sleep until that value is rewritten or the new value
lapses.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/huge_memory.c | 19 ++++++++++++++++---
 1 file changed, 16 insertions(+), 3 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -89,6 +89,7 @@ static unsigned int khugepaged_full_scans;
 static unsigned int khugepaged_scan_sleep_millisecs __read_mostly = 10000;
 /* during fragmentation poll the hugepage allocator once every minute */
 static unsigned int khugepaged_alloc_sleep_millisecs __read_mostly = 60000;
+static unsigned long khugepaged_sleep_expire;
 static struct task_struct *khugepaged_thread __read_mostly;
 static DEFINE_MUTEX(khugepaged_mutex);
 static DEFINE_SPINLOCK(khugepaged_mm_lock);
@@ -467,6 +468,7 @@ static ssize_t scan_sleep_millisecs_store(struct kobject *kobj,
 		return -EINVAL;
 
 	khugepaged_scan_sleep_millisecs = msecs;
+	khugepaged_sleep_expire = 0;
 	wake_up_interruptible(&khugepaged_wait);
 
 	return count;
@@ -494,6 +496,7 @@ static ssize_t alloc_sleep_millisecs_store(struct kobject *kobj,
 		return -EINVAL;
 
 	khugepaged_alloc_sleep_millisecs = msecs;
+	khugepaged_sleep_expire = 0;
 	wake_up_interruptible(&khugepaged_wait);
 
 	return count;
@@ -2797,15 +2800,25 @@ static void khugepaged_do_scan(void)
 		put_page(hpage);
 }
 
+static bool khugepaged_should_wakeup(void)
+{
+	return kthread_should_stop() ||
+	       time_after_eq(jiffies, khugepaged_sleep_expire);
+}
+
 static void khugepaged_wait_work(void)
 {
 	if (khugepaged_has_work()) {
-		if (!khugepaged_scan_sleep_millisecs)
+		const unsigned long scan_sleep_jiffies =
+			msecs_to_jiffies(khugepaged_scan_sleep_millisecs);
+
+		if (!scan_sleep_jiffies)
 			return;
 
+		khugepaged_sleep_expire = jiffies + scan_sleep_jiffies;
 		wait_event_freezable_timeout(khugepaged_wait,
-					     kthread_should_stop(),
-			msecs_to_jiffies(khugepaged_scan_sleep_millisecs));
+					     khugepaged_should_wakeup(),
+					     scan_sleep_jiffies);
 		return;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
