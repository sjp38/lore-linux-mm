Return-Path: <SRS0=7ROk=S6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 15FA3C43219
	for <linux-mm@archiver.kernel.org>; Sun, 28 Apr 2019 12:17:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9C1E62075D
	for <linux-mm@archiver.kernel.org>; Sun, 28 Apr 2019 12:17:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9C1E62075D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E9EB16B0003; Sun, 28 Apr 2019 08:17:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E50A46B0006; Sun, 28 Apr 2019 08:17:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D18006B0007; Sun, 28 Apr 2019 08:17:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 958536B0003
	for <linux-mm@kvack.org>; Sun, 28 Apr 2019 08:17:55 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id d1so5477682pgk.21
        for <linux-mm@kvack.org>; Sun, 28 Apr 2019 05:17:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=8ytr9mfB+3ADyDqCyHRH/M+Ov7q23lBmJ9jUVDNHihc=;
        b=YKBTEo7C4d76cGmWBKIQRi/BSyzwN+/+ow5yIOuwhXneyeEBMvw+v1Bc3pLvkqRuea
         n5JpkSwGnUnsR3xN1Db6Kz8p7lY6QMk81WX/ebSXQL+H0Qr1A+ymnsUXltauRdoh3gnL
         mV3Lie3cOiQSv2KX40soj1K+18h9uvd6QZXnHEC9uNUzFtb9bwGeWnfRpMAhJc6Jyqw9
         71FWnBUPHLah18QOFLti0lco0aBdjNR3Np9teM++8o25+fjoDs97r7KzPotbxQ0vEoS8
         a5r48Tfwo2k3vA+k9f+THerYuK+JK6x6s7CpOlvEy21i1joQ7cm8VpEq2Kg5g6TPOK0d
         llPg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAV/v3gXRCz3jNe0ORIE9Y26SpPl11XK0YY1+3eD+gShZ5bM3T6u
	PZelH7ja+Jk4hfWbUg78esyVTgvZ3dScLdAIJ5RC9JHs/YPfpHFgSWuHE94aQyLvCFlq22anqpd
	68ix1+YBDhIKiV9CV6HdBElyaipnrXaV1fzo+wSVRreKAS8+IRb59NdncccUdZ5qGrQ==
X-Received: by 2002:a62:5582:: with SMTP id j124mr57658477pfb.53.1556453875176;
        Sun, 28 Apr 2019 05:17:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy5MFEsz6RekbAyM57AIAW105vnOqKjIIlKGrR4zi5728x+DNN+5zDXWgxTyvuVIrCUPfMF
X-Received: by 2002:a62:5582:: with SMTP id j124mr57658396pfb.53.1556453873771;
        Sun, 28 Apr 2019 05:17:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556453873; cv=none;
        d=google.com; s=arc-20160816;
        b=ZmowSRKfnW+Dz5Xk+/vEokKjNq2ZX6a/TIOp+zUVhGVWYCyyB1krGqIsJUg2VMfRUX
         eaiXStX5skAE2aq4SaYsvIa/OjHgEbGy04wTQGdFRL/RlmZa1AQ4aQAdcEUSPX6QYP33
         4xGxqFVR/IvvRqZy39Dujq27qzioBaDz5SV8lSxp9F1+FtzR6Yyq9wjvEe/cjhAJBpqx
         PzZ+V+T+DK9gC/ctKaXAZnjN9NVUhDLB9yJTUB6HPAaUCL8A3YZ5VrT/mMWOundGU2wd
         DNnvqsK8cH9AHdF7uHdl5vxnCeGrJ0bJaRxzOXspSz3v45ZsCZAGZAgpvQ7YrT9oT4Pi
         fjyw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=8ytr9mfB+3ADyDqCyHRH/M+Ov7q23lBmJ9jUVDNHihc=;
        b=Gmwa3nhHtqbFbCjZLPQNVUmB+BxvHtHxtOhpg8cG1WhHG/brkEb8HUyXwxGEHqHdFI
         DUSFXoH1qoKvR+wUdr2VgVkVj/UfFb+I412lmMLTV36YOhmMyaR8DbI2A6zlk7xBzTdO
         TtWQHlKrwaruqf+OOj+kp41kYAvtsrmBZjfI5cQY4bODx6Cs77dXuBFgd4lxW+mCwsnL
         vDrjHGMzIoWHALQw5pg2610sUeAOTqd2UEDBGe1IzvK9YbtRPOYNrq4hvHod7P4qQVPZ
         t1Al9cnCFLxzjxq0+28oUw/Dmd+Du7ZAC3MT6bymGMZfY08Ljocwh7dWnfbEzgLsDFZ+
         GujA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f5si5737060pgj.491.2019.04.28.05.17.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Apr 2019 05:17:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3SBx96p127170
	for <linux-mm@kvack.org>; Sun, 28 Apr 2019 08:17:53 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2s54nut0v9-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 28 Apr 2019 08:17:52 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Sun, 28 Apr 2019 13:17:50 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Sun, 28 Apr 2019 13:17:48 +0100
Received: from d06av24.portsmouth.uk.ibm.com (mk.ibm.com [9.149.105.60])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3SCHlO049283208
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Sun, 28 Apr 2019 12:17:47 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 1C68942041;
	Sun, 28 Apr 2019 12:17:47 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 8A07B4203F;
	Sun, 28 Apr 2019 12:17:45 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.112])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Sun, 28 Apr 2019 12:17:45 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Sun, 28 Apr 2019 15:17:44 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>,
        Randy Dunlap <rdunlap@infradead.org>, linux-doc@vger.kernel.org,
        linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH v3] docs/vm: add documentation of memory models
Date: Sun, 28 Apr 2019 15:17:43 +0300
X-Mailer: git-send-email 2.7.4
X-TM-AS-GCONF: 00
x-cbid: 19042812-0016-0000-0000-000002761A45
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19042812-0017-0000-0000-000032D29C8F
Message-Id: <1556453863-16575-1-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-28_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904280089
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Describe what {FLAT,DISCONTIG,SPARSE}MEM are and how they manage to
maintain pfn <-> struct page correspondence.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
v3 changes:
* more spelling and grammar

v2 changes:
* spelling/grammar fixes
* added note about deprecation of DISCONTIGMEM

 Documentation/vm/index.rst        |   1 +
 Documentation/vm/memory-model.rst | 183 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 184 insertions(+)
 create mode 100644 Documentation/vm/memory-model.rst

diff --git a/Documentation/vm/index.rst b/Documentation/vm/index.rst
index b58cc3b..e8d943b 100644
--- a/Documentation/vm/index.rst
+++ b/Documentation/vm/index.rst
@@ -37,6 +37,7 @@ descriptions of data structures and algorithms.
    hwpoison
    hugetlbfs_reserv
    ksm
+   memory-model
    mmu_notifier
    numa
    overcommit-accounting
diff --git a/Documentation/vm/memory-model.rst b/Documentation/vm/memory-model.rst
new file mode 100644
index 0000000..382f72a
--- /dev/null
+++ b/Documentation/vm/memory-model.rst
@@ -0,0 +1,183 @@
+.. SPDX-License-Identifier: GPL-2.0
+
+.. _physical_memory_model:
+
+=====================
+Physical Memory Model
+=====================
+
+Physical memory in a system may be addressed in different ways. The
+simplest case is when the physical memory starts at address 0 and
+spans a contiguous range up to the maximal address. It could be,
+however, that this range contains small holes that are not accessible
+for the CPU. Then there could be several contiguous ranges at
+completely distinct addresses. And, don't forget about NUMA, where
+different memory banks are attached to different CPUs.
+
+Linux abstracts this diversity using one of the three memory models:
+FLATMEM, DISCONTIGMEM and SPARSEMEM. Each architecture defines what
+memory models it supports, what the default memory model is and
+whether it is possible to manually override that default.
+
+.. note::
+   At time of this writing, DISCONTIGMEM is considered deprecated,
+   although it is still in use by several architectures.
+
+All the memory models track the status of physical page frames using
+:c:type:`struct page` arranged in one or more arrays.
+
+Regardless of the selected memory model, there exists one-to-one
+mapping between the physical page frame number (PFN) and the
+corresponding `struct page`.
+
+Each memory model defines :c:func:`pfn_to_page` and :c:func:`page_to_pfn`
+helpers that allow the conversion from PFN to `struct page` and vice
+versa.
+
+FLATMEM
+=======
+
+The simplest memory model is FLATMEM. This model is suitable for
+non-NUMA systems with contiguous, or mostly contiguous, physical
+memory.
+
+In the FLATMEM memory model, there is a global `mem_map` array that
+maps the entire physical memory. For most architectures, the holes
+have entries in the `mem_map` array. The `struct page` objects
+corresponding to the holes are never fully initialized.
+
+To allocate the `mem_map` array, architecture specific setup code
+should call :c:func:`free_area_init_node` function or its convenience
+wrapper :c:func:`free_area_init`. Yet, the mappings array is not
+usable until the call to :c:func:`memblock_free_all` that hands all
+the memory to the page allocator.
+
+If an architecture enables `CONFIG_ARCH_HAS_HOLES_MEMORYMODEL` option,
+it may free parts of the `mem_map` array that do not cover the
+actual physical pages. In such case, the architecture specific
+:c:func:`pfn_valid` implementation should take the holes in the
+`mem_map` into account.
+
+With FLATMEM, the conversion between a PFN and the `struct page` is
+straightforward: `PFN - ARCH_PFN_OFFSET` is an index to the
+`mem_map` array.
+
+The `ARCH_PFN_OFFSET` defines the first page frame number for
+systems with physical memory starting at address different from 0.
+
+DISCONTIGMEM
+============
+
+The DISCONTIGMEM model treats the physical memory as a collection of
+`nodes` similarly to how Linux NUMA support does. For each node Linux
+constructs an independent memory management subsystem represented by
+`struct pglist_data` (or `pg_data_t` for short). Among other
+things, `pg_data_t` holds the `node_mem_map` array that maps
+physical pages belonging to that node. The `node_start_pfn` field of
+`pg_data_t` is the number of the first page frame belonging to that
+node.
+
+The architecture setup code should call :c:func:`free_area_init_node` for
+each node in the system to initialize the `pg_data_t` object and its
+`node_mem_map`.
+
+Every `node_mem_map` behaves exactly as FLATMEM's `mem_map` -
+every physical page frame in a node has a `struct page` entry in the
+`node_mem_map` array. When DISCONTIGMEM is enabled, a portion of the
+`flags` field of the `struct page` encodes the node number of the
+node hosting that page.
+
+The conversion between a PFN and the `struct page` in the
+DISCONTIGMEM model became slightly more complex as it has to determine
+which node hosts the physical page and which `pg_data_t` object
+holds the `struct page`.
+
+Architectures that support DISCONTIGMEM provide :c:func:`pfn_to_nid`
+to convert PFN to the node number. The opposite conversion helper
+:c:func:`page_to_nid` is generic as it uses the node number encoded in
+page->flags.
+
+Once the node number is known, the PFN can be used to index
+appropriate `node_mem_map` array to access the `struct page` and
+the offset of the `struct page` from the `node_mem_map` plus
+`node_start_pfn` is the PFN of that page.
+
+SPARSEMEM
+=========
+
+SPARSEMEM is the most versatile memory model available in Linux and it
+is the only memory model that supports several advanced features such
+as hot-plug and hot-remove of the physical memory, alternative memory
+maps for non-volatile memory devices and deferred initialization of
+the memory map for larger systems.
+
+The SPARSEMEM model presents the physical memory as a collection of
+sections. A section is represented with :c:type:`struct mem_section`
+that contains `section_mem_map` that is, logically, a pointer to an
+array of struct pages. However, it is stored with some other magic
+that aids the sections management. The section size and maximal number
+of section is specified using `SECTION_SIZE_BITS` and
+`MAX_PHYSMEM_BITS` constants defined by each architecture that
+supports SPARSEMEM. While `MAX_PHYSMEM_BITS` is an actual width of a
+physical address that an architecture supports, the
+`SECTION_SIZE_BITS` is an arbitrary value.
+
+The maximal number of sections is denoted `NR_MEM_SECTIONS` and
+defined as
+
+.. math::
+
+   NR\_MEM\_SECTIONS = 2 ^ {(MAX\_PHYSMEM\_BITS - SECTION\_SIZE\_BITS)}
+
+The `mem_section` objects are arranged in a two-dimensional array
+called `mem_sections`. The size and placement of this array depend
+on `CONFIG_SPARSEMEM_EXTREME` and the maximal possible number of
+sections:
+
+* When `CONFIG_SPARSEMEM_EXTREME` is disabled, the `mem_sections`
+  array is static and has `NR_MEM_SECTIONS` rows. Each row holds a
+  single `mem_section` object.
+* When `CONFIG_SPARSEMEM_EXTREME` is enabled, the `mem_sections`
+  array is dynamically allocated. Each row contains PAGE_SIZE worth of
+  `mem_section` objects and the number of rows is calculated to fit
+  all the memory sections.
+
+The architecture setup code should call :c:func:`memory_present` for
+each active memory range or use :c:func:`memblocks_present` or
+:c:func:`sparse_memory_present_with_active_regions` wrappers to
+initialize the memory sections. Next, the actual memory maps should be
+set up using :c:func:`sparse_init`.
+
+With SPARSEMEM there are two possible ways to convert a PFN to the
+corresponding `struct page` - a "classic sparse" and "sparse
+vmemmap". The selection is made at build time and it is determined by
+the value of `CONFIG_SPARSEMEM_VMEMMAP`.
+
+The classic sparse encodes the section number of a page in page->flags
+and uses high bits of a PFN to access the section that maps that page
+frame. Inside a section, the PFN is the index to the array of pages.
+
+The sparse vmemmap uses a virtually mapped memory map to optimize
+pfn_to_page and page_to_pfn operations. There is a global `struct
+page *vmemmap` pointer that points to a virtually contiguous array of
+`struct page` objects. A PFN is an index to that array and the the
+offset of the `struct page` from `vmemmap` is the PFN of that
+page.
+
+To use vmemmap, an architecture has to reserve a range of virtual
+addresses that will map the physical pages containing the memory
+map and make sure that `vmemmap` points to that range. In addition,
+the architecture should implement :c:func:`vmemmap_populate` method
+that will allocate the physical memory and create page tables for the
+virtual memory map. If an architecture does not have any special
+requirements for the vmemmap mappings, it can use default
+:c:func:`vmemmap_populate_basepages` provided by the generic memory
+management.
+
+The virtually mapped memory map allows storing `struct page` objects
+for persistent memory devices in pre-allocated storage on those
+devices. This storage is represented with :c:type:`struct vmem_altmap`
+that is eventually passed to vmemmap_populate() through a long chain
+of function calls. The vmemmap_populate() implementation may use the
+`vmem_altmap` along with :c:func:`altmap_alloc_block_buf` helper to
+allocate memory map on the persistent memory device.
-- 
2.7.4

