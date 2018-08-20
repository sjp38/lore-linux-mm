Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id ADB936B16F4
	for <linux-mm@kvack.org>; Sun, 19 Aug 2018 23:26:45 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id a70-v6so13755780qkb.16
        for <linux-mm@kvack.org>; Sun, 19 Aug 2018 20:26:45 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e65-v6si7698495qkd.158.2018.08.19.20.26.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 Aug 2018 20:26:44 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 1/1] mm: thp: fix transparent_hugepage/defrag = madvise || always
Date: Sun, 19 Aug 2018 23:26:40 -0400
Message-Id: <20180820032640.9896-2-aarcange@redhat.com>
In-Reply-To: <20180820032640.9896-1-aarcange@redhat.com>
References: <20180820032204.9591-3-aarcange@redhat.com>
 <20180820032640.9896-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>

qemu uses MADV_HUGEPAGE which allows direct compaction (i.e.
__GFP_DIRECT_RECLAIM is set).

The problem is that direct compaction combined with the NUMA
__GFP_THISNODE logic in mempolicy.c is telling reclaim to swap very
hard the local node, instead of failing the allocation if there's no
THP available in the local node.

Such logic was ok until __GFP_THISNODE was added to the THP allocation
path even with MPOL_DEFAULT.

The idea behind the __GFP_THISNODE addition, is that it is better to
provide local memory in PAGE_SIZE units than to use remote NUMA THP
backed memory. That largely depends on the remote latency though, on
threadrippers for example the overhead is relatively low in my
experience.

The combination of __GFP_THISNODE and __GFP_DIRECT_RECLAIM results in
extremely slow qemu startup with vfio, if the VM is larger than the
size of one host NUMA node. This is because it will try very hard to
unsuccessfully swapout get_user_pages pinned pages as result of the
__GFP_THISNODE being set, instead of falling back to PAGE_SIZE
allocations and instead of trying to allocate THP on other nodes (it
would be even worse without vfio type1 GUP pins of course, except it'd
be swapping heavily instead).

It's very easy to reproduce this by setting
transparent_hugepage/defrag to "always", even with a simple memhog.

1) This can be fixed by retaining the __GFP_THISNODE logic also for
   __GFP_DIRECT_RELCAIM by allowing only one compaction run. Not even
   COMPACT_SKIPPED (i.e. compaction failing because not enough free
   memory in the zone) should be allowed to invoke reclaim.

2) An alternative is not use __GFP_THISNODE if __GFP_DIRECT_RELCAIM
   has been set by the caller (i.e. MADV_HUGEPAGE or
   defrag="always"). That would keep the NUMA locality restriction
   only when __GFP_DIRECT_RECLAIM is not set by the caller. So THP
   will be provided from remote nodes if available before falling back
   to PAGE_SIZE units in the local node, but an app using defrag =
   always (or madvise with MADV_HUGEPAGE) supposedly prefers that.

These are the results of 1) (higher GB/s is better).

Finished: 30 GB mapped, 10.188535s elapsed, 2.94GB/s
Finished: 34 GB mapped, 12.274777s elapsed, 2.77GB/s
Finished: 38 GB mapped, 13.847840s elapsed, 2.74GB/s
Finished: 42 GB mapped, 14.288587s elapsed, 2.94GB/s

Finished: 30 GB mapped, 8.907367s elapsed, 3.37GB/s
Finished: 34 GB mapped, 10.724797s elapsed, 3.17GB/s
Finished: 38 GB mapped, 14.272882s elapsed, 2.66GB/s
Finished: 42 GB mapped, 13.929525s elapsed, 3.02GB/s

These are the results of 2) (higher GB/s is better).

Finished: 30 GB mapped, 10.163159s elapsed, 2.95GB/s
Finished: 34 GB mapped, 11.806526s elapsed, 2.88GB/s
Finished: 38 GB mapped, 10.369081s elapsed, 3.66GB/s
Finished: 42 GB mapped, 12.357719s elapsed, 3.40GB/s

Finished: 30 GB mapped, 8.251396s elapsed, 3.64GB/s
Finished: 34 GB mapped, 12.093030s elapsed, 2.81GB/s
Finished: 38 GB mapped, 11.824903s elapsed, 3.21GB/s
Finished: 42 GB mapped, 15.950661s elapsed, 2.63GB/s

This is current upstream (higher GB/s is better).

Finished: 30 GB mapped, 8.821632s elapsed, 3.40GB/s
Finished: 34 GB mapped, 341.979543s elapsed, 0.10GB/s
Finished: 38 GB mapped, 761.933231s elapsed, 0.05GB/s
Finished: 42 GB mapped, 1188.409235s elapsed, 0.04GB/s

vfio is a good test because by pinning all memory it avoids the
swapping and reclaim only wastes CPU, a memhog based test would
created swapout storms and supposedly show a bigger stddev.

What is better between 1) and 2) depends on the hardware and on the
software. Virtualization EPT/NTP gets a bigger boost from THP as well
than host applications.

This commit implements 2).

Reported-by: Alex Williamson <alex.williamson@redhat.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/mempolicy.c | 32 ++++++++++++++++++++++++++++++--
 1 file changed, 30 insertions(+), 2 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index d6512ef28cde..fb7f9581a835 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2047,8 +2047,36 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
 
 		if (!nmask || node_isset(hpage_node, *nmask)) {
 			mpol_cond_put(pol);
-			page = __alloc_pages_node(hpage_node,
-						gfp | __GFP_THISNODE, order);
+			/*
+			 * We cannot invoke reclaim if __GFP_THISNODE
+			 * is set. Invoking reclaim with
+			 * __GFP_THISNODE set, would cause THP
+			 * allocations to trigger heavy swapping
+			 * despite there may be tons of free memory
+			 * (including potentially plenty of THP
+			 * already available in the buddy) on all the
+			 * other NUMA nodes.
+			 *
+			 * At most we could invoke compaction when
+			 * __GFP_THISNODE is set (but we would need to
+			 * refrain from invoking reclaim even if
+			 * compaction returned COMPACT_SKIPPED because
+			 * there wasn't not enough memory to succeed
+			 * compaction). For now just avoid
+			 * __GFP_THISNODE instead of limiting the
+			 * allocation path to a strict and single
+			 * compaction invocation.
+			 *
+			 * Supposedly if direct reclaim was enabled by
+			 * the caller, the app prefers THP regardless
+			 * of the node it comes from so this would be
+			 * more desiderable behavior than only
+			 * providing THP originated from the local
+			 * node in such case.
+			 */
+			if (!(gfp & __GFP_DIRECT_RECLAIM))
+				gfp |= __GFP_THISNODE;
+			page = __alloc_pages_node(hpage_node, gfp, order);
 			goto out;
 		}
 	}
