Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id D79F06B0034
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 20:39:46 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp2so6325925pbb.28
        for <linux-mm@kvack.org>; Tue, 17 Sep 2013 17:39:46 -0700 (PDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 18 Sep 2013 06:09:11 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 293E5E0055
	for <linux-mm@kvack.org>; Wed, 18 Sep 2013 06:10:06 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8I0d6DS40501416
	for <linux-mm@kvack.org>; Wed, 18 Sep 2013 06:09:06 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8I0d7rw004256
	for <linux-mm@kvack.org>; Wed, 18 Sep 2013 06:09:08 +0530
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v3 4/4] mm/hwpoison: fix the lack of one reference count against poisoned page
Date: Wed, 18 Sep 2013 08:38:57 +0800
Message-Id: <1379464737-23592-4-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1379464737-23592-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1379464737-23592-1-git-send-email-liwanp@linux.vnet.ibm.com>
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

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Acked-by: Andi Kleen <ak@linux.intel.com>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/hwpoison-inject.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

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
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
