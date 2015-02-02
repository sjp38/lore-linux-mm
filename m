Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f176.google.com (mail-ie0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id 382F26B0032
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 12:45:24 -0500 (EST)
Received: by mail-ie0-f176.google.com with SMTP id at20so19172432iec.7
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 09:45:23 -0800 (PST)
Received: from mail-ig0-x232.google.com (mail-ig0-x232.google.com. [2607:f8b0:4001:c05::232])
        by mx.google.com with ESMTPS id uv6si8006628igb.18.2015.02.02.09.45.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Feb 2015 09:45:23 -0800 (PST)
Received: by mail-ig0-f178.google.com with SMTP id hl2so18572060igb.5
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 09:45:23 -0800 (PST)
Date: Mon, 2 Feb 2015 09:45:21 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] mm: Export __vmalloc_node
In-Reply-To: <1422846627-26890-2-git-send-email-green@linuxhacker.ru>
Message-ID: <alpine.DEB.2.10.1502020940530.5117@chino.kir.corp.google.com>
References: <1422846627-26890-1-git-send-email-green@linuxhacker.ru> <1422846627-26890-2-git-send-email-green@linuxhacker.ru>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Drokin <green@linuxhacker.ru>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Sun, 1 Feb 2015, green@linuxhacker.ru wrote:

> From: Oleg Drokin <green@linuxhacker.ru>
> 
> vzalloc_node helpfully suggests to use __vmalloc_node if a more tight
> control over allocation flags is needed, but in fact __vmalloc_node
> is not only not exported, it's also static, so could not be used
> outside of mm/vmalloc.c
> Make it to be available as it was apparently intended.
> 

__vmalloc_node() is for the generalized functionality that is needed for 
the vmalloc API and not part of the API itself.  I think what you want to 
do is add a vmalloc_node_gfp(), or more specifically a vzalloc_node_gfp(), 
to do GFP_NOFS when needed.

> Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
> ---
>  include/linux/vmalloc.h |  3 +++
>  mm/vmalloc.c            | 10 ++++------
>  2 files changed, 7 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
> index b87696f..7eb2c46 100644
> --- a/include/linux/vmalloc.h
> +++ b/include/linux/vmalloc.h
> @@ -73,6 +73,9 @@ extern void *vmalloc_exec(unsigned long size);
>  extern void *vmalloc_32(unsigned long size);
>  extern void *vmalloc_32_user(unsigned long size);
>  extern void *__vmalloc(unsigned long size, gfp_t gfp_mask, pgprot_t prot);
> +extern void *__vmalloc_node(unsigned long size, unsigned long align,
> +			    gfp_t gfp_mask, pgprot_t prot, int node,
> +			    const void *caller);
>  extern void *__vmalloc_node_range(unsigned long size, unsigned long align,
>  			unsigned long start, unsigned long end, gfp_t gfp_mask,
>  			pgprot_t prot, int node, const void *caller);
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 39c3388..b882d95 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1552,9 +1552,6 @@ void *vmap(struct page **pages, unsigned int count,
>  }
>  EXPORT_SYMBOL(vmap);
>  
> -static void *__vmalloc_node(unsigned long size, unsigned long align,
> -			    gfp_t gfp_mask, pgprot_t prot,
> -			    int node, const void *caller);
>  static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
>  				 pgprot_t prot, int node)
>  {
> @@ -1685,13 +1682,14 @@ fail:
>   *	allocator with @gfp_mask flags.  Map them into contiguous
>   *	kernel virtual space, using a pagetable protection of @prot.
>   */
> -static void *__vmalloc_node(unsigned long size, unsigned long align,
> -			    gfp_t gfp_mask, pgprot_t prot,
> -			    int node, const void *caller)
> +void *__vmalloc_node(unsigned long size, unsigned long align,
> +		     gfp_t gfp_mask, pgprot_t prot, int node,
> +		     const void *caller)
>  {
>  	return __vmalloc_node_range(size, align, VMALLOC_START, VMALLOC_END,
>  				gfp_mask, prot, node, caller);
>  }
> +EXPORT_SYMBOL(__vmalloc_node);
>  
>  void *__vmalloc(unsigned long size, gfp_t gfp_mask, pgprot_t prot)
>  {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
