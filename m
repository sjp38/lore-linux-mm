Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 08BDF828DF
	for <linux-mm@kvack.org>; Sat, 16 Jan 2016 05:07:40 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id cy9so407658642pac.0
        for <linux-mm@kvack.org>; Sat, 16 Jan 2016 02:07:40 -0800 (PST)
Received: from mail-pa0-x242.google.com (mail-pa0-x242.google.com. [2607:f8b0:400e:c03::242])
        by mx.google.com with ESMTPS id c90si23200174pfd.178.2016.01.16.02.07.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 Jan 2016 02:07:39 -0800 (PST)
Received: by mail-pa0-x242.google.com with SMTP id yy13so30425549pab.1
        for <linux-mm@kvack.org>; Sat, 16 Jan 2016 02:07:39 -0800 (PST)
Date: Sat, 16 Jan 2016 19:05:57 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH v2] zsmalloc: fix migrate_zspage-zs_free race condition
Message-ID: <20160116100557.GC566@swordfish>
References: <1452843551-4464-1-git-send-email-junil0814.lee@lge.com>
 <20160115143434.GA25332@blaptop.local>
 <56991514.9000609@suse.cz>
 <20160116040913.GA566@swordfish>
 <5699F4C9.1070902@suse.cz>
 <20160116080650.GB566@swordfish>
 <5699FC69.4010000@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5699FC69.4010000@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim <minchan@kernel.org>, Junil Lee <junil0814.lee@lge.com>, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On (01/16/16 09:16), Vlastimil Babka wrote:
[..]
> BTW, couldn't the correct fix also just look like this?
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 9f15bdd9163c..43f743175ede 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -1635,8 +1635,8 @@ static int migrate_zspage(struct zs_pool *pool, struct
> size_class *class,
>                 free_obj = obj_malloc(d_page, class, handle);
>                 zs_object_copy(free_obj, used_obj, class);
>                 index++;
> +               /* This also effectively unpins the handle */
>                 record_obj(handle, free_obj);
> -               unpin_tag(handle);
>                 obj_free(pool, class, used_obj);
>         }

I think this will work.


> But I'd still recommend WRITE_ONCE in record_obj(). And I'm not even sure it's
> safe on all architectures to do a simple overwrite of a word against somebody
> else trying to lock a bit there?

hm... for example, generic bitops from include/asm-generic/bitops/atomic.h
use _atomic_spin_lock_irqsave()

 #define test_and_set_bit_lock(nr, addr)  test_and_set_bit(nr, addr)

 static inline int test_and_set_bit(int nr, volatile unsigned long *addr)
 {
         unsigned long mask = BIT_MASK(nr);
         unsigned long *p = ((unsigned long *)addr) + BIT_WORD(nr);
         unsigned long old;
         unsigned long flags;

         _atomic_spin_lock_irqsave(p, flags);
         old = *p;
         *p = old | mask;
         _atomic_spin_unlock_irqrestore(p, flags);

         return (old & mask) != 0;
 }

so overwriting it from the outside world (w/o taking _atomic_spin_lock_irqsave(p))
can theoretically be tricky in some cases.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
