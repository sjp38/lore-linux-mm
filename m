Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id BDD3C6B0032
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 20:41:29 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz10so7535624pad.2
        for <linux-mm@kvack.org>; Tue, 17 Sep 2013 17:41:29 -0700 (PDT)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 18 Sep 2013 06:09:10 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 2CC88E0058
	for <linux-mm@kvack.org>; Wed, 18 Sep 2013 06:10:04 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8I0d4kX22610068
	for <linux-mm@kvack.org>; Wed, 18 Sep 2013 06:09:04 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8I0d5SF032293
	for <linux-mm@kvack.org>; Wed, 18 Sep 2013 06:09:06 +0530
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v3 3/4] mm/hwpoison: fix false report 2nd try page recovery
Date: Wed, 18 Sep 2013 08:38:56 +0800
Message-Id: <1379464737-23592-3-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1379464737-23592-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1379464737-23592-1-git-send-email-liwanp@linux.vnet.ibm.com>
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
Acked-by: Andi Kleen <ak@linux.intel.com>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/memory-failure.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index ed41c63..615764c 100644
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
