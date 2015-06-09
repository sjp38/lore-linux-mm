Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id E70E36B0032
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 02:55:26 -0400 (EDT)
Received: by payr10 with SMTP id r10so7661980pay.1
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 23:55:26 -0700 (PDT)
Received: from mgwym04.jp.fujitsu.com (mgwym04.jp.fujitsu.com. [211.128.242.43])
        by mx.google.com with ESMTPS id kq5si7587612pbc.36.2015.06.08.23.55.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jun 2015 23:55:26 -0700 (PDT)
Received: from m3051.s.css.fujitsu.com (m3051.s.css.fujitsu.com [10.134.21.209])
	by yt-mxoi2.gw.nic.fujitsu.com (Postfix) with ESMTP id 77D8DAC012D
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 15:55:22 +0900 (JST)
Message-ID: <55768DBD.9010203@jp.fujitsu.com>
Date: Tue, 09 Jun 2015 15:54:53 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 03/12] mm: introduce MIGRATE_MIRROR to manage the
 mirrored, pages
References: <55704A7E.5030507@huawei.com> <55704B8C.7080506@huawei.com>
In-Reply-To: <55704B8C.7080506@huawei.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, nao.horiguchi@gmail.com, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, "Luck, Tony" <tony.luck@intel.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2015/06/04 21:58, Xishi Qiu wrote:
> This patch introduces a new MIGRATE_TYPES called "MIGRATE_MIRROR", it is used
> to storage the mirrored pages list.
> When cat /proc/pagetypeinfo, you can see the count of free mirrored blocks.
>

I guess you need to add Mel to CC.

> e.g.
> euler-linux:~ # cat /proc/pagetypeinfo
> Page block order: 9
> Pages per block:  512
>
> Free pages count per migrate type at order       0      1      2      3      4      5      6      7      8      9     10
> Node    0, zone      DMA, type    Unmovable      1      1      0      0      2      1      1      0      1      0      0
> Node    0, zone      DMA, type  Reclaimable      0      0      0      0      0      0      0      0      0      0      0
> Node    0, zone      DMA, type      Movable      0      0      0      0      0      0      0      0      0      0      3
> Node    0, zone      DMA, type       Mirror      0      0      0      0      0      0      0      0      0      0      0
> Node    0, zone      DMA, type      Reserve      0      0      0      0      0      0      0      0      0      1      0
> Node    0, zone      DMA, type      Isolate      0      0      0      0      0      0      0      0      0      0      0
> Node    0, zone    DMA32, type    Unmovable      0      0      1      0      0      0      0      1      1      1      0
> Node    0, zone    DMA32, type  Reclaimable      0      0      0      0      0      0      0      0      0      0      0
> Node    0, zone    DMA32, type      Movable      1      2      6      6      6      4      5      3      3      2    738
> Node    0, zone    DMA32, type       Mirror      0      0      0      0      0      0      0      0      0      0      0
> Node    0, zone    DMA32, type      Reserve      0      0      0      0      0      0      0      0      0      0      1
> Node    0, zone    DMA32, type      Isolate      0      0      0      0      0      0      0      0      0      0      0
> Node    0, zone   Normal, type    Unmovable      0      0      0      0      0      0      0      0      0      0      0
> Node    0, zone   Normal, type  Reclaimable      0      0      0      0      0      0      0      0      0      0      0
> Node    0, zone   Normal, type      Movable      0      0      1      1      0      0      0      2      1      0   4254
> Node    0, zone   Normal, type       Mirror    148    104     63     70     26     11      2      2      1      1    973
> Node    0, zone   Normal, type      Reserve      0      0      0      0      0      0      0      0      0      0      1
> Node    0, zone   Normal, type      Isolate      0      0      0      0      0      0      0      0      0      0      0
>
> Number of blocks type     Unmovable  Reclaimable      Movable       Mirror      Reserve      Isolate
> Node 0, zone      DMA            1            0            6            0            1            0
> Node 0, zone    DMA32            2            0         1525            0            1            0
> Node 0, zone   Normal            0            0         8702         2048            2            0
> Page block order: 9
> Pages per block:  512



>
> Free pages count per migrate type at order       0      1      2      3      4      5      6      7      8      9     10
> Node    1, zone   Normal, type    Unmovable      0      0      0      0      0      0      0      0      0      0      0
> Node    1, zone   Normal, type  Reclaimable      0      0      0      0      0      0      0      0      0      0      0
> Node    1, zone   Normal, type      Movable      2      2      1      1      2      1      2      2      2      3   3996
> Node    1, zone   Normal, type       Mirror     68     94     57      6      8      1      0      0      3      1   2003
> Node    1, zone   Normal, type      Reserve      0      0      0      0      0      0      0      0      0      0      1
> Node    1, zone   Normal, type      Isolate      0      0      0      0      0      0      0      0      0      0      0
>
> Number of blocks type     Unmovable  Reclaimable      Movable       Mirror      Reserve      Isolate
> Node 1, zone   Normal            0            0         8190         4096            2            0
>
>
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> ---
>   include/linux/mmzone.h | 6 ++++++
>   mm/page_alloc.c        | 3 +++
>   mm/vmstat.c            | 3 +++
>   3 files changed, 12 insertions(+)
>
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 1fae07b..b444335 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -39,6 +39,9 @@ enum {
>   	MIGRATE_UNMOVABLE,
>   	MIGRATE_RECLAIMABLE,
>   	MIGRATE_MOVABLE,
> +#ifdef CONFIG_MEMORY_MIRROR
> +	MIGRATE_MIRROR,
> +#endif

I can't imagine how the fallback logic will work at reading this patch.
I think an update for fallback order array should be in this patch...

>   	MIGRATE_PCPTYPES,	/* the number of types on the pcp lists */
>   	MIGRATE_RESERVE = MIGRATE_PCPTYPES,
>   #ifdef CONFIG_CMA
> @@ -82,6 +85,9 @@ struct mirror_info {
>   };
>
>   extern struct mirror_info mirror_info;
> +#  define is_migrate_mirror(migratetype) unlikely((migratetype) == MIGRATE_MIRROR)
> +#else
> +#  define is_migrate_mirror(migratetype) false
>   #endif
>
>   #define for_each_migratetype_order(order, type) \
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 41a95a7..3b2ff46 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3245,6 +3245,9 @@ static void show_migration_types(unsigned char type)
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
