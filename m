Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 30ADD6B00D7
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 17:54:20 -0400 (EDT)
Received: by fxm18 with SMTP id 18so2548608fxm.38
        for <linux-mm@kvack.org>; Tue, 25 Aug 2009 14:54:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <200908241007.47910.ngupta@vflare.org>
References: <200908241007.47910.ngupta@vflare.org>
Date: Mon, 24 Aug 2009 20:33:25 +0300
Message-ID: <84144f020908241033l4af09e7h9caac47d8d9b7841@mail.gmail.com>
Subject: Re: [PATCH 1/4] compcache: xvmalloc memory allocator
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: ngupta@vflare.org
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mm-cc@laptop.org
List-ID: <linux-mm.kvack.org>

Hi Nitin,

[ Nit: the name xmalloc() is usually reserved for non-failing allocators in
  user-space which is why xvmalloc() looks so confusing to me. Can we
  get a better name for the thing? Also, I'm not sure why xvmalloc is a
  separate module. Can't you just make it in-kernel or compile it in to the
  ramzswap module? ]

On Mon, Aug 24, 2009 at 7:37 AM, Nitin Gupta<ngupta@vflare.org> wrote:
> +/**
> + * xv_malloc - Allocate block of given size from pool.
> + * @pool: pool to allocate from
> + * @size: size of block to allocate
> + * @pagenum: page no. that holds the object
> + * @offset: location of object within pagenum
> + *
> + * On success, <pagenum, offset> identifies block allocated
> + * and 0 is returned. On failure, <pagenum, offset> is set to
> + * 0 and -ENOMEM is returned.
> + *
> + * Allocation requests with size > XV_MAX_ALLOC_SIZE will fail.
> + */
> +int xv_malloc(struct xv_pool *pool, u32 size, u32 *pagenum, u32 *offset,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 gfp_t flags)
> +{
> + =A0 =A0 =A0 int error;
> + =A0 =A0 =A0 u32 index, tmpsize, origsize, tmpoffset;
> + =A0 =A0 =A0 struct block_header *block, *tmpblock;
> +
> + =A0 =A0 =A0 *pagenum =3D 0;
> + =A0 =A0 =A0 *offset =3D 0;
> + =A0 =A0 =A0 origsize =3D size;
> +
> + =A0 =A0 =A0 if (unlikely(!size || size > XV_MAX_ALLOC_SIZE))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> +
> + =A0 =A0 =A0 size =3D ALIGN(size, XV_ALIGN);
> +
> + =A0 =A0 =A0 spin_lock(&pool->lock);
> +
> + =A0 =A0 =A0 index =3D find_block(pool, size, pagenum, offset);
> +
> + =A0 =A0 =A0 if (!*pagenum) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&pool->lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (flags & GFP_NOWAIT)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 error =3D grow_pool(pool, flags);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(error))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&pool->lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 index =3D find_block(pool, size, pagenum, o=
ffset);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (!*pagenum) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&pool->lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 block =3D get_ptr_atomic(*pagenum, *offset, KM_USER0);
> +
> + =A0 =A0 =A0 remove_block_head(pool, block, index);
> +
> + =A0 =A0 =A0 /* Split the block if required */
> + =A0 =A0 =A0 tmpoffset =3D *offset + size + XV_ALIGN;
> + =A0 =A0 =A0 tmpsize =3D block->size - size;
> + =A0 =A0 =A0 tmpblock =3D (struct block_header *)((char *)block + size +=
 XV_ALIGN);
> + =A0 =A0 =A0 if (tmpsize) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tmpblock->size =3D tmpsize - XV_ALIGN;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_flag(tmpblock, BLOCK_FREE);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 clear_flag(tmpblock, PREV_FREE);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_blockprev(tmpblock, *offset);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (tmpblock->size >=3D XV_MIN_ALLOC_SIZE)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 insert_block(pool, *pagenum=
, tmpoffset, tmpblock);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (tmpoffset + XV_ALIGN + tmpblock->size !=
=3D PAGE_SIZE) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tmpblock =3D BLOCK_NEXT(tmp=
block);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_blockprev(tmpblock, tmp=
offset);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* This block is exact fit */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (tmpoffset !=3D PAGE_SIZE)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 clear_flag(tmpblock, PREV_F=
REE);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 block->size =3D origsize;
> + =A0 =A0 =A0 clear_flag(block, BLOCK_FREE);
> +
> + =A0 =A0 =A0 put_ptr_atomic(block, KM_USER0);
> + =A0 =A0 =A0 spin_unlock(&pool->lock);
> +
> + =A0 =A0 =A0 *offset +=3D XV_ALIGN;
> +
> + =A0 =A0 =A0 return 0;
> +}
> +EXPORT_SYMBOL_GPL(xv_malloc);

What's the purpose of passing PFNs around? There's quite a lot of PFN
to struct page conversion going on because of it. Wouldn't it make
more sense to return (and pass) a pointer to struct page instead?

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
