Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 403D36B0032
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 03:13:10 -0400 (EDT)
Received: by padev16 with SMTP id ev16so7962108pad.0
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 00:13:10 -0700 (PDT)
Received: from mgwym02.jp.fujitsu.com (mgwym02.jp.fujitsu.com. [211.128.242.41])
        by mx.google.com with ESMTPS id ej13si7641619pdb.143.2015.06.09.00.13.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jun 2015 00:13:09 -0700 (PDT)
Received: from m3051.s.css.fujitsu.com (m3051.s.css.fujitsu.com [10.134.21.209])
	by yt-mxauth.gw.nic.fujitsu.com (Postfix) with ESMTP id 3F45EAC0982
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 16:13:05 +0900 (JST)
Message-ID: <557691E0.5020203@jp.fujitsu.com>
Date: Tue, 09 Jun 2015 16:12:32 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 10/12] mm: add the buddy system interface
References: <55704A7E.5030507@huawei.com> <55704CC4.8040707@huawei.com>
In-Reply-To: <55704CC4.8040707@huawei.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, nao.horiguchi@gmail.com, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, "Luck, Tony" <tony.luck@intel.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2015/06/04 22:04, Xishi Qiu wrote:
> Add the buddy system interface for address range mirroring feature.
> Allocate mirrored pages in MIGRATE_MIRROR list. If there is no mirrored pages
> left, use other types pages.
>
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> ---
>   mm/page_alloc.c | 40 +++++++++++++++++++++++++++++++++++++++-
>   1 file changed, 39 insertions(+), 1 deletion(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d4d2066..0fb55288 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -599,6 +599,26 @@ static inline bool is_mirror_pfn(unsigned long pfn)
>
>   	return false;
>   }
> +
> +static inline bool change_to_mirror(gfp_t gfp_flags, int high_zoneidx)
> +{
> +	/*
> +	 * Do not alloc mirrored memory below 4G, because 0-4G is
> +	 * all mirrored by default, and the list is always empty.
> +	 */
> +	if (high_zoneidx < ZONE_NORMAL)
> +		return false;
> +
> +	/* Alloc mirrored memory for only kernel */
> +	if (gfp_flags & __GFP_MIRROR)
> +		return true;

GFP_KERNEL itself should imply mirror, I think.

> +
> +	/* Alloc mirrored memory for both user and kernel */
> +	if (sysctl_mirrorable)
> +		return true;

Reading this, I think this sysctl is not good. The user cannot know what is mirrored
because memory may not be mirrored until the sysctl is set.

Thanks,
-Kame


> +
> +	return false;
> +}
>   #endif
>
>   /*
> @@ -1796,7 +1816,10 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
>   			WARN_ON_ONCE(order > 1);
>   		}
>   		spin_lock_irqsave(&zone->lock, flags);
> -		page = __rmqueue(zone, order, migratetype);
> +		if (is_migrate_mirror(migratetype))
> +			page = __rmqueue_smallest(zone, order, migratetype);
> +		else
> +			page = __rmqueue(zone, order, migratetype);
>   		spin_unlock(&zone->lock);
>   		if (!page)
>   			goto failed;
> @@ -2928,6 +2951,11 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>   	if (IS_ENABLED(CONFIG_CMA) && ac.migratetype == MIGRATE_MOVABLE)
>   		alloc_flags |= ALLOC_CMA;
>
> +#ifdef CONFIG_MEMORY_MIRROR
> +	if (change_to_mirror(gfp_mask, ac.high_zoneidx))
> +		ac.migratetype = MIGRATE_MIRROR;
> +#endif
> +
>   retry_cpuset:
>   	cpuset_mems_cookie = read_mems_allowed_begin();
>
> @@ -2943,9 +2971,19 @@ retry_cpuset:
>
>   	/* First allocation attempt */
>   	alloc_mask = gfp_mask|__GFP_HARDWALL;
> +retry:
>   	page = get_page_from_freelist(alloc_mask, order, alloc_flags, &ac);
>   	if (unlikely(!page)) {
>   		/*
> +		 * If there is no mirrored memory, we will alloc other
> +		 * types memory.
> +		 */
> +		if (is_migrate_mirror(ac.migratetype)) {
> +			ac.migratetype = gfpflags_to_migratetype(gfp_mask);
> +			goto retry;
> +		}
> +
> +		/*
>   		 * Runtime PM, block IO and its error handling path
>   		 * can deadlock because I/O on the device might not
>   		 * complete.
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
