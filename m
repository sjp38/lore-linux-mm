Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id D2B936B0038
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 14:20:15 -0500 (EST)
Received: by qgec40 with SMTP id c40so157359269qge.2
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 11:20:15 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k61si16224776qgf.23.2015.12.10.11.20.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Dec 2015 11:20:13 -0800 (PST)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [-mm PATCH v2 00/25] get_user_pages() for dax pte and pmd mappings
References: <20151210023708.30368.92962.stgit@dwillia2-desk3.jf.intel.com>
	<x49r3iutbv2.fsf@segfault.boston.devel.redhat.com>
	<CAPcyv4gfMSW=x=LcZeEqX6hvO39Q2=nyUxq3FwMxaZ6PEGZtMg@mail.gmail.com>
Date: Thu, 10 Dec 2015 14:20:06 -0500
In-Reply-To: <CAPcyv4gfMSW=x=LcZeEqX6hvO39Q2=nyUxq3FwMxaZ6PEGZtMg@mail.gmail.com>
	(Dan Williams's message of "Thu, 10 Dec 2015 10:56:17 -0800")
Message-ID: <x49fuzat8k9.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@sr71.net>, Toshi Kani <toshi.kani@hpe.com>, David Airlie <airlied@linux.ie>, Dave Hansen <dave.hansen@linux.intel.com>, Dave Chinner <david@fromorbit.com>, Linux MM <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Christoph Hellwig <hch@lst.de>, Andrea Arcangeli <aarcange@redhat.com>, kbuild test robot <lkp@intel.com>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Richard Weinberger <richard@nod.at>, X86 ML <x86@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Mel Gorman <mgorman@suse.de>, Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jeff Dike <jdike@addtoit.com>, Jens Axboe <axboe@fb.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Christoffer Dall <christoffer.dall@linaro.org>, Jan Kara <jack@suse.com>, Paolo Bonzini <pbonzini@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Dan Williams <dan.j.williams@intel.com> writes:

> On Thu, Dec 10, 2015 at 10:08 AM, Jeff Moyer <jmoyer@redhat.com> wrote:
>> Dan Williams <dan.j.williams@intel.com> writes:
>>
>>> Summary:
>>>
>>> To date, we have implemented two I/O usage models for persistent memory,
>>> PMEM (a persistent "ram disk") and DAX (mmap persistent memory into
>>> userspace).  This series adds a third, DAX-GUP, that allows DAX mappings
>>> to be the target of direct-i/o.  It allows userspace to coordinate
>>> DMA/RDMA from/to persistent memory.
>>>
>>> The implementation leverages the ZONE_DEVICE mm-zone that went into
>>> 4.3-rc1 (also discussed at kernel summit) to flag pages that are owned
>>> and dynamically mapped by a device driver.  The pmem driver, after
>>> mapping a persistent memory range into the system memmap via
>>> devm_memremap_pages(), arranges for DAX to distinguish pfn-only versus
>>> page-backed pmem-pfns via flags in the new pfn_t type.
>>
>> So, this basically means that an admin has to decide whether or not DMA
>> will be used on a given device before making a file system on it.  That
>> seems like an odd requirement.  There's also a configuration option of
>> whether to put those backing struct pages into DRAM or PMEM (which, of
>> course, will be dictated by the size of pmem).  I really think we should
>> reconsider this approach.
>>
>> First, the admin shouldn't have to choose whether or not DMA will be
>> done on the file system.
>
> To be clear it's not "whether or not DMA will be done on the file
> system", it's whether or not both DMA and DAX will be done
> simultaneously on the filesystem.

Fair point, but I'd view one of those configurations as not recommended.
To be clear, if you're just going to use the device for block based
access, using btt is the safer option.

> DAX is already a capability that an admin can inadvertently disable by
> mis-configuring the alignment of a partition [1].

Heh, using my own commit against me? ;-) Anyway, the commit message
suggests that dax *could* be supported on misaligned partitions.

> Why not also disable it when DMA support is not configured and force
> the fs back to page-cache?  Namespace creation tooling in userspace
> can default to enabling DAX + DMA.

Well, the only reason I can come up with is manufactured:  we've forced
the admin to decide between having that extra space for storage and
doing DMA, and he or she opted for more space.

>> Second, eating up storage space to track
>> mostly unused struct pages seems like a waste.  Is there no future for
>> the "introduce __pfn_t, evacuate struct page from sgls"[1] approach?
>> And if not, is there some other way we can solve this problem?
>
> I'm still very much interested in revisiting the page-less mechanisms
> over time, but given comments like Dave's [2], it's not on any short
> term horizon.

OK.

>> I know dynamic allocation of struct pages is scary, but is it more tractable
>> than no pages for DMA?
>
> I wasn't convinced that it would be any better given the need to
> allocate at section granularity at fault time.  It would still require
> ZONE_DEVICE or something similar.  Waiting until get_user_pages() time
> to allocate pages means we don't get __get_user_pages_fast support.
> It also was not clear to that it would prevent exhaustion of DRAM for
> long-standing / large mappings.

Hmm, yeah, this does seem like a less attractive approach.  Thanks for
enumerating the issues.

-Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
