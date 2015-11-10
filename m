Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id E7B146B0259
	for <linux-mm@kvack.org>; Tue, 10 Nov 2015 13:44:45 -0500 (EST)
Received: by igcph11 with SMTP id ph11so56471354igc.1
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 10:44:45 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g79si6335091ioj.81.2015.11.10.10.44.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Nov 2015 10:44:45 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: RFC [PATCH 0/1] ksm: introduce ksm_max_page_sharing per page deduplication limit
Date: Tue, 10 Nov 2015 19:44:40 +0100
Message-Id: <1447181081-30056-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>
Cc: linux-mm@kvack.org, Petr Holasek <pholasek@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@linux.intel.com>

Hello,

this patch solves KSM computational complexity issues in the rmap walk
that created stalls during enterprise usage on large systems with lots
of RAM and CPUs. It's incremental with the patches posted earlier and
it should apply clean to upstream.

Special review should be done on the KSM page migration code with
merge_across_nodes == 0. I tested merge_across_nodes == 0 but not very
hard. The old code in this area in fact looked flakey in case two KSM
pages of equal content ended up being migrated in the same node. With
this new code instead they end up in the same "chain" in the right
stable_tree or the page under migration is merged into an existing KSM
page of the right node if page_mapcount allows for it.

At the moment the chains aren't defragmented but they could be. It'd
be enough to refile a couple of remap_items for each prune of the
stable_node_chain, from a "dup" with the lowest rmap_hlist_len to the
dup with the highest (not yet full) rmap_hlist_len. The rmap_hlist_len
of the "dup" that got its rmap_item removed, would drop to zero and it
would be garbage collected at the next prune pass and the
page_sharing/page_shared ratio would increase up to the peak possible
given the current max_page_sharing. However the "chain" prune logic
already tries to compact the "dups" in as few stable nodes as
possible. Overall if any defragmentation logic of the stable_node
"chains" really turn out to be good idea, it's better to do it in an
incremental patch as it's an orthogonal problem.

Changing max_page_sharing without first doing "echo 2
>/sys/kernel/mm/ksm/run" (that get rid of the entire stable rbtree)
would also be possible but I didn't think it was worth it as certain
asserts become not enforceable anymore.

The code has perhaps too much asserts, mostly VM_BUG_ON though (the
few BUG_ON are there because in those few cases if the asserts trigger
and ksmd doesn't stop there, it'd corrupt memory randomly). I can
remove the VM_BUG_ON when this gets more testing and gets out of
RFC. Also note, there's no VM_WARN_ON available.

Some testsuite that pretends to know the internals of KSM and predict
exact page_sharing/page_shared values, may give false positive with
this patch applied, but it's enough to set max_page_sharing to a very
large value in order to pass the old tests. Ideally those testsuites
should learn about the max_page_sharing limit and predict the new
page_sharing/shared results with the new code to validate it.

Comments welcome, thanks,
Andrea

Andrea Arcangeli (1):
  ksm: introduce ksm_max_page_sharing per page deduplication limit

 Documentation/vm/ksm.txt |  63 ++++
 mm/ksm.c                 | 731 ++++++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 728 insertions(+), 66 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
