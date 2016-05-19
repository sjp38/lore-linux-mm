Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2EF506B0005
	for <linux-mm@kvack.org>; Wed, 18 May 2016 20:51:36 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 4so127199432pfw.0
        for <linux-mm@kvack.org>; Wed, 18 May 2016 17:51:36 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id g65si15659790pfc.237.2016.05.18.17.51.34
        for <linux-mm@kvack.org>;
        Wed, 18 May 2016 17:51:35 -0700 (PDT)
Date: Thu, 19 May 2016 09:52:04 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: malloc() size in CMA region seems to be aligned to CMA_ALIGNMENT
Message-ID: <20160519005204.GB10245@js1304-P5Q-DELUXE>
References: <CA+a3UFfGxJajS3Lqkp8M4kaikTWHprUXbUvECYC9dojgazQ8pg@mail.gmail.com>
 <20160518084824.GA21680@dhcp22.suse.cz>
 <CA+a3UFefby0+H2wfV9J27cs3waheUshWsEhs099c25cT6G-8Og@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+a3UFefby0+H2wfV9J27cs3waheUshWsEhs099c25cT6G-8Og@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lunar12 lunartwix <lunartwix@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>

On Wed, May 18, 2016 at 09:15:13PM +0800, lunar12 lunartwix wrote:
> 2016-05-18 16:48 GMT+08:00 Michal Hocko <mhocko@kernel.org>:
> > [CC linux-mm and some usual suspects]

Michal, Thanks.

> >
> > On Tue 17-05-16 23:37:55, lunar12 lunartwix wrote:
> >> A 4MB dma_alloc_coherent  in kernel after malloc(2*1024) 40 times in
> >> CMA region by user space will cause an error on our ARM 3.18 kernel
> >> platform with a 32MB CMA.
> >>
> >> It seems that the malloc in CMA region will be aligned to
> >> CMA_ALIGNMENT everytime even if the requested malloc size is very
> >> small so the CMA region is not available after the malloc operations.
> >>
> >> Is there any configuraiton that can change this behavior??
> >>
> >> Thanks
> >>
> >> Cheers
> >> Ken
> >
> > --
> > Michal Hocko
> > SUSE Labs
> 
> Update more information and any comment would be very appreciated
> 
> CMA region (from boot message):
> Reserved memory: created CMA memory pool at 0x22e00000, size 80 MiB
> 
> User space test program:
> 
>     do
>     {
> 
>         addr = malloc(2*1024);
>         memset((void *)addr,2*1024,0x5A);
>         vaddr=(unsigned int)addr;
> 
>         //get_user_page & page_to_phys in kernel
>         ioctl(devfd, IOCTL_MSYS_USER_TO_PHYSICAL, &addr)
> 
>         count++;
>         paddr=(unsigned int)addr;
> 
>         if(paddr>0x22E00000)
>         {
>             printf("USR:0x%08X 0x%08X %d\n",vaddr,paddr,count);
>         }
>     } while(addr!=NULL);
> 
> 
> System print out:
> 
> USR:0x0164B248 0x27C00000 11337
> USR:0x0164BA50 0x27C00000 11338
> USR:0x0164C258 0x27800000 11339
> USR:0x0164CA60 0x27800000 11340
> USR:0x0164D268 0x27600000 11341
> USR:0x0164DA70 0x27600000 11342
> USR:0x0164E278 0x27400000 11343
> USR:0x0164EA80 0x27400000 11344
> USR:0x0164F288 0x27200000 11345
> USR:0x0164FA90 0x27200000 11346
> ....
> It seems that an 2MB CMA would be occpuied every 2 malloc()

I'm not familiar with device part of CMA but try to analyze.

Above output means that your device maps 2 MB CMA mem to 1 page. I guess
that your device requires such alignment. Could you check
CONFIG_CMA_ALIGNMENT? And, insert to log to below snippet
in drivers/base/dma-contiguous.c to check your device align requirement?

struct page *dma_alloc_from_contiguous(struct device *dev, size_t count,
                                       unsigned int align)
{                                                                                          
        if (align > CONFIG_CMA_ALIGNMENT)
                align = CONFIG_CMA_ALIGNMENT;
        return cma_alloc(dev_get_cma_area(dev), count, align);
}

I guess changing CONFIG_CMA_ALIGNMENT works for you, but, since it
ignore your device align requirement, I'm not sure that it is right solution.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
