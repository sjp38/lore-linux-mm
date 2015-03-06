Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id E401F6B0038
	for <linux-mm@kvack.org>; Fri,  6 Mar 2015 16:13:26 -0500 (EST)
Received: by wevm14 with SMTP id m14so61925088wev.8
        for <linux-mm@kvack.org>; Fri, 06 Mar 2015 13:13:26 -0800 (PST)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id ng4si19958006wic.45.2015.03.06.13.13.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 06 Mar 2015 13:13:24 -0800 (PST)
Date: Fri, 6 Mar 2015 13:13:09 -0800
From: Shaohua Li <shli@fb.com>
Subject: Re: [PATCH] vmscan: get_scan_count selects anon pages conservative
Message-ID: <20150306211309.GA3054673@devbig257.prn2.facebook.com>
References: <d8192a90f6f9b474b33ec732b88b8b2d7e8623cd.1425499261.git.shli@fb.com>
 <54F770A7.2030205@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <54F770A7.2030205@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, Kernel-team@fb.com, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>

On Wed, Mar 04, 2015 at 03:52:55PM -0500, Rik van Riel wrote:
> On 03/04/2015 03:03 PM, Shaohua Li wrote:
> > kswapd is a per-node based. Sometimes there is imbalance between nodes,
> > node A is full of clean file pages (easy to reclaim), node B is
> > full of anon pages (hard to reclaim). With memory pressure, kswapd will
> > be waken up for both nodes. The kswapd of node B will try to swap, while
> > we prefer reclaim pages from node A first. The real issue here is we
> > don't have a mechanism to prevent memory allocation from a hard-reclaim
> > node (node B here) if there is an easy-reclaim node (node A) to reclaim
> > memory.
> > 
> > The swap can happen even with swapiness 0. Below is a simple script to
> > trigger it. cpu 1 and 8 are in different node, each has 72G memory:
> > truncate -s 70G img
> > taskset -c 8 dd if=img of=/dev/null bs=4k
> > taskset -c 1 usemem 70G
> > 
> > The swap can even easier to trigger because we have a protect mechanism
> > for situation file pages are less than high watermark. This logic makes
> > sense but could be more conservative.
> > 
> > This patch doesn't try to fix the kswapd imbalance issue above, but make
> > get_scan_count more conservative to select anon pages. The protect
> > mechanism is designed for situation file pages are rotated frequently.
> > In that situation, page reclaim should be in trouble, eg, priority is
> > lower. So let's only apply the protect mechanism in that situation. In
> > pratice, this fixes the swap issue in above test.
> > 
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Mel Gorman <mgorman@suse.de>
> > Cc: Rik van Riel <riel@redhat.com>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Signed-off-by: Shaohua Li <shli@fb.com>
> 
> Doh, never mind my earlier comment. I must be too tired
> to look at stuff right...
> 
> I see how your patch helps avoid the problem, but I am
> worried about potential side effects. I suspect it could
> lead to page cache thrashing when all zones are low on
> page cache memory.
> 
> Would it make sense to explicitly check that we are low
> on page cache pages in all zones on the scan list, before
> forcing anon only scanning, when we get into this function?

Ok, we still need to check the priority to make sure kswapd doesn't
stuck to zones without enough file pages. How about this one?
