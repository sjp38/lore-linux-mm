Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9C4246B000C
	for <linux-mm@kvack.org>; Mon, 14 May 2018 04:13:56 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id a21-v6so12453791qtp.19
        for <linux-mm@kvack.org>; Mon, 14 May 2018 01:13:56 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id j2-v6si8461296qtn.252.2018.05.14.01.13.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 May 2018 01:13:55 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w4E84IPZ124864
	for <linux-mm@kvack.org>; Mon, 14 May 2018 04:13:54 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2hy5m6u15k-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 14 May 2018 04:13:54 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 14 May 2018 09:13:52 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 2/3] docs/vm: transhuge: minor updates
Date: Mon, 14 May 2018 11:13:39 +0300
In-Reply-To: <1526285620-453-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1526285620-453-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1526285620-453-3-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: linux-doc <linux-doc@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Some formatting changes and addition of a sentence introducing khugepaged

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 Documentation/vm/transhuge.rst | 47 ++++++++++++++++++++++++++++++++----------
 1 file changed, 36 insertions(+), 11 deletions(-)

diff --git a/Documentation/vm/transhuge.rst b/Documentation/vm/transhuge.rst
index 56d04cbb..47c7e47 100644
--- a/Documentation/vm/transhuge.rst
+++ b/Documentation/vm/transhuge.rst
@@ -9,14 +9,19 @@ Objective
 
 Performance critical computing applications dealing with large memory
 working sets are already running on top of libhugetlbfs and in turn
-hugetlbfs. Transparent Hugepage Support is an alternative means of
+hugetlbfs. Transparent HugePage Support (THP) is an alternative mean of
 using huge pages for the backing of virtual memory with huge pages
 that supports the automatic promotion and demotion of page sizes and
 without the shortcomings of hugetlbfs.
 
-Currently it only works for anonymous memory mappings and tmpfs/shmem.
+Currently THP only works for anonymous memory mappings and tmpfs/shmem.
 But in the future it can expand to other filesystems.
 
+.. note::
+   in the examples below we presume that the basic page size is 4K and
+   the huge page size is 2M, although the actual numbers may vary
+   depending on the CPU architecture.
+
 The reason applications are running faster is because of two
 factors. The first factor is almost completely irrelevant and it's not
 of significant interest because it'll also have the downside of
@@ -28,15 +33,27 @@ only matters the first time the memory is accessed for the lifetime of
 a memory mapping. The second long lasting and much more important
 factor will affect all subsequent accesses to the memory for the whole
 runtime of the application. The second factor consist of two
-components: 1) the TLB miss will run faster (especially with
-virtualization using nested pagetables but almost always also on bare
-metal without virtualization) and 2) a single TLB entry will be
-mapping a much larger amount of virtual memory in turn reducing the
-number of TLB misses. With virtualization and nested pagetables the
-TLB can be mapped of larger size only if both KVM and the Linux guest
-are using hugepages but a significant speedup already happens if only
-one of the two is using hugepages just because of the fact the TLB
-miss is going to run faster.
+components:
+
+1) the TLB miss will run faster (especially with virtualization using
+   nested pagetables but almost always also on bare metal without
+   virtualization)
+
+2) a single TLB entry will be mapping a much larger amount of virtual
+   memory in turn reducing the number of TLB misses. With
+   virtualization and nested pagetables the TLB can be mapped of
+   larger size only if both KVM and the Linux guest are using
+   hugepages but a significant speedup already happens if only one of
+   the two is using hugepages just because of the fact the TLB miss is
+   going to run faster.
+
+THP can be enabled system wide or restricted to certain tasks or even
+memory ranges inside task's address space. Unless THP is completely
+disabled, there is ``khugepaged`` daemon that scans memory and
+collapses sequences of basic pages into huge pages.
+
+The THP behaviour is controlled via :ref:`sysfs <thp_sysfs>`
+interface and using madivse(2) and prctl(2) system calls.
 
 Transparent Hugepage Support maximizes the usefulness of free memory
 if compared to the reservation approach of hugetlbfs by allowing all
@@ -69,9 +86,14 @@ Applications that gets a lot of benefit from hugepages and that don't
 risk to lose memory by using hugepages, should use
 madvise(MADV_HUGEPAGE) on their critical mmapped regions.
 
+.. _thp_sysfs:
+
 sysfs
 =====
 
+Global THP controls
+-------------------
+
 Transparent Hugepage Support for anonymous memory can be entirely disabled
 (mostly for debugging purposes) or only enabled inside MADV_HUGEPAGE
 regions (to avoid the risk of consuming more memory resources) or enabled
@@ -142,6 +164,9 @@ khugepaged will be automatically started when
 transparent_hugepage/enabled is set to "always" or "madvise, and it'll
 be automatically shutdown if it's set to "never".
 
+Khugepaged controls
+-------------------
+
 khugepaged runs usually at low frequency so while one may not want to
 invoke defrag algorithms synchronously during the page faults, it
 should be worth invoking defrag at least in khugepaged. However it's
-- 
2.7.4
