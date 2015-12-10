Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id EFDF56B0038
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 13:08:57 -0500 (EST)
Received: by qgcc31 with SMTP id c31so155537201qgc.3
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 10:08:57 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o3si1765750ywo.166.2015.12.10.10.08.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Dec 2015 10:08:57 -0800 (PST)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [-mm PATCH v2 00/25] get_user_pages() for dax pte and pmd mappings
References: <20151210023708.30368.92962.stgit@dwillia2-desk3.jf.intel.com>
Date: Thu, 10 Dec 2015 13:08:49 -0500
In-Reply-To: <20151210023708.30368.92962.stgit@dwillia2-desk3.jf.intel.com>
	(Dan Williams's message of "Wed, 09 Dec 2015 18:37:09 -0800")
Message-ID: <x49r3iutbv2.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Dave Hansen <dave@sr71.net>, Toshi Kani <toshi.kani@hpe.com>, David Airlie <airlied@linux.ie>, Dave Hansen <dave.hansen@linux.intel.com>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, "H. Peter Anvin" <hpa@zytor.com>, Christoph Hellwig <hch@lst.de>, Andrea Arcangeli <aarcange@redhat.com>, kbuild test robot <lkp@intel.com>, linux-nvdimm@ml01.01.org, Richard Weinberger <richard@nod.at>, x86@kernel.org, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Mel Gorman <mgorman@suse.de>, Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jeff Dike <jdike@addtoit.com>, Jens Axboe <axboe@fb.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Christoffer Dall <christoffer.dall@linaro.org>, Jan Kara <jack@suse.com>, Paolo Bonzini <pbonzini@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Dan Williams <dan.j.williams@intel.com> writes:

> Summary:
>
> To date, we have implemented two I/O usage models for persistent memory,
> PMEM (a persistent "ram disk") and DAX (mmap persistent memory into
> userspace).  This series adds a third, DAX-GUP, that allows DAX mappings
> to be the target of direct-i/o.  It allows userspace to coordinate
> DMA/RDMA from/to persistent memory.
>
> The implementation leverages the ZONE_DEVICE mm-zone that went into
> 4.3-rc1 (also discussed at kernel summit) to flag pages that are owned
> and dynamically mapped by a device driver.  The pmem driver, after
> mapping a persistent memory range into the system memmap via
> devm_memremap_pages(), arranges for DAX to distinguish pfn-only versus
> page-backed pmem-pfns via flags in the new pfn_t type.

So, this basically means that an admin has to decide whether or not DMA
will be used on a given device before making a file system on it.  That
seems like an odd requirement.  There's also a configuration option of
whether to put those backing struct pages into DRAM or PMEM (which, of
course, will be dictated by the size of pmem).  I really think we should
reconsider this approach.

First, the admin shouldn't have to choose whether or not DMA will be
done on the file system.  Second, eating up storage space to track
mostly unused struct pages seems like a waste.  Is there no future for
the "introduce __pfn_t, evacuate struct page from sgls"[1] approach?
And if not, is there some other way we can solve this problem?  I know
dynamic allocation of struct pages is scary, but is it more tractable
than no pages for DMA?

Cheers,
Jeff

[1] https://lwn.net/Articles/647404/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
