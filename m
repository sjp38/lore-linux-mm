Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f179.google.com (mail-yk0-f179.google.com [209.85.160.179])
	by kanga.kvack.org (Postfix) with ESMTP id 88A6E6B0032
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 20:16:41 -0500 (EST)
Received: by mail-yk0-f179.google.com with SMTP id 19so8345628ykq.10
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 17:16:41 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u10si1234088yhg.214.2015.01.15.17.16.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jan 2015 17:16:40 -0800 (PST)
Date: Thu, 15 Jan 2015 17:16:27 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 2/5] mm/compaction: enhance tracepoint output for
 compaction begin/end
Message-Id: <20150115171627.91b51c2e.akpm@linux-foundation.org>
In-Reply-To: <1421307673-24084-2-git-send-email-iamjoonsoo.kim@lge.com>
References: <1421307673-24084-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1421307673-24084-2-git-send-email-iamjoonsoo.kim@lge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 15 Jan 2015 16:41:10 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:

> We now have tracepoint for begin event of compaction and it prints
> start position of both scanners, but, tracepoint for end event of
> compaction doesn't print finish position of both scanners. It'd be
> also useful to know finish position of both scanners so this patch
> add it. It will help to find odd behavior or problem on compaction
> internal logic.
> 
> And, mode is added to both begin/end tracepoint output, since
> according to mode, compaction behavior is quite different.
> 
> And, lastly, status format is changed to string rather than
> status number for readability.
> 
> ...
>
> +	TP_printk("zone_start=0x%lx migrate_pfn=0x%lx free_pfn=0x%lx zone_end=0x%lx, mode=%s status=%s",
> +		__entry->zone_start,
> +		__entry->migrate_pfn,
> +		__entry->free_pfn,
> +		__entry->zone_end,
> +		__entry->sync ? "sync" : "async",
> +		compaction_status_string[__entry->status])
>  );
>  
>  #endif /* _TRACE_COMPACTION_H */
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 546e571..2d86a20 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -19,6 +19,14 @@
>  #include "internal.h"
>  
>  #ifdef CONFIG_COMPACTION
> +char *compaction_status_string[] = {
> +	"deferred",
> +	"skipped",
> +	"continue",
> +	"partial",
> +	"complete",
> +};

compaction_status_string[] is unreferenced if tracing is disabled -
more ifdeffery is needed?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
