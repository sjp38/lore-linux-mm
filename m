Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f44.google.com (mail-vk0-f44.google.com [209.85.213.44])
	by kanga.kvack.org (Postfix) with ESMTP id 0848A6B0253
	for <linux-mm@kvack.org>; Mon, 17 Aug 2015 11:32:09 -0400 (EDT)
Received: by vkaw128 with SMTP id w128so25474277vka.1
        for <linux-mm@kvack.org>; Mon, 17 Aug 2015 08:32:08 -0700 (PDT)
Received: from mail-vk0-f53.google.com (mail-vk0-f53.google.com. [209.85.213.53])
        by mx.google.com with ESMTPS id j1si17440735vdb.97.2015.08.17.08.32.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Aug 2015 08:32:08 -0700 (PDT)
Received: by vkbf67 with SMTP id f67so55794852vkb.3
        for <linux-mm@kvack.org>; Mon, 17 Aug 2015 08:32:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150817150158.GB2625@lst.de>
References: <20150813031253.36913.29580.stgit@otcpl-skl-sds-2.jf.intel.com>
	<20150813035028.36913.25267.stgit@otcpl-skl-sds-2.jf.intel.com>
	<20150815090635.GF21033@lst.de>
	<CAPcyv4hMaRDOttcnvjq-aBXqgaPuB1d1XVi-dJFryC9pJ8PhMw@mail.gmail.com>
	<20150815155846.GA26248@lst.de>
	<CAPcyv4iN0BmipDfrsoCg2N2KnhX0+Hz2-ghr1i0H4US+bFe+Dw@mail.gmail.com>
	<20150817150158.GB2625@lst.de>
Date: Mon, 17 Aug 2015 08:32:07 -0700
Message-ID: <CAPcyv4i5K2_rVwSJFon6x=f+Rsfd-yfkp4ACeSWwJ5K0OXxRrA@mail.gmail.com>
Subject: Re: [RFC PATCH 5/7] libnvdimm, e820: make CONFIG_X86_PMEM_LEGACY a
 tristate option
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Boaz Harrosh <boaz@plexistor.com>, Rik van Riel <riel@redhat.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, david <david@fromorbit.com>, Ingo Molnar <mingo@kernel.org>, Linux MM <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>

On Mon, Aug 17, 2015 at 8:01 AM, Christoph Hellwig <hch@lst.de> wrote:
> On Sat, Aug 15, 2015 at 09:04:02AM -0700, Dan Williams wrote:
>> What other layer? /sys/devices/platform/e820_pmem is that exact same
>> device we had before this patch.  We just have a proper driver for it
>> now.
>
> We're adding another layer of indirection between the old e820 file
> and the new module.

Ok, yes, I was confused by "another layer of platform_devices".

That said here are the non-unit-test related reasons for this change
that I would include in a new changelog:

---

We currently register a platform device for e820 type-12 memory and
register a nvdimm bus beneath it.  Registering the platform device
triggers the device-core machinery to probe for a driver, but that
search currently comes up empty.  Building the nvdimm-bus registration
into the e820_pmem platform device registration in this way forces
libnvdimm to be built-in.  Instead, convert the built-in portion of
CONFIG_X86_PMEM_LEGACY to simply register a platform device and move
the rest of the logic to the driver for e820_pmem, for the following
reasons:

1/ Letting libnvdimm be a module allows building and testing
libnvdimm.ko changes without rebooting

2/ All the normal policy around modules can be applied to e820_pmem
(unbind to disable and/or blacklisting the module from loading by
default)

3/ Moving the driver to a generic location and converting it to scan
"iomem_resource" rather than "e820.map" means any other architecture
can take advantage of this simple nvdimm resource discovery mechanism
by registering a resource named "Persistent Memory (legacy)"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
