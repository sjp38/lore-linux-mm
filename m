Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0562A6B29FF
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 08:16:43 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id z24-v6so2472247plo.2
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 05:16:42 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q8-v6si4371220pfh.353.2018.08.23.05.16.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Aug 2018 05:16:42 -0700 (PDT)
Date: Thu, 23 Aug 2018 14:16:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: measuring reclaim overhead without NR_PAGES_SCANNED
Message-ID: <20180823121637.GB16852@dhcp22.suse.cz>
References: <CAA25o9QLMuDSL6L3+7KQO=NrtohB=dgvLgsusLTy5-qsAK6Org@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA25o9QLMuDSL6L3+7KQO=NrtohB=dgvLgsusLTy5-qsAK6Org@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>

On Wed 22-08-18 18:50:36, Luigi Semenzato wrote:
> My apologies for not noticing this earlier, but we're often working
> with older kernels.
> 
> On May 3, 2017 this patch was merged:
> 
> commit c822f6223d03c2c5b026a21da09c6b6d523258cd
> Author:     Johannes Weiner <hannes@cmpxchg.org>
> AuthorDate: Wed May 3 14:52:10 2017 -0700
> Commit:     Linus Torvalds <torvalds@linux-foundation.org>
> CommitDate: Wed May 3 15:52:08 2017 -0700
> 
>     mm: delete NR_PAGES_SCANNED and pgdat_reclaimable()
> 
> I was planning to use this number as a measure of how much work the
> kernel was doing trying to reclaim pages (by comparing it, for
> instance, to the number of pages actually swapped in).  I am not even
> sure how good a metric this would be.

I do not think it would be a good fit for that. NR_PAGES_SCANNED was
really volatile (any freed page would reset the counter).

> Does anybody have suggestions for a good (or better) replacement?

I usually compare the number of pages scanned vs reclaimed from both
kswapd and allocator (direct reclaim) context. But it only tells you the
overall effectivity of the reclaim rather than how much _work_ had to be
done to release each page. Some of them would need to get unmapped
first. Some require to release buffers etc... I do not think we have a
good measure for that right now except for looking at tracepoints.

Johannes is working on pressure stall information [1] which might be
better fit for what you need.

[1] http://lkml.kernel.org/r/20180801151958.32590-1-hannes@cmpxchg.org
-- 
Michal Hocko
SUSE Labs
