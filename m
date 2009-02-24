Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 28A1D6B00BD
	for <linux-mm@kvack.org>; Tue, 24 Feb 2009 11:53:31 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id DB25082C43F
	for <linux-mm@kvack.org>; Tue, 24 Feb 2009 11:58:08 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Z8GFwb2idKqN for <linux-mm@kvack.org>;
	Tue, 24 Feb 2009 11:58:04 -0500 (EST)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 26B3482C41E
	for <linux-mm@kvack.org>; Tue, 24 Feb 2009 11:58:04 -0500 (EST)
Date: Tue, 24 Feb 2009 11:43:29 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 04/19] Convert gfp_zone() to use a table of precalculated
 values
In-Reply-To: <1235477835-14500-5-git-send-email-mel@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0902241112310.22519@qirst.com>
References: <1235477835-14500-1-git-send-email-mel@csn.ul.ie> <1235477835-14500-5-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Tue, 24 Feb 2009, Mel Gorman wrote:

>  static inline enum zone_type gfp_zone(gfp_t flags)
>  {
> -#ifdef CONFIG_ZONE_DMA
> -	if (flags & __GFP_DMA)
> -		return ZONE_DMA;
> -#endif
> -#ifdef CONFIG_ZONE_DMA32
> -	if (flags & __GFP_DMA32)
> -		return ZONE_DMA32;
> -#endif
> -	if ((flags & (__GFP_HIGHMEM | __GFP_MOVABLE)) ==
> -			(__GFP_HIGHMEM | __GFP_MOVABLE))
> -		return ZONE_MOVABLE;
> -#ifdef CONFIG_HIGHMEM
> -	if (flags & __GFP_HIGHMEM)
> -		return ZONE_HIGHMEM;
> -#endif
> -	return ZONE_NORMAL;
> +	return gfp_zone_table[flags & GFP_ZONEMASK];
>  }

Aassume

GFP_DMA		= 0x01
GFP_DMA32	= 0x02
GFP_MOVABLE	= 0x04
GFP_HIGHMEM	= 0x08

ZONE_NORMAL	= 0
ZONE_DMA	= 1
ZONE_DMA32	= 2
ZONE_MOVABLE	= 3
ZONE_HIGHMEM	= 4

then we could implement gfp_zone simply as:

static inline enum zone_type gfp_zone(gfp_t flags)
{
	return ffs(flags & 0xf);
}

However, this would return ZONE_MOVABLE if only GFP_MOVABLE would be
set but not GFP_HIGHMEM.

If we could make sure that GFP_MOVABLE always includes GFP_HIGHMEM then
this would not be a problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
