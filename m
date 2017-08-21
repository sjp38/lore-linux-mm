Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id F011C280310
	for <linux-mm@kvack.org>; Mon, 21 Aug 2017 02:37:44 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id w14so6992814wrc.3
        for <linux-mm@kvack.org>; Sun, 20 Aug 2017 23:37:44 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f66si5254223wmd.164.2017.08.20.23.37.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 20 Aug 2017 23:37:43 -0700 (PDT)
Date: Mon, 21 Aug 2017 08:37:41 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch -mm] mm, compaction: persistently skip hugetlbfs
 pageblocks fix
Message-ID: <20170821063740.GC13724@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1708151638550.106658@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1708151639130.106658@chino.kir.corp.google.com>
 <20170818084912.GA18513@dhcp22.suse.cz>
 <alpine.DEB.2.10.1708201734390.117182@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.DEB.2.10.1708201734390.117182@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun 20-08-17 17:36:41, David Rientjes wrote:
> Fix build:
> 
> mm/compaction.c: In function a??isolate_freepages_blocka??:
> mm/compaction.c:469:4: error: implicit declaration of function a??pageblock_skip_persistenta?? [-Werror=implicit-function-declaration]
>     if (pageblock_skip_persistent(page, order)) {
>     ^
> mm/compaction.c:470:5: error: implicit declaration of function a??set_pageblock_skipa?? [-Werror=implicit-function-declaration]
>      set_pageblock_skip(page);
>      ^
> 
> CMA doesn't guarantee pageblock skip will get reset when migration and 
> freeing scanners meet, and pageblock skip is a CONFIG_COMPACTION only 
> feature, so disable it when CONFIG_COMPACTION=n.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Yes, this passes the compilation test for me.

> ---
>  include/linux/pageblock-flags.h | 11 +++++++++++
>  mm/compaction.c                 |  8 +++++++-
>  2 files changed, 18 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/pageblock-flags.h b/include/linux/pageblock-flags.h
> --- a/include/linux/pageblock-flags.h
> +++ b/include/linux/pageblock-flags.h
> @@ -96,6 +96,17 @@ void set_pfnblock_flags_mask(struct page *page,
>  #define set_pageblock_skip(page) \
>  			set_pageblock_flags_group(page, 1, PB_migrate_skip,  \
>  							PB_migrate_skip)
> +#else
> +static inline bool get_pageblock_skip(struct page *page)
> +{
> +	return false;
> +}
> +static inline void clear_pageblock_skip(struct page *page)
> +{
> +}
> +static inline void set_pageblock_skip(struct page *page)
> +{
> +}
>  #endif /* CONFIG_COMPACTION */
>  
>  #endif	/* PAGEBLOCK_FLAGS_H */
> diff --git a/mm/compaction.c b/mm/compaction.c
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -322,7 +322,13 @@ static inline bool isolation_suitable(struct compact_control *cc,
>  	return true;
>  }
>  
> -static void update_pageblock_skip(struct compact_control *cc,
> +static inline bool pageblock_skip_persistent(struct page *page,
> +					     unsigned int order)
> +{
> +	return false;
> +}
> +
> +static inline void update_pageblock_skip(struct compact_control *cc,
>  			struct page *page, unsigned long nr_isolated,
>  			bool migrate_scanner)
>  {


-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
