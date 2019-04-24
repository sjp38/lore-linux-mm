Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3600C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 10:28:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4DFF921773
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 10:28:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4DFF921773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F2DC46B0007; Wed, 24 Apr 2019 06:28:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EB7126B0008; Wed, 24 Apr 2019 06:28:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D7F9F6B000A; Wed, 24 Apr 2019 06:28:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7F0FB6B0007
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 06:28:47 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id r8so559345edd.21
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 03:28:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=dhfm3jTvsX2n/D5y56nV22ccKTlxf5APor7WYBG2OX0=;
        b=MlTsFnRpuad8tua9eRkBQ/7+1dmM8KLYVWBwZWa1L/HgAeaoS5WpM37cuo3dFByVi8
         TjO3R9JX5C2OHAbZhRkt2LsWZqphz+TjUMeyGZlFZZeyeUFPc2jJ/9OzZJ3CB+HYFjr0
         Cyz0+35fKQYO8rf6E0lAarKb60dpStoq4deIq8/SEZVevBpmxxfAA+O1RvJuYG6Qt1HX
         mY6xuwGbQbDG6EHlfu937SBcNYFIu1CifWr4HQP9DFhMBFoVqdciBxtZ66xTrW9Smvxv
         RAPnqJRiTW/rZZnf30qGlBoYkl59BEfyuzfvEwD5KFw0K6DwZqbDKF2SH5p21Mrd8Oba
         qhFA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAV8cKQE24UKHz+iSLTjNTsvNMhiI0GzOg9YgQgo+4ucLF1ejN55
	oly4tSKhmGL5UyTq1Xb0WkY+nP6+CrPc9lsQcDwIHgDhyxmsVdnCyDHGHhN+37ddougy9egPq68
	ClrDBYsHbgPkQ2TNKjKWplqDOvSjCTRo/Ws1E597xsZVS0zFqMdqM+h6desXWWRKNQw==
X-Received: by 2002:aa7:c88a:: with SMTP id p10mr20086236eds.145.1556101726957;
        Wed, 24 Apr 2019 03:28:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyo5P1KwlshS8rVRYT2oHWdwhGm1Lzro9dclBWyl392ZVbn93GnAfP91GONk1RPOus3N7zj
X-Received: by 2002:aa7:c88a:: with SMTP id p10mr20086181eds.145.1556101725708;
        Wed, 24 Apr 2019 03:28:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556101725; cv=none;
        d=google.com; s=arc-20160816;
        b=j4cYXiAw2L6x/g46Me+t84UB3k9ueVZSgZPDpfb+Xan+Qqz1HeTwa0/Qs9aRxxLNhU
         +Tb6bh5oPciueSYFsDsdoZ+qY8LJ2eT0dyNkmmYcUhMCf7bJ9gV8p/mKdoQJHxQT7i6d
         HvnDhjLFpXQkCNEQQjhV3zpVoDemCh5CeYNVapqk73B8AbVQ1tH1fYF2qTltliKP9F0g
         9XOhm0d46RxFwf645984jkg9dkweJPDaKPYMYGbpC+cYb9JyweKh7jZ9Rxc1e6o67nSo
         gMY+LhJZ8F0OGenzdIgcyUE0mnXPkOPpi8yv1AjBGzWntro8iIZ95FYp7i+KmVCW3omJ
         44dg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=dhfm3jTvsX2n/D5y56nV22ccKTlxf5APor7WYBG2OX0=;
        b=qu9dbSsbfPn9aLzwi4IVjLTe3OpW/Evllb/ZjURxOQ3rN/ALUdFkTFrYyQi5UJJTJn
         ZKCUmnhOdxQ+qVkab9cSG5EvWfLtSGYRfc/6aF9MVLiDuQ0iD35i6nXHiw7lYHw77dp4
         e1SXKpiW7OBW2RtcGhmTXv6IhqHDsa+8MurcuQWp8c+f0QoBQJq3q01JGosjCqXk61iN
         6dDgezeVuyJG8ke+L3Bde8QJILK/BI0Q/IG2E6Vnmc56EUBJfswCGcq1NVcfSxgtscYt
         GIdQiVmRvB3EkzTF7um/oyYsGJwrSpi2AS2L99cxQeKmTMcUDg9qRyOvkY5PGjaCaty5
         8CFQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id c33si1069968eda.356.2019.04.24.03.28.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 03:28:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3OAP9li001867
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 06:28:43 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2s2np1h6d7-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 06:28:43 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 24 Apr 2019 11:28:41 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 24 Apr 2019 11:28:39 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3OAScpI38469700
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 24 Apr 2019 10:28:38 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 33E4A4C046;
	Wed, 24 Apr 2019 10:28:38 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id C33904C040;
	Wed, 24 Apr 2019 10:28:36 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.112])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed, 24 Apr 2019 10:28:36 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Wed, 24 Apr 2019 13:28:36 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Jonathan Corbet <corbet@lwn.net>
Cc: linux-doc@vger.kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH] docs/vm: add documentation of memory models
Date: Wed, 24 Apr 2019 13:28:35 +0300
X-Mailer: git-send-email 2.7.4
X-TM-AS-GCONF: 00
x-cbid: 19042410-0028-0000-0000-00000364F203
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19042410-0029-0000-0000-00002424439E
Message-Id: <1556101715-31966-1-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-24_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904240086
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Describe what {FLAT,DISCONTIG,SPARSE}MEM are and how they manage to
maintain pfn <-> struct page correspondence.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 Documentation/vm/index.rst        |   1 +
 Documentation/vm/memory-model.rst | 171 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 172 insertions(+)
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
index 0000000..914c52a
--- /dev/null
+++ b/Documentation/vm/memory-model.rst
@@ -0,0 +1,171 @@
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
+memory models it supports, what is the default memory model and
+whether it possible to manually override that default.
+
+All the memory models track the status of physical page frames using
+:c:type:`struct page` arranged in one or more arrays.
+
+Regardless of the selected memory model, there exists one-to-one
+mapping between the physical page frame number (PFN) and the
+corresponding `struct page`.
+
+Each memory model defines :c:func:`pfn_to_page` and :c:func:`page_to_pfn`
+helpers that allow the conversion from PFN to `struct page` and vise
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
+systems that their physical memory does not start at 0.
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
+The `mem_section` objects are arranged in a two dimensional array
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
+map. and make sure that `vmemmap` points to that range. In addition,
+the architecture should implement :c:func:`vmemmap_populate` method
+that will allocate the physical memory and create page tables for the
+virtual memory map. If an architecture does not have any special
+requirements for the vmemmap mappings, it can use default
+:c:func:`vmemmap_populate_basepages` provided by the generic memory
+management.
-- 
2.7.4

