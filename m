Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f46.google.com (mail-bk0-f46.google.com [209.85.214.46])
	by kanga.kvack.org (Postfix) with ESMTP id 5FA346B0031
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 17:03:22 -0500 (EST)
Received: by mail-bk0-f46.google.com with SMTP id r7so1501583bkg.5
        for <linux-mm@kvack.org>; Fri, 24 Jan 2014 14:03:21 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id tl9si4517655bkb.150.2014.01.24.14.03.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 24 Jan 2014 14:03:21 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 0/2] mm: reduce reclaim stalls with heavy anon and dirty cache
Date: Fri, 24 Jan 2014 17:03:02 -0500
Message-Id: <1390600984-13925-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Tejun reported stuttering and latency spikes on a system where random
tasks would enter direct reclaim and get stuck on dirty pages.  Around
50% of memory was occupied by tmpfs backed by an SSD, and another disk
(rotating) was reading and writing at max speed to shrink a partition.

Analysis:

When calculating the amount of dirtyable memory, the VM considers all
free memory and all file and anon pages as baseline to which to apply
dirty limits.  This implies that, given memory pressure from dirtied
cache, the VM would actually start swapping to make room.  But alas,
this is not really the case and page reclaim tries very hard not to
swap as long as there is any used-once cache available.  The dirty
limit may have been 10-15% of main memory, but page cache was less
than 50% of that, which means that a third of the pages that the
reclaimers actually looked at were dirty.  Kswapd stopped making
progress, and in turn allocators were forced into direct reclaim only
to get stuck on dirty/writeback congestion.

These two patches fix the dirtyable memory calculation to acknowledge
the fact that the VM does not really replace anon with dirty cache.
As such, anon memory can no longer be considered "dirtyable."

Longer term we probably want to look into reducing some of the bias
towards cache.  The problematic workload in particular was not even
using any of the anon pages, one swap burst could have resolved it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
