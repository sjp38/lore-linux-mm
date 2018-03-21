Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id E095A6B0006
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 18:23:25 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id v3so3354940pfm.21
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:23:25 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id t2sor1543390pfk.17.2018.03.21.15.23.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Mar 2018 15:23:24 -0700 (PDT)
Date: Wed, 21 Mar 2018 15:23:57 -0700
From: Nicolin Chen <nicoleotsuka@gmail.com>
Subject: mm/hmm: a simple question regarding devm_request_mem_region()
Message-ID: <20180321222357.GA31089@Asurada-Nvidia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello Jerome,

I started to looking at the mm/hmm code and having a question at the
devm_request_mem_region() call in the hmm_devmem_add() implementation:

>	addr = min((unsigned long)iomem_resource.end,
>		   (1UL << MAX_PHYSMEM_BITS) - 1);

The main question is here as I am a bit confused by this addr. The code
is trying to get an addr from the end of memory space. However, I have
tried on an ARM64 platform where ioport_resource.end is -1, so it takes
"(1UL << MAX_PHYSMEM_BITS) - 1" as the addr base, while this addr is way
beyond the actual main memory size that's available on my board. Is HMM
supposed to get an memory region like this? Would it be possible for you
to give some hint to help me understand it?

>	addr = addr - size + 1UL;
>
>	/*
>	 * FIXME add a new helper to quickly walk resource tree and find free
>	 * range
>	 *
>	 * FIXME what about ioport_resource resource ?
>	 */
>	for (; addr > size && addr >= iomem_resource.start; addr -= size) {
>		ret = region_intersects(addr, size, 0, IORES_DESC_NONE);
>		if (ret != REGION_DISJOINT)
>			continue;
>
>		devmem->resource = devm_request_mem_region(device, addr, size,

Thanks
Nicolin
