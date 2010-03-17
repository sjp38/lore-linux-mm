Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id A64AA6B004D
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 22:49:54 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2H2npij005075
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 17 Mar 2010 11:49:51 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1D67345DE4E
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 11:49:51 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id CCE6645DE4F
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 11:49:50 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A9CEFE08003
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 11:49:50 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 49B191DB803E
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 11:49:50 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 06/11] Export fragmentation index via /proc/extfrag_index
In-Reply-To: <1268412087-13536-7-git-send-email-mel@csn.ul.ie>
References: <1268412087-13536-1-git-send-email-mel@csn.ul.ie> <1268412087-13536-7-git-send-email-mel@csn.ul.ie>
Message-Id: <20100317114321.4C9A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 17 Mar 2010 11:49:49 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> +/*
> + * A fragmentation index only makes sense if an allocation of a requested
> + * size would fail. If that is true, the fragmentation index indicates
> + * whether external fragmentation or a lack of memory was the problem.
> + * The value can be used to determine if page reclaim or compaction
> + * should be used
> + */
> +int fragmentation_index(unsigned int order, struct contig_page_info *info)
> +{
> +	unsigned long requested = 1UL << order;
> +
> +	if (!info->free_blocks_total)
> +		return 0;
> +
> +	/* Fragmentation index only makes sense when a request would fail */
> +	if (info->free_blocks_suitable)
> +		return -1000;
> +
> +	/*
> +	 * Index is between 0 and 1 so return within 3 decimal places
> +	 *
> +	 * 0 => allocation would fail due to lack of memory
> +	 * 1 => allocation would fail due to fragmentation
> +	 */
> +	return 1000 - ( (1000+(info->free_pages * 1000 / requested)) / info->free_blocks_total);
> +}

Dumb question.

your paper (http://portal.acm.org/citation.cfm?id=1375634.1375641) says

fragmentation_index = 1 - (TotalFree/SizeRequested)/BlocksFree

but your code have extra '1000+'. Why?



Probably, I haven't understand the intention of this calculation.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
