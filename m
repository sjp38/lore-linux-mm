Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 76FC06B0062
	for <linux-mm@kvack.org>; Tue,  3 Jun 2014 02:43:25 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id p10so4271702pdj.21
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 23:43:25 -0700 (PDT)
Received: from cnbjrel01.sonyericsson.com (cnbjrel01.sonyericsson.com. [219.141.167.165])
        by mx.google.com with ESMTPS id da3si18812716pbc.123.2014.06.02.23.43.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Jun 2014 23:43:24 -0700 (PDT)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Tue, 3 Jun 2014 14:43:13 +0800
Subject: RE: MIGRATE_RESERVE  pages in show_mem function problems
Message-ID: <35FD53F367049845BC99AC72306C23D1029A27656A2C@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D1029A27656A08@CNBJMBX05.corpusers.net>
 <53889CC6.1060907@suse.cz>
In-Reply-To: <53889CC6.1060907@suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Vlastimil Babka' <vbabka@suse.cz>
Cc: "'akpm@linux-foundation.org'" <akpm@linux-foundation.org>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'cody@linux.vnet.ibm.com'" <cody@linux.vnet.ibm.com>, "'linux-arch-owner@vger.kernel.org'" <linux-arch-owner@vger.kernel.org>, 'Will Deacon' <will.deacon@arm.com>, "'hannes@cmpxchg.org'" <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Hi=20

I see,
Your patch should be ok to fix this problem,
Could I know if this patch will be merged into kernel mainline branch?

Thanks

-----Original Message-----
From: Vlastimil Babka [mailto:vbabka@suse.cz]=20
Sent: Friday, May 30, 2014 10:59 PM
To: Wang, Yalin
Cc: 'akpm@linux-foundation.org'; 'linux-mm@kvack.org'; 'linux-kernel@vger.k=
ernel.org'; 'cody@linux.vnet.ibm.com'; 'linux-arch-owner@vger.kernel.org'; =
'Will Deacon'; 'hannes@cmpxchg.org'; Joonsoo Kim
Subject: Re: MIGRATE_RESERVE pages in show_mem function problems

On 05/28/2014 04:24 AM, Wang, Yalin wrote:
> Hi
>
> I find the show_mem function show page MIGRATE types result is not=20
> correct for MIGRATE_RESERVE pages :
>
> Normal: 1582*4kB (UEMC) 1317*8kB (UEMC) 1020*16kB (UEMC) 450*32kB=20
> (UEMC) 206*64kB (UEMC) 40*128kB (UM) 10*256kB (UM) 10*512kB (UM)=20
> 1*1024kB (M) 0*2048kB 0*4096kB =3D 74592kB
>
> Some pages should be marked (R)  , while it is changed into=20
> MIGRATE_MOVEABLE or UNMOVEABLE in free_area list , It's not correct for d=
ebug .
> I make a patch for this:
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c index 5dba293..6ef8ebe=20
> 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1198,7 +1198,8 @@ static int rmqueue_bulk(struct zone *zone, unsigned=
 int order,
>                          list_add_tail(&page->lru, list);
>                  if (IS_ENABLED(CONFIG_CMA)) {
>                          mt =3D get_pageblock_migratetype(page);
> -                       if (!is_migrate_cma(mt) && !is_migrate_isolate(mt=
))
> +                       if (!is_migrate_cma(mt) && !is_migrate_isolate(mt=
)
> +                               && mt !=3D MIGRATE_RESERVE)
>                                  mt =3D migratetype;
>                  }
>                  set_freepage_migratetype(page, mt);
>
>
> seems work ok , I am curious is it a BUG ? or designed like this for some=
 reason ?

Hi, this is a known problem that should be fixed for the rmqueue_bulk() par=
t by this patch:
http://www.ozlabs.org/~akpm/mmotm/broken-out/mm-page_alloc-prevent-migrate_=
reserve-pages-from-being-misplaced.patch

Testing is welcome if you can reproduce it easily enough.

Note that even with the patch, MIGRATE_RESERVE pageblocks can still disappe=
ar for two reasons:

- when MAX_ORDER-1 > pageblock_order (such as x86_64), there can be a singl=
e MIGRATE_RESERVE pageblock created for a smaller zone, and get merged with=
 !MIGRATE_RESERVE buddy pageblock
- when min_free_kbytes sysctl is used, creation of new MIGRATE_RESERVE page=
blocks can race with other CPUs putting pages in their pcplists, and then f=
reeing then on a wronge free_list. If try_to_steal_freepages happens to fin=
d such misplaced page, it might remark the pageblock.

I think the second problem is extremely rare, but Joonsoo Kim confirmed the=
 first one to happen. You can check the -mm archives for threads around the=
 patch above.

Vlastimil

> Thanks
>
>
> <6>[  250.751554] lowmem_reserve[]: 0 0 0 <6>[  250.751606] Normal:=20
> 1582*4kB (UEMC) 1317*8kB (UEMC) 1020*16kB (UEMC) 450*32kB (UEMC)=20
> 206*64kB (UEMC) 40*128kB (UM) 10*256kB (UM) 10*512kB (UM) 1*1024kB (M)=20
> 0*2048kB 0*4096kB =3D 74592kB <6>[  250.751848] HighMem: 167*4kB (UC)=20
> 3*8kB (U) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB=20
> 0*2048kB 0*4096kB =3D 692kB <6>[  250.752020] 62596 total pagecache=20
> pages <6>[  250.752046] 0 pages in swap cache <6>[  250.752074] Swap=20
> cache stats: add 0, delete 0, find 0/0
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
> To unsubscribe, send a message with 'unsubscribe linux-mm' in the body=20
> to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dilto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
