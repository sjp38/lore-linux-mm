Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B66ECC4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 12:29:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4AD4020882
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 12:29:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="VhuUM0Nn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4AD4020882
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9BAA06B0008; Wed,  3 Apr 2019 08:29:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 96A366B000A; Wed,  3 Apr 2019 08:29:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 859716B000C; Wed,  3 Apr 2019 08:29:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4C6D16B0008
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 08:29:42 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id l74so5416036pfb.23
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 05:29:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:to:to:cc:cc:cc
         :subject:in-reply-to:references:message-id;
        bh=8iNQFzyu1TDwPEiodhmRLVeWf2jXVMQE4/sjNN/ogA8=;
        b=XSMVfrGVir2X4TPKxxLfEsuZbgndeQroSKO8PJ4gs6vu3M3WJ4U/vVcFsElQa8pswK
         dAwpppIcfouie3xhPXEFAkPd6Vr+lFQJnRlAm+xcOWXCwVAQdYpoUyx2HOJjKTAsjDmw
         zzdnW9wWv38srVfG9gRPk/V6TlKdTN6g3az8nFir8lm884jDhAK189cLmOYqLWvE+wY4
         zcq6FIYslWhBpuNtFwY21ab+00LUh1mqc/fIAG/a++8lug+5HkrOOwywdleGR4EA1bMN
         mt0XGYBQ1LUIYhI+czDHcFJkqirU5FJ3MNwVdv4zK5hsB9roLajJSg8GCmDCXMhd0yZg
         Dyzw==
X-Gm-Message-State: APjAAAVW5Ny3ur9pmX6HonEr/uXotQgnWLQxec/Hsu9KmUQztkgseK9a
	dp3e7c1iCYMUvjnfKW7N+EALUKzne/KkZQMRxkj6JCB1n+nGeqiQUoE9SI/HJCo4WR5PknZww50
	3j+xL6akV7OhxPXK/zA207Ym7+SeidsKqq9wchi2xv6dsQtrmB4HNtc8a+qRlsm/u0g==
X-Received: by 2002:a63:30c5:: with SMTP id w188mr48359233pgw.76.1554294581735;
        Wed, 03 Apr 2019 05:29:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyTyvXJNw0kz0riK1VJ9aYYJcYfRbxqqFFMQnSzHC085NHYWyxl510ztPqxXUOEp6b8HnPF
X-Received: by 2002:a63:30c5:: with SMTP id w188mr48359124pgw.76.1554294580396;
        Wed, 03 Apr 2019 05:29:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554294580; cv=none;
        d=google.com; s=arc-20160816;
        b=QO2jsvx1NEcX0S/eD787DOyC9Xk+8SOIOLlbrhLZ+9DaLOtUQPwLeHboi+MSv9lARE
         8UfQ2M74mAKWGAnq0eODC6Y0JzFoIQ76N1+VyTSeMqsVua3e3KyYYBtP37BjlZxeBs7r
         bIyQZ55Ay3ChsAVZVE7JBwwPfnlQAve0FtC3mHqdus0Umcz141mxSSp90euz+FEDzQsv
         5TPxMgGR9d+HTeEw2ex8/YoDxGKdYLRF25DWfgmHNp65hDLFwNmLrqpMr5LL7XVq7Fkb
         E1fYoHN+zK2AOzxKUR3Ujg0iqih4RQe226RkOTZx0CJJ89DVAjtTEghNqYMDiP3EdReb
         tH4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:subject:cc:cc:cc:to:to:to:from
         :date:dkim-signature;
        bh=8iNQFzyu1TDwPEiodhmRLVeWf2jXVMQE4/sjNN/ogA8=;
        b=Pvvd3WB67zipqb+4c9Z88CAmcUxgWdVgZybdHWyTpqjJzzSwk2kAeub101r8/eMRba
         mVBuUxcj1mPzDBj11GZ60KXWWmd+r51tRas6gmr7dP676bCqM+kGOcEKkEq2Jpnw5mBs
         X5cibTgxFJccUSlerLLWDGIwxkealtBNRHUoPpLnGDqHR2c6W4BiQp9XlEOPZD2MF8My
         ZeDImpB/hQpubmmjG1QOybIeL0CbWBdqQ8AMkwXVB4M10b9UcH855FGwaG95GE5TzUUF
         a6IL+hAHAJ+bCnY33FgB5QxEsBcWekGeHFl8MOhbE8Z03/nF0hJotQtkyq3uAXxAeWle
         C5oA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=VhuUM0Nn;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id j26si13550660pfe.175.2019.04.03.05.29.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 05:29:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=VhuUM0Nn;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (unknown [23.100.24.84])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id C4187214AF;
	Wed,  3 Apr 2019 12:29:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1554294580;
	bh=tC7VHdeuTQrsr8HVJVxmxKXyzoqq8aUa2Cj/IKZv0II=;
	h=Date:From:To:To:To:Cc:CC:Cc:Subject:In-Reply-To:References:From;
	b=VhuUM0NndOh9A2fzQL76yIalkUdX1tn/tqMhy5WP2XOOTeuY2xjv0NtWZsdSrLDRt
	 a6BYD+6yrcI8ElQxbbOugTpCWjQ2WNXclh7q2CHqjza7XY9JB6BwdTZVi4tPqrISmv
	 jFCbNM3YN91pqK5O3s494Hvf9p1aaH7A66i6Xe0U=
Date: Wed, 03 Apr 2019 12:29:39 +0000
From: Sasha Levin <sashal@kernel.org>
To: Sasha Levin <sashal@kernel.org>
To:   "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To:     dan.j.williams@intel.com, akpm@linux-foundation.org,
Cc:     linux-nvdimm@lists.01.org, linux-mm@kvack.org,
CC: stable@vger.kernel.org
Cc: stable@vger.kernel.org
Subject: Re: [PATCH v2] mm: Fix modifying of page protection by insert_pfn_pmd()
In-Reply-To: <20190402115125.18803-1-aneesh.kumar@linux.ibm.com>
References: <20190402115125.18803-1-aneesh.kumar@linux.ibm.com>
Message-Id: <20190403122939.C4187214AF@mail.kernel.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

[This is an automated email]

This commit has been processed because it contains a -stable tag.
The stable tag indicates that it's relevant for the following trees: all

The bot has tested the following trees: v5.0.5, v4.19.32, v4.14.109, v4.9.166, v4.4.177, v3.18.137.

v5.0.5: Build OK!
v4.19.32: Build OK!
v4.14.109: Failed to apply! Possible dependencies:
    b4e98d9ac775 ("mm: account pud page tables")
    c4812909f5d5 ("mm: introduce wrappers to access mm->nr_ptes")

v4.9.166: Failed to apply! Possible dependencies:
    166f61b9435a ("mm: codgin-style fixes")
    505a60e22560 ("asm-generic: introduce 5level-fixup.h")
    5c6a84a3f455 ("mm/kasan: Switch to using __pa_symbol and lm_alias")
    82b0f8c39a38 ("mm: join struct fault_env and vm_fault")
    953c66c2b22a ("mm: THP page cache support for ppc64")
    b279ddc33824 ("mm: clarify mm_struct.mm_{users,count} documentation")
    b4e98d9ac775 ("mm: account pud page tables")
    c2febafc6773 ("mm: convert generic code to 5-level paging")
    c4812909f5d5 ("mm: introduce wrappers to access mm->nr_ptes")

v4.4.177: Failed to apply! Possible dependencies:
    01871e59af5c ("mm, dax: fix livelock, allow dax pmd mappings to become writeable")
    01c8f1c44b83 ("mm, dax, gpu: convert vm_insert_mixed to pfn_t")
    0e749e54244e ("dax: increase granularity of dax_clear_blocks() operations")
    1bdb2d4ee05f ("ARM: split off core mapping logic from create_mapping")
    34c0fd540e79 ("mm, dax, pmem: introduce pfn_t")
    3ed3a4f0ddff ("mm: cleanup *pte_alloc* interfaces")
    52db400fcd50 ("pmem, dax: clean up clear_pmem()")
    7bc3777ca19c ("sparc64: Trim page tables for 8M hugepages")
    b2e0d1625e19 ("dax: fix lifetime of in-kernel dax mappings with dax_map_atomic()")
    c4812909f5d5 ("mm: introduce wrappers to access mm->nr_ptes")
    c7936206b971 ("ARM: implement create_mapping_late() for EFI use")
    f25748e3c34e ("mm, dax: convert vmf_insert_pfn_pmd() to pfn_t")
    f579b2b10412 ("ARM: factor out allocation routine from __create_mapping()")

v3.18.137: Failed to apply! Possible dependencies:
    047fc8a1f9a6 ("libnvdimm, nfit, nd_blk: driver for BLK-mode access persistent memory")
    2a3746984c98 ("x86: Use new cache mode type in track_pfn_remap() and track_pfn_insert()")
    34c0fd540e79 ("mm, dax, pmem: introduce pfn_t")
    4c1eaa2344fb ("drivers/block/pmem: Fix 32-bit build warning in pmem_alloc()")
    5cad465d7fa6 ("mm: add vmf_insert_pfn_pmd()")
    61031952f4c8 ("arch, x86: pmem api for ensuring durability of persistent memory updates")
    62232e45f4a2 ("libnvdimm: control (ioctl) messages for nvdimm_bus and nvdimm devices")
    777783e0abae ("staging: android: binder: move to the "real" part of the kernel")
    957e3facd147 ("gcov: enable GCOV_PROFILE_ALL from ARCH Kconfigs")
    9e853f2313e5 ("drivers/block/pmem: Add a driver for persistent memory")
    9f53f9fa4ad1 ("libnvdimm, pmem: add libnvdimm support to the pmem driver")
    b94d5230d06e ("libnvdimm, nfit: initial libnvdimm infrastructure and NFIT support")
    cb389b9c0e00 ("dax: drop size parameter to ->direct_access()")
    dd22f551ac0a ("block: Change direct_access calling convention")
    e2e05394e4a3 ("pmem, dax: have direct_access use __pmem annotation")
    ec776ef6bbe1 ("x86/mm: Add support for the non-standard protected e820 type")
    f0dc089ce217 ("libnvdimm: enable iostat")
    f25748e3c34e ("mm, dax: convert vmf_insert_pfn_pmd() to pfn_t")


How should we proceed with this patch?

--
Thanks,
Sasha

