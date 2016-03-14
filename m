Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id AF8936B0253
	for <linux-mm@kvack.org>; Mon, 14 Mar 2016 04:07:21 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id fe3so135579552pab.1
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 01:07:21 -0700 (PDT)
Received: from mail-pa0-x242.google.com (mail-pa0-x242.google.com. [2607:f8b0:400e:c03::242])
        by mx.google.com with ESMTPS id v8si23707163pfi.16.2016.03.14.01.07.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Mar 2016 01:07:21 -0700 (PDT)
Received: by mail-pa0-x242.google.com with SMTP id hj7so14057655pac.1
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 01:07:20 -0700 (PDT)
Date: Mon, 14 Mar 2016 17:08:43 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC][PATCH v3 3/5] mm/zsmalloc: introduce zs_huge_object()
Message-ID: <20160314080842.GC542@swordfish>
References: <1457016363-11339-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1457016363-11339-4-git-send-email-sergey.senozhatsky@gmail.com>
 <20160314065331.GA12337@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160314065331.GA12337@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On (03/14/16 15:53), Minchan Kim wrote:
[..]
> On Thu, Mar 03, 2016 at 11:46:01PM +0900, Sergey Senozhatsky wrote:
> > zsmalloc knows the watermark after which classes are considered
> > to be ->huge -- every object stored consumes the entire zspage (which
> > consist of a single order-0 page). On x86_64, PAGE_SHIFT 12 box, the
> > first non-huge class size is 3264, so starting down from size 3264,
> > objects share page(-s) and thus minimize memory wastage.
> > 
> > zram, however, has its own statically defined watermark for `bad'
> > compression "3 * PAGE_SIZE / 4 = 3072", and stores every object
> > larger than this watermark (3072) as a PAGE_SIZE, object, IOW,
> > to a ->huge class, this results in increased memory consumption and
> > memory wastage. (With a small exception: 3264 bytes class. zs_malloc()
> > adds ZS_HANDLE_SIZE to the object's size, so some objects can pass
> > 3072 bytes and get_size_class_index(size) will return 3264 bytes size
> > class).
> > 
> > Introduce zs_huge_object() function which tells whether the supplied
> > object's size belongs to a huge class; so zram now can store objects
> > to ->huge clases only when those objects have sizes greater than
> > huge_class_size_watermark.
> 
> I understand the problem you pointed out but I don't like this way.
> 
> Huge class is internal thing in zsmalloc so zram shouldn't be coupled
> with it. Zram uses just zsmalloc to minimize meory wastage which is
> all zram should know about zsmalloc.

well, zram already coupled with zsmalloc() and it has always been,
that's the reality. there are zs_foo() calls, and not a single one
zpool_foo() call. I'm not in love with zs_huge_object() either, but
that's much better than forcing zsmalloc to be less efficient based
on some pretty random expectations (no offense).

> Instead, how about changing max_zpage_size?
> 
>         static const size_t max_zpage_size = 4096;
> 
> So, if compression doesn't help memory efficiency, we don't
> need to have decompress overhead. Only that case, we store
> decompressed page.

hm, disabling this zram future entirely... this can do the trick,
I think. zswap is quite happy not having any expectations on
"how effectively an unknown compression algorithm will compress
an unknown data set", and that's the "right" thing to do here,
we can't count on anything.


> For other huge size class(e.g., PAGE_SIZE / 4 * 3 ~ PAGE_SIZE),
> you sent a patch to reduce waste memory as 5/5 so I think it's
> a good justification between memory efficiency VS.
> decompress overhead.

so the plan is to raise max_zpage_size to PAGE_SIZE and to increase
the number of huge classes, so zsmalloc can be more helpful. sounds
good to me.


> Thanks.

Thanks.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
