Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f175.google.com (mail-io0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 059666B0005
	for <linux-mm@kvack.org>; Mon, 18 Jan 2016 02:09:39 -0500 (EST)
Received: by mail-io0-f175.google.com with SMTP id g73so348449422ioe.3
        for <linux-mm@kvack.org>; Sun, 17 Jan 2016 23:09:39 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id y10si7477470igw.59.2016.01.17.23.09.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 17 Jan 2016 23:09:38 -0800 (PST)
Date: Mon, 18 Jan 2016 16:11:57 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3] zsmalloc: fix migrate_zspage-zs_free race condition
Message-ID: <20160118071157.GD7453@bbox>
References: <1453095596-44055-1-git-send-email-junil0814.lee@lge.com>
 <20160118063611.GC7453@bbox>
 <20160118065434.GB459@swordfish>
MIME-Version: 1.0
In-Reply-To: <20160118065434.GB459@swordfish>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Junil Lee <junil0814.lee@lge.com>, ngupta@vflare.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, vbabka@suse.cz

On Mon, Jan 18, 2016 at 03:54:34PM +0900, Sergey Senozhatsky wrote:
> On (01/18/16 15:36), Minchan Kim wrote:
> [..]
> > > --- a/mm/zsmalloc.c
> > > +++ b/mm/zsmalloc.c
> > > @@ -1635,8 +1635,8 @@ static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
> > >  		free_obj = obj_malloc(d_page, class, handle);
> > >  		zs_object_copy(free_obj, used_obj, class);
> > >  		index++;
> > > +		/* This also effectively unpins the handle */
> > 
> > As reply of Vlastimil, I relied that I guess it doesn't work.
> > We shouldn't omit unpin_tag and we should add WRITE_ONCE in
> > record_obj.
> > 
> > As well, it's worth to dobule check with locking guys.
> > I will send updated version.
> 
> but would WRITE_ONCE() tell the compiler that there is a dependency?
> __write_once_size() does not even issue a barrier for sizes <= 8 (our
> case).
> 
> include/linux/compiler.h
> 
> static __always_inline void __write_once_size(volatile void *p, void *res, int size)
> {
> 	switch (size) {
> 	case 1: *(volatile __u8 *)p = *(__u8 *)res; break;
> 	case 2: *(volatile __u16 *)p = *(__u16 *)res; break;
> 	case 4: *(volatile __u32 *)p = *(__u32 *)res; break;
> 	case 8: *(volatile __u64 *)p = *(__u64 *)res; break;
> 	default:
> 		barrier();
> 		__builtin_memcpy((void *)p, (const void *)res, size);
> 		barrier();
> 	}
> }
> 
> #define WRITE_ONCE(x, val) \
> ({							\
> 	union { typeof(x) __val; char __c[1]; } __u =	\
> 		{ .__val = (__force typeof(x)) (val) }; \
> 	__write_once_size(&(x), __u.__c, sizeof(x));	\
> 	__u.__val;					\
> })
> 
> 
> so, even if clear_bit_unlock/test_and_set_bit_lock do smp_mb or
> barrier(), there is no corresponding barrier from record_obj()->WRITE_ONCE().
> so I don't think WRITE_ONCE() will help the compiler, or am I missing
> something?

We need two things

1. compiler barrier
2. memory barrier.

As compiler barrier, WRITE_ONCE works to prevent store tearing here
by compiler.
However, if we omit unpin_tag here, we lose memory barrier(e,g, smp_mb)
so another CPU could see stale data caused CPU memory reordering.


> 
> .... add a barrier() to record_obj()?
> 
> 	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
