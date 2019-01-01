Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 48B7F8E0002
	for <linux-mm@kvack.org>; Tue,  1 Jan 2019 04:23:24 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id w18so35919304qts.8
        for <linux-mm@kvack.org>; Tue, 01 Jan 2019 01:23:24 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id b9si1302364qtq.169.2019.01.01.01.23.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Jan 2019 01:23:23 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id x019KAX3044671
	for <linux-mm@kvack.org>; Tue, 1 Jan 2019 04:23:23 -0500
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2pr417u1ka-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 01 Jan 2019 04:23:22 -0500
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Tue, 1 Jan 2019 09:23:21 -0000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: Re: [RFC][PATCH v2 11/21] kvm: allocate page table pages from DRAM
In-Reply-To: <20181226133351.703380444@intel.com>
References: <20181226131446.330864849@intel.com> <20181226133351.703380444@intel.com>
Date: Tue, 01 Jan 2019 14:53:07 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87pntg7mv8.fsf@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Yao Yuan <yuan.yao@intel.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Fan Du <fan.du@intel.com>, Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

Fengguang Wu <fengguang.wu@intel.com> writes:

> From: Yao Yuan <yuan.yao@intel.com>
>
> Signed-off-by: Yao Yuan <yuan.yao@intel.com>
> Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
> ---
> arch/x86/kvm/mmu.c |   12 +++++++++++-
> 1 file changed, 11 insertions(+), 1 deletion(-)
>
> --- linux.orig/arch/x86/kvm/mmu.c	2018-12-26 20:54:48.846720344 +0800
> +++ linux/arch/x86/kvm/mmu.c	2018-12-26 20:54:48.842719614 +0800
> @@ -950,6 +950,16 @@ static void mmu_free_memory_cache(struct
>  		kmem_cache_free(cache, mc->objects[--mc->nobjs]);
>  }
>  
> +static unsigned long __get_dram_free_pages(gfp_t gfp_mask)
> +{
> +       struct page *page;
> +
> +       page = __alloc_pages(GFP_KERNEL_ACCOUNT, 0, numa_node_id());
> +       if (!page)
> +	       return 0;
> +       return (unsigned long) page_address(page);
> +}
> +

May be it is explained in other patches. What is preventing the
allocation from pmem here? Is it that we are not using the memory
policy prefered node id and hence the zone list we built won't have the
PMEM node?


>  static int mmu_topup_memory_cache_page(struct kvm_mmu_memory_cache *cache,
>  				       int min)
>  {
> @@ -958,7 +968,7 @@ static int mmu_topup_memory_cache_page(s
>  	if (cache->nobjs >= min)
>  		return 0;
>  	while (cache->nobjs < ARRAY_SIZE(cache->objects)) {
> -		page = (void *)__get_free_page(GFP_KERNEL_ACCOUNT);
> +		page = (void *)__get_dram_free_pages(GFP_KERNEL_ACCOUNT);
>  		if (!page)
>  			return cache->nobjs >= min ? 0 : -ENOMEM;
>  		cache->objects[cache->nobjs++] = page;

-aneesh
