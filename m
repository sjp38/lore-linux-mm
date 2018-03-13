Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 92B0C6B026C
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 10:29:29 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e10so7531966pff.3
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 07:29:29 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h12-v6sor99742pls.70.2018.03.13.07.29.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Mar 2018 07:29:28 -0700 (PDT)
Date: Tue, 13 Mar 2018 23:29:20 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCHv2 2/2] zram: drop max_zpage_size and use
 zs_huge_class_size()
Message-ID: <20180313142920.GA100978@rodete-laptop-imager.corp.google.com>
References: <20180306070639.7389-1-sergey.senozhatsky@gmail.com>
 <20180306070639.7389-3-sergey.senozhatsky@gmail.com>
 <20180313090249.GA240650@rodete-desktop-imager.corp.google.com>
 <20180313102437.GA5114@jagdpanzerIV>
 <20180313135815.GA96381@rodete-laptop-imager.corp.google.com>
 <20180313141813.GA741@tigerII.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180313141813.GA741@tigerII.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

On Tue, Mar 13, 2018 at 11:18:13PM +0900, Sergey Senozhatsky wrote:
> On (03/13/18 22:58), Minchan Kim wrote:
> > > > If it is static, we can do this in zram_init? I believe it's more readable in that
> > > > it's never changed betweens zram instances.
> > > 
> > > We need to have at least one pool, because pool decides where the
> > > watermark is. At zram_init() stage we don't have a pool yet. We
> > > zs_create_pool() in zram_meta_alloc() so that's why I put
> > > zs_huge_class_size() there. I'm not in love with it, but that's
> > > the only place where we can have it.
> > 
> > Fair enough. Then what happens if client calls zs_huge_class_size
> > without creating zs_create_pool?
> 
> Will receive 0.
> One of the version was returning SIZE_MAX in such case.
> 
> size_t zs_huge_class_size(void)
>  {
> +	if (unlikely(!huge_class_size))
> +		return SIZE_MAX;
>  	return huge_class_size;
>  }

I really don't want to have such API which returns different size on
different context.

The thing is we need to create pool first to get right value.
It means zs_huge_class_size should depend on zs_create_pool.
So, I think passing zs_pool to zs_huge_class_size is right way to
prevent such misuse and confusing. Yub, franky speaknig, zsmalloc
is not popular like slab allocator  or page allocator so this like
discussion would be waste. However, we don't need big effort to do
and this is review phase so I want to make more robust/readable. ;-)

> 
> > I think we should make zs_huge_class_size has a zs_pool as argument.
> 
> Can do, but the param will be unused. May be we can do something

Yub, param wouldn't be unused but it's the way of creating dependency
intentionally. It could make code more robust/readable.

Please, let's pass zs_pool and returns always right huge size.

> like below instead:
> 
>  size_t zs_huge_class_size(void)
>  {
> +	if (unlikely(!huge_class_size))
> +		return 3 * PAGE_SIZE / 4;
>  	return huge_class_size;
>  }
> 
> Should do no harm (unless I'm missing something).


> 
> 	-ss
