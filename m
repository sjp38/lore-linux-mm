Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 97D926B0032
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 16:11:37 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so6023691pbb.19
        for <linux-mm@kvack.org>; Tue, 17 Sep 2013 13:11:37 -0700 (PDT)
Date: Tue, 17 Sep 2013 13:11:32 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/3] mm/vmalloc: don't warning vmalloc allocation
 failure twice
Message-Id: <20130917131132.30cea21dba15f42b919fe71a@linux-foundation.org>
In-Reply-To: <1378125345-13228-2-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1378125345-13228-1-git-send-email-liwanp@linux.vnet.ibm.com>
	<1378125345-13228-2-git-send-email-liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon,  2 Sep 2013 20:35:44 +0800 Wanpeng Li <liwanp@linux.vnet.ibm.com> wrote:

> Don't warning twice in __vmalloc_area_node and __vmalloc_node_range if 
> __vmalloc_area_node allocation failure.
> 
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> ---
>  mm/vmalloc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index ee41cc6..e324d38 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1635,7 +1635,7 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
>  
>  	addr = __vmalloc_area_node(area, gfp_mask, prot, node, caller);
>  	if (!addr)
> -		goto fail;
> +		return NULL;
>  
>  	/*
>  	 * In this function, newly allocated vm_struct has VM_UNINITIALIZED

Putting a `return' in the middle of a function is often a bad thing -
functions which have multiple return points often lead to resource and
locking leaks.

It's particularly bad to have that return *after* a bunch of "goto
fail" statements - the result is utter spaghetti.

Fix:

--- a/mm/vmalloc.c~mm-vmalloc-dont-warn-about-vmalloc-allocation-failure-twice-fix
+++ a/mm/vmalloc.c
@@ -1626,16 +1626,16 @@ void *__vmalloc_node_range(unsigned long
 
 	size = PAGE_ALIGN(size);
 	if (!size || (size >> PAGE_SHIFT) > totalram_pages)
-		goto fail;
+		goto warn;
 
 	area = __get_vm_area_node(size, align, VM_ALLOC | VM_UNINITIALIZED,
 				  start, end, node, gfp_mask, caller);
 	if (!area)
-		goto fail;
+		goto warn;
 
 	addr = __vmalloc_area_node(area, gfp_mask, prot, node, caller);
 	if (!addr)
-		return NULL;
+		goto fail;
 
 	/*
 	 * In this function, newly allocated vm_struct has VM_UNINITIALIZED
@@ -1653,10 +1653,11 @@ void *__vmalloc_node_range(unsigned long
 
 	return addr;
 
-fail:
+warn:
 	warn_alloc_failed(gfp_mask, 0,
 			  "vmalloc: allocation failure: %lu bytes\n",
 			  real_size);
+fail:
 	return NULL;
 }
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
