Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id 9E1986B0254
	for <linux-mm@kvack.org>; Wed,  5 Aug 2015 04:02:41 -0400 (EDT)
Received: by qgeu79 with SMTP id u79so24431967qge.1
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 01:02:41 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id 33si4141212qgl.25.2015.08.05.01.02.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 05 Aug 2015 01:02:40 -0700 (PDT)
Message-ID: <55C1C132.2010805@huawei.com>
Date: Wed, 5 Aug 2015 15:54:26 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add the block to the tail of the list in expand()
References: <55BB4027.7080200@huawei.com> <55BC0392.2070205@intel.com> <55BECC85.7050206@huawei.com> <55BEE99E.8090901@intel.com> <55C011A6.1090003@huawei.com> <55C0CBC3.2000602@intel.com>
In-Reply-To: <55C0CBC3.2000602@intel.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, iamjoonsoo.kim@lge.com, alexander.h.duyck@redhat.com, sasha.levin@oracle.com, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2015/8/4 22:27, Dave Hansen wrote:

> On 08/03/2015 06:13 PM, Xishi Qiu wrote:
>> How did you do the experiment?
> 
> I just stuck in some counters in expand() that looked to see whether the
> list was empty or not when the page is added and then printed them out
> occasionally.
> 

Hi Dave,

I add some debug code like this, but it doesn't trigger the dump_stack().

--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -834,6 +834,12 @@ static inline void expand(struct zone *zone, struct page *page,
                        continue;
                }
 #endif
+
+         if (!list_empty(&area->free_list[migratetype])) {
+                 printk("expand(), the list is not empty\n");
+                 dump_stack();
+         }
+
                list_add(&page[size].lru, &area->free_list[migratetype]);
                area->nr_free++;
                set_page_order(&page[size], high);


> It will be interesting to see the results both on a freshly-booted
> system and one that's reached relatively steady-state and is moving
> around a minimal number of pageblocks between the different types.
> 
> In any case, the end result here needs to be some indication that the
> patch either helps ease fragmentation or helps performance.
> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
