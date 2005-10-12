Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j9CGi3m4003159
	for <linux-mm@kvack.org>; Wed, 12 Oct 2005 12:44:03 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j9CGi2hU114606
	for <linux-mm@kvack.org>; Wed, 12 Oct 2005 12:44:03 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j9CGi2RC009349
	for <linux-mm@kvack.org>; Wed, 12 Oct 2005 12:44:02 -0400
Date: Wed, 12 Oct 2005 09:43:54 -0700
From: mike kravetz <kravetz@us.ibm.com>
Subject: Re: [PATCH 5/8] Fragmentation Avoidance V17: 005_fallback
Message-ID: <20051012164353.GA9425@w-mikek2.ibm.com>
References: <20051011151221.16178.67130.sendpatchset@skynet.csn.ul.ie> <20051011151246.16178.40148.sendpatchset@skynet.csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20051011151246.16178.40148.sendpatchset@skynet.csn.ul.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: akpm@osdl.org, jschopp@austin.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Tue, Oct 11, 2005 at 04:12:47PM +0100, Mel Gorman wrote:
> This patch implements fallback logic. In the event there is no 2^(MAX_ORDER-1)
> blocks of pages left, this will help the system decide what list to use. The
> highlights of the patch are;
> 
> o Define a RCLM_FALLBACK type for fallbacks
> o Use a percentage of each zone for fallbacks. When a reserved pool of pages
>   is depleted, it will try and use RCLM_FALLBACK before using anything else.
>   This greatly reduces the amount of fallbacks causing fragmentation without
>   needing complex balancing algorithms

I'm having a little trouble seeing how adding a new type (RCLM_FALLBACK)
helps.  Seems to me that pages put into the RCLM_FALLBACK area would have
gone to the global free list and available to anyone.  I must be missing
something here.

> +int fallback_allocs[RCLM_TYPES][RCLM_TYPES+1] = {
> +	{RCLM_NORCLM,	RCLM_FALLBACK, RCLM_KERN,   RCLM_USER, RCLM_TYPES},
> +	{RCLM_KERN,     RCLM_FALLBACK, RCLM_NORCLM, RCLM_USER, RCLM_TYPES},
> +	{RCLM_USER,     RCLM_FALLBACK, RCLM_NORCLM, RCLM_KERN, RCLM_TYPES},
> +	{RCLM_FALLBACK, RCLM_NORCLM,   RCLM_KERN,   RCLM_USER, RCLM_TYPES}

Do you really need that last line?  Can an allocation of type RCLM_FALLBACK
realy be made?

-- 
Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
