Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f169.google.com (mail-yw0-f169.google.com [209.85.161.169])
	by kanga.kvack.org (Postfix) with ESMTP id A7B226B007E
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 15:43:07 -0400 (EDT)
Received: by mail-yw0-f169.google.com with SMTP id h65so110936574ywe.0
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 12:43:07 -0700 (PDT)
Received: from mail-yw0-x230.google.com (mail-yw0-x230.google.com. [2607:f8b0:4002:c05::230])
        by mx.google.com with ESMTPS id 205si3009303ybg.168.2016.03.31.12.43.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Mar 2016 12:43:06 -0700 (PDT)
Received: by mail-yw0-x230.google.com with SMTP id h65so110936170ywe.0
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 12:43:06 -0700 (PDT)
MIME-Version: 1.0
Date: Fri, 1 Apr 2016 01:13:06 +0530
Message-ID: <CAGnW=BYw9iqm8BpuWrxgcvXV3wwvHcvMtynPeHUGHHiZfPmfuA@mail.gmail.com>
Subject: Issue with ioremap
From: punnaiah choudary kalluri <punnaia@xilinx.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hi,

We are using the pl353 smc controller for interfacing the nand in our zynq SOC.
The driver for this controller is currently under mainline review.
Recently we are moved to 4.4 kernel and observing issues with the driver.
while debug, found that the issue is with the virtual address returned from
the ioremap is not aligned to the physical address and causing nand
access failures.
the nand controller physical address starts at 0xE1000000 and the size is 16MB.
the ioremap function in 4.3 kernel returns the virtual address that is
aligned to the size
but not the case in 4.4 kernel.

this controller uses the  bits [31:24] as base address and use rest all bits for
configuring adders cycles, chip select information. so it expects the
virtual address also
aligned to 0xFF000000 otherwise the nand commands issued will fail.


with >= 4.4 kernel
0xf0200000-0xf1201000 16781312 devm_ioremap+0x3c/0x70 phys=e1000000 ioremap

with <= 4.3 kernel
0xf1000000-0xf2001000 16781312 devm_ioremap+0x38/0x68 phys=e1000000 ioremap

the below hack fixes the issue. but its not a proper fix and it just pointing
me the clue for this issue. so, any pointers and help to over come this issue ?
is there a way to do static mapping for the above requirement?


diff --git a/mm/vmalloc.c b/mm/vmalloc.c index 8e3c9c5..fda58d6 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1340,9 +1340,13 @@ static struct vm_struct
*__get_vm_area_node(unsigned long size,
                                        PAGE_SHIFT, IOREMAP_MAX_ORDER);

         size = PAGE_ALIGN(size);
 +       if (size == 0x1000000)
 +               align = 0x1000000;
         if (unlikely(!size))
                 return NULL;

 +       printk(" size %x align %x\n", size, align);
 +
         area = kzalloc_node(sizeof(*area), gfp_mask & GFP_RECLAIM_MASK, node);
         if (unlikely(!area))
                 return NULL;

Thanks,
Punnaiah

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
