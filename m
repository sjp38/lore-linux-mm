Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id E534C6B000C
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 12:50:59 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id o18-v6so31354246qko.21
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 09:50:59 -0700 (PDT)
Received: from EUR04-DB3-obe.outbound.protection.outlook.com (mail-eopbgr60126.outbound.protection.outlook.com. [40.107.6.126])
        by mx.google.com with ESMTPS id r37-v6si9954qvc.85.2018.07.11.09.50.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 11 Jul 2018 09:50:59 -0700 (PDT)
Subject: Re: [PATCH v7] mm: Distinguish VMalloc pages
References: <20180710165326.9378-1-willy@infradead.org>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <b9114b25-4ff2-045d-faf9-0747673e3957@virtuozzo.com>
Date: Wed, 11 Jul 2018 19:52:34 +0300
MIME-Version: 1.0
In-Reply-To: <20180710165326.9378-1-willy@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <jiangshanlai@gmail.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>



On 07/10/2018 07:53 PM, Matthew Wilcox wrote:
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 21e1b6a9f113..8a4698b368de 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -153,6 +153,11 @@ struct page {
>  			spinlock_t ptl;
>  #endif
>  		};
> +		struct {	/* VMalloc pages */
> +			struct vm_struct *vm_area;
> +			unsigned long vm_offset;
> +			unsigned long _vm_id;	/* MAPPING_VMalloc */
> +		};
>  		struct {	/* ZONE_DEVICE pages */
>  			/** @pgmap: Points to the hosting device page map. */
>  			struct dev_pagemap *pgmap;
> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> index 901943e4754b..588b8dd28a85 100644
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -699,6 +699,32 @@ PAGE_TYPE_OPS(Kmemcg, kmemcg)
>   */
>  PAGE_TYPE_OPS(Table, table)
>  
> +/*
> + * vmalloc pages may be mapped to userspace, so we need some other way
> + * to distinguish them from other kinds of pages.  Use page->mapping for
> + * this purpose.  Values below 0x1000 cannot be real pointers.  Setting
> + * the bottom bit makes page_mapping() return NULL, which is what we want.
> + */
> +#define MAPPING_VMalloc		(void *)0x441

So this makes the vmalloc pages look like anon pages,
while previously they were !PageAnon.

I'm pretty sure this is not going to work.


> +
> +#define PAGE_MAPPING_OPS(name)						\
> +static __always_inline int Page##name(struct page *page)		\
> +{									\
> +	return page->mapping == MAPPING_##name;				\
> +}									\
> +static __always_inline void __SetPage##name(struct page *page)		\
> +{									\
> +	VM_BUG_ON_PAGE(page->mapping != NULL, page);			\
> +	page->mapping = MAPPING_##name;					\
> +}									\
> +static __always_inline void __ClearPage##name(struct page *page)	\
> +{									\
> +	VM_BUG_ON_PAGE(page->mapping != MAPPING_##name, page);		\
> +	page->mapping = NULL;						\
> +}
> +
> +PAGE_MAPPING_OPS(VMalloc)
> +
