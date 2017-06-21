Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id D8FBF6B02F3
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 14:55:54 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id g46so33177967wrd.3
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 11:55:54 -0700 (PDT)
Received: from mail-wr0-x22e.google.com (mail-wr0-x22e.google.com. [2a00:1450:400c:c0c::22e])
        by mx.google.com with ESMTPS id l185si13904544wmb.99.2017.06.21.11.55.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 11:55:53 -0700 (PDT)
Received: by mail-wr0-x22e.google.com with SMTP id 77so147097972wrb.1
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 11:55:53 -0700 (PDT)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [PATCH] mm/page_alloc.c: eliminate unsigned confusion in __rmqueue_fallback
Date: Wed, 21 Jun 2017 20:55:28 +0200
Message-Id: <20170621185529.2265-1-linux@rasmusvillemoes.dk>
In-Reply-To: <20170621094344.GC22051@dhcp22.suse.cz>
References: <20170621094344.GC22051@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Hillf Danton <hillf.zj@alibaba-inc.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Vinayak Menon <vinmenon@codeaurora.org>, Xishi Qiu <qiuxishi@huawei.com>
Cc: Hao Lee <haolee.swjtu@gmail.com>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Since current_order starts as MAX_ORDER-1 and is then only
decremented, the second half of the loop condition seems
superfluous. However, if order is 0, we may decrement current_order
past 0, making it UINT_MAX. This is obviously too subtle ([1], [2]).

Since we need to add some comment anyway, change the two variables to
signed, making the counting-down for loop look more familiar, and
apparently also making gcc generate slightly smaller code.

[1] https://lkml.org/lkml/2016/6/20/493
[2] https://lkml.org/lkml/2017/6/19/345

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---
Michal, something like this, perhaps?

mm/page_alloc.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2302f250d6b1..e656f4da9772 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2204,19 +2204,23 @@ static bool unreserve_highatomic_pageblock(const struct alloc_context *ac,
  * list of requested migratetype, possibly along with other pages from the same
  * block, depending on fragmentation avoidance heuristics. Returns true if
  * fallback was found so that __rmqueue_smallest() can grab it.
+ *
+ * The use of signed ints for order and current_order is a deliberate
+ * deviation from the rest of this file, to make the for loop
+ * condition simpler.
  */
 static inline bool
-__rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
+__rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
 {
 	struct free_area *area;
-	unsigned int current_order;
+	int current_order;
 	struct page *page;
 	int fallback_mt;
 	bool can_steal;
 
 	/* Find the largest possible block of pages in the other list */
 	for (current_order = MAX_ORDER-1;
-				current_order >= order && current_order <= MAX_ORDER-1;
+				current_order >= order;
 				--current_order) {
 		area = &(zone->free_area[current_order]);
 		fallback_mt = find_suitable_fallback(area, current_order,
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
