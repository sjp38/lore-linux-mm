Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 0DC566B0031
	for <linux-mm@kvack.org>; Mon, 14 Oct 2013 18:26:19 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id up15so7860155pbc.40
        for <linux-mm@kvack.org>; Mon, 14 Oct 2013 15:26:19 -0700 (PDT)
Date: Mon, 14 Oct 2013 15:26:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] mm/zswap: refoctor the get/put routines
Message-Id: <20131014152615.0c0e9c8467fd63fdd31f4add@linux-foundation.org>
In-Reply-To: <000101cec8c6$01b10020$05130060$%yang@samsung.com>
References: <000101cec8c6$01b10020$05130060$%yang@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>
Cc: sjenning@linux.vnet.ibm.com, sjennings@variantweb.net, 'Minchan Kim' <minchan@kernel.org>, bob.liu@oracle.com, weijie.yang.kh@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org

On Mon, 14 Oct 2013 18:12:34 +0800 Weijie Yang <weijie.yang@samsung.com> wrote:

> The refcount routine was not fit the kernel get/put semantic exactly,
> There were too many judgement statements on refcount and it could be minus.
> 
> This patch does the following:
> 
> - move refcount judgement to zswap_entry_put() to hide resource free function.
> 
> - add a new function zswap_entry_find_get(), so that callers can use easily
> in the following pattern:
> 
>    zswap_entry_find_get
>    .../* do something */
>    zswap_entry_put
> 
> - to eliminate compile error, move some functions declaration
> 
> This patch is based on Minchan Kim <minchan@kernel.org> 's idea and suggestion.
> 
> ...
>
> @@ -815,7 +809,7 @@ static void zswap_frontswap_invalidate_area(unsigned type)
>  	 */
>  	while ((node = rb_first(&tree->rbroot))) {
>  		entry = rb_entry(node, struct zswap_entry, rbnode);
> -		rb_erase(&entry->rbnode, &tree->rbroot);
> +		zswap_rb_erase(&tree->rbroot, entry);
>  		zbud_free(tree->pool, entry->handle);
>  		zswap_entry_cache_free(entry);
>  		atomic_dec(&zswap_stored_pages);
> -- 

zswap_frontswap_invalidate_area() has changed significantly in curent
mainline, so this will need redoing please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
