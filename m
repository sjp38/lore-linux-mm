Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 8624D6B0038
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 15:53:09 -0500 (EST)
Received: by widex7 with SMTP id ex7so31730327wid.1
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 12:53:08 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p9si31434311wiy.111.2015.03.04.12.53.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Mar 2015 12:53:07 -0800 (PST)
Message-ID: <54F770A7.2030205@redhat.com>
Date: Wed, 04 Mar 2015 15:52:55 -0500
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
> 
> The swap can even easier to trigger because we have a protect mechanism
> for situation file pages are less than high watermark. This logic makes
> sense but could be more conservative.
> 
> This patch doesn't try to fix the kswapd imbalance issue above, but make
> get_scan_count more conservative to select anon pages. The protect
> mechanism is designed for situation file pages are rotated frequently.
> In that situation, page reclaim should be in trouble, eg, priority is
> lower. So let's only apply the protect mechanism in that situation. In
> pratice, this fixes the swap issue in above test.
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Shaohua Li <shli@fb.com>

Doh, never mind my earlier comment. I must be too tired
to look at stuff right...

I see how your patch helps avoid the problem, but I am
worried about potential side effects. I suspect it could
lead to page cache thrashing when all zones are low on
page cache memory.

Would it make sense to explicitly check that we are low
on page cache pages in all zones on the scan list, before
forcing anon only scanning, when we get into this function?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
