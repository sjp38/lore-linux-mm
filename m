Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 830736B0292
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 14:45:35 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id r14so22300962qte.11
        for <linux-mm@kvack.org>; Thu, 20 Jul 2017 11:45:35 -0700 (PDT)
Received: from mail-qt0-x243.google.com (mail-qt0-x243.google.com. [2607:f8b0:400d:c0d::243])
        by mx.google.com with ESMTPS id o3si2398482qtc.72.2017.07.20.11.45.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jul 2017 11:45:34 -0700 (PDT)
Received: by mail-qt0-x243.google.com with SMTP id 50so4525100qtz.0
        for <linux-mm@kvack.org>; Thu, 20 Jul 2017 11:45:34 -0700 (PDT)
From: josef@toxicpanda.com
Subject: [PATCH 0/2][V3] slab and general reclaim improvements
Date: Thu, 20 Jul 2017 14:45:29 -0400
Message-Id: <1500576331-31214-1-git-send-email-jbacik@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org, riel@redhat.com, akpm@linux-foundation.org, david@fromorbit.com, kernel-team@fb.com

This is a new set of patches to address some slab reclaim issues I observed when
trying to convert btrfs over to a purely slab meta data system.  The problem is
our slab reclaim amounts are based on how page cache scanning goes, which is not
related to how much slab is in use on the system.  This means we waste a lot of
cycles trying to reclaim really small numbers of objects and thus induce a huge
latency hit when we hit memory pressure.

The second patch is to fix another problem I noticed, namely that we will
constantly evict active pages instead of trying to evict shorter lived pages and
objects.  You can run the following test to see the behavior

https://github.com/josefbacik/debug-scripts/blob/master/cache-pressure/cache-pressure.sh

Reading two files that fit nicely into RAM, and then add slab pressure from
fs_mark and you'll see that we will evict both files 3 or 4 times during the
run.  With my patches we don't evict any of the file pages at all, only the slab
pressure.

CHANGES SINCE V2:

After discussions with Minchan and Dave I went back to the drawing board.
Dave's suggestion of shrinker specific callbacks to allow shrinkers to reclaim
at their own rate was intriguing so I did this first.  Unfortunately this fell
apart as I couldn't figure out a scheme to make the reclaim stuff work without
needlessly inducing latency during 'stable' periods.  Without a view of the
whole system it's hard to know when to trigger scanning of active objects
without wasting CPU cycles that aren't actually needed.  We will end up starting
our background thread and scanning objects when in reality our workload would
fit perfectly fine in memory.

Minchan's main complaint of my stuff was that it was too aggressive, and any
attempt to short circuit the aggression would be unfair to other shrinkers.  So
instead use his idea of using sc->priority to determine our scan count.  But
instead of using the traditional ratio, just use scan = nr_objects >>
sc->priority.  This gets us what we do with the LRU, which is scan = pages >>
sc->priority, and gives us an appropriate amount of aggressiveness for slab
reclaim.

I've dropped the other two patches around stopping slab reclaim, and have
changed the slab pressure to be based on sc->priority, which is consistent with
every other LRU on the system, and gives me the same results in my testcases.
Thanks,

Josef

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
