Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 98FE86B0031
	for <linux-mm@kvack.org>; Thu, 10 Apr 2014 06:02:53 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id jt11so3749959pbb.14
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 03:02:53 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id pm5si1882406pbc.441.2014.04.10.03.02.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 10 Apr 2014 03:02:52 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N3T0036F7WGMV60@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 10 Apr 2014 11:02:40 +0100 (BST)
Message-id: <53466C4A.2030107@samsung.com>
Date: Thu, 10 Apr 2014 12:02:50 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
MIME-version: 1.0
Subject: Re: [RFC] Helper to abstract vma handling in media layer
References: <1395085776-8626-1-git-send-email-jack@suse.cz>
In-reply-to: <1395085776-8626-1-git-send-email-jack@suse.cz>
Content-type: text/plain; charset=UTF-8; format=flowed
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, linux-mm@kvack.org
Cc: linux-media@vger.kernel.org, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, 'Tomasz Stanislawski' <t.stanislaws@samsung.com>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>

Hello,

On 2014-03-17 20:49, Jan Kara wrote:
>    The following patch series is my first stab at abstracting vma handling
> from the various media drivers. After this patch set drivers have to know
> much less details about vmas, their types, and locking. My motivation for
> the series is that I want to change get_user_pages() locking and I want
> to handle subtle locking details in as few places as possible.
>
> The core of the series is the new helper get_vaddr_pfns() which is given a
> virtual address and it fills in PFNs into provided array. If PFNs correspond to
> normal pages it also grabs references to these pages. The difference from
> get_user_pages() is that this function can also deal with pfnmap, mixed, and io
> mappings which is what the media drivers need.
>
> The patches are just compile tested (since I don't have any of the hardware
> I'm afraid I won't be able to do any more testing anyway) so please handle
> with care. I'm grateful for any comments.

Thanks for posting this series! I will check if it works with our 
hardware soon.
This is something I wanted to introduce some time ago to simplify buffer
handling in dma-buf, but I had no time to start working.

However I would like to go even further with integration of your pfn 
vector idea.
This structure looks like a best solution for a compact representation 
of the
memory buffer, which should be considered by the hardware as contiguous 
(either
contiguous in physical memory or mapped contiguously into dma address 
space by
the respective iommu). As you already noticed it is widely used by 
graphics and
video drivers.

I would also like to add support for pfn vector directly to the dma-mapping
subsystem. This can be done quite easily (even with a fallback for 
architectures
which don't provide method for it). I will try to prepare rfc soon. This 
will
finally remove the need for hacks in media/v4l2-core/videobuf2-dma-contig.c

Thanks for motivating me to finally start working on this!

Best regards
-- 
Marek Szyprowski, PhD
Samsung R&D Institute Poland

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
