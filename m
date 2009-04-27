Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 68DC96B00C6
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 16:48:10 -0400 (EDT)
Received: from zps77.corp.google.com (zps77.corp.google.com [172.25.146.77])
	by smtp-out.google.com with ESMTP id n3RKmoJl031759
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 21:48:51 +0100
Received: from wa-out-1112.google.com (wafm16.prod.google.com [10.114.189.16])
	by zps77.corp.google.com with ESMTP id n3RKmmgG029173
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 13:48:49 -0700
Received: by wa-out-1112.google.com with SMTP id m16so62408waf.6
        for <linux-mm@kvack.org>; Mon, 27 Apr 2009 13:48:48 -0700 (PDT)
Date: Mon, 27 Apr 2009 13:48:47 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC] Replace the watermark-related union in struct zone with
 a watermark[] array
In-Reply-To: <20090427170054.GE912@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.0904271340320.11972@chino.kir.corp.google.com>
References: <1240408407-21848-1-git-send-email-mel@csn.ul.ie> <1240408407-21848-19-git-send-email-mel@csn.ul.ie> <alpine.DEB.2.00.0904221251350.14558@chino.kir.corp.google.com> <20090427170054.GE912@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 27 Apr 2009, Mel Gorman wrote:

> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index c1fa208..1ff59fd 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -163,6 +163,13 @@ static inline int is_unevictable_lru(enum lru_list l)
>  #endif
>  }
>  
> +enum zone_watermarks {
> +	WMARK_MIN,
> +	WMARK_LOW,
> +	WMARK_HIGH,
> +	NR_WMARK
> +};
> +
>  struct per_cpu_pages {
>  	int count;		/* number of pages in the list */
>  	int high;		/* high watermark, emptying needed */
> @@ -275,12 +282,9 @@ struct zone_reclaim_stat {
>  
>  struct zone {
>  	/* Fields commonly accessed by the page allocator */
> -	union {
> -		struct {
> -			unsigned long	pages_min, pages_low, pages_high;
> -		};
> -		unsigned long pages_mark[3];
> -	};
> +
> +	/* zone watermarks, indexed with WMARK_LOW, WMARK_MIN and WMARK_HIGH */
> +	unsigned long watermark[NR_WMARK];
>  
>  	/*
>  	 * We don't know if the memory that we're going to allocate will be freeable

I thought the suggestion was for something like

	#define zone_wmark_min(z)	(z->pages_mark[WMARK_MIN])
	...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
