Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id AA3C46B005C
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 15:31:19 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id v3so6839120pfm.21
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 12:31:19 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e1-v6sor967561plk.32.2018.03.05.12.31.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Mar 2018 12:31:18 -0800 (PST)
Subject: Re: [PATCH 3/7] struct page: add field for vm_struct
References: <20180228200620.30026-1-igor.stoppa@huawei.com>
 <20180228200620.30026-4-igor.stoppa@huawei.com>
From: J Freyensee <why2jjj.linux@gmail.com>
Message-ID: <2985e90a-5937-9432-c53e-f594b27e7afa@gmail.com>
Date: Mon, 5 Mar 2018 12:31:14 -0800
MIME-Version: 1.0
In-Reply-To: <20180228200620.30026-4-igor.stoppa@huawei.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>, david@fromorbit.com, willy@infradead.org, keescook@chromium.org, mhocko@kernel.org
Cc: labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

Reviewed-by: Jay Freyensee <why2jjj.linux@gmail.com>

On 2/28/18 12:06 PM, Igor Stoppa wrote:
> When a page is used for virtual memory, it is often necessary to obtain
> a handler to the corresponding vm_struct, which refers to the virtually
> continuous area generated when invoking vmalloc.
>
> The struct page has a "mapping" field, which can be re-used, to store a
> pointer to the parent area.
>
> This will avoid more expensive searches, later on.
>
> Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
> ---
>   include/linux/mm_types.h | 1 +
>   mm/vmalloc.c             | 2 ++
>   2 files changed, 3 insertions(+)
>
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index fd1af6b9591d..c3a4825e10c0 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -84,6 +84,7 @@ struct page {
>   		void *s_mem;			/* slab first object */
>   		atomic_t compound_mapcount;	/* first tail page */
>   		/* page_deferred_list().next	 -- second tail page */
> +		struct vm_struct *area;
>   	};
>   
>   	/* Second double word */
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index ebff729cc956..61a1ca22b0f6 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1536,6 +1536,7 @@ static void __vunmap(const void *addr, int deallocate_pages)
>   			struct page *page = area->pages[i];
>   
>   			BUG_ON(!page);
> +			page->area = NULL;
>   			__free_pages(page, 0);
>   		}
>   
> @@ -1705,6 +1706,7 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
>   			area->nr_pages = i;
>   			goto fail;
>   		}
> +		page->area = area;
>   		area->pages[i] = page;
>   		if (gfpflags_allow_blocking(gfp_mask|highmem_mask))
>   			cond_resched();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
