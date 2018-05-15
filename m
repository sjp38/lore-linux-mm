Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8D8036B000A
	for <linux-mm@kvack.org>; Tue, 15 May 2018 05:33:00 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id z16-v6so7709762pgv.16
        for <linux-mm@kvack.org>; Tue, 15 May 2018 02:33:00 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l4-v6si11129832plb.213.2018.05.15.02.32.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 15 May 2018 02:32:59 -0700 (PDT)
Subject: Re: [PATCH v5 13/17] mm: Add hmm_data to struct page
References: <20180504183318.14415-1-willy@infradead.org>
 <20180504183318.14415-14-willy@infradead.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <3a804ef2-9196-c946-895c-54dc7cab618b@suse.cz>
Date: Tue, 15 May 2018 11:32:56 +0200
MIME-Version: 1.0
In-Reply-To: <20180504183318.14415-14-willy@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <jiangshanlai@gmail.com>, Pekka Enberg <penberg@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>

On 05/04/2018 08:33 PM, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> Make hmm_data an explicit member of the struct page union.
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> ---
>  include/linux/hmm.h      |  8 ++------
>  include/linux/mm_types.h | 14 +++++++++-----
>  2 files changed, 11 insertions(+), 11 deletions(-)
> 
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index 39988924de3a..91c1b2dccbbb 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -522,9 +522,7 @@ void hmm_devmem_remove(struct hmm_devmem *devmem);
>  static inline void hmm_devmem_page_set_drvdata(struct page *page,
>  					       unsigned long data)
>  {
> -	unsigned long *drvdata = (unsigned long *)&page->pgmap;
> -
> -	drvdata[1] = data;

Well, that was ugly :)

> +	page->hmm_data = data;
>  }
>  
>  /*
> @@ -535,9 +533,7 @@ static inline void hmm_devmem_page_set_drvdata(struct page *page,
>   */
>  static inline unsigned long hmm_devmem_page_get_drvdata(const struct page *page)
>  {
> -	const unsigned long *drvdata = (const unsigned long *)&page->pgmap;
> -
> -	return drvdata[1];
> +	return page->hmm_data;
>  }
>  
>  
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 5a519279dcd5..fa05e6ca31ed 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -150,11 +150,15 @@ struct page {
>  		/** @rcu_head: You can use this to free a page by RCU. */
>  		struct rcu_head rcu_head;
>  
> -		/**
> -		 * @pgmap: For ZONE_DEVICE pages, this points to the hosting
> -		 * device page map.
> -		 */
> -		struct dev_pagemap *pgmap;
> +		struct {
> +			/**
> +			 * @pgmap: For ZONE_DEVICE pages, this points to the
> +			 * hosting device page map.
> +			 */
> +			struct dev_pagemap *pgmap;
> +			unsigned long hmm_data;
> +			unsigned long _zd_pad_1;	/* uses mapping */
> +		};

Maybe move this above rcu_head and make the comments look more like for
the other union variants?

>  	};
>  
>  	union {		/* This union is 4 bytes in size. */
> 
