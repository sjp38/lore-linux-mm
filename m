Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9A8948E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 13:54:53 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id v16so15832347wru.8
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 10:54:53 -0800 (PST)
Received: from bhuna.collabora.co.uk (bhuna.collabora.co.uk. [2a00:1098:0:82:1000:25:2eeb:e3e3])
        by mx.google.com with ESMTPS id g28si31588272wrb.162.2019.01.03.10.54.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 03 Jan 2019 10:54:52 -0800 (PST)
Date: Thu, 3 Jan 2019 13:54:53 -0500
From: =?utf-8?B?R2HDq2w=?= PORTAY <gael.portay@collabora.com>
Subject: Re: [usb-storage] Re: cma: deadlock using usb-storage and fs
Message-ID: <20190103185452.pwsl7xsf4cp4curz@archlinux.localdomain>
References: <20181216222117.v5bzdfdvtulv2t54@archlinux.localdomain>
 <Pine.LNX.4.44L0.1812171038300.1630-100000@iolanthe.rowland.org>
 <20181217182922.bogbrhjm6ubnswqw@archlinux.localdomain>
 <c3ab7935-8d8d-27a0-99a7-0dab51244a42@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c3ab7935-8d8d-27a0-99a7-0dab51244a42@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Alan Stern <stern@rowland.harvard.edu>, linux-mm@kvack.org, usb-storage@lists.one-eyed-alien.net

Laura,

On Mon, Dec 17, 2018 at 01:57:37PM -0800, Laura Abbott wrote:
> (...)
> 
> The ARM dma layer uses gfpflags_allow_blocking to decide if it should
> use CMA vs. the atomic pool:
> 
> static inline bool gfpflags_allow_blocking(const gfp_t gfp_flags)
> {
>         return !!(gfp_flags & __GFP_DIRECT_RECLAIM);
> }
> 
> That's not sufficient to cover the writeback case. This is
> used in multiple DMA allocations (arm64 and intel-iommu at
> first pass) so I think we need a new gfpflags_allow_writeback
> for deciding if CMA should be used.
> 
> Thanks,
> Laura

To let you know, in a first instance, I hacked the function
__dma_alloc() to take the GPF_NOIO flag into consideration (which is
likely the same fix you mention above; except that it applies only to
that function, in order to make sure it does not break things
somewherelse that I do not control).

        *handle = ARM_MAPPING_ERROR;
        allowblock = gfpflags_allow_blocking(gfp);
+       /* Following is a work-around to prevent from deadlock in CMA
+        * allocator when a task triggers for a page migration. Others
+        * tasks may wants to migrate theirs pages using CMA but get
+        * locked because the first task already holds the mutex.
+        *
+        * Because CMA is blocking, it refuses to go for CMA if GFP_NOIO
+        * flag is set.
+        */
+       if (allowblock)
+               allowblock = !!(gfp & GFP_NOIO);
        cma = allowblock ? dev_get_cma_area(dev) : false;

I thought it was not working until I decided to give it a retry today...
and it works!

Regards,
Gael
