Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com [74.125.82.179])
	by kanga.kvack.org (Postfix) with ESMTP id BEFF86B0038
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 15:17:18 -0500 (EST)
Received: by wevl61 with SMTP id l61so11788714wev.0
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 12:17:18 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id fb8si13668218wid.20.2015.03.04.12.17.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Mar 2015 12:17:17 -0800 (PST)
Message-ID: <54F76840.5070009@redhat.com>
Date: Wed, 04 Mar 2015 15:17:04 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] vmscan: get_scan_count selects anon pages conservative
References: <d8192a90f6f9b474b33ec732b88b8b2d7e8623cd.1425499261.git.shli@fb.com>
In-Reply-To: <d8192a90f6f9b474b33ec732b88b8b2d7e8623cd.1425499261.git.shli@fb.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>, linux-mm@kvack.org
Cc: Kernel-team@fb.com, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>

On 03/04/2015 03:03 PM, Shaohua Li wrote:
> kswapd is a per-node based. Sometimes there is imbalance between nodes,
> node A is full of clean file pages (easy to reclaim), node B is
> full of anon pages (hard to reclaim). With memory pressure, kswapd will
> be waken up for both nodes. The kswapd of node B will try to swap, while
> we prefer reclaim pages from node A first. The real issue here is we
> don't have a mechanism to prevent memory allocation from a hard-reclaim
> node (node B here) if there is an easy-reclaim node (node A) to reclaim
> memory.
> 
> The swap can happen even with swapiness 0. Below is a simple script to
> trigger it. cpu 1 and 8 are in different node, each has 72G memory:
> truncate -s 70G img
> taskset -c 8 dd if=img of=/dev/null bs=4k
> taskset -c 1 usemem 70G

> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 5e8eadd..31b03e6 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1990,7 +1990,7 @@ static void get_scan_count(struct lruvec *lruvec, int swappiness,
>  	 * thrashing file LRU becomes infinitely more attractive than
>  	 * anon pages.  Try to detect this based on file LRU size.
>  	 */
> -	if (global_reclaim(sc)) {
> +	if (global_reclaim(sc) && sc->priority < DEF_PRIORITY - 2) {
>  		unsigned long zonefile;
>  		unsigned long zonefree;

What kernel does this apply to?

Current upstream does not seem to have the
"sc->priority < DEF_PRIORITY - 2" check, unless
I somehow managed to mess up "git clone" on several
systems.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
