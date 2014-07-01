Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id C11B26B0035
	for <linux-mm@kvack.org>; Mon, 30 Jun 2014 20:32:21 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id w10so9061176pde.24
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 17:32:21 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id iu6si99598pbc.4.2014.06.30.17.32.20
        for <linux-mm@kvack.org>;
        Mon, 30 Jun 2014 17:32:20 -0700 (PDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH] hwpoison: Fix race with changing page during offlining v2
Date: Mon, 30 Jun 2014 17:32:16 -0700
Message-Id: <1404174736-17480-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Andi Kleen <ak@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

From: Andi Kleen <ak@linux.intel.com>

When a hwpoison page is locked it could change state
due to parallel modifications.  Check after the lock
if the page is still the same compound page.

[v2: Removed earlier non LRU check which should be already
covered elsewhere]

Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 mm/memory-failure.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index cd8989c..99e5077 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1168,6 +1168,16 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 	lock_page(hpage);
 
 	/*
+	 * The page could have changed compound pages during the locking.
+	 * If this happens just bail out.
+	 */
+	if (compound_head(p) != hpage) {
+		action_result(pfn, "different compound page after locking", IGNORED);
+		res = -EBUSY;
+		goto out;
+	}
+
+	/*
 	 * We use page flags to determine what action should be taken, but
 	 * the flags can be modified by the error containment action.  One
 	 * example is an mlocked page, where PG_mlocked is cleared by
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
