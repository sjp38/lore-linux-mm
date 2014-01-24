Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f43.google.com (mail-bk0-f43.google.com [209.85.214.43])
	by kanga.kvack.org (Postfix) with ESMTP id 359A36B0031
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 17:52:08 -0500 (EST)
Received: by mail-bk0-f43.google.com with SMTP id mx11so1543180bkb.2
        for <linux-mm@kvack.org>; Fri, 24 Jan 2014 14:52:07 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id ti7si4596017bkb.291.2014.01.24.14.52.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 24 Jan 2014 14:52:06 -0800 (PST)
Date: Fri, 24 Jan 2014 17:51:56 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 0/2] mm: reduce reclaim stalls with heavy anon and dirty
 cache
Message-ID: <20140124225156.GG4407@cmpxchg.org>
References: <1390600984-13925-1-git-send-email-hannes@cmpxchg.org>
 <20140124143003.2629e9c2c8c2595e805c8c25@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140124143003.2629e9c2c8c2595e805c8c25@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Jan 24, 2014 at 02:30:03PM -0800, Andrew Morton wrote:
> On Fri, 24 Jan 2014 17:03:02 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > Tejun reported stuttering and latency spikes on a system where random
> > tasks would enter direct reclaim and get stuck on dirty pages.  Around
> > 50% of memory was occupied by tmpfs backed by an SSD, and another disk
> > (rotating) was reading and writing at max speed to shrink a partition.
> 
> Do you think this is serious enough to squeeze these into 3.14?

We have been biasing towards cache reclaim at least as far back as the
LRU split and we always considered anon dirtyable, so it's not really
a *new* problem.  And there is a chance of regressing write bandwidth
for certain workloads by effectively shrinking their dirty limit -
although that is easily fixed by changing dirty_ratio.

On the other hand, the stuttering is pretty nasty (could reproduce it
locally too) and the workload is not exactly esoteric.  Plus, I'm not
sure if waiting will increase the test exposure.

So 3.14 would work for me, unless Mel and Rik have concerns.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
