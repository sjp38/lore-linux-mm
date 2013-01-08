Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 6D2EC6B004D
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 22:16:32 -0500 (EST)
Received: by mail-pb0-f44.google.com with SMTP id uo1so11072470pbc.17
        for <linux-mm@kvack.org>; Mon, 07 Jan 2013 19:16:31 -0800 (PST)
Date: Mon, 7 Jan 2013 19:16:29 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: compaction: fix echo 1 > compact_memory return error
 issue
In-Reply-To: <20130107133354.03f2ba80.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1301071916140.18525@chino.kir.corp.google.com>
References: <1357458273-28558-1-git-send-email-r64343@freescale.com> <20130107135721.GD3885@suse.de> <20130107133354.03f2ba80.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Jason Liu <r64343@freescale.com>, linux-kernel@vger.kernel.org, riel@redhat.com, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org

On Mon, 7 Jan 2013, Andrew Morton wrote:

> --- a/mm/compaction.c~mm-compaction-fix-echo-1-compact_memory-return-error-issue-fix
> +++ a/mm/compaction.c
> @@ -1150,7 +1150,7 @@ unsigned long try_to_compact_pages(struc
>  
>  
>  /* Compact all zones within a node */
> -static int __compact_pgdat(pg_data_t *pgdat, struct compact_control *cc)
> +static void __compact_pgdat(pg_data_t *pgdat, struct compact_control *cc)
>  {
>  	int zoneid;
>  	struct zone *zone;
> @@ -1183,11 +1183,9 @@ static int __compact_pgdat(pg_data_t *pg
>  		VM_BUG_ON(!list_empty(&cc->freepages));
>  		VM_BUG_ON(!list_empty(&cc->migratepages));
>  	}
> -
> -	return 0;
>  }
>  
> -int compact_pgdat(pg_data_t *pgdat, int order)
> +void compact_pgdat(pg_data_t *pgdat, int order)
>  {
>  	struct compact_control cc = {
>  		.order = order,
> @@ -1195,10 +1193,10 @@ int compact_pgdat(pg_data_t *pgdat, int 
>  		.page = NULL,
>  	};
>  
> -	return __compact_pgdat(pgdat, &cc);
> +	__compact_pgdat(pgdat, &cc);
>  }
>  
> -static int compact_node(int nid)
> +static void compact_node(int nid)
>  {
>  	struct compact_control cc = {
>  		.order = -1,
> @@ -1206,7 +1204,7 @@ static int compact_node(int nid)
>  		.page = NULL,
>  	};
>  
> -	return __compact_pgdat(NODE_DATA(nid), &cc);
> +	__compact_pgdat(NODE_DATA(nid), &cc);
>  }
>  
>  /* Compact all nodes in the system */
> diff -puN include/linux/compaction.h~mm-compaction-fix-echo-1-compact_memory-return-error-issue-fix include/linux/compaction.h
> --- a/include/linux/compaction.h~mm-compaction-fix-echo-1-compact_memory-return-error-issue-fix
> +++ a/include/linux/compaction.h
> @@ -23,7 +23,7 @@ extern int fragmentation_index(struct zo
>  extern unsigned long try_to_compact_pages(struct zonelist *zonelist,
>  			int order, gfp_t gfp_mask, nodemask_t *mask,
>  			bool sync, bool *contended, struct page **page);
> -extern int compact_pgdat(pg_data_t *pgdat, int order);
> +extern void compact_pgdat(pg_data_t *pgdat, int order);
>  extern void reset_isolation_suitable(pg_data_t *pgdat);
>  extern unsigned long compaction_suitable(struct zone *zone, int order);
>  
> @@ -80,9 +80,8 @@ static inline unsigned long try_to_compa
>  	return COMPACT_CONTINUE;
>  }
>  
> -static inline int compact_pgdat(pg_data_t *pgdat, int order)
> +static inline void compact_pgdat(pg_data_t *pgdat, int order)
>  {
> -	return COMPACT_CONTINUE;
>  }
>  
>  static inline void reset_isolation_suitable(pg_data_t *pgdat)

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
