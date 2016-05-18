Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 180AE6B007E
	for <linux-mm@kvack.org>; Wed, 18 May 2016 09:15:15 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id x7so110631550qkd.2
        for <linux-mm@kvack.org>; Wed, 18 May 2016 06:15:15 -0700 (PDT)
Received: from mail-yw0-x241.google.com (mail-yw0-x241.google.com. [2607:f8b0:4002:c05::241])
        by mx.google.com with ESMTPS id x67si3159908ywg.385.2016.05.18.06.15.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 May 2016 06:15:14 -0700 (PDT)
Received: by mail-yw0-x241.google.com with SMTP id y6so6487053ywe.0
        for <linux-mm@kvack.org>; Wed, 18 May 2016 06:15:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160518084824.GA21680@dhcp22.suse.cz>
References: <CA+a3UFfGxJajS3Lqkp8M4kaikTWHprUXbUvECYC9dojgazQ8pg@mail.gmail.com>
	<20160518084824.GA21680@dhcp22.suse.cz>
Date: Wed, 18 May 2016 21:15:13 +0800
Message-ID: <CA+a3UFefby0+H2wfV9J27cs3waheUshWsEhs099c25cT6G-8Og@mail.gmail.com>
Subject: Re: malloc() size in CMA region seems to be aligned to CMA_ALIGNMENT
From: lunar12 lunartwix <lunartwix@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>

2016-05-18 16:48 GMT+08:00 Michal Hocko <mhocko@kernel.org>:
> [CC linux-mm and some usual suspects]
>
> On Tue 17-05-16 23:37:55, lunar12 lunartwix wrote:
>> A 4MB dma_alloc_coherent  in kernel after malloc(2*1024) 40 times in
>> CMA region by user space will cause an error on our ARM 3.18 kernel
>> platform with a 32MB CMA.
>>
>> It seems that the malloc in CMA region will be aligned to
>> CMA_ALIGNMENT everytime even if the requested malloc size is very
>> small so the CMA region is not available after the malloc operations.
>>
>> Is there any configuraiton that can change this behavior??
>>
>> Thanks
>>
>> Cheers
>> Ken
>
> --
> Michal Hocko
> SUSE Labs

Update more information and any comment would be very appreciated

CMA region (from boot message):
Reserved memory: created CMA memory pool at 0x22e00000, size 80 MiB

User space test program:

    do
    {

        addr = malloc(2*1024);
        memset((void *)addr,2*1024,0x5A);
        vaddr=(unsigned int)addr;

        //get_user_page & page_to_phys in kernel
        ioctl(devfd, IOCTL_MSYS_USER_TO_PHYSICAL, &addr)

        count++;
        paddr=(unsigned int)addr;

        if(paddr>0x22E00000)
        {
            printf("USR:0x%08X 0x%08X %d\n",vaddr,paddr,count);
        }
    } while(addr!=NULL);


System print out:

USR:0x0164B248 0x27C00000 11337
USR:0x0164BA50 0x27C00000 11338
USR:0x0164C258 0x27800000 11339
USR:0x0164CA60 0x27800000 11340
USR:0x0164D268 0x27600000 11341
USR:0x0164DA70 0x27600000 11342
USR:0x0164E278 0x27400000 11343
USR:0x0164EA80 0x27400000 11344
USR:0x0164F288 0x27200000 11345
USR:0x0164FA90 0x27200000 11346
....
It seems that an 2MB CMA would be occpuied every 2 malloc()

Cheers
Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
