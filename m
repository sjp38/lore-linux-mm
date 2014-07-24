Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f49.google.com (mail-qa0-f49.google.com [209.85.216.49])
	by kanga.kvack.org (Postfix) with ESMTP id 68C296B007D
	for <linux-mm@kvack.org>; Thu, 24 Jul 2014 15:51:18 -0400 (EDT)
Received: by mail-qa0-f49.google.com with SMTP id dc16so3462703qab.22
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 12:51:18 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a13si12717588qge.120.2014.07.24.12.51.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Jul 2014 12:51:17 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 2/2] hwpoison: call action_result() in failure path of hwpoison_user_mappings()
Date: Thu, 24 Jul 2014 15:50:53 -0400
Message-Id: <1406231453-27928-2-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1406231453-27928-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1406231453-27928-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <andi@firstfloor.org>, Chen Yucong <slaoub@gmail.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>

hwpoison_user_mappings() could fail for various reasons, so printk()s
to print out the reasons should be done in each failure check inside
hwpoison_user_mappings().
And currently we don't call action_result() when hwpoison_user_mappings()
fails, which is not consistent with other exit points of memory error
handler. So this patch fixes these messaging problems.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/memory-failure.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git mmotm-2014-07-22-15-58.orig/mm/memory-failure.c mmotm-2014-07-22-15-58/mm/memory-failure.c
index f465b98d0209..44c6bd201d3a 100644
--- mmotm-2014-07-22-15-58.orig/mm/memory-failure.c
+++ mmotm-2014-07-22-15-58/mm/memory-failure.c
@@ -911,8 +911,10 @@ static int hwpoison_user_mappings(struct page *p, unsigned long pfn,
 	if (!page_mapped(hpage))
 		return SWAP_SUCCESS;
 
-	if (PageKsm(p))
+	if (PageKsm(p)) {
+		pr_err("MCE %#lx: can't handle KSM pages.\n", pfn);
 		return SWAP_FAIL;
+	}
 
 	if (PageSwapCache(p)) {
 		printk(KERN_ERR
@@ -1245,7 +1247,7 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 	 */
 	if (hwpoison_user_mappings(p, pfn, trapno, flags, &hpage)
 	    != SWAP_SUCCESS) {
-		printk(KERN_ERR "MCE %#lx: cannot unmap page, give up\n", pfn);
+		action_result(pfn, "unmapping failed", IGNORED);
 		res = -EBUSY;
 		goto out;
 	}
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
