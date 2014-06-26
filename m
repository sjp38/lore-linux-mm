Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id D9FC86B00A0
	for <linux-mm@kvack.org>; Thu, 26 Jun 2014 14:23:19 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id um1so3486939pbc.2
        for <linux-mm@kvack.org>; Thu, 26 Jun 2014 11:23:19 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id hp4si11076396pac.0.2014.06.26.11.23.18
        for <linux-mm@kvack.org>;
        Thu, 26 Jun 2014 11:23:18 -0700 (PDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH] hwpoison: Fix race with changing page during offlining
Date: Thu, 26 Jun 2014 11:22:52 -0700
Message-Id: <1403806972-14267-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, tony.luck@intel.com, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, dave.hansen@linux.intel.com

From: Andi Kleen <ak@linux.intel.com>

While running the mcelog test suite on 3.14 I hit the following VM_BUG_ON:

soft_offline: 0x56d4: unknown non LRU page type 3ffff800008000
page:ffffea000015b400 count:3 mapcount:2097169 mapping:          (null) index:0xffff8800056d7000
page flags: 0x3ffff800004081(locked|slab|head)
------------[ cut here ]------------
kernel BUG at mm/rmap.c:1495!

I think what happened is that a LRU page turned into a slab page in parallel
with offlining. memory_failure initially tests for this case, but doesn't
retest later after the page has been locked.

This patch fixes this race. It also check for the case that the page
changed compound pages.

Unfortunately since it's a race I wasn't able to reproduce later,
so the specific case is not tested.

Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: dave.hansen@linux.intel.com
Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 mm/memory-failure.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 90002ea..e277726a 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1143,6 +1143,22 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 	lock_page(hpage);
 
 	/*
+	 * The page could have turned into a non LRU page or
+	 * changed compound pages during the locking.
+	 * If this happens just bail out.
+	 */
+	if (compound_head(p) != hpage) {
+		action_result(pfn, "different compound page after locking", IGNORED);
+		res = -EBUSY;
+		goto out;
+	}
+	if (!PageLRU(hpage)) {
+		action_result(pfn, "non LRU after locking", IGNORED);
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
