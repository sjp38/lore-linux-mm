Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5AB7C32753
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 02:18:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7BC732171F
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 02:18:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7BC732171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DB22C8E0005; Wed, 31 Jul 2019 22:18:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D62668E0003; Wed, 31 Jul 2019 22:18:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C50A68E0005; Wed, 31 Jul 2019 22:18:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 85EC08E0003
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 22:18:02 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id n4so38136202plp.4
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 19:18:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=E+dsPV3fdkn9L2MrLUuw5jeKi9Q5EWdqKQmCASIVjSY=;
        b=rIJuR0eBk5W4WSmoOqVFbKK1xRaKpMYBFbtKHfXzIFSMhNQ4IG3pgtElXasr6YX+2V
         81NmUu9GgqyHm/nAOn6FUfN31dDfn/jRqfzaQEI32K6OP4XMnMvA9u69cdMk2FpVvqQc
         jPpaeyXJVZijqAYye3puE6E+cNhQkFpQlQHkO1kHust1L1ijcbdVI6PPPMc+FUx2pBfG
         hGdeWBc455g2SyD9UFHZ9Ge48/i1ASGj4XNeBII22Xqsyo73ls/szVW9eKoIOqBCbqvq
         zQAxqEnxiZswy117RtBGupEH111TqDbkBce13S4v1k4aNswLEUYmvek92HMAwmu5+g8F
         QCyg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAXjiTytry2AC7o/DQdy749hgsZ0+Gpk6nJ8yUS2MfDzxER9jha+
	78K1vt2BkjisDaM2TV6LnFZzikdmuiMt6V0l7bfGbe9D9mY+amlHYMrzVDNOMwXZPPzn59Szpsj
	W/3a7QMagggRK8fnV87qTpfSNbmC2b87kroufWEFzoNoQtWI5A7vbRBIcPuxtGvY=
X-Received: by 2002:a63:b10f:: with SMTP id r15mr46593054pgf.230.1564625882014;
        Wed, 31 Jul 2019 19:18:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxUWTFiUqdlKyuC96KqvImV2PPcemrwMOeWKcF+hv5hSy8p7jjv8sxhupSIkxQcGo/M+4Z4
X-Received: by 2002:a63:b10f:: with SMTP id r15mr46592962pgf.230.1564625880322;
        Wed, 31 Jul 2019 19:18:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564625880; cv=none;
        d=google.com; s=arc-20160816;
        b=M3uTtO+G2N3IhhGJmt2u7JzcpLPoySQv5cuOAKqzXzQ5uXBX0eKnqqsblU9ZFd1PXL
         ZM+c2jAKNMTS3gbv97nMTz5WqzRYE+cFIH7bfsDzVusec9FqzQ0FAliDL0Hx2fGqod4H
         FF+C15Y5AqcLfWVYx5lziEux+tptexfGExdJ77K7P8CP2J/4GKkxbG7rrWX75mOrjVmw
         jIJRFL9IBAgUjZni17mtwco/uz2CFVXyUgXDo1A5Gd0I/c1qiX410BtYpH6TROMRSVSA
         4qufSGP5pg900DyWBdUg2B08IAs+Xt0/ByjvKT8PDYKi8FBTlJoEVIkvuv6lkzlU1bQf
         4FlA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=E+dsPV3fdkn9L2MrLUuw5jeKi9Q5EWdqKQmCASIVjSY=;
        b=yTgjiZ6SUGvvqgMg+tqrLYckKefgg7q/TCztqTL45nmS3lxe+KNVDOuXdknXT8gozS
         1oyqypAa+LR+wzsRaiZLmI4jVG2jEIQeoDV9eim09mGcfMUZ/mLFJEG44bh/7iIXHSwM
         Q8igAxK4oh6aQNqzv3r6qOPbrcxd/dxU1tVmYJFiRmBPLiiYqDLB1cXJna9p7UbwZwhv
         irzSX7KalZKnuoPtH4WkWb+giVRlMBj/qjduqloVRXQKeTU3Op1T0shjAkMV2Pp8dFB/
         ihPQ2GgsFosKtsGuvMS2FegmFlvJ6U6OVhpW1QUyViykmc+cGt/6M25nbkU3fLdyrnKe
         kaSg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail105.syd.optusnet.com.au (mail105.syd.optusnet.com.au. [211.29.132.249])
        by mx.google.com with ESMTP id n11si2704418pgr.460.2019.07.31.19.17.59
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 19:18:00 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.249;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-195-139-63.pa.nsw.optusnet.com.au [49.195.139.63])
	by mail105.syd.optusnet.com.au (Postfix) with ESMTPS id B1C03361C0E;
	Thu,  1 Aug 2019 12:17:58 +1000 (AEST)
Received: from discord.disaster.area ([192.168.253.110])
	by dread.disaster.area with esmtp (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1ht0eA-0003aM-MO; Thu, 01 Aug 2019 12:16:50 +1000
Received: from dave by discord.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1ht0fG-0001kX-HQ; Thu, 01 Aug 2019 12:17:58 +1000
From: Dave Chinner <david@fromorbit.com>
To: linux-xfs@vger.kernel.org
Cc: linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: [RFC] [PATCH 00/24] mm, xfs: non-blocking inode reclaim
Date: Thu,  1 Aug 2019 12:17:28 +1000
Message-Id: <20190801021752.4986-1-david@fromorbit.com>
X-Mailer: git-send-email 2.22.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=D+Q3ErZj c=1 sm=1 tr=0 cx=a_idp_d
	a=fNT+DnnR6FjB+3sUuX8HHA==:117 a=fNT+DnnR6FjB+3sUuX8HHA==:17
	a=FmdZ9Uzk2mMA:10 a=6pmmO7TpwXUFMkABp0cA:9 a=h_H2Fkk-1ZVItCAh:21
	a=XAvxuiYTQ6zQNYpj:21
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Folks,

We've had a problem with inode reclaim for a long time - XFS is
capable of caching tens of millions of inodes with ease and dirtying
hundreds of thousands of those cached inodes every second. It is
also capable of reclaiming more than half a million clean inodes per
second per reclaim thread.

The result of this is that when there is a significant change in
sustained memory pressure on a system ith a large inode cache,
memory reclaim rapidly frees all the clean XFS inodes, but cannot
make progress on reclaiming dirty inodes because they are rate
limited by IO.

However, the shrinker infrastructure in the kernel has no way to
feed back rate limiting to the core memory reclaim algorithms.  In
fact there are no feedback mechanisms at all, and so when reclaim
has freed all the clean inodes and starts hitting dirty inodes, the
filesystem shrinker has no way of telling reclaim that the inode
reclaim rate has dropped from 500k/s to 500/s.

The result is that reclaim continues to try to free memory but
because it makes no progress freeing inodes it puts much more
pressure on the page LRUs and frees more pages. When it runs out of
pages, it starts swapping, and when it runs out of swap or can't get
a page for swap-in it starts going on an OOM kill rampage.  This
does nothing to "fix" the shortage of memory caused by the slowness
of dirty inode reclaim - if memory demand continues we just keep
hitting the OOM killer until either something critical is killed or
memory demand eases.

For a long time, XFS has avoided this insane spiral of shouty
OOM-killer rage death by cleaning inodes directly in the shrinker.
This has the effect of throttling memory reclaim to the rate at
which dirty inodes can be cleaned. Hence when we get into the state
when memory reclaim is dependent on inode reclaim making progress
we don't ever allow LRU reclaim to run so far ahead of inode reclaim
that it winds up reclaim priority and runs out of LRU pages to
reclaim and/or swap.

This has a downside, though. When there is a large amount of clean
page cache and a small amount of inode cache that is dirty (e.g.
lots of file data pressure and/or application memory demand) the
inode reclaim shrinkers can run out of clean inodes to reclaim and
start blocking on inode writeback. This can result in long reclaim
latencies even though there is lots of memory that can be
immediately reclaimed from the page cache. This is ... suboptimal.

There are other issues. We have to block kswapd, too, because it
will continue running until watermarks are satisfied, and that is
frequently the vector for shouty swappy death because it doesn't
back off before priority windup from lack of progress occurs.
Blocking kswapd then affects direct reclaim function, which often
backs off expecting kswapd to make progress in the mean time. But if
kswapd is not making progress, direct reclaim ends up in priority
windup from lack of progress, too. This is especially prevalent in
workloads that have a high percentage of GFP_NOFS allocations (e.g.
filesystem modification workloads).

The shrinkers have another problem w/ GFP_NOFS reclaim: the work
that is deferred because the shrinker cannot make progress gets
lumped on the first reclaim context that can do that work. That
means a direct reclaimer might get lumped with scanning millions of
objects during low priority scanning when it should only be scanning
a couple of thousand objects. This can result in highly
unpredictable and extremely long direct reclaim delays, especially
if it bumps into dirty inodes.

This is most definitely sub-optimal, but it's better than random
and/or premature OOM killer invocation under trivial workloads and
lots of reclaimable memory still being available. Hence we've kinda
been stuck with the sucky behaviour we have now.

This patch set aims to fix all these problems (at last!). The memory
reclaim and shrinker changes involve:

- a substantial rework of how the shrinker defers work, moving all
  the deferred work to kswapd to remove all the unpredictability
  from direct reclaim.  Direct reclaim will only do the work the
  direct reclaim context determines is necesary.

- deferred work is capped to prevent excessive scanning, and the
  amount of deferred work kswapd will do in each scan is increased
  linearly w.r.t. increasing reclaim priority. Hence when we are
  desparate for memory, kswapd will be running all the deferred work
  as quickly as possible.

- The amount of deferred work and the amount of scanning that is
  done by the shrinkers is now tracked in the struct reclaim_state.
  This allows shrink_node() to see how much work is being done in
  comparison to both the LRU scanning and how much shrinker work is
  being deferred to kswapd. This allows direct reclaim to back off
  when too much work is being deferred and hence allow kswapd to
  make progress on the deferred work while it waits.

- A "need backoff" flag has been added to the struct reclaim_state.
  This allows individual shrinkers to indicate to kswapd that they
  need some time to finish work before being scanned again. This is
  basically for the same situation where kswapd backs off from LRU
  scanning.

  i.e. the LRU scanning has run into the tail of the LRU and is only
  finding dirty objects that require IO to complete before reclaim
  can make further progress. This is exactly the same problem we
  have with inode reclaim in XFS, and it is this mechanism that
  enables us to move to an IO-less inode reclaim architecture.

The XFS changes are all over the place, and address both the reclaim
blocking problems and all the other related issues I found while
working on this patchest. These involve:

- fixing IO priority inversion problems between metadata
  writeback (inodes!) and log IO caused by the block layer write
  throttling (more on this later).

- some slab caches weren't marked as reclaimable, so were
  incorrectly accounted. Also account for the pages xfs_buf reclaim
  releases.

- reduced the delayed logging dirty item aggregation size (the CIL).
  This defines the minimum amount of memory XFS can operate in when
  there is heavy modifications in progress.

- reduced the memory footprint of the CIL when repeated
  modifications to objects occur.

- Added a mechanism to push the AIL to a specific LSN (metadata
  modification epoch) and wait for it. This forms the basis for
  direct inode reclaim deferring IO and waiting for some progress
  without issuing IO iteslf.

- reworked inode reclaim to use a list_lru to track inodes in
  reclaim rather than a radix tree tag in the inode cache. We
  iterated the radix tree for reclaim because it resulted in optimal
  IO patterns from multiple concurrent reclaimers, but we dont' have
  to care about that any more because all IO comes from the AIL now.

  This gives us try LRU reclaim, and it allows us to effectively
  determine when we've run out of clean inodes to easily reclaim and
  provide that feedback to the higher levels via the "need backoff"
  flag.

- direct reclaim is non-blocking while scanning, but at the end of a
  scan it will still block waiting for IO, but only for /some/
  progress to be made and not specific individual IOs.

- kswapd based reclaim is fully non-blocking.

The result is that there is now enough feedback from the shrinkers
into the main memory reclaim loop for it to back off in the
situations where back-off is required to avoid OOM killer
invocation, despite XFS now largely doing non-blocking reclaim.

Testing involves at 16p/16GB machine running a fsmark workload that
creates sustained heavy dirty inode cache pressure, then
progressively locking 2GB of memory at time to squeeze the workload
into less and less memory. A vanilla kernel runs well up to 12GB
squeezed, but at 14GB squeezed performance goes to hell. With just
the hacky "don't block kswapd by removing SYNC_WAIT" patch that
people seem to like, OOM kills start when squeezed to 12GB. With
that extended to direct reclaim, OOM kills start with squeezed to
just 8GB. With the full patchset, it runs similar to a vanilla
kernel up to 12GB squeezed, and vastly out-performs the vanilla
kernel with 14GB squeezed. Performance only drops ~20% with a 14GB
squeeze, whereas the vanilla kernel sees up to a 90% drop in
performance.

I also ran testing with simoop, a simulated workload that Chris
Mason put together to demonstrate the long tail latency and
allocation stall problems the blocking in inode reclaim was causing
for workloads at FB.  The vanilla kernel averaged ~5 stalls/sec over
a test period of 10 hours, this patch series resulted in:

alloc stall rate = 0.00/sec (avg: 0.04) (p50: 0.04) (p95: 0.16) (p99: 0.32)

stalls almost going away entirely over a 10 hour period.

IOWs, the signs are there that this is a workable solution to the
problems caused by blocking inode reclaim without re-introducing the
the Death-by-OOM-killer issues the blocking avoids.

Please note that I haven't full gone non-blocking on direct reclaim
for a couple of reasons:

1. congestion_wait() and wait_iff_congested() are completely broken.
The blkmq change-over ripped out all the block layer congestion
reporting in 5.0 and didn't replace it with anything, so unless you
are operating on an NFS client, Ceph, FUSE or a DVD, congestion
checks and backoff aren't actually doing what they are supposed to.
i.e. wait_iff_congested() never blocks, and congestion_wait() always
sleeps for it's full timeout.

IOWs, the whole bdi-based IO congestion feedback mechanism no longer
functions as intended, and so I'm betting a lot of the memory
reclaim heuristics no longer function as they were intended to...

2. The block layer write throttle is full of priority inversions.
Apart from the log IO one I fixed in this series, I noticed that
swap in/out has a major problem. I lost count of the number of OOM
kills that occurred from the swap in path when there were several
processes blocked in wbt_wait() in the block layer in the swap out
path. i.e. if swap out had been making progress, swap in would not
have oom killed. Hence I found it still necessary to throttle direct
reclaim back in the shrinker as there wasn't a realiable way to get
the core reclaim code to throttle effectively.

FWIW, from the swap in/out perspective, this whole inversion problem
is made worse by #1: the congestion_wait/wait_iff_congested
interfaces being broken. Direct reclaim uses wait_iff_congested() to
back off if kswapd has indicated that the node is congested
(PGDAT_CONGESTED) and reclaim is struggling to make progress.
However, this backoff never actually happens now and hence direct
reclaim barrels into the swap code as hard as it can and blocks in
wbt_wait() waiting behind other swap IO instead of backing off and
waiting for some IO to complete and then retrying it's allocation....

3. the memory reclaim code is so full of special case heuristics I'd
be surprised if anyone knows how it actually functions. That's why
I'm not surprised anyone noticed that the congestion backoff code
doesn't actually work properly anymore. And it's impossible to
tell where it is best to place back-off functionality because there
are so many different places that do special case back-offs and
retry loops and they all do it differently.

Hence my attempts to get shrinker driven back-offs to work
effectively have largely been hitting different parts of the code
with a heavy sledgehammer and seeing if there was any observable
effect on the inode cache reclaim patterns and OOM kill resistance.
There's a limit to how effective such brute force discovery can be,
and mixed with the lack of functioning congestion back-off I never
really found the best place to throttle direct reclaim effectively.

So maybe if we fix the bdi congestion interfaces so they work again
we can get rid of the waiting in direct reclaim, but right now I
don't see any other choice. One battle at a time....

Comments, thoughts welcome.

-Dave.


Diffstat;

 drivers/staging/android/ashmem.c |   8 +-
 fs/gfs2/glock.c                  |   5 +-
 fs/gfs2/quota.c                  |   6 +-
 fs/inode.c                       |   2 +-
 fs/nfs/dir.c                     |   6 +-
 fs/super.c                       |   6 +-
 fs/xfs/xfs_buf.c                 |  15 +-
 fs/xfs/xfs_icache.c              | 563 ++++++++-------------------------------
 fs/xfs/xfs_icache.h              |  20 +-
 fs/xfs/xfs_inode.h               |   8 +
 fs/xfs/xfs_inode_item.c          |  28 +-
 fs/xfs/xfs_log.c                 |  19 +-
 fs/xfs/xfs_log_cil.c             |   7 +-
 fs/xfs/xfs_log_priv.h            |   3 +-
 fs/xfs/xfs_mount.c               |  10 +-
 fs/xfs/xfs_mount.h               |   6 +-
 fs/xfs/xfs_qm.c                  |  11 +-
 fs/xfs/xfs_super.c               |  96 +++++--
 fs/xfs/xfs_trans_ail.c           | 104 ++++++--
 fs/xfs/xfs_trans_priv.h          |   8 +-
 include/linux/shrinker.h         |   7 +
 include/linux/swap.h             |   8 +-
 include/trace/events/vmscan.h    |  69 +++--
 mm/slab.c                        |   2 +-
 mm/slob.c                        |   2 +-
 mm/slub.c                        |   2 +-
 mm/vmscan.c                      | 203 +++++++++-----
 net/sunrpc/auth.c                |   5 +-
 28 files changed, 549 insertions(+), 680 deletions(-)


