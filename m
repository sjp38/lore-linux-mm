Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id D0DE26B0035
	for <linux-mm@kvack.org>; Thu, 24 Apr 2014 12:40:47 -0400 (EDT)
Received: by mail-ob0-f172.google.com with SMTP id wo20so2943517obc.17
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 09:40:47 -0700 (PDT)
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
        by mx.google.com with ESMTPS id sd1si3969992obb.46.2014.04.24.09.40.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 24 Apr 2014 09:40:46 -0700 (PDT)
Received: by mail-ob0-f172.google.com with SMTP id wo20so2965201obc.3
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 09:40:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1397805849-4913-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1397805849-4913-1-git-send-email-iamjoonsoo.kim@lge.com>
Date: Thu, 24 Apr 2014 17:40:46 +0100
Message-ID: <CAAG0J9-8WbO48jXpUfOq6CmHinL9dMg5Ee9-J9qndBEtZgWYJg@mail.gmail.com>
Subject: Re: [PATCH] slab: fix the type of the index on freelist index accessor
From: James Hogan <james.hogan@imgtec.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Steven King <sfking@fdwdc.com>, Geert Uytterhoeven <geert@linux-m68k.org>

On 18 April 2014 08:24, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
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

I also hit this problem on MIPS with v3.15-rc2 and 16K pages. With
this patch it boots fine.

Tested-by: James Hogan <james.hogan@imgtec.com>

Thanks
James

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
> @@ -2572,13 +2572,13 @@ static void *alloc_slabmgmt(struct kmem_cache *cachep,
>         return freelist;
>  }
>
> -static inline freelist_idx_t get_free_obj(struct page *page, unsigned char idx)
> +static inline freelist_idx_t get_free_obj(struct page *page, unsigned int idx)
>  {
>         return ((freelist_idx_t *)page->freelist)[idx];
>  }
>
>  static inline void set_free_obj(struct page *page,
> -                                       unsigned char idx, freelist_idx_t val)
> +                                       unsigned int idx, freelist_idx_t val)
>  {
>         ((freelist_idx_t *)(page->freelist))[idx] = val;
>  }
> --
> 1.7.9.5
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
