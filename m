Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id C1C166B0005
	for <linux-mm@kvack.org>; Mon, 18 Jan 2016 01:30:27 -0500 (EST)
Received: by mail-ig0-f170.google.com with SMTP id ik10so49497509igb.1
        for <linux-mm@kvack.org>; Sun, 17 Jan 2016 22:30:27 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id vt4si24291956igb.57.2016.01.17.22.30.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 17 Jan 2016 22:30:27 -0800 (PST)
Date: Mon, 18 Jan 2016 15:32:46 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2] zsmalloc: fix migrate_zspage-zs_free race condition
Message-ID: <20160118063246.GB7453@bbox>
References: <1452843551-4464-1-git-send-email-junil0814.lee@lge.com>
 <20160115143434.GA25332@blaptop.local>
 <56991514.9000609@suse.cz>
 <20160116040913.GA566@swordfish>
 <5699F4C9.1070902@suse.cz>
 <20160116080650.GB566@swordfish>
 <5699FC69.4010000@suse.cz>
MIME-Version: 1.0
In-Reply-To: <5699FC69.4010000@suse.cz>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Junil Lee <junil0814.lee@lge.com>, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello, Vlastimil

On Sat, Jan 16, 2016 at 09:16:41AM +0100, Vlastimil Babka wrote:
> On 16.1.2016 9:06, Sergey Senozhatsky wrote:
> > On (01/16/16 08:44), Vlastimil Babka wrote:
> >> On 16.1.2016 5:09, Sergey Senozhatsky wrote:
> >>> On (01/15/16 16:49), Vlastimil Babka wrote:
> >>
> >> Hmm but that's an unpin, not a pin? A mistake or I'm missing something?
> > 
> > I'm sure it's just a compose-in-mail-app typo.
> 
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
> 
> But I'd still recommend WRITE_ONCE in record_obj(). And I'm not even sure it's

Thanks for the reivew. Yeah, we need WRITE_ONCE in record_obj but
your version will not work. IMHO, WRITE_ONCE can prevent store-tearing
but it couldn't prevent reordering. IOW, we need some barrier as unlock
and clear_bit_unlock includes it.
So, we shouldn't omit unpin_tag there.

> safe on all architectures to do a simple overwrite of a word against somebody
> else trying to lock a bit there?

Hmm, I think it shouldn't be a problem. It's word-alinged, word-sized
store so it should be atomic.

As other example, we have been used lock_page for a bit of page->flags
and used other bits in there with __set_bit(ie, __SetPageXXX).
I guess it's same situation with us just except we are spinning there.
But it is worth to dobule check so need to help lock guys.

> 
> > 	-ss
> > 
> >> Anyway the compiler can do the same thing here without a WRITE_ONCE().
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> > 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
