Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id 6F0546B0031
	for <linux-mm@kvack.org>; Tue,  8 Jul 2014 19:44:22 -0400 (EDT)
Received: by mail-ig0-f172.google.com with SMTP id hn18so1274899igb.5
        for <linux-mm@kvack.org>; Tue, 08 Jul 2014 16:44:22 -0700 (PDT)
Received: from nm31.bullet.mail.ne1.yahoo.com (nm31.bullet.mail.ne1.yahoo.com. [98.138.229.24])
        by mx.google.com with ESMTPS id v8si68652915icb.3.2014.07.08.16.44.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 08 Jul 2014 16:44:21 -0700 (PDT)
Message-ID: <1404862900.76779.YahooMailNeo@web160102.mail.bf1.yahoo.com>
Date: Tue, 8 Jul 2014 16:41:40 -0700
From: PINTU KUMAR <pintu_agarwal@yahoo.com>
Reply-To: PINTU KUMAR <pintu_agarwal@yahoo.com>
Subject: [linux-3.10.17] Could not allocate memory from free CMA areas
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>"linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>
Cc: "pintu.k@outlook.com" <pintu.k@outlook.com>, "pintu.k@samsung.com" <pintu.k@samsung.com>, "vishu_1385@yahoo.com" <vishu_1385@yahoo.com>, "m.szyprowski@samsung.com" <m.szyprowski@samsung.com>, "mina86@mina86.com" <mina86@mina86.com>, "ngupta@vflare.org" <ngupta@vflare.org>, "iqbalblr@gmail.com" <iqbalblr@gmail.com>

Hi,=0A=0AWe are facing one problem on linux 3.10 when we try to use CMA as =
large as 56MB for 256MB RAM device.=0AWe found that after certain point of =
time (during boot), min watermark check is failing when "free_pages" and "f=
ree_cma_pages" are almost equal and falls below the min level.=0A=0Asystem =
details:=0AARM embedded device: RAM: 256MB=0AKernel version: 3.10.17=0AFixe=
d Reserved memory: ~40MB=0AAvailable memory: 217MB=0ACMA reserved 1 : 56MB=
=0AZRAM configured: 128MB or 64MB=0Amin_free_kbytes: 1625 (default)=0AMemor=
y controller group enabled (MEMCG)=0A=0A=0AAfter boot-up the "free -tm" com=
mand shows free memory as: ~50MB=0ACMA is used for all UI display purposes.=
 CMA used during bootup is close to ~6MB.=0AThus most of the free memory is=
 in the form of CMA free memory.=0AZRAM getting uses was around ~5MB.=0A=0A=
=0ADuring boot-up itself we observe that the following conditions are met.=
=0A=0A=0Aif (free_pages - free_cma <=3D min + lowmem_reserve) {=0A=A0=A0=A0=
 printk"[PINTU]: __zone_watermark_ok: failed !\n");=0A=0A=A0=A0=A0 return f=
alse;=0A}=0AHere: free_pages was: 12940, free_cma was: 12380, min: 566, low=
mem: 0=0A=0A=0AThus is condition is met most of the time.=0AAnd because of =
this watermark failure, Kswapd is waking up frequently.=0AThe /proc/pagetyp=
einfo reports that most of the higher order pages are from CMA regions.=0A=
=0A=0AWe also observed that ZRAM is trying to allocate memory from CMA regi=
on and failing.=0A=0AWe also tried by decreasing the CMA region to 20MB. Wi=
th this the watermark failure is not happening in boot time. But if we laun=
ch more than 3 apps {Browser, music-player etc}, again the watermark starte=
d failing.=0A=0AAlso we tried decreasing the min_free_kbytes=3D256, and wit=
h this also watermark is passed.=0A=0AOur observation is that ZRAM/zsmalloc=
 trying to allocate memory from CMA areas and failed.=0A=0A=0APlease let us=
 know if anybody have come across the same problem and how to resolve this =
issue.=0A=0A=0A=0A=0A=0AThank You!=0ARegards,=0APintu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
