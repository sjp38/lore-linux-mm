Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 23DAD6B0032
	for <linux-mm@kvack.org>; Mon, 29 Jun 2015 03:34:35 -0400 (EDT)
Received: by pdbep18 with SMTP id ep18so90311062pdb.1
        for <linux-mm@kvack.org>; Mon, 29 Jun 2015 00:34:34 -0700 (PDT)
Received: from mgwkm01.jp.fujitsu.com (mgwkm01.jp.fujitsu.com. [202.219.69.168])
        by mx.google.com with ESMTPS id h7si63086091pat.180.2015.06.29.00.34.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jun 2015 00:34:33 -0700 (PDT)
Received: from m3051.s.css.fujitsu.com (m3051.s.css.fujitsu.com [10.134.21.209])
	by kw-mxoi2.gw.nic.fujitsu.com (Postfix) with ESMTP id 72AA0AC03FC
	for <linux-mm@kvack.org>; Mon, 29 Jun 2015 16:34:30 +0900 (JST)
Message-ID: <5590F4A7.4030606@jp.fujitsu.com>
Date: Mon, 29 Jun 2015 16:32:55 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC v2 PATCH 2/8] mm: introduce MIGRATE_MIRROR to manage the
 mirrored pages
References: <558E084A.60900@huawei.com> <558E0948.2010104@huawei.com>
In-Reply-To: <558E0948.2010104@huawei.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, "Luck, Tony" <tony.luck@intel.com>, Hanjun Guo <guohanjun@huawei.com>, Xiexiuqi <xiexiuqi@huawei.com>, leon@leon.nu, Dave Hansen <dave.hansen@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2015/06/27 11:24, Xishi Qiu wrote:
> This patch introduces a new migratetype called "MIGRATE_MIRROR", it is used to
> allocate mirrored pages.
> When cat /proc/pagetypeinfo, you can see the count of free mirrored blocks.
>
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>

My fear about this approarch is that this may break something existing.

Now, when we add MIGRATE_MIRROR type, we'll hide attributes of pageblocks as
MIGRATE_UNMOVABOLE, MIGRATE_RECLAIMABLE, MIGRATE_MOVABLE.

Logically, MIRROR attribute is independent from page mobility and this overwrites
will make some information lost.

Then,

> ---
>   include/linux/mmzone.h | 9 +++++++++
>   mm/page_alloc.c        | 3 +++
>   mm/vmstat.c            | 3 +++
>   3 files changed, 15 insertions(+)
>
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 54d74f6..54e891a 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -39,6 +39,9 @@ enum {
>   	MIGRATE_UNMOVABLE,
>   	MIGRATE_RECLAIMABLE,
>   	MIGRATE_MOVABLE,
> +#ifdef CONFIG_MEMORY_MIRROR
> +	MIGRATE_MIRROR,
> +#endif

I think
         MIGRATE_MIRROR_UNMOVABLE,
         MIGRATE_MIRROR_RECLAIMABLE,
         MIGRATE_MIRROR_MOVABLE,         <== adding this may need discuss.
         MIGRATE_MIRROR_RESERVED,        <== reserved pages should be maintained per mirrored/unmirrored.

should be added with the following fallback list.

/*
  * MIRROR page range is defined by firmware at boot. The range is limited
  * and is used only for kernel memory mirroring.
  */
[MIGRATE_UNMOVABLE_MIRROR]   = {MIGRATE_RECLAIMABLE_MIRROR, MIGRATE_RESERVE}
[MIGRATE_RECLAIMABLE_MIRROR] = {MIGRATE_UNMOVABLE_MIRROR, MIGRATE_RESERVE}

Then, we'll not lose the original information of "Reclaiable Pages".

One problem here is whteher we should have MIGRATE_RESERVE_MIRROR.

If we never allow users to allocate mirrored memory, we should have MIGRATE_RESERVE_MIRROR.
But it seems to require much more code change to do that.

Creating a zone or adding an attribues to zones are another design choice.

Anyway, your patch doesn't takes care of reserved memory calculation at this point.
Please check setup_zone_migrate_reserve() That will be a problem.

Thanks,
-Kame

>   	MIGRATE_PCPTYPES,	/* the number of types on the pcp lists */
>   	MIGRATE_RESERVE = MIGRATE_PCPTYPES,
>   #ifdef CONFIG_CMA
> @@ -69,6 +72,12 @@ enum {
>   #  define is_migrate_cma(migratetype) false
>   #endif
>
> +#ifdef CONFIG_MEMORY_MIRROR
> +#  define is_migrate_mirror(migratetype) unlikely((migratetype) == MIGRATE_MIRROR)
> +#else
> +#  define is_migrate_mirror(migratetype) false
> +#endif
> +
>   #define for_each_migratetype_order(order, type) \
>   	for (order = 0; order < MAX_ORDER; order++) \
>   		for (type = 0; type < MIGRATE_TYPES; type++)
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index ebffa0e..6e4d79f 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3216,6 +3216,9 @@ static void show_migration_types(unsigned char type)
>   		[MIGRATE_UNMOVABLE]	= 'U',
>   		[MIGRATE_RECLAIMABLE]	= 'E',
>   		[MIGRATE_MOVABLE]	= 'M',
> +#ifdef CONFIG_MEMORY_MIRROR
> +		[MIGRATE_MIRROR]	= 'O',
> +#endif
>   		[MIGRATE_RESERVE]	= 'R',
>   #ifdef CONFIG_CMA
>   		[MIGRATE_CMA]		= 'C',
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 4f5cd97..d0323e0 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -901,6 +901,9 @@ static char * const migratetype_names[MIGRATE_TYPES] = {
>   	"Unmovable",
>   	"Reclaimable",
>   	"Movable",
> +#ifdef CONFIG_MEMORY_MIRROR
> +	"Mirror",
> +#endif
>   	"Reserve",
>   #ifdef CONFIG_CMA
>   	"CMA",
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
