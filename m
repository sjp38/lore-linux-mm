Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id E00B682F66
	for <linux-mm@kvack.org>; Thu, 15 Oct 2015 12:04:33 -0400 (EDT)
Received: by obbda8 with SMTP id da8so69048965obb.1
        for <linux-mm@kvack.org>; Thu, 15 Oct 2015 09:04:33 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id jb4si7857303obb.59.2015.10.15.09.04.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Oct 2015 09:04:30 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 0/6] KSM fixes
Date: Thu, 15 Oct 2015 18:04:19 +0200
Message-Id: <1444925065-4841-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Petr Holasek <pholasek@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

Hello,

With a stress test leveraging Hugh's allksm old patch, I found a
random memory corruption bug (modify and user after free). It's firing
oopses and generic instability so it's not just theoretical, but it
can only be reproduced in practice with frequent exits and KSM at 100%
CPU load. Note that it's common to give an entire core to KSM when the
system is low on memory in production, http://www.ovirt.org/MoM is
likely to do that as well. The allksm hack (not in this patchset) only
facilitates at creating a workload that exit frequently to increase
the frequency of the race window, without having to patch and rebuild
binaries to call the MADV_MERGEABLE by hand.

I also did some other orthogonal optimization and cleanup.

I'm sending those upstream standalone, separately from some more
complex larger and orthogonal pending changes I'm currently working
on. Those will take more time to review and this fix is higher
priority.

I haven't added -stable but at least 1/6 is definitely a candidate for
stable, IMHO 2/6 would be good idea too. If this passes review and the
fix is confirmed, I can resubmit at least 1/6 to stable. Comments?

Thanks,
Andrea

Andrea Arcangeli (6):
  ksm: fix rmap_item->anon_vma memory corruption and vma user after free
  ksm: add cond_resched() to the rmap_walks
  ksm: don't fail stable tree lookups if walking over stale stable_nodes
  ksm: use the helper method to do the hlist_empty check
  ksm: use find_mergeable_vma in try_to_merge_with_ksm_page
  ksm: unstable_tree_search_insert error checking cleanup

 mm/ksm.c  | 97 ++++++++++++++++++++++++++++++++++++++++++++++++++++++---------
 mm/rmap.c |  4 +++
 2 files changed, 88 insertions(+), 13 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
