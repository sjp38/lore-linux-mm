Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 8662A6B0254
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 12:07:45 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id n186so27389728wmn.1
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 09:07:45 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s125si3749963wmd.74.2016.03.11.09.07.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 11 Mar 2016 09:07:44 -0800 (PST)
Subject: Re: Suspicious error for CMA stress test
References: <56D6F008.1050600@huawei.com> <56D79284.3030009@redhat.com>
 <CAAmzW4PUwoVF+F-BpOZUHhH6YHp_Z8VkiUjdBq85vK6AWVkyPg@mail.gmail.com>
 <56D832BD.5080305@huawei.com> <20160304020232.GA12036@js1304-P5Q-DELUXE>
 <20160304043232.GC12036@js1304-P5Q-DELUXE> <56D92595.60709@huawei.com>
 <20160304063807.GA13317@js1304-P5Q-DELUXE> <56D93ABE.9070406@huawei.com>
 <20160307043442.GB24602@js1304-P5Q-DELUXE> <56DD38E7.3050107@huawei.com>
 <56DDCB86.4030709@redhat.com> <56DE30CB.7020207@huawei.com>
 <56DF7B28.9060108@huawei.com>
 <CAAmzW4NDJwgq_P33Ru_X0MKXGQEnY5dr_SY1GFutPAqEUAc_rg@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56E2FB5C.1040602@suse.cz>
Date: Fri, 11 Mar 2016 18:07:40 +0100
MIME-Version: 1.0
In-Reply-To: <CAAmzW4NDJwgq_P33Ru_X0MKXGQEnY5dr_SY1GFutPAqEUAc_rg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>, "Leizhen (ThunderTown)" <thunder.leizhen@huawei.com>
Cc: Laura Abbott <labbott@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Hanjun Guo <guohanjun@huawei.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Laura Abbott <lauraa@codeaurora.org>, qiuxishi <qiuxishi@huawei.com>, Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Arnd Bergmann <arnd@arndb.de>, dingtinahong <dingtianhong@huawei.com>, chenjie6@huawei.com, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 03/11/2016 04:00 PM, Joonsoo Kim wrote:
> 2016-03-09 10:23 GMT+09:00 Leizhen (ThunderTown) <thunder.leizhen@huawei.com>:
>>
>> Hi, Joonsoo:
>>         This new patch worked well. Do you plan to upstream it in the near furture?
> 
> Of course!
> But, I should think more because it touches allocator's fastpatch and
> I'd like to detour.
> If I fail to think a better solution, I will send it as is, soon.

How about something like this? Just and idea, probably buggy (off-by-one etc.).
Should keep away cost from <pageblock_order iterations at the expense of the
relatively fewer >pageblock_order iterations.

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ff1e3cbc8956..b8005a07b2a1 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -685,21 +685,13 @@ static inline void __free_one_page(struct page *page,
 	unsigned long combined_idx;
 	unsigned long uninitialized_var(buddy_idx);
 	struct page *buddy;
-	unsigned int max_order = MAX_ORDER;
+	unsigned int max_order = pageblock_order + 1;
 
 	VM_BUG_ON(!zone_is_initialized(zone));
 	VM_BUG_ON_PAGE(page->flags & PAGE_FLAGS_CHECK_AT_PREP, page);
 
 	VM_BUG_ON(migratetype == -1);
-	if (is_migrate_isolate(migratetype)) {
-		/*
-		 * We restrict max order of merging to prevent merge
-		 * between freepages on isolate pageblock and normal
-		 * pageblock. Without this, pageblock isolation
-		 * could cause incorrect freepage accounting.
-		 */
-		max_order = min_t(unsigned int, MAX_ORDER, pageblock_order + 1);
-	} else {
+	if (likely(!is_migrate_isolate(migratetype))) {
 		__mod_zone_freepage_state(zone, 1 << order, migratetype);
 	}
 
@@ -708,11 +700,12 @@ static inline void __free_one_page(struct page *page,
 	VM_BUG_ON_PAGE(page_idx & ((1 << order) - 1), page);
 	VM_BUG_ON_PAGE(bad_range(zone, page), page);
 
+continue_merging:
 	while (order < max_order - 1) {
 		buddy_idx = __find_buddy_index(page_idx, order);
 		buddy = page + (buddy_idx - page_idx);
 		if (!page_is_buddy(page, buddy, order))
-			break;
+			goto done_merging;
 		/*
 		 * Our buddy is free or it is CONFIG_DEBUG_PAGEALLOC guard page,
 		 * merge with it and move up one order.
@@ -729,6 +722,26 @@ static inline void __free_one_page(struct page *page,
 		page_idx = combined_idx;
 		order++;
 	}
+	if (max_order < MAX_ORDER) {
+		if (IS_ENABLED(CONFIG_CMA) &&
+				unlikely(has_isolate_pageblock(zone))) {
+
+			int buddy_mt;
+
+			buddy_idx = __find_buddy_index(page_idx, order);
+			buddy = page + (buddy_idx - page_idx);
+			buddy_mt = get_pageblock_migratetype(buddy);
+
+			if (migratetype != buddy_mt &&
+					(is_migrate_isolate(migratetype) ||
+					is_migrate_isolate(buddy_mt)))
+				goto done_merging;
+		}
+		max_order++;
+		goto continue_merging;
+	}
+
+done_merging:
 	set_page_order(page, order);
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
