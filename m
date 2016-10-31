Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 07E9E6B029B
	for <linux-mm@kvack.org>; Mon, 31 Oct 2016 11:26:33 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id f78so30628782oih.7
        for <linux-mm@kvack.org>; Mon, 31 Oct 2016 08:26:33 -0700 (PDT)
Received: from mail-oi0-x241.google.com (mail-oi0-x241.google.com. [2607:f8b0:4003:c06::241])
        by mx.google.com with ESMTPS id y52si16686307otd.127.2016.10.31.08.26.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Oct 2016 08:26:32 -0700 (PDT)
Received: by mail-oi0-x241.google.com with SMTP id v84so5979045oie.2
        for <linux-mm@kvack.org>; Mon, 31 Oct 2016 08:26:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20161031102057.GZ1041@n2100.armlinux.org.uk>
References: <20161024115737.16276.71059.stgit@ahduyck-blue-test.jf.intel.com>
 <20161024120447.16276.50401.stgit@ahduyck-blue-test.jf.intel.com> <20161031102057.GZ1041@n2100.armlinux.org.uk>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Mon, 31 Oct 2016 08:26:30 -0700
Message-ID: <CAKgT0Uf8vg-78T15EMtnZ7Muz5aRZ_0o2e0GZn8Pc+TjD3xn7w@mail.gmail.com>
Subject: Re: [net-next PATCH RFC 04/26] arch/arm: Add option to skip sync on
 DMA map and unmap
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>, Netdev <netdev@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Jesper Dangaard Brouer <brouer@redhat.com>, David Miller <davem@davemloft.net>

On Mon, Oct 31, 2016 at 3:20 AM, Russell King - ARM Linux
<linux@armlinux.org.uk> wrote:
> On Mon, Oct 24, 2016 at 08:04:47AM -0400, Alexander Duyck wrote:
>> The use of DMA_ATTR_SKIP_CPU_SYNC was not consistent across all of the DMA
>> APIs in the arch/arm folder.  This change is meant to correct that so that
>> we get consistent behavior.
>
> I'm really not convinced that this is anywhere close to correct behaviour.
>
> If we're DMA-ing to a buffer, and we unmap it or sync_for_cpu, then we
> will want to access the DMA'd data - especially in the sync_for_cpu case,
> it's pointless to call sync_for_cpu if we're not going to access the
> data.

First, let me clarify.  The sync_for_cpu call will still work the
same.  This only effects the map/unmap calls.

> So the idea of skipping the CPU copy when DMA_ATTR_SKIP_CPU_SYNC is set
> seems to be completely wrong - it means we end up reading the stale data
> that was in the buffer, completely ignoring whatever was DMA'd to it.

I agree.  However this is meant to be used in the dma_unmap call only
if sync_for_cpu has already been called for the regions that could
have been updated by the device.

> What's the use case for DMA_ATTR_SKIP_CPU_SYNC ?

The main use case I have in mind is to allow for pseudo-static DMA
mappings where we can share them between the network stack and the
device driver.  I use igb as an example.

1   allocate page, reset page_offset to 0
2   map page while passing DMA_ATTR_SKIP_CPU_SYNC
3   dma_sync_single_range_for_device starting at page_offset, length
2K (largest possible write by device)
4   device performs Rx DMA and updates Rx descriptor
5   read length from Rx descriptor
6   dma_sync_single_range_for_cpu starting at page_offset, length
reported by descriptor
7   if page_count == 1
        7.1  update page_offset with xor 2K
        7.2  hand page up to network stack
        7.3  goto 3
8   unmap page with DMA_ATTR_SKIP_CPU_SYNC
9   hand page up to network stack
10 goto 1

The idea is we want to be able to have a page be accessible to the
device, but be able to share it with the network stack which might try
to write to the page.  By letting the driver handle the
synchronization we get two main advantages. First we end up looping
over fewer cache lines as we only have to invalidate the region
updated by the device in steps 3 and 6 instead of the entire page.
The other advantage is that the pages are writable by the network
stack since step 8 will not invalidate the entire mapping.

I am just as concerned about the possibility of stale data.  That is
why I have gone through and made sure that any path in the igb driver
called sync for the region held by the device before we might call
unmap.  It isn't that I don't want the data to be kept fresh, it is a
matter of wanting control over what we are invalidating.  Here is a
link to the igb patch I have that was a part of this set.

https://patchwork.ozlabs.org/patch/686747/

Thanks.

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
