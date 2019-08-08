Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B1A89C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 16:33:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 806D021874
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 16:33:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 806D021874
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 351826B0010; Thu,  8 Aug 2019 12:33:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2DADA6B0266; Thu,  8 Aug 2019 12:33:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1A4036B0269; Thu,  8 Aug 2019 12:33:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id EA09E6B0010
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 12:33:07 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id q26so86152053qtr.3
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 09:33:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=tlM/91c7+c/Z6Kjuw2HmxiD/3I3JGzslDTcoE3TRAow=;
        b=suxZZTcW8XBbgIcSb8yBR8/PW6C+awL3/4+Nid2ZnpvHxtENfLRL4JXQZtVKPu4jma
         rJfF9XR3o9klVREuRVLecCS/pFM6Ux0Ei9bU4FOZjp6mameIsC06mhTxtCD2FBzjz92W
         lowRZlzQv+IGrVUhPT/0U/syYQETwGZL//GcpQXLGOFKOWJMTRfdL/jQ7Czu42yYOH77
         hEhb/WKA04jxgiCYf5d/zksL3Msb3hrmBpxvTelo+nGwj24mIkU0jtMPcEe0i1aDKZge
         EBvCIfXXzMza9DkYNp+gvN8MmkaJeGb4L5/I0HSMz4NHXV9zFYqKSNTjufFuDkVdx8a9
         378g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWhlJtrRklbxcBgSKfLvm/pz8cy0IpZeX4g7DJmreVwm7468J3/
	+3FRtV2+C8A9hHDe7ZrtKllU36XfqT5e+L/f45/YeZ9VIfdEdnsLB3kZ8bCj0/XW+7xV77YUw3+
	v/8ho63CPBbKofTbUR+iIhlTZmGXy9O3RhVPgS2jS7Eli04SL6gOlwCrYP3yFKSy8ug==
X-Received: by 2002:a37:d287:: with SMTP id f129mr7867715qkj.310.1565281987755;
        Thu, 08 Aug 2019 09:33:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyt12UJvuYZTVlXfs0vLuFAGuG5nyUM+4dgR0WBo4FGbsQWQuDEW64yos9fV3NE3AmLpX1i
X-Received: by 2002:a37:d287:: with SMTP id f129mr7867665qkj.310.1565281987177;
        Thu, 08 Aug 2019 09:33:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565281987; cv=none;
        d=google.com; s=arc-20160816;
        b=vxKpkXY4QkfcjohnKjZ8oFYkCOhUyL4e5juNOYPpW/RJWAWewEOTdJGO16CD3UVZqi
         yrx74Q53eIYVJ1YPxICsH0471nhEUkJnTE+erXhBxei3Wy6h4n7vrtBYzguknDxOiMZB
         YtwMhlHc7lQhuSsypJufcZ0kCzfaoEWHPLwkxz/sBtoesrv0kKsQa0FJMsG0SphF7EkE
         pAv+089n1sZ08OGaJUczOpBZBLBzL1Din2b0KTKbu8ywaIwEoGec0TOQ05ECnNQD9jO5
         CbgIB/bnyTOED9YSKavxk71IpV3UZ9kf09bmmN+pL3Zu52K6ELEWiM0zHfbqus+VEUtB
         MxuQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=tlM/91c7+c/Z6Kjuw2HmxiD/3I3JGzslDTcoE3TRAow=;
        b=MD3QB7csNgaOeoIbSe7ZxyaeeCyFKZRNbL3JPhskgGhM0vpfa5737aG9Yhq4Y9c1NO
         Nl4lExypARA5COgr5oIOMgVllPS4XrQlvRk+zh5eh8atpsIz6h4hAE7EExuMRMk3v+B1
         lEW/cMCEUOv/nMaEJcM2GyGt0Bc01Y6Nwn+rjz6c857DYPJu8Dopz5tdGADFeYPEvpRP
         xZ5vrX+4pUpOfEUpzRYmfqOJasNhFMoXo1ArXPKgmGkBa/iz0rhNkDcXh7kr5qbh965N
         3NXEV+S1wGuyGUUsw0ZhLft5DpuZaoTNDgvn8s71HPeF017EHh4OvE4v/xAOrVZZaaQL
         Fnxg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k127si52851862qkc.355.2019.08.08.09.33.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 09:33:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6CD3BCF22;
	Thu,  8 Aug 2019 16:33:06 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (unknown [10.43.17.136])
	by smtp.corp.redhat.com (Postfix) with SMTP id A42CE19C69;
	Thu,  8 Aug 2019 16:33:04 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Thu,  8 Aug 2019 18:33:06 +0200 (CEST)
Date: Thu, 8 Aug 2019 18:33:03 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Song Liu <songliubraving@fb.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	akpm@linux-foundation.org, matthew.wilcox@oracle.com,
	kirill.shutemov@linux.intel.com, kernel-team@fb.com,
	william.kucharski@oracle.com, srikar@linux.vnet.ibm.com
Subject: Re: [PATCH v12 5/6] khugepaged: enable collapse pmd for pte-mapped
 THP
Message-ID: <20190808163303.GB7934@redhat.com>
References: <20190807233729.3899352-1-songliubraving@fb.com>
 <20190807233729.3899352-6-songliubraving@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190807233729.3899352-6-songliubraving@fb.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Thu, 08 Aug 2019 16:33:06 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 08/07, Song Liu wrote:
>
> +void collapse_pte_mapped_thp(struct mm_struct *mm, unsigned long addr)
> +{
> +	unsigned long haddr = addr & HPAGE_PMD_MASK;
> +	struct vm_area_struct *vma = find_vma(mm, haddr);
> +	struct page *hpage = NULL;
> +	pmd_t *pmd, _pmd;
> +	spinlock_t *ptl;
> +	int count = 0;
> +	int i;
> +
> +	if (!vma || !vma->vm_file ||
> +	    vma->vm_start > haddr || vma->vm_end < haddr + HPAGE_PMD_SIZE)
> +		return;
> +
> +	/*
> +	 * This vm_flags may not have VM_HUGEPAGE if the page was not
> +	 * collapsed by this mm. But we can still collapse if the page is
> +	 * the valid THP. Add extra VM_HUGEPAGE so hugepage_vma_check()
> +	 * will not fail the vma for missing VM_HUGEPAGE
> +	 */
> +	if (!hugepage_vma_check(vma, vma->vm_flags | VM_HUGEPAGE))
> +		return;
> +
> +	pmd = mm_find_pmd(mm, haddr);

OK, I do not see anything really wrong...

a couple of questions below.

> +	for (i = 0, addr = haddr; i < HPAGE_PMD_NR; i++, addr += PAGE_SIZE) {
> +		pte_t *pte = pte_offset_map(pmd, addr);
> +		struct page *page;
> +
> +		if (pte_none(*pte))
> +			continue;
> +
> +		page = vm_normal_page(vma, addr, *pte);
> +
> +		if (!page || !PageCompound(page))
> +			return;
> +
> +		if (!hpage) {
> +			hpage = compound_head(page);

OK,

> +			if (hpage->mapping != vma->vm_file->f_mapping)
> +				return;

is it really possible? May be WARN_ON(hpage->mapping != vm_file->f_mapping)
makes more sense ?

> +		if (hpage + i != page)
> +			return;

ditto.

Oleg.

