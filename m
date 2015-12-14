Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id CC0E06B0255
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 11:44:03 -0500 (EST)
Received: by qget30 with SMTP id t30so16315187qge.3
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 08:44:03 -0800 (PST)
Received: from mail-qk0-x22f.google.com (mail-qk0-x22f.google.com. [2607:f8b0:400d:c09::22f])
        by mx.google.com with ESMTPS id m68si35601821qgm.33.2015.12.14.08.44.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Dec 2015 08:44:03 -0800 (PST)
Received: by qkfb125 with SMTP id b125so143570474qkf.2
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 08:44:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <x49lh8xccb8.fsf@segfault.boston.devel.redhat.com>
References: <20151210023708.30368.92962.stgit@dwillia2-desk3.jf.intel.com>
	<x49r3iutbv2.fsf@segfault.boston.devel.redhat.com>
	<CAPcyv4gfMSW=x=LcZeEqX6hvO39Q2=nyUxq3FwMxaZ6PEGZtMg@mail.gmail.com>
	<x49fuzat8k9.fsf@segfault.boston.devel.redhat.com>
	<CAPcyv4jtF2LwK3jbsjPHB7=JE1O0-TkRQGQcMSrB9bPZVdFd8A@mail.gmail.com>
	<x49lh8xccb8.fsf@segfault.boston.devel.redhat.com>
Date: Mon, 14 Dec 2015 08:44:02 -0800
Message-ID: <CAPcyv4ju8BxtPzkC16jvS-C8QdWSU471KaPeyKNf7hdGF6HdqA@mail.gmail.com>
Subject: Re: [-mm PATCH v2 00/25] get_user_pages() for dax pte and pmd mappings
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@sr71.net>, Toshi Kani <toshi.kani@hpe.com>, David Airlie <airlied@linux.ie>, Dave Hansen <dave.hansen@linux.intel.com>, Dave Chinner <david@fromorbit.com>, Linux MM <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Christoph Hellwig <hch@lst.de>, Andrea Arcangeli <aarcange@redhat.com>, kbuild test robot <lkp@intel.com>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Richard Weinberger <richard@nod.at>, X86 ML <x86@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Mel Gorman <mgorman@suse.de>, Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jeff Dike <jdike@addtoit.com>, Jens Axboe <axboe@fb.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Christoffer Dall <christoffer.dall@linaro.org>, Jan Kara <jack@suse.com>, Paolo Bonzini <pbonzini@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Mon, Dec 14, 2015 at 6:52 AM, Jeff Moyer <jmoyer@redhat.com> wrote:
> Dan Williams <dan.j.williams@intel.com> writes:
>
>> In the meantime, I expect some would say DAX is a toy as long as it
>> continues to fail at DMA.
>
> I suppose this is the crux of it.  Given that we may be able to migrate
> away from the allocation of storage for temporary data structures in the
> future, and given that admin tooling could hide the undesirable
> configurations, this approach seems workable.

Here's my current thoughts on the tooling for namespace creation:

   ndctl create-namespace

That command by default will create a maximally sized pmem namespace
and set up the struct page memmap by default i.e. it defaults to the
following parameters:

    ndctl create-namespace --type=pmem --mode=memory

The other options for 'mode' are 'safe' and 'raw' where 'safe'
establishes a btt, and 'raw' exposes the full un-decorated capacity of
the namespace.

If you have a pre-existing 'raw' mode pmem namespace, you can convert
it to be enabled for dma, and other capabilities typical memory
possesses, with the following:

    ndctl create-namespace --mode=memory -r namespace0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
