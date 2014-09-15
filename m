Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id F39616B0036
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 03:18:28 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id v10so5703125pde.3
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 00:18:28 -0700 (PDT)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id sa2si21254871pbc.8.2014.09.15.00.18.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 15 Sep 2014 00:18:27 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NBX007HULRHJX20@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 15 Sep 2014 08:21:18 +0100 (BST)
Message-id: <54169130.2000601@samsung.com>
Date: Mon, 15 Sep 2014 11:11:44 +0400
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [RFC/PATCH v2 05/10] mm: slub: share slab_err and object_err
 functions
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1410359487-31938-1-git-send-email-a.ryabinin@samsung.com>
 <1410359487-31938-6-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1410359487-31938-6-git-send-email-a.ryabinin@samsung.com>
Content-type: text/plain; charset=UTF-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>

On 09/10/2014 06:31 PM, Andrey Ryabinin wrote:
> Remove static and add function declarations to mm/slab.h so they
> could be used by kernel address sanitizer.
> 

The same as with virt_to_obj. include/linux/slub_def.h is much better place for this than mm/slab.h.


> Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
> ---
>  mm/slab.h | 5 +++++
>  mm/slub.c | 4 ++--
>  2 files changed, 7 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/slab.h b/mm/slab.h
> index 3e3a6ae..87491dd 100644
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -345,6 +345,11 @@ static inline struct kmem_cache_node *get_node(struct kmem_cache *s, int node)
>  
>  void *slab_next(struct seq_file *m, void *p, loff_t *pos);
>  void slab_stop(struct seq_file *m, void *p);
> +void slab_err(struct kmem_cache *s, struct page *page,
> +		const char *fmt, ...);
> +void object_err(struct kmem_cache *s, struct page *page,
> +		u8 *object, char *reason);
> +
>  
>  static inline void *virt_to_obj(struct kmem_cache *s, void *slab_page, void *x)
>  {
> diff --git a/mm/slub.c b/mm/slub.c
> index fa86e58..c4158b2 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -639,14 +639,14 @@ static void print_trailer(struct kmem_cache *s, struct page *page, u8 *p)
>  	dump_stack();
>  }
>  
> -static void object_err(struct kmem_cache *s, struct page *page,
> +void object_err(struct kmem_cache *s, struct page *page,
>  			u8 *object, char *reason)
>  {
>  	slab_bug(s, "%s", reason);
>  	print_trailer(s, page, object);
>  }
>  
> -static void slab_err(struct kmem_cache *s, struct page *page,
> +void slab_err(struct kmem_cache *s, struct page *page,
>  			const char *fmt, ...)
>  {
>  	va_list args;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
