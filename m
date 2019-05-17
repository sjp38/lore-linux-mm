Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F4083C04E87
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 16:03:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B70B02168B
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 16:03:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="qLjX5pYM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B70B02168B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 449606B0003; Fri, 17 May 2019 12:03:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3FACC6B0005; Fri, 17 May 2019 12:03:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 29A836B0006; Fri, 17 May 2019 12:03:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 005B16B0003
	for <linux-mm@kvack.org>; Fri, 17 May 2019 12:03:05 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id 68so3540485otu.18
        for <linux-mm@kvack.org>; Fri, 17 May 2019 09:03:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:from:date:message-id
         :subject:to:cc;
        bh=gRcrtb5zkBV22N7ejZ8gd80yYzuG0eMMK0Likb2l39A=;
        b=mZ7CCH4t4KXxXjHuKGVXV2vM9t2UG+/r0pZZGK1gOIVAMqFCuiXyp7RiMQ49EtzvJ2
         H5G+rzurOxAMPjIxRWn6kjaTHP9rDMNXMNwQHsk25DXm8nFrQrLZzOLxp0dCxxnPo1EK
         MEDjh3yyqi3gzJ+vCUh8csGsfN9T5W1nLs1ewQLd2e+1pL+DYz49rghWIFMH0SVIyMMq
         2fztnt2bBIu497CVVuKih/BHxWh1UCtPi8HrX3Lbn7pP9e15PGl1LFc8b98eUzQtg6XA
         wxcsMG7fJQIxP/DamqHqvsiI774q2F2MX5lJv9ALx0p/jKlGC5T0I9h6IWBHriD+DBmF
         g0xg==
X-Gm-Message-State: APjAAAXTZqlXRAKt3PflX65TR+aXb1QbcTmM0Ab13gHt3BvWGH7AiiW/
	5oz4q3H84eFXzQYahdEK1OvAPPa5C5xI/c0GJe9qr5r1V9SYm0d9Hne1yNCIOWY4xvCc+qG+xPP
	X91EjWzrMIHMvXv8ZmEZukLBN0PcniPCoKE93avWbesn5RVnmKBN3dVs6Emy1QPU9rA==
X-Received: by 2002:a9d:3e16:: with SMTP id a22mr23446048otd.142.1558108984623;
        Fri, 17 May 2019 09:03:04 -0700 (PDT)
X-Received: by 2002:a9d:3e16:: with SMTP id a22mr23445954otd.142.1558108983402;
        Fri, 17 May 2019 09:03:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558108983; cv=none;
        d=google.com; s=arc-20160816;
        b=wrt3qh4Cn8t1BGk3pMRT9/weWkJaQ1chQFYVI5vp4mQ5d6q+HO2w0rwL3GdwtSeyOb
         lF1EJBxyUCAk7Fcf415B144LixvgPdNuvWlqk0KqyhQaOw5WwLjxJxf5ZCa8i7qlciwa
         QllpnZ2BF02kT0mz1rEU5HmzMtsRFsCQZJ8jWVjjJ1lI658ixZ0JJMHI3BzswWfa/cBh
         QnecA89h5XI0cwz+tRWEYQIVAJPtRs4IcohGnKD9MFEAVgdftP1S1gyC8tMR4FUWtGNL
         BJFHu2Ty0NPRNdwstrCkqWVTEDEqAKKNhnXgZ+oCXn3zSXJoF/F4T/69Tc9kCG+Cpjd3
         xB4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:mime-version:dkim-signature;
        bh=gRcrtb5zkBV22N7ejZ8gd80yYzuG0eMMK0Likb2l39A=;
        b=1GIgFROqmzRnuEwa+ecpk0OnwRBRA1400h7un7tLjHeMV2131J4LucqmpB5ig8RlEb
         4ALnOWNtEBTNQV4yUehbIXtehpDgMX33R2RbdQmR040AiOUURKxZUFsLxr96x3txGAUn
         NjzxsdseeN+XT3PL3ICtedTtW4hbdWsJQ2uduhB5z7iKyGG+C3Bp5dOlMRninMrLsYiy
         d8t+IZXMWn1TXgo4OZVhNiVv6peEUH9eqLmKIh52Q0gpL9z5lLleiBCO18PKzQbw59Ph
         wzZsH9ZQFLsnFj2dWVtc2uurd150XGu1QSuU0S6ger0xcEzpeAc71vK9m7dF3a1dFHJu
         UWAQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=qLjX5pYM;
       spf=pass (google.com: domain of jaewon31.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jaewon31.kim@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u4sor4521317otq.88.2019.05.17.09.03.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 May 2019 09:03:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of jaewon31.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=qLjX5pYM;
       spf=pass (google.com: domain of jaewon31.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jaewon31.kim@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:from:date:message-id:subject:to:cc;
        bh=gRcrtb5zkBV22N7ejZ8gd80yYzuG0eMMK0Likb2l39A=;
        b=qLjX5pYMmcTMjN5iFgyQsKZE0y6c8l2+gMnFTxjnwzcVJC9+73IQv1ERNRGBwqcVB1
         jRNQe7asKnOot4X72/nbnRE7ZLXpGGHhCVQHVNfntOjMG1qo7pS5msGMHFXbT8alz6NV
         8MZ4GlFAmF9tHddkLWQiIfiLZoD3R230cflReazsdSKB8hmkKBI5BpKwxrIt27vfGiRV
         iaoxpaCP0JJhEj2JXMFaw8wwGrfzzn0XPmAsNMq0oa8ktvb2lMmfwa7TtfouoWL0DbPa
         0DGFpoS0qsgQPx2kd48oCzrUSwvRpDEoz39no2EGJVCoA96kzHrljKfOemLP4MpMrC+3
         9VWw==
X-Google-Smtp-Source: APXvYqxmJfR52ctG4tHDsK2W7JZpTz8cICNLg1PMwwOW2FZTYEBQrxwnQVaenqKDcW/K5NYKOXtN9pY4O8t6RCdDLOk=
X-Received: by 2002:a9d:64c1:: with SMTP id n1mr8954538otl.259.1558108983107;
 Fri, 17 May 2019 09:03:03 -0700 (PDT)
MIME-Version: 1.0
From: Jaewon Kim <jaewon31.kim@gmail.com>
Date: Sat, 18 May 2019 01:02:28 +0900
Message-ID: <CAJrd-UuMRdWHky4gkmiR0QYozfXW0O35Ohv6mJPFx2TLa8hRKg@mail.gmail.com>
Subject: [RFC PATCH] usb: host: xhci: allow __GFP_FS in dma allocation
To: gregkh@linuxfoundation.org, m.szyprowski@samsung.com, linux-mm@kvack.org, 
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Jaewon Kim <jaewon31.kim@samsung.com>, ytk.lee@samsung.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello I don't have enough knowledge on USB core but I've wondered
why GFP_NOIO has been used in xhci_alloc_dev for
xhci_alloc_virt_device. I found commit ("a6d940dd759b xhci: Use
GFP_NOIO during device reset"). But can we just change GFP_NOIO
to __GFP_RECLAIM | __GFP_FS ?

Please refer to below case.

I got a report from Lee YongTaek <ytk.lee@samsung.com> that the
xhci_alloc_virt_device was too slow over 2 seconds only for one page
allocation.

1) It was because kernel version was v4.14 and DMA allocation was
done from CMA(Contiguous Memory Allocator) where CMA region was
almost filled with file page and  CMA passes GFP down to page
isolation. And the page isolation only allows file page isolation only to
requests having __GFP_FS.

2) Historically CMA was changed at v4.19 to use GFP_KERNEL
regardless of GFP passed to  DMA allocation through the
commit 6518202970c1 "(mm/cma: remove unsupported gfp_mask
parameter from cma_alloc()".

I think pre v4.19 the xhci_alloc_virt_device could be very slow
depending on CMA situation but free to USB deadlock issue. But as of
v4.19, I think, it will be fast but can face the deadlock issue.
Consequently I think to meet the both cases, I think USB can pass
__GFP_FS without __GFP_IO.

If __GFP_FS is passed from USB core, of course, the CMA patch also
need to be changed to pass GFP.

diff --git a/drivers/usb/host/xhci.c b/drivers/usb/host/xhci.c
index 005e65922608..38abcd03a1a2 100644
--- a/drivers/usb/host/xhci.c
+++ b/drivers/usb/host/xhci.c
@@ -3893,7 +3893,7 @@ int xhci_alloc_dev(struct usb_hcd *hcd, struct
usb_device *udev)
         * xhci_discover_or_reset_device(), which may be called as part of
         * mass storage driver error handling.
         */
-       if (!xhci_alloc_virt_device(xhci, slot_id, udev, GFP_NOIO)) {
+       if (!xhci_alloc_virt_device(xhci, slot_id, udev, __GFP_RECLAIM
| __GFP_FS)) {
                xhci_warn(xhci, "Could not allocate xHCI USB device
data structures\n");
                goto disable_slot;
        }


Thank you

