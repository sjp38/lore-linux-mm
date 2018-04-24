Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id F1B386B0008
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 02:40:47 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id u13-v6so21363590wre.1
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 23:40:47 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id v8si8729121edf.311.2018.04.23.23.40.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Apr 2018 23:40:46 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3O6d3vq038639
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 02:40:45 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2hhy9y8n5j-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 02:40:44 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 24 Apr 2018 07:40:40 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 3/7] docs/vm: ksm: add "Design" section
Date: Tue, 24 Apr 2018 09:40:24 +0300
In-Reply-To: <1524552028-7017-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1524552028-7017-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1524552028-7017-4-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-doc <linux-doc@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Include the KSM description from the source code comment, add a subsection
about reverse mapping and include kernel-doc references for KSM data
structures.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 Documentation/vm/ksm.rst | 39 +++++++++++++++++++++++++++++++++++++++
 1 file changed, 39 insertions(+)

diff --git a/Documentation/vm/ksm.rst b/Documentation/vm/ksm.rst
index 786d460..0e5a085 100644
--- a/Documentation/vm/ksm.rst
+++ b/Documentation/vm/ksm.rst
@@ -206,6 +206,45 @@ stable_node "dups" with few rmap_items in them, but that may increase
 the ksmd CPU usage and possibly slowdown the readonly computations on
 the KSM pages of the applications.
 
+Design
+======
+
+Overview
+--------
+
+.. kernel-doc:: mm/ksm.c
+   :DOC: Overview
+
+Reverse mapping
+---------------
+KSM maintains reverse mapping information for KSM pages in the stable
+tree.
+
+If a KSM page is shared between less than ``max_page_sharing`` VMAs,
+the node of the stable tree that represents such KSM page points to a
+list of :c:type:`struct rmap_item` and the ``page->mapping`` of the
+KSM page points to the stable tree node.
+
+When the sharing passes this threshold, KSM adds a second dimension to
+the stable tree. The tree node becomes a "chain" that links one or
+more "dups". Each "dup" keeps reverse mapping information for a KSM
+page with ``page->mapping`` pointing to that "dup".
+
+Every "chain" and all "dups" linked into a "chain" enforce the
+invariant that they represent the same write protected memory content,
+even if each "dup" will be pointed by a different KSM page copy of
+that content.
+
+This way the stable tree lookup computational complexity is unaffected
+if compared to an unlimited list of reverse mappings. It is still
+enforced that there cannot be KSM page content duplicates in the
+stable tree itself.
+
+Reference
+---------
+.. kernel-doc:: mm/ksm.c
+   :functions: mm_slot ksm_scan stable_node rmap_item
+
 --
 Izik Eidus,
 Hugh Dickins, 17 Nov 2009
-- 
2.7.4
