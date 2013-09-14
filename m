Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 8336A6B0044
	for <linux-mm@kvack.org>; Sat, 14 Sep 2013 19:54:39 -0400 (EDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sun, 15 Sep 2013 05:15:54 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 25A3E3940057
	for <linux-mm@kvack.org>; Sun, 15 Sep 2013 05:24:21 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8ENuaSP46399710
	for <linux-mm@kvack.org>; Sun, 15 Sep 2013 05:26:36 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8ENsXl1029643
	for <linux-mm@kvack.org>; Sun, 15 Sep 2013 05:24:34 +0530
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [RESEND PATCH v2 3/4] mm/hwpoison: fix false report 2nd try page recovery
Date: Sun, 15 Sep 2013 07:53:58 +0800
Message-Id: <1379202839-23939-3-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1379202839-23939-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1379202839-23939-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Tony Luck <tony.luck@intel.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

If the page is poisoned by software inject w/ MF_COUNT_INCREASED flag, there
is a false report 2nd try page recovery which is not truth, this patch fix it
by report first try free buddy page recovery if MF_COUNT_INCREASED is set.

Before patch:

[  346.332041] Injecting memory failure at pfn 200010
[  346.332189] MCE 0x200010: free buddy, 2nd try page recovery: Delayed

After patch:

[  297.742600] Injecting memory failure at pfn 200010
[  297.742941] MCE 0x200010: free buddy page recovery: Delayed

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/memory-failure.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index b114570..6293164 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1114,8 +1114,10 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 			 * shake_page could have turned it free.
 			 */
 			if (is_free_buddy_page(p)) {
-				action_result(pfn, "free buddy, 2nd try",
-						DELAYED);
+				if (flags & MF_COUNT_INCREASED)
+					action_result(pfn, "free buddy", DELAYED);
+				else
+					action_result(pfn, "free buddy, 2nd try", DELAYED);
 				return 0;
 			}
 			action_result(pfn, "non LRU", IGNORED);
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
