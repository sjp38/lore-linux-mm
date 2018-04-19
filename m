Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 17E016B0003
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 09:23:17 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id c56-v6so5232804wrc.5
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 06:23:17 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 5si1135194edi.408.2018.04.19.06.23.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Apr 2018 06:23:15 -0700 (PDT)
Subject: Re: [PATCH v3 09/14] mm: Use page->deferred_list
References: <20180418184912.2851-1-willy@infradead.org>
 <20180418184912.2851-10-willy@infradead.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <c67f7169-a12d-0cdc-c198-bf499972eb83@suse.cz>
Date: Thu, 19 Apr 2018 15:23:12 +0200
MIME-Version: 1.0
In-Reply-To: <20180418184912.2851-10-willy@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Pekka Enberg <penberg@kernel.org>

On 04/18/2018 08:49 PM, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> Now that we can represent the location of 'deferred_list' in C instead
> of comments, make use of that ability.
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/huge_memory.c | 7 ++-----
>  mm/page_alloc.c  | 2 +-
>  2 files changed, 3 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 14ed6ee5e02f..55ad852fbf17 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -483,11 +483,8 @@ pmd_t maybe_pmd_mkwrite(pmd_t pmd, struct vm_area_struct *vma)
>  
>  static inline struct list_head *page_deferred_list(struct page *page)
>  {
> -	/*
> -	 * ->lru in the tail pages is occupied by compound_head.
> -	 * Let's use ->mapping + ->index in the second tail page as list_head.
> -	 */
> -	return (struct list_head *)&page[2].mapping;
> +	/* ->lru in the tail pages is occupied by compound_head. */
> +	return &page[2].deferred_list;
>  }
>  
>  void prep_transhuge_page(struct page *page)
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 88e817d7ccef..18720eccbce1 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -953,7 +953,7 @@ static int free_tail_pages_check(struct page *head_page, struct page *page)
>  	case 2:
>  		/*
>  		 * the second tail page: ->mapping is
> -		 * page_deferred_list().next -- ignore value.
> +		 * deferred_list.next -- ignore value.
>  		 */
>  		break;
>  	default:
> 
