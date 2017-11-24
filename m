Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id BF2AC6B025E
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 05:35:43 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id y41so13406962wrc.22
        for <linux-mm@kvack.org>; Fri, 24 Nov 2017 02:35:43 -0800 (PST)
Received: from smtp-out6.electric.net (smtp-out6.electric.net. [192.162.217.184])
        by mx.google.com with ESMTPS id 57si2238063edz.9.2017.11.24.02.35.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Nov 2017 02:35:42 -0800 (PST)
From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [RFC v2] dma-coherent: introduce no-align to avoid allocation
 failure and save memory
Date: Fri, 24 Nov 2017 10:35:56 +0000
Message-ID: <ac459cbf03c343ecad78450d89f340e7@AcuMS.aculab.com>
References: <CGME20171124055811epcas1p364177b515eb072d25cd9f49573daef72@epcas1p3.samsung.com>
 <20171124055833.10998-1-jaewon31.kim@samsung.com>
In-Reply-To: <20171124055833.10998-1-jaewon31.kim@samsung.com>
Content-Language: en-US
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Jaewon Kim' <jaewon31.kim@samsung.com>, "m.szyprowski@samsung.com" <m.szyprowski@samsung.com>, "hch@lst.de" <hch@lst.de>, "robin.murphy@arm.com" <robin.murphy@arm.com>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>
Cc: "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mhocko@suse.com" <mhocko@suse.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "jaewon31.kim@gmail.com" <jaewon31.kim@gmail.com>

From: Jaewon Kim
> Sent: 24 November 2017 05:59
>=20
> dma-coherent uses bitmap APIs which internally consider align based on th=
e
> requested size. If most of allocations are small size like KBs, using
> alignment scheme seems to be good for anti-fragmentation. But if large
> allocation are commonly used, then an allocation could be failed because
> of the alignment. To avoid the allocation failure, we had to increase tot=
al
> size.
>=20
> This is a example, total size is 30MB, only few memory at front is being
> used, and 9MB is being requsted. Then 9MB will be aligned to 16MB. The
> first try on offset 0MB will be failed because others already are using
> them. The second try on offset 16MB will be failed because of ouf of boun=
d.
>=20
> So if the alignment is not necessary on a specific dma-coherent memory
> region, we can set no-align property. Then dma-coherent will ignore the
> alignment only for the memory region.

ISTM that the alignment needs to be a property of the request, not of the
device. Certainly the device driver code is most likely to know the specifi=
c
alignment requirements of any specific allocation.

We've some hardware that would need large allocations to be 16k aligned.
We actually use multiple 16k allocations because any large buffers are
accessed directly from userspace (mmap and vm_iomap_memory) and the
card has its own page tables (with 16k pages).

	David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
