Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9BBCC6B0253
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 14:26:14 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id d75so25424826qkc.0
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 11:26:14 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h39si6762833qtc.171.2017.01.12.11.26.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jan 2017 11:26:13 -0800 (PST)
Date: Thu, 12 Jan 2017 20:26:11 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [LSF/MM ATTEND] 2017 userfaultfd-WP, node reclaim vs zone
 compaction, THP
Message-ID: <20170112192611.GO4947@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org

Hello,

I'd like to attend this year LSF/MM summit. Some topics of my interest
would be:

1) userfaultfd WP and soft-dirty interaction (i.e. obsolete
   soft-dirty). Arch-dependent changes are required for this: from
   one-more VM_FAULT_RETRY in a row to be returned by handle_mm_fault,
   to a special bit in pagetable and swap entry, very similarly to
   what soft dirty has been doing.

   The main rationale to eventually obsolete soft-dirty is that
   userfaultfd WP won't require O(N) pagetable scans to find out which
   pages got dirty (where N is the number of pagetables mapping the
   region to be monitored, not the number of pages that got
   dirty). userfaultfd will have the same runtime cost regardless of
   the size of the area to be monitored for writes, similar to PML
   (Page Modification Logging) feature in the CPU for VMX.

   soft-dirty is also triggering write protect faults, the only
   advantage it has for some usage (which is a disadvantage for other
   usages like database/KVM live snapshotting) is it's asynchronous,
   but userfaultfs can also add an asynchronous feature mode later by
   allocating and queuing up uffd messages, instead of blocking the
   tasks.

   If there's interested I could also summarize the current
   userfaultfd status with hugetlbfs/shmem/non-cooperative support
   currently merged in -mm.

2) the s/zone/node/ conversion of the page LRU feels still incomplete,
   as compaction still works zone based and can't compact memory
   crossing the zone boundaries. While it's is simpler to do
   compaction that way, it's not ideal because reclaim works node
   based.

   To avoid dropping some patches that implement "compaction aware
   zone_reclaim_mode" (i.e. now node_reclaim_mode) I'm still running
   with zone LRU, although I don't disagree with the node LRU per se,
   my only issue is that compaction still work zone based and that
   collides with those changes.

   With reclaim working node based and compaction working zone
   based, I would need to call a blind for_each_zone(node)
   compaction() loop which is far from ideal compared to compaction
   crossing the zone boundary. Most pages that can be migrated by
   compaction can go in any zone, not all but we could record the page
   classzone.

   On a side note just yesterday I got this message from kbuild bot:

---
FYI, we noticed a 7.2% improvement of pbzip2.throughput due to commit:


commit: 59ebc9c2dff1bd6476f621e1c9802dc40c8c5e98 ("Revert
"mm/page_alloc.c: recalculate some of node threshold when
on/offline memory"")
https://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git master
---

   This may be a statistical blip, I didn't investigate why zone LRU
   should be faster for this test but I assume kbuild is reliable and
   the result reproducible.

3) I'm always interested in the THP related developments, from native
   swapout (perhaps native swapin) to ext4 support etc..

Thank you,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
