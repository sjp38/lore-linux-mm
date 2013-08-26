Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 2AB2D6B003A
	for <linux-mm@kvack.org>; Sun, 25 Aug 2013 21:19:14 -0400 (EDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 26 Aug 2013 22:13:23 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 0209B2BB0051
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 11:19:10 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7Q12veH66715648
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 11:02:57 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7Q1J8vs000466
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 11:19:09 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v3 7/8] mm/hwpoison: add '#' to madvise_hwpoison
Date: Mon, 26 Aug 2013 09:18:50 +0800
Message-Id: <1377479931-7430-7-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1377479931-7430-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1377479931-7430-1-git-send-email-liwanp@linux.vnet.ibm.com>
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
