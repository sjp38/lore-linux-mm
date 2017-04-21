Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9F9156B0397
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 21:55:24 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id b136so2543709qkc.1
        for <linux-mm@kvack.org>; Thu, 20 Apr 2017 18:55:24 -0700 (PDT)
Received: from mail-qk0-x229.google.com (mail-qk0-x229.google.com. [2607:f8b0:400d:c09::229])
        by mx.google.com with ESMTPS id f90si7936049qtd.32.2017.04.20.18.55.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Apr 2017 18:55:23 -0700 (PDT)
Received: by mail-qk0-x229.google.com with SMTP id f133so61856849qke.2
        for <linux-mm@kvack.org>; Thu, 20 Apr 2017 18:55:23 -0700 (PDT)
MIME-Version: 1.0
From: Pavel Roskin <plroskin@gmail.com>
Date: Thu, 20 Apr 2017 18:55:22 -0700
Message-ID: <CAN_72e0_725VFdq_h6bMUuBkSUi7EMnu=r6mLLzcauOyG1BS=w@mail.gmail.com>
Subject: devm_ioremap_resource() creates duplicate resource
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hello!

I'm writing a device driver for a subdevice of a PCIe multifunctional
device. It's a platform device that has its resources described in the
top-level driver for the multifuctional device.

I followed the common pattern when a memory resource is obtained by
calling platform_get_resource() and then reserved and remapped by
calling devm_ioremap_resource().

  res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
  base = devm_ioremap_resource(&pdev->dev, res);

The problem with that approach is that the resource appears twice in
/proc/iomem:

  fdc60000-fdc6000f : My Dev
    fdc60000-fdc6000f : My Dev

I see that devm_ioremap_resource() takes the start address and the
size of the existing resource and reserves the region at the same
address.

Some drivers (e.g. drivers/mfd/db8500-prcmu.c) use devm_ioremap()
instead. But my concern is that the resource is not marked as busy in
that case.

Which approach is preferred? If there a good way to mark an existing
resource as busy (short of direct flag manipulation)? Would it make
sense to have an API to reserve an existing resource?

-- 
Regards,
Pavel Roskin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
