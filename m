Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id D35B66B0038
	for <linux-mm@kvack.org>; Fri, 12 May 2017 15:38:11 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id x53so22627321qtx.14
        for <linux-mm@kvack.org>; Fri, 12 May 2017 12:38:11 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b134si4155717qkg.182.2017.05.12.12.38.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 May 2017 12:38:10 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [RFC] [PATCH 0/1] ksm: fix use after free with merge_across_nodes = 0
Date: Fri, 12 May 2017 21:38:04 +0200
Message-Id: <20170512193805.8807-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: Evgheni Dereveanchin <ederevea@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Petr Holasek <pholasek@redhat.com>, Hugh Dickins <hughd@google.com>, Arjan van de Ven <arjan@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Gavin Guo <gavin.guo@canonical.com>, Jay Vosburgh <jay.vosburgh@canonical.com>, Mel Gorman <mgorman@techsingularity.net>

Hello,

The KSMscale patch in -mm (not yet upstream) is fundamental for
enterprise use and in turn it's included in -mm, RHEL, CentoOS and
Ubuntu and it'd be great if it could be merged upstream (especially
after solving this problem with merge_across_nodes = 0 ...).

https://marc.info/?l=linux-mm&m=149265809928003&w=2
http://kernel.ubuntu.com/~gavinguo/sf00131845/numa-131845.svg
http://kernel.ubuntu.com/~gavinguo/sf00131845/virtual_appliances_loading.png

A few weeks ago I got a report that with merge_across_nodes set to 0
KSM would eventually crash with an user after free (I assumed it was
an use after free because the kindly provided crashdump showed a
corrupted stable_node). Everything was again rock solid after setting
merge_across_nodes back to 1.

merge_across_nodes set to 0 is a tuning performance optimization
for NUMA that creates a different copy of KSM pages for each NUMA node
with a KSM stable_tree for each node (instead of sharing the same
equal memory across the whole system with a single stable_tree).

I couldn't reproduce this bug so far but there's a definitive use
after free in the merge_across_nodes = 0 path, so it would help if who
can reproduce already can give this a spin (untested... or better
tested but only in a NUMA balancing environment that never reproduced the use
after free in the first place so it's inconclusive).

In production I recommend to leave the merge_across_nodes default
value set to 1 if running with the KSMscale patch applied for the time
being, until this is confirmed fixed.

Again this fix should be considered untested so it should be run in testing
environment only.

Thanks,
Andrea

Andrea Arcangeli (1):
  ksm: fix use after free with merge_across_nodes = 0

 mm/ksm.c | 66 +++++++++++++++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 55 insertions(+), 11 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
