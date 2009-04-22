Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id A8B7C6B00FA
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 16:06:12 -0400 (EDT)
Received: from zps37.corp.google.com (zps37.corp.google.com [172.25.146.37])
	by smtp-out.google.com with ESMTP id n3MK6BUB025115
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 13:06:12 -0700
Received: from rv-out-0708.google.com (rvfc5.prod.google.com [10.140.180.5])
	by zps37.corp.google.com with ESMTP id n3MK6AdU028471
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 13:06:10 -0700
Received: by rv-out-0708.google.com with SMTP id c5so130066rvf.14
        for <linux-mm@kvack.org>; Wed, 22 Apr 2009 13:06:10 -0700 (PDT)
Date: Wed, 22 Apr 2009 13:06:07 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 18/22] Use allocation flags as an index to the zone
 watermark
In-Reply-To: <1240408407-21848-19-git-send-email-mel@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.0904221251350.14558@chino.kir.corp.google.com>
References: <1240408407-21848-1-git-send-email-mel@csn.ul.ie> <1240408407-21848-19-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 22 Apr 2009, Mel Gorman wrote:

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index b174f2c..6030f49 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1154,10 +1154,15 @@ failed:
>  	return NULL;
>  }
>  
> -#define ALLOC_NO_WATERMARKS	0x01 /* don't check watermarks at all */
> -#define ALLOC_WMARK_MIN		0x02 /* use pages_min watermark */
> -#define ALLOC_WMARK_LOW		0x04 /* use pages_low watermark */
> -#define ALLOC_WMARK_HIGH	0x08 /* use pages_high watermark */
> +/* The WMARK bits are used as an index zone->pages_mark */
> +#define ALLOC_WMARK_MIN		0x00 /* use pages_min watermark */
> +#define ALLOC_WMARK_LOW		0x01 /* use pages_low watermark */
> +#define ALLOC_WMARK_HIGH	0x02 /* use pages_high watermark */
> +#define ALLOC_NO_WATERMARKS	0x04 /* don't check watermarks at all */
> +
> +/* Mask to get the watermark bits */
> +#define ALLOC_WMARK_MASK	(ALLOC_NO_WATERMARKS-1)
> +
>  #define ALLOC_HARDER		0x10 /* try to alloc harder */
>  #define ALLOC_HIGH		0x20 /* __GFP_HIGH set */
>  #define ALLOC_CPUSET		0x40 /* check for correct cpuset */

The watermark flags should probably be members of an anonymous enum since 
they're being used as an index into an array.  If another watermark were 
ever to be added it would require a value of 0x03, for instance.

	enum {
		ALLOC_WMARK_MIN,
		ALLOC_WMARK_LOW,
		ALLOC_WMARK_HIGH,

		ALLOC_WMARK_MASK = 0xf	/* no more than 16 possible watermarks */
	};

This eliminates ALLOC_NO_WATERMARKS and the caller that uses it would 
simply pass 0.

> @@ -1445,12 +1450,7 @@ zonelist_scan:
>  
>  		if (!(alloc_flags & ALLOC_NO_WATERMARKS)) {

This would become

	if (alloc_flags & ALLOC_WMARK_MASK)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
