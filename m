Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 08F066B01AD
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 20:13:15 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5F0DCGO031521
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 15 Jun 2010 09:13:13 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id ADFAD45DE64
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 09:13:12 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8A11D45DE61
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 09:13:12 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6AF1AE08001
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 09:13:12 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 21CFD1DB803B
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 09:13:12 +0900 (JST)
Date: Tue, 15 Jun 2010 09:08:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/12] Avoid overflowing of stack during page reclaim V2
Message-Id: <20100615090833.12f69ae5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1276514273-27693-1-git-send-email-mel@csn.ul.ie>
References: <1276514273-27693-1-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 14 Jun 2010 12:17:41 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> SysBench
> ========
>                 traceonly-v2r5  stackreduce-v2r5     nodirect-v2r5
>            1 11025.01 ( 0.00%) 10249.52 (-7.57%) 10430.57 (-5.70%)
>            2  3844.63 ( 0.00%)  4988.95 (22.94%)  4038.95 ( 4.81%)
>            3  3210.23 ( 0.00%)  2918.52 (-9.99%)  3113.38 (-3.11%)
>            4  1958.91 ( 0.00%)  1987.69 ( 1.45%)  1808.37 (-8.32%)
>            5  2864.92 ( 0.00%)  3126.13 ( 8.36%)  2355.70 (-21.62%)
>            6  4831.63 ( 0.00%)  3815.67 (-26.63%)  4164.09 (-16.03%)
>            7  3788.37 ( 0.00%)  3140.39 (-20.63%)  3471.36 (-9.13%)
>            8  2293.61 ( 0.00%)  1636.87 (-40.12%)  1754.25 (-30.75%)
> FTrace Reclaim Statistics
>                                      traceonly-v2r5  stackreduce-v2r5     nodirect-v2r5
> Direct reclaims                               9843      13398      51651 
> Direct reclaim pages scanned                871367    1008709    3080593 
> Direct reclaim write async I/O               24883      30699          0 
> Direct reclaim write sync I/O                    0          0          0 

Hmm, page-scan and reclaims jumps up but...


> User/Sys Time Running Test (seconds)        734.52    712.39     703.9
> Percentage Time Spent Direct Reclaim         0.00%     0.00%     0.00%
> Total Elapsed Time (seconds)               9710.02   9589.20   9334.45
> Percentage Time kswapd Awake                 0.06%     0.00%     0.00%
> 

Execution time is reduced. Does this shows removing "I/O noise" by direct
reclaim makes the system happy ? or writeback in direct reclaim give
us too much costs ?

It seems I'll have to consider about avoiding direct-reciam in memcg, later.

BTW, I think we'll have to add wait-for-pages-to-be-cleaned trick in
direct reclaim if we want to avoid too much scanning, later.


Thank you for interesting test.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
