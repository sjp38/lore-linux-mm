Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3FC51280260
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 03:26:17 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id g186so377722413pgc.2
        for <linux-mm@kvack.org>; Mon, 21 Nov 2016 00:26:17 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id h5si17745703pgg.22.2016.11.21.00.26.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Nov 2016 00:26:16 -0800 (PST)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAL8NPYx009186
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 03:26:15 -0500
Received: from e28smtp01.in.ibm.com (e28smtp01.in.ibm.com [125.16.236.1])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26us0g1j66-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 03:26:14 -0500
Received: from localhost
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 21 Nov 2016 13:56:11 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 22BBD394006D
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 13:56:09 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAL8Q7Qf35127458
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 13:56:07 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAL8Q72m029550
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 13:56:07 +0530
Subject: Re: [HMM v13 04/18] mm/ZONE_DEVICE/free-page: callback when page is
 freed
References: <1479493107-982-1-git-send-email-jglisse@redhat.com>
 <1479493107-982-5-git-send-email-jglisse@redhat.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Mon, 21 Nov 2016 13:56:02 +0530
MIME-Version: 1.0
In-Reply-To: <1479493107-982-5-git-send-email-jglisse@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Message-Id: <5832AF9A.8020808@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On 11/18/2016 11:48 PM, JA(C)rA'me Glisse wrote:
> When a ZONE_DEVICE page refcount reach 1 it means it is free and nobody
> is holding a reference on it (only device to which the memory belong do).
> Add a callback and call it when that happen so device driver can implement
> their own free page management.
> 
> Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> ---
>  include/linux/memremap.h | 4 ++++
>  kernel/memremap.c        | 8 ++++++++
>  2 files changed, 12 insertions(+)
> 
> diff --git a/include/linux/memremap.h b/include/linux/memremap.h
> index fe61dca..469c88d 100644
> --- a/include/linux/memremap.h
> +++ b/include/linux/memremap.h
> @@ -37,17 +37,21 @@ static inline struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
>  
>  /**
>   * struct dev_pagemap - metadata for ZONE_DEVICE mappings
> + * @free_devpage: free page callback when page refcount reach 1
>   * @altmap: pre-allocated/reserved memory for vmemmap allocations
>   * @res: physical address range covered by @ref
>   * @ref: reference count that pins the devm_memremap_pages() mapping
>   * @dev: host device of the mapping for debug
> + * @data: privata data pointer for free_devpage
>   * @flags: memory flags (look for MEMORY_FLAGS_NONE in memory_hotplug.h)
>   */
>  struct dev_pagemap {
> +	void (*free_devpage)(struct page *page, void *data);
>  	struct vmem_altmap *altmap;
>  	const struct resource *res;
>  	struct percpu_ref *ref;
>  	struct device *dev;
> +	void *data;
>  	int flags;
>  };
>  
> diff --git a/kernel/memremap.c b/kernel/memremap.c
> index 438a73aa2..3d28048 100644
> --- a/kernel/memremap.c
> +++ b/kernel/memremap.c
> @@ -190,6 +190,12 @@ EXPORT_SYMBOL(get_zone_device_page);
>  
>  void put_zone_device_page(struct page *page)
>  {
> +	/*
> +	 * If refcount is 1 then page is freed and refcount is stable as nobody
> +	 * holds a reference on the page.
> +	 */
> +	if (page->pgmap->free_devpage && page_count(page) == 1)
> +		page->pgmap->free_devpage(page, page->pgmap->data);
>  	put_dev_pagemap(page->pgmap);
>  }
>  EXPORT_SYMBOL(put_zone_device_page);
> @@ -326,6 +332,8 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
>  	pgmap->ref = ref;
>  	pgmap->res = &page_map->res;
>  	pgmap->flags = flags | MEMORY_DEVICE;
> +	pgmap->free_devpage = NULL;
> +	pgmap->data = NULL;

When is the driver expected to load up pgmap->free_devpage ? I thought
this function is one of the right places. Though as all the pages in
the same hotplug operation point to the same dev_pagemap structure this
loading can be done at later point of time as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
