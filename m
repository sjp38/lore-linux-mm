Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id DDF406B00BE
	for <linux-mm@kvack.org>; Wed, 16 Jul 2014 12:29:00 -0400 (EDT)
Received: by mail-we0-f182.google.com with SMTP id k48so22335wev.27
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 09:28:59 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id n2si21283228wic.30.2014.07.16.09.28.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 16 Jul 2014 09:28:58 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: memcontrol: use page lists for uncharge batching fix - hugetlb page->lru
Date: Wed, 16 Jul 2014 12:28:53 -0400
Message-Id: <1405528133-3054-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Naoya-san reports that page->lru of hugetlb pages gets corrupted when
they hit the uncharge path from put_page().

Add a preliminary check for whether the page is even a valid memcg
page before messing with it's ->lru list.

Reported-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b2f924359e79..0eb1eaa2f1ff 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -6606,9 +6606,16 @@ static void uncharge_list(struct list_head *page_list)
  */
 void mem_cgroup_uncharge(struct page *page)
 {
+	struct page_cgroup *pc;
+
 	if (mem_cgroup_disabled())
 		return;
 
+	/* Don't touch page->lru of any random page, pre-check: */
+	pc = lookup_page_cgroup(page);
+	if (!PageCgroupUsed(pc))
+		return;
+
 	INIT_LIST_HEAD(&page->lru);
 	uncharge_list(&page->lru);
 }
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
