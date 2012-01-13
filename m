Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id A3EFE6B004F
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 05:49:03 -0500 (EST)
Date: Fri, 13 Jan 2012 10:48:56 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v2] mm/compaction : do optimazition when the migration
 scanner gets no page
Message-ID: <20120113104856.GQ4118@suse.de>
References: <1326347222-9980-1-git-send-email-b32955@freescale.com>
 <20120112080311.GA30634@barrios-desktop.redhat.com>
 <20120112114835.GI4118@suse.de>
 <20120113005026.GA2614@barrios-desktop.redhat.com>
 <4F0F987E.1080001@freescale.com>
 <20120113031221.GA6473@barrios-desktop>
 <4F0FA593.6010903@freescale.com>
 <20120113035037.GA10924@barrios-desktop.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120113035037.GA10924@barrios-desktop.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Huang Shijie <b32955@freescale.com>, akpm@linux-foundation.org, linux-mm@kvack.org

On Fri, Jan 13, 2012 at 12:50:37PM +0900, Minchan Kim wrote:
> 
> Okay. If you want it really, How about this?
> Why I insist on is I don't want to change ISOLATE_NONE's semantic.
> It's very clear and readable.
> We should change code itself instead of semantic of ISOLATE_NONE.
> 
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -376,7 +376,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
>  
>         trace_mm_compaction_isolate_migratepages(nr_scanned, nr_isolated);
>  
> -       return ISOLATE_SUCCESS;
> +       return cc->nr_migratepages ? ISOLATE_SUCCESS : ISOLATE_NONE;
>  }
>  
>  /*
> @@ -547,6 +547,12 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
>                         ret = COMPACT_PARTIAL;
>                         goto out;
>                 case ISOLATE_NONE:
> +                       /*
> +                        * If we can't isolate pages at all, we want to
> +                        * trace, still.
> +                        */
> +                       count_vm_event(COMPACTBLOCKS);
> +                       trace_mm_compaction_migratepages(0, 0);
>                         continue;
>                 case ISOLATE_SUCCESS:
>                         ;
> 

This will increment COMPACTBLOCKS and trigger the tracepoint even
when no scanning took place. It only happens with the migration and free
scanner meet so once per full compaction cycle which should be a rare
case. That should be fine.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
