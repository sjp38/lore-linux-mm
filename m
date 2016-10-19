Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 45F2F6B0264
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 13:50:27 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id t73so72989421oie.5
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 10:50:27 -0700 (PDT)
Received: from mail-oi0-x233.google.com (mail-oi0-x233.google.com. [2607:f8b0:4003:c06::233])
        by mx.google.com with ESMTPS id b68si5938481oih.130.2016.10.19.10.50.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Oct 2016 10:50:26 -0700 (PDT)
Received: by mail-oi0-x233.google.com with SMTP id d132so39648580oib.2
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 10:50:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1476826937-20665-2-git-send-email-sbates@raithlin.com>
References: <1476826937-20665-1-git-send-email-sbates@raithlin.com> <1476826937-20665-2-git-send-email-sbates@raithlin.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 19 Oct 2016 10:50:25 -0700
Message-ID: <CAPcyv4gmiqMNb+Q88Mf-9fFb4z4uAfWbbEWrv42OBH8838SSPQ@mail.gmail.com>
Subject: Re: [PATCH 1/3] memremap.c : Add support for ZONE_DEVICE IO memory
 with struct pages.
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Bates <sbates@raithlin.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-rdma@vger.kernel.org, linux-block@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, haggaie@mellanox.com, Christoph Hellwig <hch@infradead.org>, Jens Axboe <axboe@fb.com>, Jonathan Corbet <corbet@lwn.net>, jim.macdonald@everspin.com, sbates@raithin.com, Logan Gunthorpe <logang@deltatee.com>

On Tue, Oct 18, 2016 at 2:42 PM, Stephen Bates <sbates@raithlin.com> wrote:
> From: Logan Gunthorpe <logang@deltatee.com>
>
> We build on recent work that adds memory regions owned by a device
> driver (ZONE_DEVICE) [1] and to add struct page support for these new
> regions of memory [2].
>
> 1. Add an extra flags argument into dev_memremap_pages to take in a
> MEMREMAP_XX argument. We update the existing calls to this function to
> reflect the change.
>
> 2. For completeness, we add MEMREMAP_WT support to the memremap;
> however we have no actual need for this functionality.
>
> 3. We add the static functions, add_zone_device_pages and
> remove_zone_device pages. These are similar to arch_add_memory except
> they don't create the memory mapping. We don't believe these need to be
> made arch specific, but are open to other opinions.
>
> 4. dev_memremap_pages and devm_memremap_pages_release are updated to
> treat IO memory slightly differently. For IO memory we use a combination
> of the appropriate io_remap function and the zone_device pages functions
> created above. A flags variable and kaddr pointer are added to struct
> page_mem to facilitate this for the release function. We also set up
> the page attribute tables for the mapped region correctly based on the
> desired mapping.
>

This description says "what" is being done, but not "why".

In the cover letter, "[PATCH 0/3] iopmem : A block device for PCIe
memory",  it mentions that the lack of I/O coherency is a known issue
and users of this functionality need to be cognizant of the pitfalls.
If that is the case why do we need support for different cpu mapping
types than the default write-back cache setting?  It's up to the
application to handle cache cpu flushing similar to what we require of
device-dax users in the persistent memory case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
