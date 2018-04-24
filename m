Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id ACE116B000C
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 02:40:56 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id k23-v6so13762596qtj.16
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 23:40:56 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id p18si1604186qvi.150.2018.04.23.23.40.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Apr 2018 23:40:55 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3O6eXMT117035
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 02:40:54 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2hhvswpm9n-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 02:40:52 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 24 Apr 2018 07:40:42 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 4/7] docs/vm: ksm: reshuffle text between "sysfs" and "design" sections
Date: Tue, 24 Apr 2018 09:40:25 +0300
In-Reply-To: <1524552028-7017-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1524552028-7017-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1524552028-7017-5-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-doc <linux-doc@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

The description of "max_page_sharing" sysfs attribute includes lots of
implementation details that more naturally belong in the "Design"
section.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 Documentation/vm/ksm.rst | 51 ++++++++++++++++++++++++++++--------------------
 1 file changed, 30 insertions(+), 21 deletions(-)

diff --git a/Documentation/vm/ksm.rst b/Documentation/vm/ksm.rst
index 0e5a085..00961b8 100644
--- a/Documentation/vm/ksm.rst
+++ b/Documentation/vm/ksm.rst
@@ -133,31 +133,21 @@ use_zero_pages
 
 max_page_sharing
         Maximum sharing allowed for each KSM page. This enforces a
-        deduplication limit to avoid the virtual memory rmap lists to
-        grow too large. The minimum value is 2 as a newly created KSM
-        page will have at least two sharers. The rmap walk has O(N)
-        complexity where N is the number of rmap_items (i.e. virtual
-        mappings) that are sharing the page, which is in turn capped
-        by ``max_page_sharing``. So this effectively spreads the linear
-        O(N) computational complexity from rmap walk context over
-        different KSM pages. The ksmd walk over the stable_node
-        "chains" is also O(N), but N is the number of stable_node
-        "dups", not the number of rmap_items, so it has not a
-        significant impact on ksmd performance. In practice the best
-        stable_node "dup" candidate will be kept and found at the head
-        of the "dups" list. The higher this value the faster KSM will
-        merge the memory (because there will be fewer stable_node dups
-        queued into the stable_node chain->hlist to check for pruning)
-        and the higher the deduplication factor will be, but the
-        slowest the worst case rmap walk could be for any given KSM
-        page. Slowing down the rmap_walk means there will be higher
+        deduplication limit to avoid high latency for virtual memory
+        operations that involve traversal of the virtual mappings that
+        share the KSM page. The minimum value is 2 as a newly created
+        KSM page will have at least two sharers. The higher this value
+        the faster KSM will merge the memory and the higher the
+        deduplication factor will be, but the slower the worst case
+        virtual mappings traversal could be for any given KSM
+        page. Slowing down this traversal means there will be higher
         latency for certain virtual memory operations happening during
         swapping, compaction, NUMA balancing and page migration, in
         turn decreasing responsiveness for the caller of those virtual
         memory operations. The scheduler latency of other tasks not
-        involved with the VM operations doing the rmap walk is not
-        affected by this parameter as the rmap walks are always
-        schedule friendly themselves.
+        involved with the VM operations doing the virtual mappings
+        traversal is not affected by this parameter as these
+        traversals are always schedule friendly themselves.
 
 stable_node_chains_prune_millisecs
         How frequently to walk the whole list of stable_node "dups"
@@ -240,6 +230,25 @@ if compared to an unlimited list of reverse mappings. It is still
 enforced that there cannot be KSM page content duplicates in the
 stable tree itself.
 
+The deduplication limit enforced by ``max_page_sharing`` is required
+to avoid the virtual memory rmap lists to grow too large. The rmap
+walk has O(N) complexity where N is the number of rmap_items
+(i.e. virtual mappings) that are sharing the page, which is in turn
+capped by ``max_page_sharing``. So this effectively spreads the linear
+O(N) computational complexity from rmap walk context over different
+KSM pages. The ksmd walk over the stable_node "chains" is also O(N),
+but N is the number of stable_node "dups", not the number of
+rmap_items, so it has not a significant impact on ksmd performance. In
+practice the best stable_node "dup" candidate will be kept and found
+at the head of the "dups" list.
+
+High values of ``max_page_sharing`` result in faster memory merging
+(because there will be fewer stable_node dups queued into the
+stable_node chain->hlist to check for pruning) and higher
+deduplication factor at the expense of slower worst case for rmap
+walks for any KSM page which can happen during swapping, compaction,
+NUMA balancing and page migration.
+
 Reference
 ---------
 .. kernel-doc:: mm/ksm.c
-- 
2.7.4
