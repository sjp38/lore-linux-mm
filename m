Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 833AB6B0034
	for <linux-mm@kvack.org>; Mon,  2 Sep 2013 08:34:05 -0400 (EDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 2 Sep 2013 22:20:10 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id F33AA2CE8052
	for <linux-mm@kvack.org>; Mon,  2 Sep 2013 22:34:00 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r82CHdQV10617140
	for <linux-mm@kvack.org>; Mon, 2 Sep 2013 22:17:39 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r82CXxnQ028564
	for <linux-mm@kvack.org>; Mon, 2 Sep 2013 22:34:00 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH 4/4] mm/hwpoison: fix the lack of one reference count against poisoned page 
Date: Mon,  2 Sep 2013 20:33:44 +0800
Message-Id: <1378125224-12794-4-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1378125224-12794-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1378125224-12794-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Tony Luck <tony.luck@intel.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

The lack of one reference count against poisoned page for hwpoison_inject w/o 
hwpoison_filter enabled result in hwpoison detect -1 users still referenced 
the page, however, the number should be 0 except the poison handler held one 
after successfully unmap. This patch fix it by hold one referenced count against 
poisoned page for hwpoison_inject w/ and w/o hwpoison_filter enabled.

Before patch:

[   71.902112] Injecting memory failure at pfn 224706
[   71.902137] MCE 0x224706: dirty LRU page recovery: Failed
[   71.902138] MCE 0x224706: dirty LRU page still referenced by -1 users

After patch:

[   94.710860] Injecting memory failure at pfn 215b68
[   94.710885] MCE 0x215b68: dirty LRU page recovery: Recovered

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/hwpoison-inject.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/hwpoison-inject.c b/mm/hwpoison-inject.c
index afc2daa..4c84678 100644
--- a/mm/hwpoison-inject.c
+++ b/mm/hwpoison-inject.c
@@ -20,8 +20,6 @@ static int hwpoison_inject(void *data, u64 val)
 	if (!capable(CAP_SYS_ADMIN))
 		return -EPERM;
 
-	if (!hwpoison_filter_enable)
-		goto inject;
 	if (!pfn_valid(pfn))
 		return -ENXIO;
 
@@ -33,6 +31,9 @@ static int hwpoison_inject(void *data, u64 val)
 	if (!get_page_unless_zero(hpage))
 		return 0;
 
+	if (!hwpoison_filter_enable)
+		goto inject;
+
 	if (!PageLRU(p) && !PageHuge(p))
 		shake_page(p, 0);
 	/*
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
