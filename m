Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f51.google.com (mail-vk0-f51.google.com [209.85.213.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9619E6B0038
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 13:56:18 -0500 (EST)
Received: by vkca188 with SMTP id a188so97035664vkc.0
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 10:56:18 -0800 (PST)
Received: from mail-vk0-x22f.google.com (mail-vk0-x22f.google.com. [2607:f8b0:400c:c05::22f])
        by mx.google.com with ESMTPS id x73si11450534vkd.122.2015.12.10.10.56.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Dec 2015 10:56:17 -0800 (PST)
Received: by vkha189 with SMTP id a189so96375143vkh.2
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 10:56:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <x49r3iutbv2.fsf@segfault.boston.devel.redhat.com>
References: <20151210023708.30368.92962.stgit@dwillia2-desk3.jf.intel.com>
	<x49r3iutbv2.fsf@segfault.boston.devel.redhat.com>
Date: Thu, 10 Dec 2015 10:56:17 -0800
Message-ID: <CAPcyv4gfMSW=x=LcZeEqX6hvO39Q2=nyUxq3FwMxaZ6PEGZtMg@mail.gmail.com>
Subject: Re: [-mm PATCH v2 00/25] get_user_pages() for dax pte and pmd mappings
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@sr71.net>, Toshi Kani <toshi.kani@hpe.com>, David Airlie <airlied@linux.ie>, Dave Hansen <dave.hansen@linux.intel.com>, Dave Chinner <david@fromorbit.com>, Linux MM <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Christoph Hellwig <hch@lst.de>, Andrea Arcangeli <aarcange@redhat.com>, kbuild test robot <lkp@intel.com>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Richard Weinberger <richard@nod.at>, X86 ML <x86@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Mel Gorman <mgorman@suse.de>, Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jeff Dike <jdike@addtoit.com>, Jens Axboe <axboe@fb.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Christoffer Dall <christoffer.dall@linaro.org>, Jan Kara <jack@suse.com>, Paolo Bonzini <pbonzini@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Thu, Dec 10, 2015 at 10:08 AM, Jeff Moyer <jmoyer@redhat.com> wrote:
> Dan Williams <dan.j.williams@intel.com> writes:
>
>> Summary:
>>
>> To date, we have implemented two I/O usage models for persistent memory,
>> PMEM (a persistent "ram disk") and DAX (mmap persistent memory into
>> userspace).  This series adds a third, DAX-GUP, that allows DAX mappings
>> to be the target of direct-i/o.  It allows userspace to coordinate
>> DMA/RDMA from/to persistent memory.
>>
>> The implementation leverages the ZONE_DEVICE mm-zone that went into
>> 4.3-rc1 (also discussed at kernel summit) to flag pages that are owned
>> and dynamically mapped by a device driver.  The pmem driver, after
>> mapping a persistent memory range into the system memmap via
>> devm_memremap_pages(), arranges for DAX to distinguish pfn-only versus
>> page-backed pmem-pfns via flags in the new pfn_t type.
>
> So, this basically means that an admin has to decide whether or not DMA
> will be used on a given device before making a file system on it.  That
> seems like an odd requirement.  There's also a configuration option of
> whether to put those backing struct pages into DRAM or PMEM (which, of
> course, will be dictated by the size of pmem).  I really think we should
> reconsider this approach.
>
> First, the admin shouldn't have to choose whether or not DMA will be
> done on the file system.

To be clear it's not "whether or not DMA will be done on the file
system", it's whether or not both DMA and DAX will be done
simultaneously on the filesystem.

DAX is already a capability that an admin can inadvertently disable by
mis-configuring the alignment of a partition [1].  Why not also
disable it when DMA support is not configured and force the fs back to
page-cache?  Namespace creation tooling in userspace can default to
enabling DAX + DMA.

> Second, eating up storage space to track
> mostly unused struct pages seems like a waste.  Is there no future for
> the "introduce __pfn_t, evacuate struct page from sgls"[1] approach?
> And if not, is there some other way we can solve this problem?

I'm still very much interested in revisiting the page-less mechanisms
over time, but given comments like Dave's [2], it's not on any short
term horizon.

> I know dynamic allocation of struct pages is scary, but is it more tractable
> than no pages for DMA?

I wasn't convinced that it would be any better given the need to
allocate at section granularity at fault time.  It would still require
ZONE_DEVICE or something similar.  Waiting until get_user_pages() time
to allocate pages means we don't get __get_user_pages_fast support.
It also was not clear to that it would prevent exhaustion of DRAM for
long-standing / large mappings.

[1]: https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=f0b2e563bc41
[2]: https://lists.01.org/pipermail/linux-nvdimm/2015-August/001853.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
