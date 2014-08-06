Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id D89DF6B0081
	for <linux-mm@kvack.org>; Wed,  6 Aug 2014 03:52:26 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id fp1so2865470pdb.33
        for <linux-mm@kvack.org>; Wed, 06 Aug 2014 00:52:26 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id kc13si212157pad.41.2014.08.06.00.52.24
        for <linux-mm@kvack.org>;
        Wed, 06 Aug 2014 00:52:25 -0700 (PDT)
Date: Wed, 6 Aug 2014 16:59:45 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [linux-3.10.17] Could not allocate memory from free CMA areas
Message-ID: <20140806075945.GA3661@js1304-P5Q-DELUXE>
References: <54sabdnxop04vxd7ewndc0qf.1407077745645@email.android.com>
 <003201cfafb3$3fe43180$bfac9480$@lge.com>
 <BAY169-W348ADD9113F32C2B459631EFE30@phx.gbl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BAY169-W348ADD9113F32C2B459631EFE30@phx.gbl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pintu Kumar <pintu.k@outlook.com>
Cc: PINTU KUMAR <pintu_agarwal@yahoo.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "ritesh.list@gmail.com" <ritesh.list@gmail.com>, "mgorman@suse.de" <mgorman@suse.de>, "pintu.k@samsung.com" <pintu.k@samsung.com>, "m.szyprowski@samsung.com" <m.szyprowski@samsung.com>, "mina86@mina86.com" <mina86@mina86.com>, "ngupta@vflare.org" <ngupta@vflare.org>, "iqbalblr@gmail.com" <iqbalblr@gmail.com>, "rohit.kr@samsung.com" <rohit.kr@samsung.com>, "vishnu.ps@samsung.com" <vishnu.ps@samsung.com>

On Tue, Aug 05, 2014 at 08:24:50PM +0530, Pintu Kumar wrote:
> Hello,
> 
> > From: iamjoonsoo.kim@lge.com
> > To: pintu_agarwal@yahoo.com; linux-mm@kvack.org; linux-arm-kernel@lists.infradead.org; linaro-mm-sig@lists.linaro.org; ritesh.list@gmail.com
> > CC: pintu.k@outlook.com; pintu.k@samsung.com; vishu_1385@yahoo.com; m.szyprowski@samsung.com; mina86@mina86.com; ngupta@vflare.org; iqbalblr@gmail.com
> > Subject: RE: [linux-3.10.17] Could not allocate memory from free CMA areas
> > Date: Mon, 4 Aug 2014 16:11:00 +0900
> > 
> >> Dear Joonsoo,
> >> 
> >> I tried your changes which are present at the below link. 
> >> https://github.com/JoonsooKim/linux/tree/cma-fix-up-v3.0-next-20140625
> >> But unfortunately for me it did not help much. 
> >> After running various apps that uses ION nonmovable memory, it fails to allocate memory after some time. When I see the pagetypeinfo shows lots of CMA pages available and non-movable were very less and thus nonmovable allocation were failing.
> > 
> > Okay. CMA pages cannot be used for nonmovable memory, so it can fail in above case.
> > 
> >> However I noticed the failure was little delayed.
> > 
> > It is good sign. I guess that there is movable/CMA ratio problem.
> > My patchset uses free CMA pages in certain ratio to free movable page consumption.
> > If your system doesn't use movable page sufficiently, free CMA pages cannot
> > be used fully. Could you test with following workaround?
> > 
> > +       if (normal> cma) {
> > +               zone->max_try_normal = pageblock_nr_pages;
> > +               zone->max_try_cma = pageblock_nr_pages;
> > +       } else {
> > +               zone->max_try_normal = pageblock_nr_pages;
> > +               zone->max_try_cma = pageblock_nr_pages;
> > +       }
> 
> I applied these changes but still the allocations are failing because there are no non-movable memory left in the system.

Hello,

kswapd doesn't work?
Please let me know your problem in detail.

> With the changes I noticed that nr_cma_free sometimes becomes almost zero.
> But in our case Display/Xorg needs to have atleast 8MB of CMA (contiguous) memory of order-8 and order-4 type.
> CMA:56MB is shared across display,camera,video etc.

Used CMA pages will be released automatically when your Display/Xorg
request them. So you don't need to worry about empty of free CMA pages.

> 
> I think the previous changes are slightly better.
> 
> My concern is that whether I am applying all you changes or missing some thing.
> I saw that your kernel version is based on next-20140625 but my kernel version is 3.10.17.
> And till now I applied only the below changes:
> https://github.com/JoonsooKim/linux/commit/33a0416b3ac1cd7c88e6b35ee61b4a81a7a14afc 
> 
> But I haven't applied this:
> https://github.com/JoonsooKim/linux/commit/166b4186d101b190cf50195d841e2189f2743649
> (CMA: always treat free cma pages as non-free on watermark checking)

This patch is somewhat related to your failure of non-movable memory
allocation. It is simple so that you can easily backport.

> These changes have other dependencies which is not present in my kernel version.
> Like inclusion of ALLOC_FAIR and area->nr_cma_free.
> Please let me know if these changes are also important for "aggressive alloc changes..."
> 
> If possible please send me all the patches related to "aggressive cma.." so that I can conclude on my experiment.

Until now, that's all. :)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
