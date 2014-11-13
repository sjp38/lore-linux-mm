Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f50.google.com (mail-yh0-f50.google.com [209.85.213.50])
	by kanga.kvack.org (Postfix) with ESMTP id DEE7B6B00E0
	for <linux-mm@kvack.org>; Thu, 13 Nov 2014 14:25:32 -0500 (EST)
Received: by mail-yh0-f50.google.com with SMTP id 29so7497277yhl.37
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 11:25:32 -0800 (PST)
Received: from mail-yk0-x236.google.com (mail-yk0-x236.google.com. [2607:f8b0:4002:c07::236])
        by mx.google.com with ESMTPS id c32si28080449yha.68.2014.11.13.11.25.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 13 Nov 2014 11:25:31 -0800 (PST)
Received: by mail-yk0-f182.google.com with SMTP id q9so2384015ykb.27
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 11:25:31 -0800 (PST)
From: Pranith Kumar <bobby.prani@gmail.com>
Subject: [PATCH 13/16] ksm: Replace smp_read_barrier_depends() with lockless_dereference()
Date: Thu, 13 Nov 2014 14:24:19 -0500
Message-Id: <1415906662-4576-14-git-send-email-bobby.prani@gmail.com>
In-Reply-To: <1415906662-4576-1-git-send-email-bobby.prani@gmail.com>
References: <1415906662-4576-1-git-send-email-bobby.prani@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, David Rientjes <rientjes@google.com>, Joerg Roedel <jroedel@suse.de>, NeilBrown <neilb@suse.de>, Sasha Levin <sasha.levin@oracle.com>, Paul McQuade <paulmcquad@gmail.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, open list <linux-kernel@vger.kernel.org>
Cc: paulmck@linux.vnet.ibm.com

Recently lockless_dereference() was added which can be used in place of
hard-coding smp_read_barrier_depends(). The following PATCH makes the change.

Signed-off-by: Pranith Kumar <bobby.prani@gmail.com>
---
 mm/ksm.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index d247efa..a67de79 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -542,15 +542,14 @@ static struct page *get_ksm_page(struct stable_node *stable_node, bool lock_it)
 	expected_mapping = (void *)stable_node +
 				(PAGE_MAPPING_ANON | PAGE_MAPPING_KSM);
 again:
-	kpfn = ACCESS_ONCE(stable_node->kpfn);
-	page = pfn_to_page(kpfn);
-
 	/*
 	 * page is computed from kpfn, so on most architectures reading
 	 * page->mapping is naturally ordered after reading node->kpfn,
 	 * but on Alpha we need to be more careful.
 	 */
-	smp_read_barrier_depends();
+	kpfn = lockless_dereference(stable_node->kpfn);
+	page = pfn_to_page(kpfn);
+
 	if (ACCESS_ONCE(page->mapping) != expected_mapping)
 		goto stale;
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
