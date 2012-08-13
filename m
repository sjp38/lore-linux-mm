Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id A339D6B0069
	for <linux-mm@kvack.org>; Mon, 13 Aug 2012 07:14:07 -0400 (EDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Mon, 13 Aug 2012 16:44:04 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7DBDjaZ30539996
	for <linux-mm@kvack.org>; Mon, 13 Aug 2012 16:43:45 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7DBDjlf001354
	for <linux-mm@kvack.org>; Mon, 13 Aug 2012 21:13:45 +1000
Message-ID: <5028E167.8050605@linux.vnet.ibm.com>
Date: Mon, 13 Aug 2012 19:13:43 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 02/12] thp: remove unnecessary check in start_khugepaged
References: <5028E12C.70101@linux.vnet.ibm.com>
In-Reply-To: <5028E12C.70101@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

The check is unnecessary since if mm_slot_cache or mm_slots_hash initialize
failed, no sysfs interface will be created

Signed-off-by: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
---
 mm/huge_memory.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 80bcd42..399e8c9 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -140,10 +140,7 @@ static int start_khugepaged(void)
 	int err = 0;
 	if (khugepaged_enabled()) {
 		int wakeup;
-		if (unlikely(!mm_slot_cache || !mm_slots_hash)) {
-			err = -ENOMEM;
-			goto out;
-		}
+
 		mutex_lock(&khugepaged_mutex);
 		if (!khugepaged_thread)
 			khugepaged_thread = kthread_run(khugepaged, NULL,
@@ -163,7 +160,7 @@ static int start_khugepaged(void)
 	} else
 		/* wakeup to exit */
 		wake_up_interruptible(&khugepaged_wait);
-out:
+
 	return err;
 }

-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
