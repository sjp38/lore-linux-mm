Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 71F1E6B0038
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 03:10:45 -0500 (EST)
Received: by padhx2 with SMTP id hx2so50165605pad.1
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 00:10:45 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id rn8si1884339pab.174.2015.11.25.00.10.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 25 Nov 2015 00:10:44 -0800 (PST)
Date: Wed, 25 Nov 2015 17:11:10 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 2/9] mm, page_owner: print symbolic migratetype of
 both page and pageblock
Message-ID: <20151125081110.GA10494@js1304-P5Q-DELUXE>
References: <1448368581-6923-1-git-send-email-vbabka@suse.cz>
 <1448368581-6923-3-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1448368581-6923-3-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>

On Tue, Nov 24, 2015 at 01:36:14PM +0100, Vlastimil Babka wrote:
> The information in /sys/kernel/debug/page_owner includes the migratetype of
> the pageblock the page belongs to. This is also checked against the page's
> migratetype (as declared by gfp_flags during its allocation), and the page is
> reported as Fallback if its migratetype differs from the pageblock's one.
> 
> This is somewhat misleading because in fact fallback allocation is not the only
> reason why these two can differ. It also doesn't direcly provide the page's
> migratetype, although it's possible to derive that from the gfp_flags.
> 
> It's arguably better to print both page and pageblock's migratetype and leave
> the interpretation to the consumer than to suggest fallback allocation as the
> only possible reason. While at it, we can print the migratetypes as string
> the same way as /proc/pagetypeinfo does, as some of the numeric values depend
> on kernel configuration. For that, this patch moves the migratetype_names
> array from #ifdef CONFIG_PROC_FS part of mm/vmstat.c to mm/page_alloc.c and
> exports it.
> 
> Example page_owner entry after the patch:
> 
> Page allocated via order 0, mask 0x2420848
> PFN 512 type Reclaimable Block 1 type Reclaimable Flags   R  LA
>  [<ffffffff81164e8a>] __alloc_pages_nodemask+0x15a/0xa30
>  [<ffffffff811ab808>] alloc_pages_current+0x88/0x120
>  [<ffffffff8115bc36>] __page_cache_alloc+0xe6/0x120
>  [<ffffffff8115c226>] pagecache_get_page+0x56/0x200
>  [<ffffffff81205892>] __getblk_slow+0xd2/0x2b0
>  [<ffffffff81205ab0>] __getblk_gfp+0x40/0x50
>  [<ffffffff81206ad7>] __breadahead+0x17/0x50
>  [<ffffffffa0437b27>] __ext4_get_inode_loc+0x397/0x3e0 [ext4]
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> ---
>  include/linux/mmzone.h |  3 +++
>  mm/page_alloc.c        | 13 +++++++++++++
>  mm/page_owner.c        |  6 +++---
>  mm/vmstat.c            | 13 -------------
>  4 files changed, 19 insertions(+), 16 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 3b6fb71..2bfad18 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -63,6 +63,9 @@ enum {
>  	MIGRATE_TYPES
>  };
>  
> +/* In mm/page_alloc.c; keep in sync also with show_migration_types() there */
> +extern char * const migratetype_names[MIGRATE_TYPES];
> +
>  #ifdef CONFIG_CMA
>  #  define is_migrate_cma(migratetype) unlikely((migratetype) == MIGRATE_CMA)
>  #else
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 35ab351..61a023a 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -229,6 +229,19 @@ static char * const zone_names[MAX_NR_ZONES] = {
>  #endif
>  };
>  
> +char * const migratetype_names[MIGRATE_TYPES] = {
> +	"Unmovable",
> +	"Movable",
> +	"Reclaimable",
> +	"HighAtomic",
> +#ifdef CONFIG_CMA
> +	"CMA",
> +#endif
> +#ifdef CONFIG_MEMORY_ISOLATION
> +	"Isolate",
> +#endif
> +};
> +
>  compound_page_dtor * const compound_page_dtors[] = {
>  	NULL,
>  	free_compound_page,
> diff --git a/mm/page_owner.c b/mm/page_owner.c
> index 983c3a1..f35826e 100644
> --- a/mm/page_owner.c
> +++ b/mm/page_owner.c
> @@ -110,11 +110,11 @@ print_page_owner(char __user *buf, size_t count, unsigned long pfn,
>  	pageblock_mt = get_pfnblock_migratetype(page, pfn);
>  	page_mt  = gfpflags_to_migratetype(page_ext->gfp_mask);
>  	ret += snprintf(kbuf + ret, count - ret,
> -			"PFN %lu Block %lu type %d %s Flags %s%s%s%s%s%s%s%s%s%s%s%s\n",
> +			"PFN %lu type %s Block %lu type %s Flags %s%s%s%s%s%s%s%s%s%s%s%s\n",

How about generalizing dump_flag_names() more and using it here?
This output is neat than dump_flag_names() but not complete.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
