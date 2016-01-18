Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f171.google.com (mail-io0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id 58E776B0005
	for <linux-mm@kvack.org>; Sun, 17 Jan 2016 20:02:38 -0500 (EST)
Received: by mail-io0-f171.google.com with SMTP id q21so535318926iod.0
        for <linux-mm@kvack.org>; Sun, 17 Jan 2016 17:02:38 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTPS id qb6si22614347igb.67.2016.01.17.17.02.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 17 Jan 2016 17:02:37 -0800 (PST)
Subject: Re: [PATCH v2] zsmalloc: fix migrate_zspage-zs_free race condition
References: <1452843551-4464-1-git-send-email-junil0814.lee@lge.com>
 <20160116100557.GC566@swordfish>
From: Junil Lee <junil0814.lee@lge.com>
Message-ID: <569C39A9.6050900@lge.com>
Date: Mon, 18 Jan 2016 10:02:33 +0900
MIME-Version: 1.0
In-Reply-To: <20160116100557.GC566@swordfish>
Content-Type: text/plain; charset=euc-kr
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Vlastimil Babka <vbabka@suse.cz>
Cc: Minchan Kim <minchan@kernel.org>, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



2016-01-16 ?AEA 7:05?! Sergey Senozhatsky AI(?!)  3/4 ' +-U:
> On (01/16/16 09:16), Vlastimil Babka wrote:
> [..]
> > BTW, couldn't the correct fix also just look like this?
> >
> > diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> > index 9f15bdd9163c..43f743175ede 100644
> > --- a/mm/zsmalloc.c
> > +++ b/mm/zsmalloc.c
> > @@ -1635,8 +1635,8 @@ static int migrate_zspage(struct zs_pool
> *pool, struct
> > size_class *class,
> > free_obj = obj_malloc(d_page, class, handle);
> > zs_object_copy(free_obj, used_obj, class);
> > index++;
> > + /* This also effectively unpins the handle */
> > record_obj(handle, free_obj);
> > - unpin_tag(handle);
> > obj_free(pool, class, used_obj);
> > }
>
> I think this will work.
>
I agree.
And I tested previous patch as I sent, this problem has not been
happened since 2 days ago.

I will resend v3 as Babka.

Thanks.
>
> > But I'd still recommend WRITE_ONCE in record_obj(). And I'm not even
> sure it's
> > safe on all architectures to do a simple overwrite of a word against
> somebody
> > else trying to lock a bit there?
>
> hm... for example, generic bitops from
> include/asm-generic/bitops/atomic.h
> use _atomic_spin_lock_irqsave()
>
> #define test_and_set_bit_lock(nr, addr) test_and_set_bit(nr, addr)
>
> static inline int test_and_set_bit(int nr, volatile unsigned long *addr)
> {
> unsigned long mask = BIT_MASK(nr);
> unsigned long *p = ((unsigned long *)addr) + BIT_WORD(nr);
> unsigned long old;
> unsigned long flags;
>
> _atomic_spin_lock_irqsave(p, flags);
> old = *p;
> *p = old | mask;
> _atomic_spin_unlock_irqrestore(p, flags);
>
> return (old & mask) != 0;
> }
>
> so overwriting it from the outside world (w/o taking
> _atomic_spin_lock_irqsave(p))
> can theoretically be tricky in some cases.
>
> -ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
