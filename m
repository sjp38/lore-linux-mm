Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 9E9C64402FE
	for <linux-mm@kvack.org>; Fri,  2 Oct 2015 18:55:25 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so51871005wic.0
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 15:55:25 -0700 (PDT)
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com. [209.85.212.173])
        by mx.google.com with ESMTPS id bf6si1392435wib.52.2015.10.02.15.55.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Oct 2015 15:55:24 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so52271355wic.0
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 15:55:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <560F0854.9040300@deltatee.com>
References: <20150923043737.36490.70547.stgit@dwillia2-desk3.jf.intel.com>
	<20150923044227.36490.99741.stgit@dwillia2-desk3.jf.intel.com>
	<20151002212137.GB30448@deltatee.com>
	<CAPcyv4iwJJX-rSgC0ramLrvccdzDXgnUAUMQbTMpoODo2f7kOw@mail.gmail.com>
	<560F0854.9040300@deltatee.com>
Date: Fri, 2 Oct 2015 15:55:23 -0700
Message-ID: <CAPcyv4jbRn8tTbuqKYCzd4Qs5FjvJCN_Jy5pjHfwX+Kw9bub0Q@mail.gmail.com>
Subject: Re: [PATCH 14/15] mm, dax, pmem: introduce {get|put}_dev_pagemap()
 for dax-gup
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Logan Gunthorpe <logang@deltatee.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@sr71.net>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Stephen Bates <Stephen.Bates@pmcs.com>

On Fri, Oct 2, 2015 at 3:42 PM, Logan Gunthorpe <logang@deltatee.com> wrote:
>
>
> On 02/10/15 03:53 PM, Dan Williams wrote:
>>
>> Yes, this location for dev_pagemap will not work.  I've since moved it
>> to a union with the lru list_head since ZONE_DEVICE pages memory
>> should always have an elevated page count and never land on a slab
>> allocator lru.
>
>
> Oh, also, I was actually hoping to make use of the lru list_head in the
> future with ZONE_DEVICE memory. One thought I had was once we have a PCIe
> device with a BAR space, we'd then need to have a way of allocating these
> buffers when user space needs them. The simple way I was thinking was to
> just use the lru list head to store lists of used and unused pages -- though
> there are probably other solutions to this that don't require using struct
> pages.
>

The current assumption is the ZONE_DEVICE ranges are being managed by
a physical address allocator.  In the case of persistent memory this
is the block allocator of the filesystem sitting on top of a pmem
block device.  The struct page is really only there to facilitate
in-flight I/O requests.  If it weren't for complexity we'd allocate
them on demand.  So you're "unused" case should be a raw pfn and then
for the time-limited duration it is in use as a struct page it should
hold a reference against the mapping.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
