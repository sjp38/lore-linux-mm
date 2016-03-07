Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id A5C0C6B0256
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 07:59:16 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id p65so69522824wmp.0
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 04:59:16 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y23si14042655wmd.54.2016.03.07.04.59.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 07 Mar 2016 04:59:15 -0800 (PST)
Subject: Re: Suspicious error for CMA stress test
References: <56D6F008.1050600@huawei.com> <56D79284.3030009@redhat.com>
 <CAAmzW4PUwoVF+F-BpOZUHhH6YHp_Z8VkiUjdBq85vK6AWVkyPg@mail.gmail.com>
 <56D832BD.5080305@huawei.com> <20160304020232.GA12036@js1304-P5Q-DELUXE>
 <20160304043232.GC12036@js1304-P5Q-DELUXE> <56D92595.60709@huawei.com>
 <20160304063807.GA13317@js1304-P5Q-DELUXE> <56D93ABE.9070406@huawei.com>
 <20160307043442.GB24602@js1304-P5Q-DELUXE>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56DD7B20.1020508@suse.cz>
Date: Mon, 7 Mar 2016 13:59:12 +0100
MIME-Version: 1.0
In-Reply-To: <20160307043442.GB24602@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Hanjun Guo <guohanjun@huawei.com>
Cc: Laura Abbott <labbott@redhat.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Laura Abbott <lauraa@codeaurora.org>, qiuxishi <qiuxishi@huawei.com>, Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Arnd Bergmann <arnd@arndb.de>, "thunder.leizhen@huawei.com" <thunder.leizhen@huawei.com>, dingtinahong <dingtianhong@huawei.com>, chenjie6@huawei.com, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 03/07/2016 05:34 AM, Joonsoo Kim wrote:
> On Fri, Mar 04, 2016 at 03:35:26PM +0800, Hanjun Guo wrote:
>>> Sad to hear that.
>>>
>>> Could you tell me your system's MAX_ORDER and pageblock_order?
>>>
>>
>> MAX_ORDER is 11, pageblock_order is 9, thanks for your help!

I thought that CMA regions/operations (and isolation IIRC?) were 
supposed to be MAX_ORDER aligned exactly to prevent needing these extra 
checks for buddy merging. So what's wrong?

> Hmm... that's same with me.
>
> Below is similar fix that prevents buddy merging when one of buddy's
> migrate type, but, not both, is MIGRATE_ISOLATE. In fact, I have
> no idea why previous fix (more correct fix) doesn't work for you.
> (It works for me.) But, maybe there is a bug on the fix
> so I make new one which is more general form. Please test it.
>
> Thanks.
>
> ---------->8-------------
>  From dd41e348572948d70b935fc24f82c096ff0fb417 Mon Sep 17 00:00:00 2001
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Date: Fri, 4 Mar 2016 13:28:17 +0900
> Subject: [PATCH] mm/cma: fix race
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>   mm/page_alloc.c | 33 +++++++++++++++++++--------------
>   1 file changed, 19 insertions(+), 14 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index c6c38ed..d80d071 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -620,8 +620,8 @@ static inline void rmv_page_order(struct page *page)
>    *
>    * For recording page's order, we use page_private(page).
>    */
> -static inline int page_is_buddy(struct page *page, struct page *buddy,
> -                                                       unsigned int order)
> +static inline int page_is_buddy(struct zone *zone, struct page *page,
> +                               struct page *buddy, unsigned int order)
>   {
>          if (!pfn_valid_within(page_to_pfn(buddy)))
>                  return 0;
> @@ -644,6 +644,20 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
>                  if (page_zone_id(page) != page_zone_id(buddy))
>                          return 0;
>
> +               if (IS_ENABLED(CONFIG_CMA) &&
> +                       unlikely(has_isolate_pageblock(zone)) &&
> +                       unlikely(order >= pageblock_order)) {
> +                       int page_mt, buddy_mt;
> +
> +                       page_mt = get_pageblock_migratetype(page);
> +                       buddy_mt = get_pageblock_migratetype(buddy);
> +
> +                       if (page_mt != buddy_mt &&
> +                               (is_migrate_isolate(page_mt) ||
> +                               is_migrate_isolate(buddy_mt)))
> +                               return 0;
> +               }
> +
>                  VM_BUG_ON_PAGE(page_count(buddy) != 0, buddy);
>
>                  return 1;
> @@ -691,17 +705,8 @@ static inline void __free_one_page(struct page *page,
>          VM_BUG_ON_PAGE(page->flags & PAGE_FLAGS_CHECK_AT_PREP, page);
>
>          VM_BUG_ON(migratetype == -1);
> -       if (is_migrate_isolate(migratetype)) {
> -               /*
> -                * We restrict max order of merging to prevent merge
> -                * between freepages on isolate pageblock and normal
> -                * pageblock. Without this, pageblock isolation
> -                * could cause incorrect freepage accounting.
> -                */
> -               max_order = min_t(unsigned int, MAX_ORDER, pageblock_order + 1);
> -       } else {
> +       if (!is_migrate_isolate(migratetype))
>                  __mod_zone_freepage_state(zone, 1 << order, migratetype);
> -       }
>
>          page_idx = pfn & ((1 << max_order) - 1);
>
> @@ -711,7 +716,7 @@ static inline void __free_one_page(struct page *page,
>          while (order < max_order - 1) {
>                  buddy_idx = __find_buddy_index(page_idx, order);
>                  buddy = page + (buddy_idx - page_idx);
> -               if (!page_is_buddy(page, buddy, order))
> +               if (!page_is_buddy(zone, page, buddy, order))
>                          break;
>                  /*
>                   * Our buddy is free or it is CONFIG_DEBUG_PAGEALLOC guard page,
> @@ -745,7 +750,7 @@ static inline void __free_one_page(struct page *page,
>                  higher_page = page + (combined_idx - page_idx);
>                  buddy_idx = __find_buddy_index(combined_idx, order + 1);
>                  higher_buddy = higher_page + (buddy_idx - combined_idx);
> -               if (page_is_buddy(higher_page, higher_buddy, order + 1)) {
> +               if (page_is_buddy(zone, higher_page, higher_buddy, order + 1)) {
>                          list_add_tail(&page->lru,
>                                  &zone->free_area[order].free_list[migratetype]);
>                          goto out;
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
