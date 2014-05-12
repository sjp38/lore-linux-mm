Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f53.google.com (mail-ee0-f53.google.com [74.125.83.53])
	by kanga.kvack.org (Postfix) with ESMTP id AE4426B0035
	for <linux-mm@kvack.org>; Mon, 12 May 2014 08:01:13 -0400 (EDT)
Received: by mail-ee0-f53.google.com with SMTP id c13so4625839eek.12
        for <linux-mm@kvack.org>; Mon, 12 May 2014 05:01:13 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.187])
        by mx.google.com with ESMTPS id l44si10358690eem.253.2014.05.12.05.01.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 May 2014 05:01:12 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: Questions regarding DMA buffer sharing using IOMMU
Date: Mon, 12 May 2014 14:00:57 +0200
Message-ID: <5218408.5YRJXjS4BX@wuerfel>
In-Reply-To: <BAY169-W12541AD089785F8BFBD4E26EF350@phx.gbl>
References: <BAY169-W12541AD089785F8BFBD4E26EF350@phx.gbl>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org
Cc: Pintu Kumar <pintu.k@outlook.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>

On Monday 12 May 2014 15:12:41 Pintu Kumar wrote:
> Hi, 
> I have some queries regarding IOMMU and CMA buffer sharing. 
> We have an embedded linux device (kernel 3.10, RAM: 256Mb) in 
> which camera and codec supports IOMMU but the display does not support IOMMU. 
> Thus for camera capture we are using iommu buffers using
> ION/DMABUF. But for all display rendering we are using CMA buffers. 
> So, the question is how to achieve buffer sharing (zero-copy)
> between Camera and Display using only IOMMU? 
> Currently we are achieving zero-copy using CMA. And we are
> exploring options to use IOMMU. 
> Now we wanted to know which option is better? To use IOMMU or CMA? 
> If anybody have come across these design please share your thoughts and results. 

There is a slight performance overhead in using the IOMMU in general,
because the IOMMU has to fetch the page table entries from memory
at least some of the time.

If that overhead is within the constraints you have for transfers between
camera and codec, you are always better off using IOMMU since that
means you don't have to do memory migration.

Note however, that we don't have a way to describe IOMMU relations
to devices in DT, so whatever you come up with to do this will most
likely be incompatible with what we do in future kernel versions.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
