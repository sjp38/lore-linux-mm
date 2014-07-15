Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 8108B6B0031
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 08:49:35 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id lj1so823183pab.5
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 05:49:35 -0700 (PDT)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id zm2si11665475pbc.119.2014.07.15.05.49.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 15 Jul 2014 05:49:34 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N8R008Y77M5JO20@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 15 Jul 2014 13:49:17 +0100 (BST)
Message-id: <53C52350.6020109@samsung.com>
Date: Tue, 15 Jul 2014 14:49:20 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
MIME-version: 1.0
Subject: Re: [linux-3.10.17] Could not allocate memory from free CMA areas
References: <1404862900.76779.YahooMailNeo@web160102.mail.bf1.yahoo.com>
In-reply-to: <1404862900.76779.YahooMailNeo@web160102.mail.bf1.yahoo.com>
Content-type: text/plain; charset=UTF-8; format=flowed
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: PINTU KUMAR <pintu_agarwal@yahoo.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>
Cc: "pintu.k@outlook.com" <pintu.k@outlook.com>, "pintu.k@samsung.com" <pintu.k@samsung.com>, "vishu_1385@yahoo.com" <vishu_1385@yahoo.com>, "mina86@mina86.com" <mina86@mina86.com>, "ngupta@vflare.org" <ngupta@vflare.org>, "iqbalblr@gmail.com" <iqbalblr@gmail.com>

Hello,

On 2014-07-09 01:41, PINTU KUMAR wrote:
> Hi,
>
> We are facing one problem on linux 3.10 when we try to use CMA as large as 56MB for 256MB RAM device.
> We found that after certain point of time (during boot), min watermark check is failing when "free_pages" and "free_cma_pages" are almost equal and falls below the min level.
>
> system details:
> ARM embedded device: RAM: 256MB
> Kernel version: 3.10.17
> Fixed Reserved memory: ~40MB
> Available memory: 217MB
> CMA reserved 1 : 56MB
> ZRAM configured: 128MB or 64MB
> min_free_kbytes: 1625 (default)
> Memory controller group enabled (MEMCG)
>
>
> After boot-up the "free -tm" command shows free memory as: ~50MB
> CMA is used for all UI display purposes. CMA used during bootup is close to ~6MB.
> Thus most of the free memory is in the form of CMA free memory.
> ZRAM getting uses was around ~5MB.
>
>
> During boot-up itself we observe that the following conditions are met.
>
>
> if (free_pages - free_cma <= min + lowmem_reserve) {
>      printk"[PINTU]: __zone_watermark_ok: failed !\n");
>
>      return false;
> }
> Here: free_pages was: 12940, free_cma was: 12380, min: 566, lowmem: 0
>
>
> Thus is condition is met most of the time.
> And because of this watermark failure, Kswapd is waking up frequently.
> The /proc/pagetypeinfo reports that most of the higher order pages are from CMA regions.
>
>
> We also observed that ZRAM is trying to allocate memory from CMA region and failing.
>
> We also tried by decreasing the CMA region to 20MB. With this the watermark failure is not happening in boot time. But if we launch more than 3 apps {Browser, music-player etc}, again the watermark started failing.
>
> Also we tried decreasing the min_free_kbytes=256, and with this also watermark is passed.
>
> Our observation is that ZRAM/zsmalloc trying to allocate memory from CMA areas and failed.
>
>
> Please let us know if anybody have come across the same problem and how to resolve this issue.

Frankly I really have no idea what is going on. ZRAM/zsmalloc should not 
try to alloc memory from CMA. I don't have access you the mentioned 
source code. What flags are passed to alloc_pages() in zram/zsmalloc? It 
should get pages from non-movable pool.

Best regards
-- 
Marek Szyprowski, PhD
Samsung R&D Institute Poland

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
