Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 893BF6B0008
	for <linux-mm@kvack.org>; Wed, 23 Jan 2013 11:57:52 -0500 (EST)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 23 Jan 2013 11:57:51 -0500
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id D7675C9003C
	for <linux-mm@kvack.org>; Wed, 23 Jan 2013 11:57:01 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0NGv1PS143264
	for <linux-mm@kvack.org>; Wed, 23 Jan 2013 11:57:01 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0NGv1Vx031880
	for <linux-mm@kvack.org>; Wed, 23 Jan 2013 14:57:01 -0200
Message-ID: <51001658.7000507@linux.vnet.ibm.com>
Date: Wed, 23 Jan 2013 10:56:56 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [LSF/MM TOPIC]swap improvements for fast SSD
References: <20130122065341.GA1850@kernel.org>
In-Reply-To: <20130122065341.GA1850@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>

On 01/22/2013 12:53 AM, Shaohua Li wrote:
> Hi,
> 
> Because of high density, low power and low price, flash storage (SSD) is a good
> candidate to partially replace DRAM. A quick answer for this is using SSD as
> swap. But Linux swap is designed for slow hard disk storage. There are a lot of
> challenges to efficiently use SSD for swap:
> 
> 1. Lock contentions (swap_lock, anon_vma mutex, swap address space lock)
> 2. TLB flush overhead. To reclaim one page, we need at least 2 TLB flush. This
> overhead is very high even in a normal 2-socket machine.
> 3. Better swap IO pattern. Both direct and kswapd page reclaim can do swap,
> which makes swap IO pattern is interleave. Block layer isn't always efficient
> to do request merge. Such IO pattern also makes swap prefetch hard.
> 4. Swap map scan overhead. Swap in-memory map scan scans an array, which is
> very inefficient, especially if swap storage is fast.
> 5. SSD related optimization, mainly discard support
> 6. Better swap prefetch algorithm. Besides item 3, sequentially accessed pages
> aren't always in LRU list adjacently, so page reclaim will not swap such pages
> in adjacent storage sectors. This makes swap prefetch hard.
> 7. Alternative page reclaim policy to bias reclaiming anonymous page.
> Currently reclaim anonymous page is considering harder than reclaim file pages,
> so we bias reclaiming file pages. If there are high speed swap storage, we are
> considering doing swap more aggressively.
> 8. Huge page swap. Huge page swap can solve a lot of problems above, but both
> THP and hugetlbfs don't support swap.

I too have also observed these issues in my work with zswap,
especially the lock contentions mentioned in 1 and the prefetch
situation in 3 and 6 that contains heuristics for rotational media.

I'd be very interested in discussing these issues and potential solutions.

Thanks to Minchan for the discussion about the front last year's summits.

Seth

> 
> I had some progresses in these areas recently:
> http://marc.info/?l=linux-mm&m=134665691021172&w=2
> http://marc.info/?l=linux-mm&m=135336039115191&w=2
> http://marc.info/?l=linux-mm&m=135882182225444&w=2
> http://marc.info/?l=linux-mm&m=135754636926984&w=2
> http://marc.info/?l=linux-mm&m=135754634526979&w=2
> But a lot of problems remain. I'd like to discuss the issues at the meeting.
> 
> Thanks,
> Shaohua
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
