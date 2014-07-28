Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 36ED06B0037
	for <linux-mm@kvack.org>; Mon, 28 Jul 2014 03:22:17 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id et14so10067738pad.9
        for <linux-mm@kvack.org>; Mon, 28 Jul 2014 00:22:16 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id bc15si8454933pdb.146.2014.07.28.00.22.15
        for <linux-mm@kvack.org>;
        Mon, 28 Jul 2014 00:22:16 -0700 (PDT)
From: "Chen, Gong" <gong.chen@linux.intel.com>
Subject: [PATCH 2/2] RAS, HWPOISON: Fix wrong error recovery status
Date: Mon, 28 Jul 2014 02:51:00 -0400
Message-Id: <1406530260-26078-3-git-send-email-gong.chen@linux.intel.com>
In-Reply-To: <1406530260-26078-1-git-send-email-gong.chen@linux.intel.com>
References: <1406530260-26078-1-git-send-email-gong.chen@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tony.luck@intel.com, n-horiguchi@ah.jp.nec.com, bp@alien8.de
Cc: linux-acpi@vger.kernel.org, linux-mm@kvack.org, "Chen, Gong" <gong.chen@linux.intel.com>

When Uncorrected error happens, if the poisoned page is referenced
by more than one user after error recovery, the recovery is not
successful. But currently the display result is wrong.
Before this patch:

MCE 0x44e336: dirty mlocked LRU page recovery: Recovered
MCE 0x44e336: dirty mlocked LRU page still referenced by 1 users
mce: Memory error not recovered

After this patch:

MCE 0x44e336: dirty mlocked LRU page recovery: Failed
MCE 0x44e336: dirty mlocked LRU page still referenced by 1 users
mce: Memory error not recovered

Signed-off-by: Chen, Gong <gong.chen@linux.intel.com>
Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/memory-failure.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index c6399e3..2985861 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -860,7 +860,6 @@ static int page_action(struct page_state *ps, struct page *p,
 	int count;
 
 	result = ps->action(p, pfn);
-	action_result(pfn, ps->msg, result);
 
 	count = page_count(p) - 1;
 	if (ps->action == me_swapcache_dirty && result == DELAYED)
@@ -871,6 +870,7 @@ static int page_action(struct page_state *ps, struct page *p,
 		       pfn, ps->msg, count);
 		result = FAILED;
 	}
+	action_result(pfn, ps->msg, result);
 
 	/* Could do more checks here if page looks ok */
 	/*
-- 
2.0.0.rc2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
