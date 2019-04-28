Return-Path: <SRS0=7ROk=S6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5321C43219
	for <linux-mm@archiver.kernel.org>; Sun, 28 Apr 2019 15:23:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6445620679
	for <linux-mm@archiver.kernel.org>; Sun, 28 Apr 2019 15:23:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="A00yZj2C"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6445620679
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 00A0D6B0005; Sun, 28 Apr 2019 11:23:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EFC456B0006; Sun, 28 Apr 2019 11:23:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E11696B0007; Sun, 28 Apr 2019 11:23:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 92EE16B0005
	for <linux-mm@kvack.org>; Sun, 28 Apr 2019 11:23:03 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id s3so9944861wrn.1
        for <linux-mm@kvack.org>; Sun, 28 Apr 2019 08:23:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=VsZRHpF1eM1W8r662PxGd2P/B+iAUQnYQ7xtlrRWJa4=;
        b=mN8E1jtEo589QWS8j52sNJBPPACN9L4Gms8zy89TKGuGgQ/pClj71rzKiGXIC6OGaJ
         NIzv53ubWIL1nSpm4vdx3drnOuF+Z1s5SXSnMG9I2p0bABP2Mrw1aSYw/1JgSDFbfg6Y
         DXQ1SODDegHtdbuDgNz4SfykxHaZf0mSgX9cfckAPcvH/YuePKT8y/wowCih5rO8p6IA
         yR4RGe7yF7skELAXq7qx1f6WvkEcsx6CLhmRpA7FXK36VFc9//0fgkKcDeUONdpchdwP
         cjGITL43NpahlpcWRIxVaHLqu4/VXCEQ0Nk8kMWaC6ifEztCv9INJ9VXrD1gWIujG2Ap
         z5LQ==
X-Gm-Message-State: APjAAAVW2Md5dJW/15JGFxkwMF+ZiU3hG7OZgrlganmKzOqnfo1Q3ukK
	umOb8wHlKzhJpqnqL4PJwIgiyFS3llr8pxiKgXPrDPocV68uW8MMN3utVprsM/XSLido6KcXfWk
	qpenVZR8LQ/cT80OoTAEXVQk4VuSJfEMTLJILpsIZ8ZFWRWx++mA1bfAhFazkPc9Lrw==
X-Received: by 2002:a7b:c5d6:: with SMTP id n22mr14188640wmk.112.1556464982923;
        Sun, 28 Apr 2019 08:23:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz4WZUZl/3UtifooW3hsceuusRPXwyUFsS7JBuLgYYtsIrodpciX2cm0dDtBKPtcv91GLmN
X-Received: by 2002:a7b:c5d6:: with SMTP id n22mr14188601wmk.112.1556464981508;
        Sun, 28 Apr 2019 08:23:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556464981; cv=none;
        d=google.com; s=arc-20160816;
        b=Atqotb6zDvR9SN2vKcDAoRQvtZ5jnygBohAJhQckw6MhxcBTySh0B8xW6WSlZ3s/Mn
         xccthejNqRkMGHw1aon2ndWuOfbLXDDJ/bxEF64fgmsKhAia+uR8DVblWws923JC7kEs
         My8pGjmxf449yMtl8dPBkeaMYtyeeRmvmtcibCUe0YYi3Wdh94+YczVNJrNhclIVxH2W
         bRIgLh2OCrTlMZK5FbDBZZgduLPF4Kw2wtJDg8IaTiVd1x1BA7ppQ+D8dsNlzYqj48ha
         m2dOZlUYrwZYypyy1cl3xG6bx+K4PSA6HaDHsLHtW8ILhNT3gD7/as+/UYsKCgNkF0OT
         9jKQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=VsZRHpF1eM1W8r662PxGd2P/B+iAUQnYQ7xtlrRWJa4=;
        b=D9ShRiEY60v38aA1X8k8ZKIglNoZVUMyAw8F6f7UGLAytVf4VVsWfpEf6jKGE867Mq
         mfitprXA0pMYl3m/52PPxjpMgRsGckXcV4cv6NTyfCnmRRNDorc/Lg3RmS8+XqPfb+kT
         Nod/wmhQqv0qBXy/ZRcDzfStd1WlOgEaNz8drckSGeX+LMajM7rRPX/zDM89SwBsldNm
         xOB2pO7nQQgGTEkC2+WXUKNXRKQX7Xl8x8mDiDHgiSXM4Envhe6JhwmAHKL14ovYdlY8
         a0G4GT9secUSTgK534hZQbA2K6kI4+/YDqrTlbA/3IOOu59asn5Sy9tM7u6coq64Qpwf
         Xvvg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=A00yZj2C;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id z18si5496003wrs.247.2019.04.28.08.23.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 28 Apr 2019 08:23:01 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=A00yZj2C;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=Content-Transfer-Encoding:Content-Type:
	In-Reply-To:MIME-Version:Date:Message-ID:From:References:Cc:To:Subject:Sender
	:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=VsZRHpF1eM1W8r662PxGd2P/B+iAUQnYQ7xtlrRWJa4=; b=A00yZj2Cbie1j+hliLPVAzTV2/
	N3Yb19RFPSR+gHrbFXZM+c13yvhY6hstGVmdeHberZtI3ohip0e5IyQskFJieeQHOvmy+xh8Jvd8u
	qaSzieCSjFPoM/xoFd1B924+WvvJVsif4/9uIyJT5c8eKeF+uDRGQ3BbwqyoblW3QcNxz/cWyhnao
	O1MyppeQLo7EqOP6Qxu3/AbRK9UkBbo80qvVMI31TnTXWMCtGSwIlCcVGeT05+lWLdGpokPaUWLIB
	5r98/dQ5659IzWlZ5XUaR5nIov/woH5Tt1B81j2pGycHBgZOkeNgvJBLsvbjHw7FHcICceHPnLD5H
	4YBjM0gA==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=midway.dunlab)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hKldo-00065s-RT; Sun, 28 Apr 2019 15:22:57 +0000
Subject: Re: [PATCH v3] docs/vm: add documentation of memory models
To: Mike Rapoport <rppt@linux.ibm.com>, Jonathan Corbet <corbet@lwn.net>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>, linux-doc@vger.kernel.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1556453863-16575-1-git-send-email-rppt@linux.ibm.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <bac26b9b-42a7-56e9-6c44-79cdbd25bbf7@infradead.org>
Date: Sun, 28 Apr 2019 08:22:49 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <1556453863-16575-1-git-send-email-rppt@linux.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/28/19 5:17 AM, Mike Rapoport wrote:
> Describe what {FLAT,DISCONTIG,SPARSE}MEM are and how they manage to
> maintain pfn <-> struct page correspondence.
> 
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>

Acked-by: Randy Dunlap <rdunlap@infradead.org>

Thanks.

> ---
> v3 changes:
> * more spelling and grammar
> 
> v2 changes:
> * spelling/grammar fixes
> * added note about deprecation of DISCONTIGMEM
> 
>  Documentation/vm/index.rst        |   1 +
>  Documentation/vm/memory-model.rst | 183 ++++++++++++++++++++++++++++++++++++++
>  2 files changed, 184 insertions(+)
>  create mode 100644 Documentation/vm/memory-model.rst
> 
> diff --git a/Documentation/vm/index.rst b/Documentation/vm/index.rst
> index b58cc3b..e8d943b 100644
> --- a/Documentation/vm/index.rst
> +++ b/Documentation/vm/index.rst
> @@ -37,6 +37,7 @@ descriptions of data structures and algorithms.
>     hwpoison
>     hugetlbfs_reserv
>     ksm
> +   memory-model
>     mmu_notifier
>     numa
>     overcommit-accounting
> diff --git a/Documentation/vm/memory-model.rst b/Documentation/vm/memory-model.rst
> new file mode 100644
> index 0000000..382f72a
> --- /dev/null
> +++ b/Documentation/vm/memory-model.rst
> @@ -0,0 +1,183 @@
> +.. SPDX-License-Identifier: GPL-2.0
> +
> +.. _physical_memory_model:
> +
> +=====================
> +Physical Memory Model
> +=====================
> +
> +Physical memory in a system may be addressed in different ways. The
> +simplest case is when the physical memory starts at address 0 and
> +spans a contiguous range up to the maximal address. It could be,
> +however, that this range contains small holes that are not accessible
> +for the CPU. Then there could be several contiguous ranges at
> +completely distinct addresses. And, don't forget about NUMA, where
> +different memory banks are attached to different CPUs.
> +
> +Linux abstracts this diversity using one of the three memory models:
> +FLATMEM, DISCONTIGMEM and SPARSEMEM. Each architecture defines what
> +memory models it supports, what the default memory model is and
> +whether it is possible to manually override that default.
> +
> +.. note::
> +   At time of this writing, DISCONTIGMEM is considered deprecated,
> +   although it is still in use by several architectures.
> +
> +All the memory models track the status of physical page frames using
> +:c:type:`struct page` arranged in one or more arrays.
> +
> +Regardless of the selected memory model, there exists one-to-one
> +mapping between the physical page frame number (PFN) and the
> +corresponding `struct page`.
> +
> +Each memory model defines :c:func:`pfn_to_page` and :c:func:`page_to_pfn`
> +helpers that allow the conversion from PFN to `struct page` and vice
> +versa.
> +
> +FLATMEM
> +=======
> +
> +The simplest memory model is FLATMEM. This model is suitable for
> +non-NUMA systems with contiguous, or mostly contiguous, physical
> +memory.
> +
> +In the FLATMEM memory model, there is a global `mem_map` array that
> +maps the entire physical memory. For most architectures, the holes
> +have entries in the `mem_map` array. The `struct page` objects
> +corresponding to the holes are never fully initialized.
> +
> +To allocate the `mem_map` array, architecture specific setup code
> +should call :c:func:`free_area_init_node` function or its convenience
> +wrapper :c:func:`free_area_init`. Yet, the mappings array is not
> +usable until the call to :c:func:`memblock_free_all` that hands all
> +the memory to the page allocator.
> +
> +If an architecture enables `CONFIG_ARCH_HAS_HOLES_MEMORYMODEL` option,
> +it may free parts of the `mem_map` array that do not cover the
> +actual physical pages. In such case, the architecture specific
> +:c:func:`pfn_valid` implementation should take the holes in the
> +`mem_map` into account.
> +
> +With FLATMEM, the conversion between a PFN and the `struct page` is
> +straightforward: `PFN - ARCH_PFN_OFFSET` is an index to the
> +`mem_map` array.
> +
> +The `ARCH_PFN_OFFSET` defines the first page frame number for
> +systems with physical memory starting at address different from 0.
> +
> +DISCONTIGMEM
> +============
> +
> +The DISCONTIGMEM model treats the physical memory as a collection of
> +`nodes` similarly to how Linux NUMA support does. For each node Linux
> +constructs an independent memory management subsystem represented by
> +`struct pglist_data` (or `pg_data_t` for short). Among other
> +things, `pg_data_t` holds the `node_mem_map` array that maps
> +physical pages belonging to that node. The `node_start_pfn` field of
> +`pg_data_t` is the number of the first page frame belonging to that
> +node.
> +
> +The architecture setup code should call :c:func:`free_area_init_node` for
> +each node in the system to initialize the `pg_data_t` object and its
> +`node_mem_map`.
> +
> +Every `node_mem_map` behaves exactly as FLATMEM's `mem_map` -
> +every physical page frame in a node has a `struct page` entry in the
> +`node_mem_map` array. When DISCONTIGMEM is enabled, a portion of the
> +`flags` field of the `struct page` encodes the node number of the
> +node hosting that page.
> +
> +The conversion between a PFN and the `struct page` in the
> +DISCONTIGMEM model became slightly more complex as it has to determine
> +which node hosts the physical page and which `pg_data_t` object
> +holds the `struct page`.
> +
> +Architectures that support DISCONTIGMEM provide :c:func:`pfn_to_nid`
> +to convert PFN to the node number. The opposite conversion helper
> +:c:func:`page_to_nid` is generic as it uses the node number encoded in
> +page->flags.
> +
> +Once the node number is known, the PFN can be used to index
> +appropriate `node_mem_map` array to access the `struct page` and
> +the offset of the `struct page` from the `node_mem_map` plus
> +`node_start_pfn` is the PFN of that page.
> +
> +SPARSEMEM
> +=========
> +
> +SPARSEMEM is the most versatile memory model available in Linux and it
> +is the only memory model that supports several advanced features such
> +as hot-plug and hot-remove of the physical memory, alternative memory
> +maps for non-volatile memory devices and deferred initialization of
> +the memory map for larger systems.
> +
> +The SPARSEMEM model presents the physical memory as a collection of
> +sections. A section is represented with :c:type:`struct mem_section`
> +that contains `section_mem_map` that is, logically, a pointer to an
> +array of struct pages. However, it is stored with some other magic
> +that aids the sections management. The section size and maximal number
> +of section is specified using `SECTION_SIZE_BITS` and
> +`MAX_PHYSMEM_BITS` constants defined by each architecture that
> +supports SPARSEMEM. While `MAX_PHYSMEM_BITS` is an actual width of a
> +physical address that an architecture supports, the
> +`SECTION_SIZE_BITS` is an arbitrary value.
> +
> +The maximal number of sections is denoted `NR_MEM_SECTIONS` and
> +defined as
> +
> +.. math::
> +
> +   NR\_MEM\_SECTIONS = 2 ^ {(MAX\_PHYSMEM\_BITS - SECTION\_SIZE\_BITS)}
> +
> +The `mem_section` objects are arranged in a two-dimensional array
> +called `mem_sections`. The size and placement of this array depend
> +on `CONFIG_SPARSEMEM_EXTREME` and the maximal possible number of
> +sections:
> +
> +* When `CONFIG_SPARSEMEM_EXTREME` is disabled, the `mem_sections`
> +  array is static and has `NR_MEM_SECTIONS` rows. Each row holds a
> +  single `mem_section` object.
> +* When `CONFIG_SPARSEMEM_EXTREME` is enabled, the `mem_sections`
> +  array is dynamically allocated. Each row contains PAGE_SIZE worth of
> +  `mem_section` objects and the number of rows is calculated to fit
> +  all the memory sections.
> +
> +The architecture setup code should call :c:func:`memory_present` for
> +each active memory range or use :c:func:`memblocks_present` or
> +:c:func:`sparse_memory_present_with_active_regions` wrappers to
> +initialize the memory sections. Next, the actual memory maps should be
> +set up using :c:func:`sparse_init`.
> +
> +With SPARSEMEM there are two possible ways to convert a PFN to the
> +corresponding `struct page` - a "classic sparse" and "sparse
> +vmemmap". The selection is made at build time and it is determined by
> +the value of `CONFIG_SPARSEMEM_VMEMMAP`.
> +
> +The classic sparse encodes the section number of a page in page->flags
> +and uses high bits of a PFN to access the section that maps that page
> +frame. Inside a section, the PFN is the index to the array of pages.
> +
> +The sparse vmemmap uses a virtually mapped memory map to optimize
> +pfn_to_page and page_to_pfn operations. There is a global `struct
> +page *vmemmap` pointer that points to a virtually contiguous array of
> +`struct page` objects. A PFN is an index to that array and the the
> +offset of the `struct page` from `vmemmap` is the PFN of that
> +page.
> +
> +To use vmemmap, an architecture has to reserve a range of virtual
> +addresses that will map the physical pages containing the memory
> +map and make sure that `vmemmap` points to that range. In addition,
> +the architecture should implement :c:func:`vmemmap_populate` method
> +that will allocate the physical memory and create page tables for the
> +virtual memory map. If an architecture does not have any special
> +requirements for the vmemmap mappings, it can use default
> +:c:func:`vmemmap_populate_basepages` provided by the generic memory
> +management.
> +
> +The virtually mapped memory map allows storing `struct page` objects
> +for persistent memory devices in pre-allocated storage on those
> +devices. This storage is represented with :c:type:`struct vmem_altmap`
> +that is eventually passed to vmemmap_populate() through a long chain
> +of function calls. The vmemmap_populate() implementation may use the
> +`vmem_altmap` along with :c:func:`altmap_alloc_block_buf` helper to
> +allocate memory map on the persistent memory device.
> 


-- 
~Randy

