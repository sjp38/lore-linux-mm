Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id D7B2682F66
	for <linux-mm@kvack.org>; Tue,  6 Oct 2015 06:59:09 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so206683255pab.3
        for <linux-mm@kvack.org>; Tue, 06 Oct 2015 03:59:09 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id n2si47959001pap.239.2015.10.06.03.59.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Oct 2015 03:59:08 -0700 (PDT)
Received: by pacfv12 with SMTP id fv12so211704059pac.2
        for <linux-mm@kvack.org>; Tue, 06 Oct 2015 03:59:08 -0700 (PDT)
Date: Tue, 6 Oct 2015 19:59:03 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] zsmalloc: fix obj_to_head use page_private(page) as
 value but not pointer
Message-ID: <20151006105903.GA8462@swordfish>
References: <1444033381-5726-1-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1444033381-5726-1-git-send-email-zhuhui@xiaomi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hui Zhu <zhuhui@xiaomi.com>
Cc: minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, teawater@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (10/05/15 16:23), Hui Zhu wrote:
> In function obj_malloc:
> 	if (!class->huge)
> 		/* record handle in the header of allocated chunk */
> 		link->handle = handle;
> 	else
> 		/* record handle in first_page->private */
> 		set_page_private(first_page, handle);
> The huge's page save handle to private directly.
> 
> But in obj_to_head:
> 	if (class->huge) {
> 		VM_BUG_ON(!is_first_page(page));
> 		return page_private(page);
> 	} else
> 		return *(unsigned long *)obj;
> It is used as a pointer.
> 

um...
obj_to_head() is not for obj_malloc(), but for record_obj() that follows.
handle is a `void *' returned from alloc_handle()->kmem_cache_alloc(), and
casted to 'unsigned long'.

we store obj as:

static void record_obj(unsigned long handle, unsigned long obj)
{
	*(unsigned long *)handle = obj;
}

regardless `class->huge'.


and retrieve it as  `*(unsigned long *)foo', which is either
	`*(unsigned long *)page_private(page)'
or
	`*(unsigned long *)obj'

'return p' and `return *p' do slightly different things for pointers.


am I missing something?

	-ss

> So change obj_to_head use page_private(page) as value but not pointer
> in obj_to_head.
> 
> Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
> ---
>  mm/zsmalloc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index f135b1b..e881d4f 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -824,7 +824,7 @@ static unsigned long obj_to_head(struct size_class *class, struct page *page,
>  {
>  	if (class->huge) {
>  		VM_BUG_ON(!is_first_page(page));
> -		return *(unsigned long *)page_private(page);
> +		return page_private(page);
>  	} else
>  		return *(unsigned long *)obj;
>  }
> -- 
> 1.9.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
