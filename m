Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id F18976B0008
	for <linux-mm@kvack.org>; Thu, 24 Jan 2013 01:28:57 -0500 (EST)
Received: by mail-ie0-f180.google.com with SMTP id c10so14830839ieb.25
        for <linux-mm@kvack.org>; Wed, 23 Jan 2013 22:28:57 -0800 (PST)
Message-ID: <1359008927.1375.7.camel@kernel>
Subject: Re: [LSF/MM TOPIC]swap improvements for fast SSD
From: Simon Jeons <simon.jeons@gmail.com>
Date: Thu, 24 Jan 2013 00:28:47 -0600
In-Reply-To: <20130122065341.GA1850@kernel.org>
References: <20130122065341.GA1850@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

On Tue, 2013-01-22 at 14:53 +0800, Shaohua Li wrote:
> Hi,
> 
> Because of high density, low power and low price, flash storage (SSD) is a good
> candidate to partially replace DRAM. A quick answer for this is using SSD as
> swap. But Linux swap is designed for slow hard disk storage. There are a lot of
> challenges to efficiently use SSD for swap:
> 
> 1. Lock contentions (swap_lock, anon_vma mutex, swap address space lock)
> 2. TLB flush overhead. To reclaim one page, we need at least 2 TLB flush. This

Which 2 TLB flush?

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


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
