Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3CFFC6B0332
	for <linux-mm@kvack.org>; Wed,  9 May 2018 03:44:02 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id k16-v6so23267935wrh.6
        for <linux-mm@kvack.org>; Wed, 09 May 2018 00:44:02 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m17-v6si95823edr.66.2018.05.09.00.44.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 09 May 2018 00:44:00 -0700 (PDT)
Date: Wed, 9 May 2018 09:43:57 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: move =?utf-8?Q?function_?=
 =?utf-8?Q?=E2=80=98is=5Fpageblock=5Fremovable=5Fnolock?= =?utf-8?B?4oCZ?=
 inside blockers
Message-ID: <20180509074357.GB32366@dhcp22.suse.cz>
References: <20180505201107.21070-1-malat@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180505201107.21070-1-malat@debian.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mathieu Malaterre <malat@debian.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Pavel Tatashin <pasha.tatashin@oracle.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat 05-05-18 22:11:06, Mathieu Malaterre wrote:
> Function a??is_pageblock_removable_nolocka?? is not used unless
> CONFIG_MEMORY_HOTREMOVE is activated. Move it in between #ifdef sentinel to
> match prototype in <linux/memory_hotplug.h>. Silence gcc warning (W=1):
> 
>   mm/page_alloc.c:7704:6: warning: no previous prototype for a??is_pageblock_removable_nolocka?? [-Wmissing-prototypes]

Could you move is_pageblock_removable_nolock to mm/memory_hotplug.c
and make it static instead? There is only one caller
is_mem_section_removable so there shouldn't be any real reason to have
it extern and add more ifdefs.
 
> Signed-off-by: Mathieu Malaterre <malat@debian.org>
> ---
>  mm/page_alloc.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 905db9d7962f..94ca579938e5 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -7701,6 +7701,7 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
>  	return false;
>  }
>  
> +#ifdef CONFIG_MEMORY_HOTREMOVE
>  bool is_pageblock_removable_nolock(struct page *page)
>  {
>  	struct zone *zone;
> @@ -7723,6 +7724,7 @@ bool is_pageblock_removable_nolock(struct page *page)
>  
>  	return !has_unmovable_pages(zone, page, 0, MIGRATE_MOVABLE, true);
>  }
> +#endif
>  
>  #if (defined(CONFIG_MEMORY_ISOLATION) && defined(CONFIG_COMPACTION)) || defined(CONFIG_CMA)
>  
> -- 
> 2.11.0
> 

-- 
Michal Hocko
SUSE Labs
