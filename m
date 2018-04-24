Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 650706B0007
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 02:40:44 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id v11-v6so21394636wri.13
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 23:40:44 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 5si1371808edi.408.2018.04.23.23.40.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Apr 2018 23:40:42 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3O6d9Tu037745
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 02:40:41 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2hhvkwxayd-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 02:40:40 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 24 Apr 2018 07:40:39 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 2/7] docs/vm: ksm: (mostly) formatting updates
Date: Tue, 24 Apr 2018 09:40:23 +0300
In-Reply-To: <1524552028-7017-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1524552028-7017-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1524552028-7017-3-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-doc <linux-doc@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Aside from the formatting:
* fixed typos
* added section and sub-section headers
* moved ksmd overview after the description of KSM origins

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 Documentation/vm/ksm.rst | 110 +++++++++++++++++++++++++++++------------------
 1 file changed, 69 insertions(+), 41 deletions(-)

diff --git a/Documentation/vm/ksm.rst b/Documentation/vm/ksm.rst
index 87e7eef..786d460 100644
--- a/Documentation/vm/ksm.rst
+++ b/Documentation/vm/ksm.rst
@@ -4,34 +4,50 @@
 Kernel Samepage Merging
 =======================
 
+Overview
+========
+
 KSM is a memory-saving de-duplication feature, enabled by CONFIG_KSM=y,
 added to the Linux kernel in 2.6.32.  See ``mm/ksm.c`` for its implementation,
 and http://lwn.net/Articles/306704/ and http://lwn.net/Articles/330589/
 
-The KSM daemon ksmd periodically scans those areas of user memory which
-have been registered with it, looking for pages of identical content which
-can be replaced by a single write-protected page (which is automatically
-copied if a process later wants to update its content).
-
 KSM was originally developed for use with KVM (where it was known as
 Kernel Shared Memory), to fit more virtual machines into physical memory,
 by sharing the data common between them.  But it can be useful to any
 application which generates many instances of the same data.
 
+The KSM daemon ksmd periodically scans those areas of user memory
+which have been registered with it, looking for pages of identical
+content which can be replaced by a single write-protected page (which
+is automatically copied if a process later wants to update its
+content). The amount of pages that KSM daemon scans in a single pass
+and the time between the passes are configured using :ref:`sysfs
+intraface <ksm_sysfs>`
+
 KSM only merges anonymous (private) pages, never pagecache (file) pages.
 KSM's merged pages were originally locked into kernel memory, but can now
 be swapped out just like other user pages (but sharing is broken when they
 are swapped back in: ksmd must rediscover their identity and merge again).
 
+Controlling KSM with madvise
+============================
+
 KSM only operates on those areas of address space which an application
 has advised to be likely candidates for merging, by using the madvise(2)
-system call: int madvise(addr, length, MADV_MERGEABLE).
+system call::
+
+	int madvise(addr, length, MADV_MERGEABLE)
+
+The app may call
+
+::
+
+	int madvise(addr, length, MADV_UNMERGEABLE)
 
-The app may call int madvise(addr, length, MADV_UNMERGEABLE) to cancel
-that advice and restore unshared pages: whereupon KSM unmerges whatever
-it merged in that range.  Note: this unmerging call may suddenly require
-more memory than is available - possibly failing with EAGAIN, but more
-probably arousing the Out-Of-Memory killer.
+to cancel that advice and restore unshared pages: whereupon KSM
+unmerges whatever it merged in that range.  Note: this unmerging call
+may suddenly require more memory than is available - possibly failing
+with EAGAIN, but more probably arousing the Out-Of-Memory killer.
 
 If KSM is not configured into the running kernel, madvise MADV_MERGEABLE
 and MADV_UNMERGEABLE simply fail with EINVAL.  If the running kernel was
@@ -43,7 +59,7 @@ MADV_UNMERGEABLE is applied to a range which was never MADV_MERGEABLE.
 
 If a region of memory must be split into at least one new MADV_MERGEABLE
 or MADV_UNMERGEABLE region, the madvise may return ENOMEM if the process
-will exceed vm.max_map_count (see Documentation/sysctl/vm.txt).
+will exceed ``vm.max_map_count`` (see Documentation/sysctl/vm.txt).
 
 Like other madvise calls, they are intended for use on mapped areas of
 the user address space: they will report ENOMEM if the specified range
@@ -54,21 +70,28 @@ Applications should be considerate in their use of MADV_MERGEABLE,
 restricting its use to areas likely to benefit.  KSM's scans may use a lot
 of processing power: some installations will disable KSM for that reason.
 
+.. _ksm_sysfs:
+
+KSM daemon sysfs interface
+==========================
+
 The KSM daemon is controlled by sysfs files in ``/sys/kernel/mm/ksm/``,
 readable by all but writable only by root:
 
 pages_to_scan
-        how many present pages to scan before ksmd goes to sleep
-        e.g. ``echo 100 > /sys/kernel/mm/ksm/pages_to_scan`` Default: 100
-        (chosen for demonstration purposes)
+        how many pages to scan before ksmd goes to sleep
+        e.g. ``echo 100 > /sys/kernel/mm/ksm/pages_to_scan``.
+
+        Default: 100 (chosen for demonstration purposes)
 
 sleep_millisecs
         how many milliseconds ksmd should sleep before next scan
-        e.g. ``echo 20 > /sys/kernel/mm/ksm/sleep_millisecs`` Default: 20
-        (chosen for demonstration purposes)
+        e.g. ``echo 20 > /sys/kernel/mm/ksm/sleep_millisecs``
+
+        Default: 20 (chosen for demonstration purposes)
 
 merge_across_nodes
-        specifies if pages from different numa nodes can be merged.
+        specifies if pages from different NUMA nodes can be merged.
         When set to 0, ksm merges only pages which physically reside
         in the memory area of same NUMA node. That brings lower
         latency to access of shared pages. Systems with more nodes, at
@@ -77,19 +100,21 @@ merge_across_nodes
         minimize memory usage, are likely to benefit from the greater
         sharing of setting 1 (default). You may wish to compare how
         your system performs under each setting, before deciding on
-        which to use. merge_across_nodes setting can be changed only
-        when there are no ksm shared pages in system: set run 2 to
+        which to use. ``merge_across_nodes`` setting can be changed only
+        when there are no ksm shared pages in the system: set run 2 to
         unmerge pages first, then to 1 after changing
-        merge_across_nodes, to remerge according to the new setting.
+        ``merge_across_nodes``, to remerge according to the new setting.
+
         Default: 1 (merging across nodes as in earlier releases)
 
 run
-        set 0 to stop ksmd from running but keep merged pages,
-        set 1 to run ksmd e.g. ``echo 1 > /sys/kernel/mm/ksm/run``,
-        set 2 to stop ksmd and unmerge all pages currently merged, but
-        leave mergeable areas registered for next run Default: 0 (must
-        be changed to 1 to activate KSM, except if CONFIG_SYSFS is
-        disabled)
+        * set to 0 to stop ksmd from running but keep merged pages,
+        * set to 1 to run ksmd e.g. ``echo 1 > /sys/kernel/mm/ksm/run``,
+        * set to 2 to stop ksmd and unmerge all pages currently merged, but
+	  leave mergeable areas registered for next run.
+
+        Default: 0 (must be changed to 1 to activate KSM, except if
+        CONFIG_SYSFS is disabled)
 
 use_zero_pages
         specifies whether empty pages (i.e. allocated pages that only
@@ -102,8 +127,9 @@ use_zero_pages
         KSM for some workloads, for example if the checksums of pages
         candidate for merging match the checksum of an empty
         page. This setting can be changed at any time, it is only
-        effective for pages merged after the change.  Default: 0
-        (normal KSM behaviour as in earlier releases)
+        effective for pages merged after the change.
+
+        Default: 0 (normal KSM behaviour as in earlier releases)
 
 max_page_sharing
         Maximum sharing allowed for each KSM page. This enforces a
@@ -112,7 +138,7 @@ max_page_sharing
         page will have at least two sharers. The rmap walk has O(N)
         complexity where N is the number of rmap_items (i.e. virtual
         mappings) that are sharing the page, which is in turn capped
-        by max_page_sharing. So this effectively spread the the linear
+        by ``max_page_sharing``. So this effectively spreads the linear
         O(N) computational complexity from rmap walk context over
         different KSM pages. The ksmd walk over the stable_node
         "chains" is also O(N), but N is the number of stable_node
@@ -140,7 +166,7 @@ stable_node_chains_prune_millisecs
         metadata with lower latency, but they will make ksmd use more
         CPU during the scan. This only applies to the stable_node
         chains so it's a noop if not a single KSM page hit the
-        max_page_sharing yet (there would be no stable_node chains in
+        ``max_page_sharing`` yet (there would be no stable_node chains in
         such case).
 
 The effectiveness of KSM and MADV_MERGEABLE is shown in ``/sys/kernel/mm/ksm/``:
@@ -157,27 +183,29 @@ full_scans
         how many times all mergeable areas have been scanned
 stable_node_chains
         number of stable node chains allocated, this is effectively
-        the number of KSM pages that hit the max_page_sharing limit
+        the number of KSM pages that hit the ``max_page_sharing`` limit
 stable_node_dups
         number of stable node dups queued into the stable_node chains
 
-A high ratio of pages_sharing to pages_shared indicates good sharing, but
-a high ratio of pages_unshared to pages_sharing indicates wasted effort.
-pages_volatile embraces several different kinds of activity, but a high
-proportion there would also indicate poor use of madvise MADV_MERGEABLE.
+A high ratio of ``pages_sharing`` to ``pages_shared`` indicates good
+sharing, but a high ratio of ``pages_unshared`` to ``pages_sharing``
+indicates wasted effort.  ``pages_volatile`` embraces several
+different kinds of activity, but a high proportion there would also
+indicate poor use of madvise MADV_MERGEABLE.
 
-The maximum possible page_sharing/page_shared ratio is limited by the
-max_page_sharing tunable. To increase the ratio max_page_sharing must
+The maximum possible ``pages_sharing/pages_shared`` ratio is limited by the
+``max_page_sharing`` tunable. To increase the ratio ``max_page_sharing`` must
 be increased accordingly.
 
-The stable_node_dups/stable_node_chains ratio is also affected by the
-max_page_sharing tunable, and an high ratio may indicate fragmentation
+The ``stable_node_dups/stable_node_chains`` ratio is also affected by the
+``max_page_sharing`` tunable, and an high ratio may indicate fragmentation
 in the stable_node dups, which could be solved by introducing
 fragmentation algorithms in ksmd which would refile rmap_items from
-one stable_node dup to another stable_node dup, in order to freeup
+one stable_node dup to another stable_node dup, in order to free up
 stable_node "dups" with few rmap_items in them, but that may increase
 the ksmd CPU usage and possibly slowdown the readonly computations on
 the KSM pages of the applications.
 
+--
 Izik Eidus,
 Hugh Dickins, 17 Nov 2009
-- 
2.7.4
