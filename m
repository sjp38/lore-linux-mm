Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4FD096B0261
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 16:44:25 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id s7so4834110pal.1
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 13:44:25 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id r6si4003282pag.138.2016.10.24.13.44.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Oct 2016 13:44:24 -0700 (PDT)
From: Josef Bacik <jbacik@fb.com>
Subject: [PATCH 0/5] Support for metadata specific accounting
Date: Mon, 24 Oct 2016 16:43:44 -0400
Message-ID: <1477341829-18673-1-git-send-email-jbacik@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-btrfs@vger.kernel.org, kernel-team@fb.com, david@fromorbit.org, jack@suse.cz, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk, hch@infradead.org, jweiner@fb.com

(Dave again I apologize, for some reason our email server hates you and so I
didn't get your previous responses again, and didn't notice until I was looking
at the patchwork history for my previous submissions, so I'll try and answer all
your questions here, and then I'll be much more judicious about making sure I'm
getting your emails.)

This is my current batch of patches to add some better infrastructure for
handling metadata related memory.  There's been a few changes to these patches
since the last go around but the approach is essentially the same.

Changes since last go around:
-WB_WRITTEN/WB_DIRTIED are now being counted in bytes.  This is necessary to
deal with metadata that is smaller than page size.  Currently btrfs only does
things in pagesize increments, but with these patches it will allow us to easily
support sub-pagesize blocksizes so we need these counters to be in bytes.
-Added a METADATA_BYTES counter to account for the total number of bytes used
for metadata.  We need this because the VM adjusts the dirty ratios based on how
much memory it thinks we can dirty, which is just the amount of free memory
plus the pagecache.
-Patch 5, which is a doozy, and I will explain below.

This is a more complete approach to keeping track of memory that is in use for
metadata.  Previously Btrfs had been using a special inode to allocate all of
our metadata pages out of, so if we had a heavy metadata workload we still
benefited from the balance_dirty_pages() throttling which kept everything sane.
We want to kill this in order to make it easier to support pagesize > blocksize
support in btrfs, in much the same way XFS does this support.

One concern that was brought up was the global accounting vs one bad actor.  We
still need the global accounting so we can enforce the global dirty limits, but
we have the per-bdi accounting as well to make sure we are punishing the bad
actor and not all the other file systems that happened to be hooked into this
infrastructure.

The *REFERENCED patch is to fix a behavior I noticed when testing these patches
on a more memory-constrained system than I had previously used.  Now that the
eviction of metadata pages is controlled soley through the shrinker interface I
was seeing a big perf drop when we had to start doing memory reclaim.  This was
because most of the RAM on the box (10gig of 16gig) was used soley by icache and
dcache.  Because this workload was just create a file and never touch it again
most of this cache was easily evictable.  However because we by default send
every object in the icache/dcache through the LRU twice, it would take around
10,000 iterations through the shrinker before it would start to evict things
(there was ~10 million objects between the two caches).  The pagecache solves
this by putting everything on the INACTIVE list first, and then theres a two
part activation phase before it's moved to the active list, so you have to
really touch a page a lot before it is considered active.  However we assume
active first, which is very latency inducing when we want to start reclaiming
objects.  Making this change keeps us in line with what pagecache does and
eliminates the performance drop I was seeing.

Let me know what you think.  I've tried to keep this as minimal and sane as
possible so we can build on it in the future as we want to handle more nuanced
scenarios.  Also if we think this is a bad approach I won't feel as bad throwing
it out ;).  Thanks,

Josef

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
