Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f173.google.com (mail-yk0-f173.google.com [209.85.160.173])
	by kanga.kvack.org (Postfix) with ESMTP id B49276B0270
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 21:16:39 -0500 (EST)
Received: by ykdr82 with SMTP id r82so108835821ykd.3
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 18:16:39 -0800 (PST)
Received: from mail-yk0-x234.google.com (mail-yk0-x234.google.com. [2607:f8b0:4002:c07::234])
        by mx.google.com with ESMTPS id x4si6569637ywf.90.2015.12.03.18.16.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Dec 2015 18:16:38 -0800 (PST)
Received: by ykba77 with SMTP id a77so108905433ykb.2
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 18:16:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <565F6A7A.4040302@deltatee.com>
References: <20151010005522.17221.87557.stgit@dwillia2-desk3.jf.intel.com>
	<562AA15E.3010403@deltatee.com>
	<CAPcyv4gQ-8-tL-rhAPzPxKzBLmWKnFcqSFVy4KVOM56_9gn6RA@mail.gmail.com>
	<565F6A7A.4040302@deltatee.com>
Date: Thu, 3 Dec 2015 18:16:38 -0800
Message-ID: <CAPcyv4jjyzKgPMzdwms8xH-_RoKEGxRp1r4qxEcPYmPv7qStqw@mail.gmail.com>
Subject: Re: [PATCH v2 00/20] get_user_pages() for dax mappings
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Logan Gunthorpe <logang@deltatee.com>
Cc: "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, Stephen Bates <Stephen.Bates@pmcs.com>

On Wed, Dec 2, 2015 at 2:02 PM, Logan Gunthorpe <logang@deltatee.com> wrote:
> On 30/11/15 03:15 PM, Dan Williams wrote:
>>
>> I appreciate the test report.  I appreciate it so much I wonder if
>> you'd be willing to re-test the current state of:
>>
>> git://git.kernel.org/pub/scm/linux/kernel/git/djbw/nvdimm
>> libnvdimm-pending
>
>
>
> Hi Dan,
>
> I've had some mixed success with the above branch. Many of my tests are
> working but I have the following two issues which I didn't see previously:
>
> * When trying to do RDMA transfers to a mmaped DAX file I get a kernel panic
> while de-registering the memory region. (The panic message is at the end of
> this email.) addr2line puts it around dax.c:723 for the first line in the
> call trace, the address where the failure occurs doesn't seem to map to a
> line of code.
>
> * Less important: my tests no longer work inside qemu because I'm using a
> region in the PCI bar space which is not on a section boundary. The latest
> code enforces that restriction which makes it harder to use with PCI memory.
> (I'm talking memremap.c:311). Presently, if I comment out the check, my VM
> tests work fine. This hasn't been a problem on real hardware as we are using
> a 64bit address space and thus the BAR addresses are better aligned.
>

I could loosen the restriction a bit to allow one unaligned mapping
per section.  However, if another mapping request came along that
tried to map a free part of the section it would fail because the code
depends on a  "1 dev_pagemap per section" relationship.  Seems an ok
compromise to me...

> I don't have much time at the moment to dig into the kernel panic myself so
> hopefully what I've provided will help you find the issue. If you need any
> more information let me know.

Could you share the test setup for this one so I can try to reproduce?
 As far as I can see this looks like an ext4 internals issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
