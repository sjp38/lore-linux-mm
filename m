Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 17F956B0036
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 22:39:49 -0400 (EDT)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 27 Aug 2013 12:22:35 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id B826B2CE8057
	for <linux-mm@kvack.org>; Tue, 27 Aug 2013 12:39:44 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7R2dVVr9109714
	for <linux-mm@kvack.org>; Tue, 27 Aug 2013 12:39:33 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r7R2dfHd002193
	for <linux-mm@kvack.org>; Tue, 27 Aug 2013 12:39:42 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v2 3/3] mm/hwpoison: fix return value of madvise_hwpoison
Date: Tue, 27 Aug 2013 10:39:31 +0800
Message-Id: <1377571171-9958-3-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1377571171-9958-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1377571171-9958-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Tony Luck <tony.luck@intel.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

The return value outside for loop is always zero which means madvise_hwpoison 
return success, however, this is not truth for soft_offline_page w/ failure
return value.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/madvise.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index a20764c..19b71e4 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -359,7 +359,7 @@ static int madvise_hwpoison(int bhv, unsigned long start, unsigned long end)
 				page_to_pfn(p), start);
 			ret = soft_offline_page(p, MF_COUNT_INCREASED);
 			if (ret)
-				break;
+				return ret;
 			continue;
 		}
 		pr_info("Injecting memory failure for page %#lx at %#lx\n",
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
