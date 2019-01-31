Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8631EC282C7
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 08:39:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4EDAC20870
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 08:39:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4EDAC20870
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ABEC28E0002; Thu, 31 Jan 2019 03:39:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A6D8E8E0001; Thu, 31 Jan 2019 03:39:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 936BD8E0002; Thu, 31 Jan 2019 03:39:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3DB358E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 03:39:04 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id l17so453927wme.1
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 00:39:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=9XVgGoExlWMi0foUCYMonQdWUrzSOZJtsDtzteW9af0=;
        b=H8CvCbIsFfXiiF2rFRT9yonD0Xygn0cU5dJ9lJFekgGuw7RC5ZZCmhQsQ30aGnuffn
         FDMhn1PJ8qdtwjrOzRyFVwFIZJlq1krgO+3c3XbcooDLN55zSb+cikVNVJr/jjIZjoaB
         7lczQgmCszo3ImGzA0NvBUKLzWvD9aoD/gU/EpsecDiVbuu7yKeI5jEbVU/jmFU3O0xp
         JT2tkxQgYjguBkcxTVnOjAuLyFgwDJs2/OtxCtsMvIPLAskLD27hooUgw68zXWV8MCzk
         AsY0+D1YuLLNCT4sKk35IM0N6d/AdFqwVkykdYZIIY9EiF55VI7bswAmj3Jv4Grc/ti4
         YrFg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AJcUukezAAKdL0slbT2VCyNutHPjNGqoodytzxun3f1q0edqRuadYaLj
	XKf8HJWNH6suF471H09qgBICILSeDdQRRBjjHuT1TpViCne+UMBdGthRdyWSpLqa7gzc/kjvv5+
	S/xKVUhNnAjMJDiJkJ6+E8On+/DBFeGKXEt5OIaOtM7Pnk34Qq9rqy48TguDwSdMcjQ==
X-Received: by 2002:adf:ce02:: with SMTP id p2mr35973470wrn.185.1548923943679;
        Thu, 31 Jan 2019 00:39:03 -0800 (PST)
X-Google-Smtp-Source: ALg8bN644a2K4YTIOGVa0BP3d1c9olkyWzmxLAcVBjlanI+vbhOqLe0Q0xTnFM0E8eZUd+rBSdxG
X-Received: by 2002:adf:ce02:: with SMTP id p2mr35973402wrn.185.1548923942632;
        Thu, 31 Jan 2019 00:39:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548923942; cv=none;
        d=google.com; s=arc-20160816;
        b=z8ug0nTN9CCj4EuV8CF7PcSmtLVghR+wSzCNX0rH+vOgBQyK9ckZIJpC+rlnpzO9p8
         iyo2jA5ziPqm30rlav8Z85qDvMfy33bnABpQ3E5IB743b3mv6646Q8waku8nTFk3Oovz
         vC0BSOjR6L0y7gHra4U1qkKLwN7hf4im0qvRX+j2eLFYbJsCx5Y8FX4YYoJBE9GZeuSd
         MfCqI7KP9+Eeqi/L/AzmKY2yd8B6xV5YOLsUjDJct1ze4GhyZX4nOm4eDbyBHCtVrCQ5
         DJLOIVLfdysiJRagvWk6tXyJ2WAbFs1uDJlEBcfHNO1wyWG2voeqprNp8+6YymM85X26
         lAwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=9XVgGoExlWMi0foUCYMonQdWUrzSOZJtsDtzteW9af0=;
        b=ht2+dLcykF+nn/bfdlTS68xaNZKZ9NQiUgEevwFmUMnBg1HKPRsoHyWlIZYFhkXwKL
         ps/UmcNtMAjGx8iIDFQ9hUsUV4TchvOoYPCk5zQXpTcct9xbGhyfzOj2d2O/kImpbdNR
         OHjwzOhz5s58/fqGdgb+VYaAX2Ro+CLCdwFseOuaisj5fYsFmntQsHzhvU9cYYQSFd0p
         SV0yHFMClvOFsYJ2tCXWfVZ+N47GPwG78EFCf8UZRIgukSNRsUL8plDzod5jSJfhZdq8
         T/7QalJ0qB9uFVY+vPYLNlIy6wihRfDXFZLoh3ibpY9Pw8OiF3MZdnTlzpfPtmbNvxFZ
         TMEQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id t17si2791351wrr.69.2019.01.31.00.39.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 00:39:02 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0V8VbWQ088142
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 03:39:01 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qbw8f1cjs-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 03:39:00 -0500
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 31 Jan 2019 08:38:58 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 31 Jan 2019 08:38:48 -0000
Received: from d06av24.portsmouth.uk.ibm.com (d06av24.portsmouth.uk.ibm.com [9.149.105.60])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x0V8clRi8782276
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Thu, 31 Jan 2019 08:38:48 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id BF89342052;
	Thu, 31 Jan 2019 08:38:46 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 4515642042;
	Thu, 31 Jan 2019 08:38:44 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu, 31 Jan 2019 08:38:44 +0000 (GMT)
Date: Thu, 31 Jan 2019 10:38:42 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com,
        kirill.shutemov@linux.intel.com, vbabka@suse.cz, riel@surriel.com,
        sfr@canb.auug.org.au, rppt@linux.vnet.ibm.com, peterz@infradead.org,
        linux@armlinux.org.uk, robin.murphy@arm.com, iamjoonsoo.kim@lge.com,
        treding@nvidia.com, keescook@chromium.org, m.szyprowski@samsung.com,
        stefanr@s5r6.in-berlin.de, hjc@rock-chips.com, heiko@sntech.de,
        airlied@linux.ie, oleksandr_andrushchenko@epam.com, joro@8bytes.org,
        pawel@osciak.com, kyungmin.park@samsung.com, mchehab@kernel.org,
        boris.ostrovsky@oracle.com, jgross@suse.com,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        linux-arm-kernel@lists.infradead.org,
        linux1394-devel@lists.sourceforge.net, dri-devel@lists.freedesktop.org,
        linux-rockchip@lists.infradead.org, xen-devel@lists.xen.org,
        iommu@lists.linux-foundation.org, linux-media@vger.kernel.org
Subject: Re: [PATCHv2 1/9] mm: Introduce new vm_insert_range and
 vm_insert_range_buggy API
References: <20190131030812.GA2174@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190131030812.GA2174@jordon-HP-15-Notebook-PC>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19013108-0008-0000-0000-000002B93473
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19013108-0009-0000-0000-000022253606
Message-Id: <20190131083842.GE28876@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-01-31_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1901310068
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 31, 2019 at 08:38:12AM +0530, Souptick Joarder wrote:
> Previouly drivers have their own way of mapping range of
> kernel pages/memory into user vma and this was done by
> invoking vm_insert_page() within a loop.
> 
> As this pattern is common across different drivers, it can
> be generalized by creating new functions and use it across
> the drivers.
> 
> vm_insert_range() is the API which could be used to mapped
> kernel memory/pages in drivers which has considered vm_pgoff
> 
> vm_insert_range_buggy() is the API which could be used to map
> range of kernel memory/pages in drivers which has not considered
> vm_pgoff. vm_pgoff is passed default as 0 for those drivers.
> 
> We _could_ then at a later "fix" these drivers which are using
> vm_insert_range_buggy() to behave according to the normal vm_pgoff
> offsetting simply by removing the _buggy suffix on the function
> name and if that causes regressions, it gives us an easy way to revert.
> 
> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> Suggested-by: Russell King <linux@armlinux.org.uk>
> Suggested-by: Matthew Wilcox <willy@infradead.org>
> ---
>  include/linux/mm.h |  4 +++
>  mm/memory.c        | 81 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  mm/nommu.c         | 14 ++++++++++
>  3 files changed, 99 insertions(+)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 80bb640..25752b0 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2565,6 +2565,10 @@ unsigned long change_prot_numa(struct vm_area_struct *vma,
>  int remap_pfn_range(struct vm_area_struct *, unsigned long addr,
>  			unsigned long pfn, unsigned long size, pgprot_t);
>  int vm_insert_page(struct vm_area_struct *, unsigned long addr, struct page *);
> +int vm_insert_range(struct vm_area_struct *vma, struct page **pages,
> +				unsigned long num);
> +int vm_insert_range_buggy(struct vm_area_struct *vma, struct page **pages,
> +				unsigned long num);
>  vm_fault_t vmf_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
>  			unsigned long pfn);
>  vm_fault_t vmf_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
> diff --git a/mm/memory.c b/mm/memory.c
> index e11ca9d..0a4bf57 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1520,6 +1520,87 @@ int vm_insert_page(struct vm_area_struct *vma, unsigned long addr,
>  }
>  EXPORT_SYMBOL(vm_insert_page);
> 
> +/**
> + * __vm_insert_range - insert range of kernel pages into user vma
> + * @vma: user vma to map to
> + * @pages: pointer to array of source kernel pages
> + * @num: number of pages in page array
> + * @offset: user's requested vm_pgoff
> + *
> + * This allows drivers to insert range of kernel pages they've allocated
> + * into a user vma.
> + *
> + * If we fail to insert any page into the vma, the function will return
> + * immediately leaving any previously inserted pages present.  Callers
> + * from the mmap handler may immediately return the error as their caller
> + * will destroy the vma, removing any successfully inserted pages. Other
> + * callers should make their own arrangements for calling unmap_region().
> + *
> + * Context: Process context.
> + * Return: 0 on success and error code otherwise.
> + */
> +static int __vm_insert_range(struct vm_area_struct *vma, struct page **pages,
> +				unsigned long num, unsigned long offset)
> +{
> +	unsigned long count = vma_pages(vma);
> +	unsigned long uaddr = vma->vm_start;
> +	int ret, i;
> +
> +	/* Fail if the user requested offset is beyond the end of the object */
> +	if (offset > num)
> +		return -ENXIO;
> +
> +	/* Fail if the user requested size exceeds available object size */
> +	if (count > num - offset)
> +		return -ENXIO;
> +
> +	for (i = 0; i < count; i++) {
> +		ret = vm_insert_page(vma, uaddr, pages[offset + i]);
> +		if (ret < 0)
> +			return ret;
> +		uaddr += PAGE_SIZE;
> +	}
> +
> +	return 0;
> +}
> +
> +/**
> + * vm_insert_range - insert range of kernel pages starts with non zero offset
> + * @vma: user vma to map to
> + * @pages: pointer to array of source kernel pages
> + * @num: number of pages in page array
> + *
> + * Maps an object consisting of `num' `pages', catering for the user's
> + * requested vm_pgoff
> + *

The elaborate description you've added to __vm_insert_range() is better put
here, as this is the "public" function.

> + * Context: Process context. Called by mmap handlers.
> + * Return: 0 on success and error code otherwise.
> + */
> +int vm_insert_range(struct vm_area_struct *vma, struct page **pages,
> +				unsigned long num)
> +{
> +	return __vm_insert_range(vma, pages, num, vma->vm_pgoff);
> +}
> +EXPORT_SYMBOL(vm_insert_range);
> +
> +/**
> + * vm_insert_range_buggy - insert range of kernel pages starts with zero offset
> + * @vma: user vma to map to
> + * @pages: pointer to array of source kernel pages
> + * @num: number of pages in page array
> + *
> + * Maps a set of pages, always starting at page[0]

Here I'd add something like:

Similar to vm_insert_range(), except that it explicitly sets @vm_pgoff to
0. This function is intended for the drivers that did not consider
@vm_pgoff.

> vm_insert_range_buggy() is the API which could be used to map
> range of kernel memory/pages in drivers which has not considered
> vm_pgoff. vm_pgoff is passed default as 0 for those drivers.

> + *
> + * Context: Process context. Called by mmap handlers.
> + * Return: 0 on success and error code otherwise.
> + */
> +int vm_insert_range_buggy(struct vm_area_struct *vma, struct page **pages,
> +				unsigned long num)
> +{
> +	return __vm_insert_range(vma, pages, num, 0);
> +}
> +EXPORT_SYMBOL(vm_insert_range_buggy);
> +
>  static vm_fault_t insert_pfn(struct vm_area_struct *vma, unsigned long addr,
>  			pfn_t pfn, pgprot_t prot, bool mkwrite)
>  {
> diff --git a/mm/nommu.c b/mm/nommu.c
> index 749276b..21d101e 100644
> --- a/mm/nommu.c
> +++ b/mm/nommu.c
> @@ -473,6 +473,20 @@ int vm_insert_page(struct vm_area_struct *vma, unsigned long addr,
>  }
>  EXPORT_SYMBOL(vm_insert_page);
> 
> +int vm_insert_range(struct vm_area_struct *vma, struct page **pages,
> +			unsigned long num)
> +{
> +	return -EINVAL;
> +}
> +EXPORT_SYMBOL(vm_insert_range);
> +
> +int vm_insert_range_buggy(struct vm_area_struct *vma, struct page **pages,
> +				unsigned long num)
> +{
> +	return -EINVAL;
> +}
> +EXPORT_SYMBOL(vm_insert_range_buggy);
> +
>  /*
>   *  sys_brk() for the most part doesn't need the global kernel
>   *  lock, except when an application is doing something nasty
> -- 
> 1.9.1
> 

-- 
Sincerely yours,
Mike.

