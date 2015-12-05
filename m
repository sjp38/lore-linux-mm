Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id E49886B0258
	for <linux-mm@kvack.org>; Fri,  4 Dec 2015 20:58:47 -0500 (EST)
Received: by pacwq6 with SMTP id wq6so17740651pac.1
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 17:58:47 -0800 (PST)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id r191si23148504pfr.27.2015.12.04.17.58.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Dec 2015 17:58:46 -0800 (PST)
References: <20151010005522.17221.87557.stgit@dwillia2-desk3.jf.intel.com>
 <562AA15E.3010403@deltatee.com>
 <CAPcyv4gQ-8-tL-rhAPzPxKzBLmWKnFcqSFVy4KVOM56_9gn6RA@mail.gmail.com>
 <565F6A7A.4040302@deltatee.com>
 <CAPcyv4jjyzKgPMzdwms8xH-_RoKEGxRp1r4qxEcPYmPv7qStqw@mail.gmail.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <566244CC.5080107@deltatee.com>
Date: Fri, 4 Dec 2015 18:58:36 -0700
MIME-Version: 1.0
In-Reply-To: <CAPcyv4jjyzKgPMzdwms8xH-_RoKEGxRp1r4qxEcPYmPv7qStqw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH v2 00/20] get_user_pages() for dax mappings
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, Stephen Bates <Stephen.Bates@pmcs.com>

Hey,

On 03/12/15 07:16 PM, Dan Williams wrote:
> I could loosen the restriction a bit to allow one unaligned mapping
> per section.  However, if another mapping request came along that
> tried to map a free part of the section it would fail because the code
> depends on a  "1 dev_pagemap per section" relationship.  Seems an ok
> compromise to me...

Sure, that would work fine for us. I think it would be very unusual ;to 
need to map two adjacent BARs in this way.

> Could you share the test setup for this one so I can try to reproduce?
>   As far as I can see this looks like an ext4 internals issue.

Ok, well it's somewhat specialized and I can't run the failing test in a 
VM because it requires infiniband hardware. We have a PCI card that has 
a large memory backed BAR space. To use that with zone_device we have a 
kernel patch that allows doing the zone device mapping with io memory 
that has write combining enabled. Then we have an out of tree kernel 
module that creates a block device from the PCI bar (similar to the pmem 
code).

I could send you all of that, assuming you have a suitable PCI device. 
However, I'm hoping none of the above has anything to do with the failure.

The test that is failing is a very simple RDMA test with an mmaped DAX 
file. So hopefully it has nothing to do with the fact that a PCI device 
backs it. So if you have some IB hardware available you could try our 
simple test code from here:

https://github.com/sbates130272/io_peer_mem/tree/master/test

The server must be run with no arguments. Then the client can be run 
with the address of the server as the first argument and a file that's 
in a DAX fs (with a size greater than 4MB). The client and server should 
be able to run on the same node, if necessary.

Let me know if this helps or if there's anything else I can provide. I 
can probably dig into it some more on Monday on our setup.

Logan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
