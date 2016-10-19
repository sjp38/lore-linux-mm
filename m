Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0CA7F280250
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 14:40:35 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id o68so24425032qkf.3
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 11:40:35 -0700 (PDT)
Received: from gateway30.websitewelcome.com (gateway30.websitewelcome.com. [192.185.147.85])
        by mx.google.com with ESMTPS id d6si16455447oia.17.2016.10.19.11.40.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Oct 2016 11:40:34 -0700 (PDT)
Received: from cm6.websitewelcome.com (cm6.websitewelcome.com [108.167.139.19])
	by gateway30.websitewelcome.com (Postfix) with ESMTP id 25F00241CA24E
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 13:40:34 -0500 (CDT)
Date: Wed, 19 Oct 2016 12:40:28 -0600
From: Stephen Bates <sbates@raithlin.com>
Subject: Re: [PATCH 1/3] memremap.c : Add support for ZONE_DEVICE IO memory
 with struct pages.
Message-ID: <20161019184028.GB16550@cgy1-donard.priv.deltatee.com>
References: <1476826937-20665-1-git-send-email-sbates@raithlin.com>
 <1476826937-20665-2-git-send-email-sbates@raithlin.com>
 <CAPcyv4gmiqMNb+Q88Mf-9fFb4z4uAfWbbEWrv42OBH8838SSPQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4gmiqMNb+Q88Mf-9fFb4z4uAfWbbEWrv42OBH8838SSPQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-rdma@vger.kernel.org, linux-block@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, haggaie@mellanox.com, Christoph Hellwig <hch@infradead.org>, Jens Axboe <axboe@fb.com>, Jonathan Corbet <corbet@lwn.net>, jim.macdonald@everspin.com, sbates@raithin.com, Logan Gunthorpe <logang@deltatee.com>

On Wed, Oct 19, 2016 at 10:50:25AM -0700, Dan Williams wrote:
> On Tue, Oct 18, 2016 at 2:42 PM, Stephen Bates <sbates@raithlin.com> wrote:
> > From: Logan Gunthorpe <logang@deltatee.com>
> >
> > We build on recent work that adds memory regions owned by a device
> > driver (ZONE_DEVICE) [1] and to add struct page support for these new
> > regions of memory [2].
> >
> > 1. Add an extra flags argument into dev_memremap_pages to take in a
> > MEMREMAP_XX argument. We update the existing calls to this function to
> > reflect the change.
> >
> > 2. For completeness, we add MEMREMAP_WT support to the memremap;
> > however we have no actual need for this functionality.
> >
> > 3. We add the static functions, add_zone_device_pages and
> > remove_zone_device pages. These are similar to arch_add_memory except
> > they don't create the memory mapping. We don't believe these need to be
> > made arch specific, but are open to other opinions.
> >
> > 4. dev_memremap_pages and devm_memremap_pages_release are updated to
> > treat IO memory slightly differently. For IO memory we use a combination
> > of the appropriate io_remap function and the zone_device pages functions
> > created above. A flags variable and kaddr pointer are added to struct
> > page_mem to facilitate this for the release function. We also set up
> > the page attribute tables for the mapped region correctly based on the
> > desired mapping.
> >
>
> This description says "what" is being done, but not "why".

Hi Dan

We discuss the motivation in the cover letter.

>
> In the cover letter, "[PATCH 0/3] iopmem : A block device for PCIe
> memory",  it mentions that the lack of I/O coherency is a known issue
> and users of this functionality need to be cognizant of the pitfalls.
> If that is the case why do we need support for different cpu mapping
> types than the default write-back cache setting?  It's up to the
> application to handle cache cpu flushing similar to what we require of
> device-dax users in the persistent memory case.

Some of the iopmem hardware we have tested has certain alignment
restrictions on BAR accesses. At the very least we require write
combine mappings for these. We then felt it appropriate to add the
other mappings for the sake of completeness.

Cheers

Stephen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
