Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id D89E16B0031
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 10:40:52 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id kl14so1526286pab.32
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 07:40:52 -0700 (PDT)
Received: from smtp106.biz.mail.gq1.yahoo.com (smtp106.biz.mail.gq1.yahoo.com. [98.137.12.181])
        by mx.google.com with SMTP id vv4si3471572pbc.365.2014.04.18.07.40.50
        for <linux-mm@kvack.org>;
        Fri, 18 Apr 2014 07:40:50 -0700 (PDT)
From: Steven King <sfking@fdwdc.com>
Subject: Re: [PATCH] slab: fix the type of the index on freelist index accessor
Date: Fri, 18 Apr 2014 07:40:47 -0700
References: <1397805849-4913-1-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1397805849-4913-1-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <201404180740.48445.sfking@fdwdc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>

On Friday 18 April 2014 12:24:09 am Joonsoo Kim wrote:
> commit 8dcc774 (slab: introduce byte sized index for the freelist of
> a slab) changes the size of freelist index and also changes prototype
> of accessor function to freelist index. And there was a mistake.
>
> The mistake is that although it changes the size of freelist index
> correctly, it changes the size of the index of freelist index incorrectly.
> With patch, freelist index can be 1 byte or 2 bytes, that means that
> num of object on on a slab can be more than 255. So we need more than 1
> byte for the index to find the index of free object on freelist. But,
> above patch makes this index type 1 byte, so slab which have more than
> 255 objects cannot work properly and in consequence of it, the system
> cannot boot.
>
> This issue was reported by Steven King on m68knommu which would use
> 2 bytes freelist index. Please refer following link.
>
> https://lkml.org/lkml/2014/4/16/433
>
> To fix it is so easy. To change the type of the index of freelist index
> on accessor functions is enough to fix this bug. Although 2 bytes is
> enough, I use 4 bytes since it have no bad effect and make things
> more easier. This fix was suggested and tested by Steven in his
> original report.
>
> Reported-by: Steven King <sfking@fdwdc.com>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
> Hello, Pekka.
>
> Could you send this for v3.15-rc2?
> Without this patch, many architecture using 2 bytes freelist index cannot
> work properly, I guess.
>
> This patch is based on v3.15-rc1.
>
> Thanks.
>
> diff --git a/mm/slab.c b/mm/slab.c
> index 388cb1a..d7f9f44 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -2572,13 +2572,13 @@ static void *alloc_slabmgmt(struct kmem_cache
> *cachep, return freelist;
>  }
>
> -static inline freelist_idx_t get_free_obj(struct page *page, unsigned char
> idx) +static inline freelist_idx_t get_free_obj(struct page *page, unsigned
> int idx) {
>  	return ((freelist_idx_t *)page->freelist)[idx];
>  }
>
>  static inline void set_free_obj(struct page *page,
> -					unsigned char idx, freelist_idx_t val)
> +					unsigned int idx, freelist_idx_t val)
>  {
>  	((freelist_idx_t *)(page->freelist))[idx] = val;
>  }

Acked-by: Steven King <sfking@fdwdc.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
