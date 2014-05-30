Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id C50FE6B0037
	for <linux-mm@kvack.org>; Fri, 30 May 2014 10:59:24 -0400 (EDT)
Received: by mail-wi0-f173.google.com with SMTP id bs8so1256565wib.0
        for <linux-mm@kvack.org>; Fri, 30 May 2014 07:59:22 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dm4si9073147wjb.26.2014.05.30.07.59.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 30 May 2014 07:59:21 -0700 (PDT)
Message-ID: <53889CC6.1060907@suse.cz>
Date: Fri, 30 May 2014 16:59:18 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: MIGRATE_RESERVE  pages in show_mem function problems
References: <35FD53F367049845BC99AC72306C23D1029A27656A08@CNBJMBX05.corpusers.net>
In-Reply-To: <35FD53F367049845BC99AC72306C23D1029A27656A08@CNBJMBX05.corpusers.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Cc: "'akpm@linux-foundation.org'" <akpm@linux-foundation.org>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'cody@linux.vnet.ibm.com'" <cody@linux.vnet.ibm.com>, "'linux-arch-owner@vger.kernel.org'" <linux-arch-owner@vger.kernel.org>, 'Will Deacon' <will.deacon@arm.com>, "'hannes@cmpxchg.org'" <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 05/28/2014 04:24 AM, Wang, Yalin wrote:
> Hi
>
> I find the show_mem function show page MIGRATE types result is not correct for
> MIGRATE_RESERVE pages :
>
> Normal: 1582*4kB (UEMC) 1317*8kB (UEMC) 1020*16kB (UEMC) 450*32kB (UEMC) 206*64kB (UEMC) 40*128kB (UM) 10*256kB (UM) 10*512kB (UM) 1*1024kB (M) 0*2048kB 0*4096kB = 74592kB
>
> Some pages should be marked (R)  , while it is changed into MIGRATE_MOVEABLE or UNMOVEABLE in free_area list ,
> It's not correct for debug .
> I make a patch for this:
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 5dba293..6ef8ebe 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1198,7 +1198,8 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
>                          list_add_tail(&page->lru, list);
>                  if (IS_ENABLED(CONFIG_CMA)) {
>                          mt = get_pageblock_migratetype(page);
> -                       if (!is_migrate_cma(mt) && !is_migrate_isolate(mt))
> +                       if (!is_migrate_cma(mt) && !is_migrate_isolate(mt)
> +                               && mt != MIGRATE_RESERVE)
>                                  mt = migratetype;
>                  }
>                  set_freepage_migratetype(page, mt);
>
>
> seems work ok , I am curious is it a BUG ? or designed like this for some reason ?

Hi, this is a known problem that should be fixed for the rmqueue_bulk() 
part by this patch:
http://www.ozlabs.org/~akpm/mmotm/broken-out/mm-page_alloc-prevent-migrate_reserve-pages-from-being-misplaced.patch

Testing is welcome if you can reproduce it easily enough.

Note that even with the patch, MIGRATE_RESERVE pageblocks can still 
disappear for two reasons:

- when MAX_ORDER-1 > pageblock_order (such as x86_64), there can be a 
single MIGRATE_RESERVE pageblock created for a smaller zone, and get 
merged with !MIGRATE_RESERVE buddy pageblock
- when min_free_kbytes sysctl is used, creation of new MIGRATE_RESERVE 
pageblocks can race with other CPUs putting pages in their pcplists, and 
then freeing then on a wronge free_list. If try_to_steal_freepages 
happens to find such misplaced page, it might remark the pageblock.

I think the second problem is extremely rare, but Joonsoo Kim confirmed 
the first one to happen. You can check the -mm archives for threads 
around the patch above.

Vlastimil

> Thanks
>
>
> <6>[  250.751554] lowmem_reserve[]: 0 0 0
> <6>[  250.751606] Normal: 1582*4kB (UEMC) 1317*8kB (UEMC) 1020*16kB (UEMC) 450*32kB (UEMC) 206*64kB (UEMC) 40*128kB (UM) 10*256kB (UM) 10*512kB (UM) 1*1024kB (M) 0*2048kB 0*4096kB = 74592kB
> <6>[  250.751848] HighMem: 167*4kB (UC) 3*8kB (U) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 692kB
> <6>[  250.752020] 62596 total pagecache pages
> <6>[  250.752046] 0 pages in swap cache
> <6>[  250.752074] Swap cache stats: add 0, delete 0, find 0/0
>
>
>
>
> Sony Mobile Communications
> Tel: My Number +18610323092
> yalin.wang@sonymobile.com
> sonymobile.com
>
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=ilto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
