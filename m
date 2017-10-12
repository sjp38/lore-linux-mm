Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0880C6B0033
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 15:11:46 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id i124so3936988wmf.1
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 12:11:45 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 94si1494451edq.368.2017.10.12.12.11.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 12 Oct 2017 12:11:44 -0700 (PDT)
Date: Thu, 12 Oct 2017 15:11:33 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/8] mm, truncate: Do not check mapping for every page
 being truncated
Message-ID: <20171012191133.GB5075@cmpxchg.org>
References: <20171012093103.13412-1-mgorman@techsingularity.net>
 <20171012093103.13412-3-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171012093103.13412-3-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Dave Chinner <david@fromorbit.com>

On Thu, Oct 12, 2017 at 10:30:57AM +0100, Mel Gorman wrote:
> During truncation, the mapping has already been checked for shmem and dax
> so it's known that workingset_update_node is required. This patch avoids
> the checks on mapping for each page being truncated. In all other cases,
> a lookup helper is used to determine if workingset_update_node() needs
> to be called. The one danger is that the API is slightly harder to use as
> calling workingset_update_node directly without checking for dax or shmem
> mappings could lead to surprises. However, the API rarely needs to be used
> and hopefully the comment is enough to give people the hint.
> 
> sparsetruncate (tiny)
>                               4.14.0-rc4             4.14.0-rc4
>                              oneirq-v1r1        pickhelper-v1r1
> Min          Time      141.00 (   0.00%)      140.00 (   0.71%)
> 1st-qrtle    Time      142.00 (   0.00%)      141.00 (   0.70%)
> 2nd-qrtle    Time      142.00 (   0.00%)      142.00 (   0.00%)
> 3rd-qrtle    Time      143.00 (   0.00%)      143.00 (   0.00%)
> Max-90%      Time      144.00 (   0.00%)      144.00 (   0.00%)
> Max-95%      Time      147.00 (   0.00%)      145.00 (   1.36%)
> Max-99%      Time      195.00 (   0.00%)      191.00 (   2.05%)
> Max          Time      230.00 (   0.00%)      205.00 (  10.87%)
> Amean        Time      144.37 (   0.00%)      143.82 (   0.38%)
> Stddev       Time       10.44 (   0.00%)        9.00 (  13.74%)
> Coeff        Time        7.23 (   0.00%)        6.26 (  13.41%)
> Best99%Amean Time      143.72 (   0.00%)      143.34 (   0.26%)
> Best95%Amean Time      142.37 (   0.00%)      142.00 (   0.26%)
> Best90%Amean Time      142.19 (   0.00%)      141.85 (   0.24%)
> Best75%Amean Time      141.92 (   0.00%)      141.58 (   0.24%)
> Best50%Amean Time      141.69 (   0.00%)      141.31 (   0.27%)
> Best25%Amean Time      141.38 (   0.00%)      140.97 (   0.29%)
> 
> As you'd expect, the gain is marginal but it can be detected. The differences
> in bonnie are all within the noise which is not surprising given the impact
> on the microbenchmark.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

With Jan's suggestion to remove the private parameter,

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
