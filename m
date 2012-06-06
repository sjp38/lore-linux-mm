Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 205F46B0080
	for <linux-mm@kvack.org>; Wed,  6 Jun 2012 04:15:24 -0400 (EDT)
From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [PATCH 6/7] highmem: remove ->virtual from struct page_address_map
Date: Wed, 6 Jun 2012 16:15:00 +0800
Message-Id: <1338970501-5098-6-git-send-email-laijs@cn.fujitsu.com>
In-Reply-To: <1338970501-5098-1-git-send-email-laijs@cn.fujitsu.com>
References: <1338970501-5098-1-git-send-email-laijs@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Tejun Heo <tj@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, "H. Peter Anvin" <hpa@linux.intel.com>, Ian Campbell <ian.campbell@citrix.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Lai Jiangshan <laijs@cn.fujitsu.com>

The virtual address is (void *)PKMAP_ADDR(kmap_index),

But struct page_address_map is always allocated with the same index
(in page_address_maps) as kmap index.

So the virtual address is (void *)PKMAP_ADDR(pam - page_address_maps) here,
the ->virtual is not needed.

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 mm/highmem.c |   17 ++++++-----------
 1 files changed, 6 insertions(+), 11 deletions(-)

diff --git a/mm/highmem.c b/mm/highmem.c
index bd2b9d3..6f028cb 100644
--- a/mm/highmem.c
+++ b/mm/highmem.c
@@ -309,7 +309,6 @@ EXPORT_SYMBOL(kunmap_high);
  */
 struct page_address_map {
 	struct page *page;
-	void *virtual;
 	struct list_head list;
 };
 
@@ -339,6 +338,7 @@ void *page_address(const struct page *page)
 	unsigned long flags;
 	void *ret;
 	struct page_address_slot *pas;
+	struct page_address_map *pam;
 
 	if (!PageHighMem(page))
 		return lowmem_page_address(page);
@@ -346,18 +346,14 @@ void *page_address(const struct page *page)
 	pas = page_slot(page);
 	ret = NULL;
 	spin_lock_irqsave(&pas->lock, flags);
-	if (!list_empty(&pas->lh)) {
-		struct page_address_map *pam;
-
-		list_for_each_entry(pam, &pas->lh, list) {
-			if (pam->page == page) {
-				ret = pam->virtual;
-				goto done;
-			}
+	list_for_each_entry(pam, &pas->lh, list) {
+		if (pam->page == page) {
+			ret = (void *)PKMAP_ADDR(pam - page_address_maps);
+			break;
 		}
 	}
-done:
 	spin_unlock_irqrestore(&pas->lock, flags);
+
 	return ret;
 }
 
@@ -370,7 +366,6 @@ static void set_high_page_map(struct page *page, unsigned int nr)
 	struct page_address_map *pam = &page_address_maps[nr];
 
 	pam->page = page;
-	pam->virtual = (void *)PKMAP_ADDR(nr);
 
 	spin_lock_irqsave(&pas->lock, flags);
 	list_add_tail(&pam->list, &pas->lh);
-- 
1.7.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
