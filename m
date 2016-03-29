Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6DC826B007E
	for <linux-mm@kvack.org>; Tue, 29 Mar 2016 10:13:38 -0400 (EDT)
Received: by mail-wm0-f51.google.com with SMTP id 127so60408133wmu.1
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 07:13:38 -0700 (PDT)
Received: from mail-wm0-x235.google.com (mail-wm0-x235.google.com. [2a00:1450:400c:c09::235])
        by mx.google.com with ESMTPS id ew3si34490324wjd.140.2016.03.29.07.13.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Mar 2016 07:13:37 -0700 (PDT)
Received: by mail-wm0-x235.google.com with SMTP id 20so28261910wmh.1
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 07:13:37 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH] mm/page_alloc: prevent merging between isolated and other pageblocks
In-Reply-To: <1458726023-27005-1-git-send-email-vbabka@suse.cz>
References: <1458726023-27005-1-git-send-email-vbabka@suse.cz>
Date: Tue, 29 Mar 2016 16:13:33 +0200
Message-ID: <xa1tzithtlrm.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Leizhen <thunder.leizhen@huawei.com>, Sasha Levin <sasha.levin@oracle.com>, qiuxishi <qiuxishi@huawei.com>, Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Arnd Bergmann <arnd@arndb.de>, dingtinahong <dingtianhong@huawei.com>, chenjie6@huawei.com, Lucas Stach <l.stach@pengutronix.de>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Hanjun Guo <guohanjun@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Laura Abbott <labbott@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Minchan Kim <minchan@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, stable@vger.kernel.org, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Wed, Mar 23 2016, Vlastimil Babka wrote:
> Hanjun Guo has reported that a CMA stress test causes broken accounting of
> CMA and free pages:
>
>> Before the test, I got:
>> -bash-4.3# cat /proc/meminfo | grep Cma
>> CmaTotal:         204800 kB
>> CmaFree:          195044 kB
>>
>>
>> After running the test:
>> -bash-4.3# cat /proc/meminfo | grep Cma
>> CmaTotal:         204800 kB
>> CmaFree:         6602584 kB
>>
>> So the freed CMA memory is more than total..
>>
>> Also the the MemFree is more than mem total:
>>
>> -bash-4.3# cat /proc/meminfo
>> MemTotal:       16342016 kB
>> MemFree:        22367268 kB
>> MemAvailable:   22370528 kB
>
> Laura Abbott has confirmed the issue and suspected the freepage accounting
> rewrite around 3.18/4.0 by Joonsoo Kim. Joonsoo had a theory that this is
> caused by unexpected merging between MIGRATE_ISOLATE and MIGRATE_CMA
> pageblocks:
>
>> CMA isolates MAX_ORDER aligned blocks, but, during the process,
>> partialy isolated block exists. If MAX_ORDER is 11 and
>> pageblock_order is 9, two pageblocks make up MAX_ORDER
>> aligned block and I can think following scenario because pageblock
>> (un)isolation would be done one by one.
>>
>> (each character means one pageblock. 'C', 'I' means MIGRATE_CMA,
>> MIGRATE_ISOLATE, respectively.
>>
>> CC -> IC -> II (Isolation)
>> II -> CI -> CC (Un-isolation)
>>
>> If some pages are freed at this intermediate state such as IC or CI,
>> that page could be merged to the other page that is resident on
>> different type of pageblock and it will cause wrong freepage count.
>
> This was supposed to be prevented by CMA operating on MAX_ORDER blocks, b=
ut
> since it doesn't hold the zone->lock between pageblocks, a race window do=
es
> exist.
>
> It's also likely that unexpected merging can occur between MIGRATE_ISOLATE
> and non-CMA pageblocks. This should be prevented in __free_one_page() sin=
ce
> commit 3c605096d315 ("mm/page_alloc: restrict max order of merging on iso=
lated
> pageblock"). However, we only check the migratetype of the pageblock where
> buddy merging has been initiated, not the migratetype of the buddy pagebl=
ock
> (or group of pageblocks) which can be MIGRATE_ISOLATE.
>
> Joonsoo has suggested checking for buddy migratetype as part of
> page_is_buddy(), but that would add extra checks in allocator hotpath and
> bloat-o-meter has shown significant code bloat (the function is inline).
>
> This patch reduces the bloat at some expense of more complicated code. The
> buddy-merging while-loop in __free_one_page() is initially bounded to
> pageblock_border and without any migratetype checks. The checks are placed
> outside, bumping the max_order if merging is allowed, and returning to the
> while-loop with a statement which can't be possibly considered harmful.
>
> This fixes the accounting bug and also removes the arguably weird state i=
n the
> original commit 3c605096d315 where buddies could be left unmerged.
>
> Fixes: 3c605096d315 ("mm/page_alloc: restrict max order of merging on iso=
lated pageblock")
> Link: https://lkml.org/lkml/2016/3/2/280
> Reported-by: Hanjun Guo <guohanjun@huawei.com>
> Debugged-by: Laura Abbott <labbott@redhat.com>
> Debugged-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: "Kirill A. Shutemov" <kirill@shutemov.name>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> Cc: <stable@vger.kernel.org> # v3.18+
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

I wonder if with this change,

	ret =3D start_isolate_page_range(pfn_max_align_down(start),
				       pfn_max_align_up(end), migratetype,
				       false);

in alloc_contig_range could be loosen up to align to pageblocks instead
of having to use max(pageblock, max_page).  It feels that it should be
possible, but on the other hand, I=E2=80=99m not certain how buddy allocator
will behave if a max_order page spans MIGRATE_CMA and MIGRATE_ISOLATE
pageblocks.  I guess start_isolate_page_range would have to split such
pages?

> ---
>  mm/page_alloc.c | 46 +++++++++++++++++++++++++++++++++-------------
>  1 file changed, 33 insertions(+), 13 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index c46b75d14b6f..b9785af4fae2 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -683,34 +683,28 @@ static inline void __free_one_page(struct page *pag=
e,
>  	unsigned long combined_idx;
>  	unsigned long uninitialized_var(buddy_idx);
>  	struct page *buddy;
> -	unsigned int max_order =3D MAX_ORDER;
> +	unsigned int max_order;
> +
> +	max_order =3D min_t(unsigned int, MAX_ORDER, pageblock_order + 1);
>=20=20
>  	VM_BUG_ON(!zone_is_initialized(zone));
>  	VM_BUG_ON_PAGE(page->flags & PAGE_FLAGS_CHECK_AT_PREP, page);
>=20=20
>  	VM_BUG_ON(migratetype =3D=3D -1);
> -	if (is_migrate_isolate(migratetype)) {
> -		/*
> -		 * We restrict max order of merging to prevent merge
> -		 * between freepages on isolate pageblock and normal
> -		 * pageblock. Without this, pageblock isolation
> -		 * could cause incorrect freepage accounting.
> -		 */
> -		max_order =3D min_t(unsigned int, MAX_ORDER, pageblock_order + 1);
> -	} else {
> +	if (likely(!is_migrate_isolate(migratetype)))
>  		__mod_zone_freepage_state(zone, 1 << order, migratetype);
> -	}
>=20=20
> -	page_idx =3D pfn & ((1 << max_order) - 1);
> +	page_idx =3D pfn & ((1 << MAX_ORDER) - 1);
>=20=20
>  	VM_BUG_ON_PAGE(page_idx & ((1 << order) - 1), page);
>  	VM_BUG_ON_PAGE(bad_range(zone, page), page);
>=20=20
> +continue_merging:
>  	while (order < max_order - 1) {
>  		buddy_idx =3D __find_buddy_index(page_idx, order);
>  		buddy =3D page + (buddy_idx - page_idx);
>  		if (!page_is_buddy(page, buddy, order))
> -			break;
> +			goto done_merging;
>  		/*
>  		 * Our buddy is free or it is CONFIG_DEBUG_PAGEALLOC guard page,
>  		 * merge with it and move up one order.
> @@ -727,6 +721,32 @@ static inline void __free_one_page(struct page *page,
>  		page_idx =3D combined_idx;
>  		order++;
>  	}
> +	if (max_order < MAX_ORDER) {
> +		/* If we are here, it means order is >=3D pageblock_order.
> +		 * We want to prevent merge between freepages on isolate
> +		 * pageblock and normal pageblock. Without this, pageblock
> +		 * isolation could cause incorrect freepage or CMA accounting.
> +		 *
> +		 * We don't want to hit this code for the more frequent
> +		 * low-order merging.
> +		 */
> +		if (unlikely(has_isolate_pageblock(zone))) {
> +			int buddy_mt;
> +
> +			buddy_idx =3D __find_buddy_index(page_idx, order);
> +			buddy =3D page + (buddy_idx - page_idx);
> +			buddy_mt =3D get_pageblock_migratetype(buddy);
> +
> +			if (migratetype !=3D buddy_mt
> +					&& (is_migrate_isolate(migratetype) ||
> +						is_migrate_isolate(buddy_mt)))
> +				goto done_merging;
> +		}
> +		max_order++;
> +		goto continue_merging;
> +	}
> +
> +done_merging:
>  	set_page_order(page, order);
>=20=20
>  	/*
> --=20
> 2.7.3
>

--=20
Best regards
=E3=83=9F=E3=83=8F=E3=82=A6 =E2=80=9C=F0=9D=93=B6=F0=9D=93=B2=F0=9D=93=B7=
=F0=9D=93=AA86=E2=80=9D =E3=83=8A=E3=82=B6=E3=83=AC=E3=83=B4=E3=82=A4=E3=83=
=84
=C2=ABIf at first you don=E2=80=99t succeed, give up skydiving=C2=BB

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
