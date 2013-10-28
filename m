Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 56DFC6B0031
	for <linux-mm@kvack.org>; Mon, 28 Oct 2013 10:13:20 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id rd3so2512109pab.0
        for <linux-mm@kvack.org>; Mon, 28 Oct 2013 07:13:19 -0700 (PDT)
Received: from psmtp.com ([74.125.245.129])
        by mx.google.com with SMTP id it5si12179409pbc.65.2013.10.28.07.13.17
        for <linux-mm@kvack.org>;
        Mon, 28 Oct 2013 07:13:17 -0700 (PDT)
Received: by mail-ee0-f51.google.com with SMTP id d41so3483457eek.10
        for <linux-mm@kvack.org>; Mon, 28 Oct 2013 07:13:15 -0700 (PDT)
Date: Mon, 28 Oct 2013 15:13:10 +0100
From: Simon Baatz <gmbnomis@gmail.com>
Subject: Re: ARM/kirkwood: v3.12-rc6: kernel BUG at mm/util.c:390!
Message-ID: <20131028141310.GA4970@schnuecks.de>
References: <20131024200730.GB17447@blackmetal.musicnaut.iki.fi>
 <20131026143617.GA14034@mudshark.cambridge.arm.com>
 <20131027195115.208f40f3@tom-ThinkPad-T410>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131027195115.208f40f3@tom-ThinkPad-T410>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <tom.leiming@gmail.com>
Cc: Will Deacon <will.deacon@arm.com>, Aaro Koskinen <aaro.koskinen@iki.fi>, Russell King - ARM Linux <linux@arm.linux.org.uk>, catalin.marinas@arm.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Andrew Morton <akpm@linux-foundation.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Tejun Heo <tj@kernel.org>, "James E.J. Bottomley" <JBottomley@parallels.com>, Jens Axboe <axboe@kernel.dk>

On Sun, Oct 27, 2013 at 07:51:15PM +0800, Ming Lei wrote:
> diff --git a/lib/scatterlist.c b/lib/scatterlist.c
> index a685c8a..eea8806 100644
> --- a/lib/scatterlist.c
> +++ b/lib/scatterlist.c
> @@ -577,7 +577,7 @@ void sg_miter_stop(struct sg_mapping_iter *miter)
>  		miter->__offset += miter->consumed;
>  		miter->__remaining -= miter->consumed;
>  
> -		if (miter->__flags & SG_MITER_TO_SG)
> +		if ((miter->__flags & SG_MITER_TO_SG) && !PageSlab(page))

This is what I was going to propose, but I would have used
!PageSlab(miter->page) ;-)

>  			flush_kernel_dcache_page(miter->page);

With this, a kernel with DEBUG_VM now boots on Kirkwood. 


- Simon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
