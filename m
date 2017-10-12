Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id BB1516B0033
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 15:45:45 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 136so3954704wmu.10
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 12:45:45 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id c35si2757332edd.94.2017.10.12.12.45.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 12 Oct 2017 12:45:44 -0700 (PDT)
Date: Thu, 12 Oct 2017 15:45:36 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/8] mm, truncate: Remove all exceptional entries from
 pagevec under one lock
Message-ID: <20171012194536.GC5075@cmpxchg.org>
References: <20171012093103.13412-1-mgorman@techsingularity.net>
 <20171012093103.13412-4-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171012093103.13412-4-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Dave Chinner <david@fromorbit.com>

On Thu, Oct 12, 2017 at 10:30:58AM +0100, Mel Gorman wrote:
> During truncate each entry in a pagevec is checked to see if it is an
> exceptional entry and if so, the shadow entry is cleaned up.  This is
> potentially expensive as multiple entries for a mapping locks/unlocks the
> tree lock.  This batches the operation such that any exceptional entries
> removed from a pagevec only acquire the mapping tree lock once. The corner
> case where this is more expensive is where there is only one exceptional
> entry but this is unlikely due to temporal locality and how it affects
> LRU ordering. Note that for truncations of small files created recently,
> this patch should show no gain because it only batches the handling of
> exceptional entries.
> 
> sparsetruncate (large)
>                               4.14.0-rc4             4.14.0-rc4
>                          pickhelper-v1r1       batchshadow-v1r1
> Min          Time       38.00 (   0.00%)       27.00 (  28.95%)
> 1st-qrtle    Time       40.00 (   0.00%)       28.00 (  30.00%)
> 2nd-qrtle    Time       44.00 (   0.00%)       41.00 (   6.82%)
> 3rd-qrtle    Time      146.00 (   0.00%)      147.00 (  -0.68%)
> Max-90%      Time      153.00 (   0.00%)      153.00 (   0.00%)
> Max-95%      Time      155.00 (   0.00%)      156.00 (  -0.65%)
> Max-99%      Time      181.00 (   0.00%)      171.00 (   5.52%)
> Amean        Time       93.04 (   0.00%)       88.43 (   4.96%)
> Best99%Amean Time       92.08 (   0.00%)       86.13 (   6.46%)
> Best95%Amean Time       89.19 (   0.00%)       83.13 (   6.80%)
> Best90%Amean Time       85.60 (   0.00%)       79.15 (   7.53%)
> Best75%Amean Time       72.95 (   0.00%)       65.09 (  10.78%)
> Best50%Amean Time       39.86 (   0.00%)       28.20 (  29.25%)
> Best25%Amean Time       39.44 (   0.00%)       27.70 (  29.77%)
> 
> bonnie
>                                       4.14.0-rc4             4.14.0-rc4
>                                  pickhelper-v1r1       batchshadow-v1r1
> Hmean     SeqCreate ops         71.92 (   0.00%)       76.78 (   6.76%)
> Hmean     SeqCreate read        42.42 (   0.00%)       45.01 (   6.10%)
> Hmean     SeqCreate del      26519.88 (   0.00%)    27191.87 (   2.53%)
> Hmean     RandCreate ops        71.92 (   0.00%)       76.95 (   7.00%)
> Hmean     RandCreate read       44.44 (   0.00%)       49.23 (  10.78%)
> Hmean     RandCreate del     24948.62 (   0.00%)    24764.97 (  -0.74%)
> 
> Truncation of a large number of files shows a substantial gain with 99% of files
> being trruncated 6.46% faster. bonnie shows a modest gain of 2.53%
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
