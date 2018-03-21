Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 216C06B002F
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:23:58 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id h33so3054057wrh.10
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 12:23:58 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id c45si643172ede.550.2018.03.21.12.23.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 12:23:56 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2LJIYAU047044
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:23:55 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2guuubvdc9-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:23:54 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 21 Mar 2018 19:23:51 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 11/32] docs/vm: ksm.txt: convert to ReST format
Date: Wed, 21 Mar 2018 21:22:27 +0200
In-Reply-To: <1521660168-14372-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1521660168-14372-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1521660168-14372-12-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, kasan-dev@googlegroups.com, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 Documentation/vm/ksm.txt | 215 ++++++++++++++++++++++++-----------------------
 1 file changed, 110 insertions(+), 105 deletions(-)

diff --git a/Documentation/vm/ksm.txt b/Documentation/vm/ksm.txt
index 6686bd2..87e7eef 100644
--- a/Documentation/vm/ksm.txt
+++ b/Documentation/vm/ksm.txt
@@ -1,8 +1,11 @@
-How to use the Kernel Samepage Merging feature
-----------------------------------------------
+.. _ksm:
+
+=======================
+Kernel Samepage Merging
+=======================
 
 KSM is a memory-saving de-duplication feature, enabled by CONFIG_KSM=y,
-added to the Linux kernel in 2.6.32.  See mm/ksm.c for its implementation,
+added to the Linux kernel in 2.6.32.  See ``mm/ksm.c`` for its implementation,
 and http://lwn.net/Articles/306704/ and http://lwn.net/Articles/330589/
 
 The KSM daemon ksmd periodically scans those areas of user memory which
@@ -51,110 +54,112 @@ Applications should be considerate in their use of MADV_MERGEABLE,
 restricting its use to areas likely to benefit.  KSM's scans may use a lot
 of processing power: some installations will disable KSM for that reason.
 
-The KSM daemon is controlled by sysfs files in /sys/kernel/mm/ksm/,
+The KSM daemon is controlled by sysfs files in ``/sys/kernel/mm/ksm/``,
 readable by all but writable only by root:
 
-pages_to_scan    - how many present pages to scan before ksmd goes to sleep
-                   e.g. "echo 100 > /sys/kernel/mm/ksm/pages_to_scan"
-                   Default: 100 (chosen for demonstration purposes)
-
-sleep_millisecs  - how many milliseconds ksmd should sleep before next scan
-                   e.g. "echo 20 > /sys/kernel/mm/ksm/sleep_millisecs"
-                   Default: 20 (chosen for demonstration purposes)
-
-merge_across_nodes - specifies if pages from different numa nodes can be merged.
-                   When set to 0, ksm merges only pages which physically
-                   reside in the memory area of same NUMA node. That brings
-                   lower latency to access of shared pages. Systems with more
-                   nodes, at significant NUMA distances, are likely to benefit
-                   from the lower latency of setting 0. Smaller systems, which
-                   need to minimize memory usage, are likely to benefit from
-                   the greater sharing of setting 1 (default). You may wish to
-                   compare how your system performs under each setting, before
-                   deciding on which to use. merge_across_nodes setting can be
-                   changed only when there are no ksm shared pages in system:
-                   set run 2 to unmerge pages first, then to 1 after changing
-                   merge_across_nodes, to remerge according to the new setting.
-                   Default: 1 (merging across nodes as in earlier releases)
-
-run              - set 0 to stop ksmd from running but keep merged pages,
-                   set 1 to run ksmd e.g. "echo 1 > /sys/kernel/mm/ksm/run",
-                   set 2 to stop ksmd and unmerge all pages currently merged,
-                         but leave mergeable areas registered for next run
-                   Default: 0 (must be changed to 1 to activate KSM,
-                               except if CONFIG_SYSFS is disabled)
-
-use_zero_pages   - specifies whether empty pages (i.e. allocated pages
-                   that only contain zeroes) should be treated specially.
-                   When set to 1, empty pages are merged with the kernel
-                   zero page(s) instead of with each other as it would
-                   happen normally. This can improve the performance on
-                   architectures with coloured zero pages, depending on
-                   the workload. Care should be taken when enabling this
-                   setting, as it can potentially degrade the performance
-                   of KSM for some workloads, for example if the checksums
-                   of pages candidate for merging match the checksum of
-                   an empty page. This setting can be changed at any time,
-                   it is only effective for pages merged after the change.
-                   Default: 0 (normal KSM behaviour as in earlier releases)
-
-max_page_sharing - Maximum sharing allowed for each KSM page. This
-                   enforces a deduplication limit to avoid the virtual
-                   memory rmap lists to grow too large. The minimum
-                   value is 2 as a newly created KSM page will have at
-                   least two sharers. The rmap walk has O(N)
-                   complexity where N is the number of rmap_items
-                   (i.e. virtual mappings) that are sharing the page,
-                   which is in turn capped by max_page_sharing. So
-                   this effectively spread the the linear O(N)
-                   computational complexity from rmap walk context
-                   over different KSM pages. The ksmd walk over the
-                   stable_node "chains" is also O(N), but N is the
-                   number of stable_node "dups", not the number of
-                   rmap_items, so it has not a significant impact on
-                   ksmd performance. In practice the best stable_node
-                   "dup" candidate will be kept and found at the head
-                   of the "dups" list. The higher this value the
-                   faster KSM will merge the memory (because there
-                   will be fewer stable_node dups queued into the
-                   stable_node chain->hlist to check for pruning) and
-                   the higher the deduplication factor will be, but
-                   the slowest the worst case rmap walk could be for
-                   any given KSM page. Slowing down the rmap_walk
-                   means there will be higher latency for certain
-                   virtual memory operations happening during
-                   swapping, compaction, NUMA balancing and page
-                   migration, in turn decreasing responsiveness for
-                   the caller of those virtual memory operations. The
-                   scheduler latency of other tasks not involved with
-                   the VM operations doing the rmap walk is not
-                   affected by this parameter as the rmap walks are
-                   always schedule friendly themselves.
-
-stable_node_chains_prune_millisecs - How frequently to walk the whole
-                   list of stable_node "dups" linked in the
-                   stable_node "chains" in order to prune stale
-                   stable_nodes. Smaller milllisecs values will free
-                   up the KSM metadata with lower latency, but they
-                   will make ksmd use more CPU during the scan. This
-                   only applies to the stable_node chains so it's a
-                   noop if not a single KSM page hit the
-                   max_page_sharing yet (there would be no stable_node
-                   chains in such case).
-
-The effectiveness of KSM and MADV_MERGEABLE is shown in /sys/kernel/mm/ksm/:
-
-pages_shared     - how many shared pages are being used
-pages_sharing    - how many more sites are sharing them i.e. how much saved
-pages_unshared   - how many pages unique but repeatedly checked for merging
-pages_volatile   - how many pages changing too fast to be placed in a tree
-full_scans       - how many times all mergeable areas have been scanned
-
-stable_node_chains - number of stable node chains allocated, this is
-		     effectively the number of KSM pages that hit the
-		     max_page_sharing limit
-stable_node_dups   - number of stable node dups queued into the
-		     stable_node chains
+pages_to_scan
+        how many present pages to scan before ksmd goes to sleep
+        e.g. ``echo 100 > /sys/kernel/mm/ksm/pages_to_scan`` Default: 100
+        (chosen for demonstration purposes)
+
+sleep_millisecs
+        how many milliseconds ksmd should sleep before next scan
+        e.g. ``echo 20 > /sys/kernel/mm/ksm/sleep_millisecs`` Default: 20
+        (chosen for demonstration purposes)
+
+merge_across_nodes
+        specifies if pages from different numa nodes can be merged.
+        When set to 0, ksm merges only pages which physically reside
+        in the memory area of same NUMA node. That brings lower
+        latency to access of shared pages. Systems with more nodes, at
+        significant NUMA distances, are likely to benefit from the
+        lower latency of setting 0. Smaller systems, which need to
+        minimize memory usage, are likely to benefit from the greater
+        sharing of setting 1 (default). You may wish to compare how
+        your system performs under each setting, before deciding on
+        which to use. merge_across_nodes setting can be changed only
+        when there are no ksm shared pages in system: set run 2 to
+        unmerge pages first, then to 1 after changing
+        merge_across_nodes, to remerge according to the new setting.
+        Default: 1 (merging across nodes as in earlier releases)
+
+run
+        set 0 to stop ksmd from running but keep merged pages,
+        set 1 to run ksmd e.g. ``echo 1 > /sys/kernel/mm/ksm/run``,
+        set 2 to stop ksmd and unmerge all pages currently merged, but
+        leave mergeable areas registered for next run Default: 0 (must
+        be changed to 1 to activate KSM, except if CONFIG_SYSFS is
+        disabled)
+
+use_zero_pages
+        specifies whether empty pages (i.e. allocated pages that only
+        contain zeroes) should be treated specially.  When set to 1,
+        empty pages are merged with the kernel zero page(s) instead of
+        with each other as it would happen normally. This can improve
+        the performance on architectures with coloured zero pages,
+        depending on the workload. Care should be taken when enabling
+        this setting, as it can potentially degrade the performance of
+        KSM for some workloads, for example if the checksums of pages
+        candidate for merging match the checksum of an empty
+        page. This setting can be changed at any time, it is only
+        effective for pages merged after the change.  Default: 0
+        (normal KSM behaviour as in earlier releases)
+
+max_page_sharing
+        Maximum sharing allowed for each KSM page. This enforces a
+        deduplication limit to avoid the virtual memory rmap lists to
+        grow too large. The minimum value is 2 as a newly created KSM
+        page will have at least two sharers. The rmap walk has O(N)
+        complexity where N is the number of rmap_items (i.e. virtual
+        mappings) that are sharing the page, which is in turn capped
+        by max_page_sharing. So this effectively spread the the linear
+        O(N) computational complexity from rmap walk context over
+        different KSM pages. The ksmd walk over the stable_node
+        "chains" is also O(N), but N is the number of stable_node
+        "dups", not the number of rmap_items, so it has not a
+        significant impact on ksmd performance. In practice the best
+        stable_node "dup" candidate will be kept and found at the head
+        of the "dups" list. The higher this value the faster KSM will
+        merge the memory (because there will be fewer stable_node dups
+        queued into the stable_node chain->hlist to check for pruning)
+        and the higher the deduplication factor will be, but the
+        slowest the worst case rmap walk could be for any given KSM
+        page. Slowing down the rmap_walk means there will be higher
+        latency for certain virtual memory operations happening during
+        swapping, compaction, NUMA balancing and page migration, in
+        turn decreasing responsiveness for the caller of those virtual
+        memory operations. The scheduler latency of other tasks not
+        involved with the VM operations doing the rmap walk is not
+        affected by this parameter as the rmap walks are always
+        schedule friendly themselves.
+
+stable_node_chains_prune_millisecs
+        How frequently to walk the whole list of stable_node "dups"
+        linked in the stable_node "chains" in order to prune stale
+        stable_nodes. Smaller milllisecs values will free up the KSM
+        metadata with lower latency, but they will make ksmd use more
+        CPU during the scan. This only applies to the stable_node
+        chains so it's a noop if not a single KSM page hit the
+        max_page_sharing yet (there would be no stable_node chains in
+        such case).
+
+The effectiveness of KSM and MADV_MERGEABLE is shown in ``/sys/kernel/mm/ksm/``:
+
+pages_shared
+        how many shared pages are being used
+pages_sharing
+        how many more sites are sharing them i.e. how much saved
+pages_unshared
+        how many pages unique but repeatedly checked for merging
+pages_volatile
+        how many pages changing too fast to be placed in a tree
+full_scans
+        how many times all mergeable areas have been scanned
+stable_node_chains
+        number of stable node chains allocated, this is effectively
+        the number of KSM pages that hit the max_page_sharing limit
+stable_node_dups
+        number of stable node dups queued into the stable_node chains
 
 A high ratio of pages_sharing to pages_shared indicates good sharing, but
 a high ratio of pages_unshared to pages_sharing indicates wasted effort.
-- 
2.7.4
