Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id D64AC6B003B
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 04:46:36 -0400 (EDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 26 Aug 2013 14:08:27 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id C346E1258055
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 14:16:21 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7Q8mBUh40239176
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 14:18:11 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r7Q8kViG030452
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 14:16:31 +0530
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v4 7/10] mm/hwpoison: add '#' to madvise_hwpoison
Date: Mon, 26 Aug 2013 16:46:11 +0800
Message-Id: <1377506774-5377-7-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1377506774-5377-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1377506774-5377-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Tony Luck <tony.luck@intel.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Add '#' to madvise_hwpoison.

Before patch:

[   95.892866] Injecting memory failure for page 19d0 at b7786000
[   95.893151] MCE 0x19d0: non LRU page recovery: Ignored

After patch:

[   95.892866] Injecting memory failure for page 0x19d0 at 0xb7786000
[   95.893151] MCE 0x19d0: non LRU page recovery: Ignored

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/madvise.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index 95795df..588bb19 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -353,14 +353,14 @@ static int madvise_hwpoison(int bhv, unsigned long start, unsigned long end)
 		if (ret != 1)
 			return ret;
 		if (bhv == MADV_SOFT_OFFLINE) {
-			printk(KERN_INFO "Soft offlining page %lx at %lx\n",
+			pr_info("Soft offlining page %#lx at %#lx\n",
 				page_to_pfn(p), start);
 			ret = soft_offline_page(p, MF_COUNT_INCREASED);
 			if (ret)
 				break;
 			continue;
 		}
-		printk(KERN_INFO "Injecting memory failure for page %lx at %lx\n",
+		pr_info("Injecting memory failure for page %#lx at %#lx\n",
 		       page_to_pfn(p), start);
 		/* Ignore return value for now */
 		memory_failure(page_to_pfn(p), 0, MF_COUNT_INCREASED);
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
