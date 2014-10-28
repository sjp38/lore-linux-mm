Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 181F1900021
	for <linux-mm@kvack.org>; Tue, 28 Oct 2014 15:09:14 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id eu11so1409675pac.2
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 12:09:13 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id q11si2189282pdl.12.2014.10.28.12.09.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Oct 2014 12:09:13 -0700 (PDT)
Received: by mail-pa0-f53.google.com with SMTP id kx10so1384627pab.40
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 12:09:12 -0700 (PDT)
Message-ID: <544FE9BE.6040503@gmail.com>
Date: Tue, 28 Oct 2014 12:08:46 -0700
From: Florian Fainelli <f.fainelli@gmail.com>
MIME-Version: 1.0
Subject: DMA allocations from CMA and fatal_signal_pending check
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, Brian Norris <computersforpeace@gmail.com>, Gregory Fong <gregory.0xf0@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, lauraa@codeaurora.org, gioh.kim@lge.com, aneesh.kumar@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, mina86@mina86.com, m.szyprowski@samsung.com, akpm@linux-foundation.org, "netdev@vger.kernel.org" <netdev@vger.kernel.org>

Hello,

While debugging why some dma_alloc_coherent() allocations where
returning NULL on our brcmstb platform, specifically with
drivers/net/ethernet/broadcom/bcmcsysport.c, I came across the
fatal_signal_pending() check in mm/page_alloc.c which is there.

This driver calls dma_alloc_coherent(, GFP_KERNEL) which ends up making
a coherent allocation from a CMA region on our platform. Since that
allocation is allowed to sleep, and because we are in bcm_syport_open(),
executed from process context, a pending signal makes
dma_alloc_coherent() return NULL.

There are two ways I could fix this:

- use a GFP_ATOMIC allocation, which would avoid this sensitivity to a
pending signal being fatal (we suffer from the same issue in
bcm_sysport_resume)

- move the DMA coherent allocation before bcm_sysport_open(), in the
driver's probe function, but if the network interface is never used, we
would be waisting precious DMA coherent memory for nothing (it is only 4
bytes times 32 but still

Now the general problem that I see with this fatal_signal_pending()
check is that any driver that calls dma_alloc_coherent() and which does
this in a process context (network drivers are frequently doing this in
their ndo_open callback) and also happens to get its allocation serviced
from CMA can now fail, instead of failing on really hard OOM conditions.
--
Florian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
