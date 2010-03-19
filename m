Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 66F3B6B004D
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 02:21:36 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2J6LWfO007249
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 19 Mar 2010 15:21:33 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BFC2545DE4F
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 15:21:32 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9E55045DE5D
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 15:21:32 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7D7AA1DB803F
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 15:21:32 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0DAB11DB8041
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 15:21:32 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 10/11] Direct compact when a high-order allocation fails
In-Reply-To: <1268412087-13536-11-git-send-email-mel@csn.ul.ie>
References: <1268412087-13536-1-git-send-email-mel@csn.ul.ie> <1268412087-13536-11-git-send-email-mel@csn.ul.ie>
Message-Id: <20100319152105.8772.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 19 Mar 2010 15:21:31 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> @@ -1765,6 +1766,31 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
>  
>  	cond_resched();
>  
> +	/* Try memory compaction for high-order allocations before reclaim */
> +	if (order) {
> +		*did_some_progress = try_to_compact_pages(zonelist,
> +						order, gfp_mask, nodemask);
> +		if (*did_some_progress != COMPACT_INCOMPLETE) {
> +			page = get_page_from_freelist(gfp_mask, nodemask,
> +					order, zonelist, high_zoneidx,
> +					alloc_flags, preferred_zone,
> +					migratetype);
> +			if (page) {
> +				__count_vm_event(COMPACTSUCCESS);
> +				return page;
> +			}
> +
> +			/*
> +			 * It's bad if compaction run occurs and fails.
> +			 * The most likely reason is that pages exist,
> +			 * but not enough to satisfy watermarks.
> +			 */
> +			count_vm_event(COMPACTFAIL);
> +
> +			cond_resched();
> +		}
> +	}
> +

Hmm..Hmmm...........

Today, I've reviewed this patch and [11/11] carefully twice. but It is harder to ack.

This patch seems to assume page compaction is faster than direct
reclaim. but it often doesn't, because dropping useless page cache is very
lightweight operation, but page compaction makes a lot of memcpy (i.e. cpu cache
pollution). IOW this patch is focusing to hugepage allocation very aggressively, but
it seems not enough care to reduce typical workload damage.


At first, I would like to clarify current reclaim corner case and how vmscan should do at this mail.

Now we have Lumpy reclaim. It is very excellent solution for externa fragmentation.
but unfortunately it have lots corner case.

Viewpoint 1. Unnecessary IO

isolate_pages() for lumpy reclaim frequently grab very young page. it is often
still dirty. then, pageout() is called much.

Unfortunately, page size grained io is _very_ inefficient. it can makes lots disk
seek and kill disk io bandwidth.


Viewpoint 2. Unevictable pages 

isolate_pages() for lumpy reclaim can pick up unevictable page. it is obviously
undroppable. so if the zone have plenty mlocked pages (it is not rare case on
server use case), lumpy reclaim can become very useless.


Viewpoint 3. GFP_ATOMIC allocation failure

Obviously lumpy reclaim can't help GFP_ATOMIC issue.


Viewpoint 4. reclaim latency

reclaim latency directly affect page allocation latency. so if lumpy reclaim with
much pageout io is slow (often it is), it affect page allocation latency and can
reduce end user experience.


I really hope that auto page migration help to solve above issue. but sadly this 
patch seems doesn't.

Honestly, I think this patch was very impressive and useful at 2-3 years ago.
because 1) we didn't have lumpy reclaim 2) we didn't have sane reclaim bail out.
then, old vmscan is very heavyweight and inefficient operation for high order reclaim.
therefore the downside of adding this page migration is hidden relatively. but...

We have to make an effort to reduce reclaim latency, not adding new latency source.
Instead, I would recommend tightly integrate page-compaction and lumpy reclaim.
I mean 1) reusing lumpy reclaim's neighbor pfn page pickking up logic 2) do page
migration instead pageout when the page is some condition (example active or dirty
or referenced or swapbacked).

This patch seems shoot me! /me die. R.I.P. ;-)


btw please don't use 'hugeadm --set-recommended-min_free_kbytes' at testing.
    To evaluate a case of free memory starvation is very important for this patch
    series, I think. I slightly doubt this patch might invoke useless compaction
    in such case.



At bottom line, the explict compaction via /proc can be merged soon, I think.
but this auto compaction logic seems need more discussion.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
