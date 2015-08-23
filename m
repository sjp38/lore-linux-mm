Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f174.google.com (mail-yk0-f174.google.com [209.85.160.174])
	by kanga.kvack.org (Postfix) with ESMTP id 176E56B0038
	for <linux-mm@kvack.org>; Sun, 23 Aug 2015 00:48:43 -0400 (EDT)
Received: by ykdt205 with SMTP id t205so106898548ykd.1
        for <linux-mm@kvack.org>; Sat, 22 Aug 2015 21:48:42 -0700 (PDT)
Received: from ns.horizon.com (ns.horizon.com. [71.41.210.147])
        by mx.google.com with SMTP id t127si8106979ywb.11.2015.08.22.21.48.41
        for <linux-mm@kvack.org>;
        Sat, 22 Aug 2015 21:48:42 -0700 (PDT)
Date: 23 Aug 2015 00:48:39 -0400
Message-ID: <20150823044839.5727.qmail@ns.horizon.com>
From: "George Spelvin" <linux@horizon.com>
Subject: Re: [PATCH 0/3] mm/vmalloc: Cache the /proc/meminfo vmalloc statistics
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mingo@kernel.org
Cc: linux@horizon.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org

Linus wrote:
> I don't think any of this can be called "correct", in that the
> unlocked accesses to the cached state are clearly racy, but I think
> it's very much "acceptable".

I'd think you could easily fix that with a seqlock-like system.

What makes it so simple is that you can always fall back to
calc_vmalloc_info if there's any problem, rather than looping or blocking.

The basic idea is that you have a seqlock counter, but if either of
the two lsbits are set, the cached information is stale.

Basically, you need a seqlock and a spinlock.  The seqlock does
most of the work, and the spinlock ensures that there's only one
updater of the cache.

vmap_unlock() does set_bit(0, &seq->sequence).  This marks the information
as stale.

get_vmalloc_info reads the seqlock.  There are two case:
- If the two lsbits are 10, the cached information is valid.
  Copy it out, re-check the seqlock, and loop if the sequence
  number changes.
- In any other case, the cached information is
  not valid.
  - Try to obtain the spinlock.  Do not block if it's unavailable.
    - If unavailable, do not block.
    - If the lock is acquired:
      - Set the sequence to (sequence | 3) + 1 (we're the only writer)
      - This bumps the sequence number and leaves the lsbits at 00 (invalid)
      - Memory barrier TBD.  Do the RCU ops in calc_vmalloc_info do it for us?
  - Call calc_vmalloc_info
  - If we obtained the spinlock earlier:
    - Copy our vmi to cached_info
    - smp_wmb()
    - set_bit(1, &seq->sequence).  This marks the information as valid,
      as long as bit 0 is still clear.
    - Release the spinlock.

Basically, bit 0 says "vmalloc info has changed", and bit 1 says
"vmalloc cache has been updated".  This clears bit 0 before
starting the update so that an update during calc_vmalloc_info
will force a new update.

So the three case are basically:
00 - calc_vmalloc_info() in progress
01 - vmap_unlock() during calc_vmalloc_info()
10 - cached_info is valid
11 - vmap_unlock has invalidated cached_info, awaiting refresh

Logically, the sequence number should be initialized to ...01,
but the code above handles 00 okay.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
