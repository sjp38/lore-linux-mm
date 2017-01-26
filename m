Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6F3676B0033
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 05:20:40 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id v77so44092690wmv.5
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 02:20:40 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y65si25945598wmb.78.2017.01.26.02.20.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 Jan 2017 02:20:39 -0800 (PST)
Date: Thu, 26 Jan 2017 10:19:16 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 5/5] mm: vmscan: move dirty pages out of the way until
 they're flushed
Message-ID: <20170126101916.tmqa3hswtxfa6nsj@suse.de>
References: <20170123181641.23938-1-hannes@cmpxchg.org>
 <20170123181641.23938-6-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170123181641.23938-6-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon, Jan 23, 2017 at 01:16:41PM -0500, Johannes Weiner wrote:
> We noticed a performance regression when moving hadoop workloads from
> 3.10 kernels to 4.0 and 4.6. This is accompanied by increased pageout
> activity initiated by kswapd as well as frequent bursts of allocation
> stalls and direct reclaim scans. Even lowering the dirty ratios to the
> equivalent of less than 1% of memory would not eliminate the issue,
> suggesting that dirty pages concentrate where the scanner is looking.
> 

Note that some of this is also impacted by
bbddabe2e436aa7869b3ac5248df5c14ddde0cbf because it can have the effect
of dirty pages reaching the end of the LRU sooner if they are being
written. It's not impossible that hadoop is rewriting the same files,
hitting the end of the LRU due to no reads and then throwing reclaim
into a hole.

I've seen a few cases where random write only workloads regressed and it
was based on whether the random number generator was selecting the same
pages. With that commit, the LRU was effectively LIFO.

Similarly, I'd seen a case where a databases whose working set was
larger than the shared memory area regressed because the spill-over from
the database buffer to RAM was not being preserved because it was all
rights. That said, the same patch prevents the database being swapped so
it's not all bad but there have been consequences.

I don't have a problem with the patch although would prefer to have seen
more data for the series. However, I'm not entirely convinced that
thrash detection was the only problem. I think not activating pages on
write was a contributing factor although this patch looks better than
considering reverting bbddabe2e436aa7869b3ac5248df5c14ddde0cbf.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
