Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 18C006B0035
	for <linux-mm@kvack.org>; Sun, 14 Sep 2014 05:36:31 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id z10so4301903pdj.6
        for <linux-mm@kvack.org>; Sun, 14 Sep 2014 02:36:30 -0700 (PDT)
Received: from mail-pd0-x22a.google.com (mail-pd0-x22a.google.com [2607:f8b0:400e:c02::22a])
        by mx.google.com with ESMTPS id jd10si8320634pbd.104.2014.09.14.02.36.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 14 Sep 2014 02:36:29 -0700 (PDT)
Received: by mail-pd0-f170.google.com with SMTP id fp1so4302713pdb.1
        for <linux-mm@kvack.org>; Sun, 14 Sep 2014 02:36:29 -0700 (PDT)
Message-ID: <54156197.5050303@gmail.com>
Date: Sun, 14 Sep 2014 12:36:23 +0300
From: Boaz Harrosh <openosd@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/9] mm: Let sparse_{add,remove}_one_section receive a
 node_id
References: <1409173922-7484-1-git-send-email-ross.zwisler@linux.intel.com> <540F1EC6.4000504@plexistor.com> <540F20AB.4000404@plexistor.com> <540F48BA.2090304@intel.com> <541022DB.9090000@plexistor.com> <541077DF.1060609@intel.com> <5410899C.3030501@plexistor.com> <54109845.3050309@intel.com> <54115FAB.2050601@gmail.com> <5411D6D9.5080107@intel.com>
In-Reply-To: <5411D6D9.5080107@intel.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Boaz Harrosh <boaz@plexistor.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jens Axboe <axboe@fb.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-nvdimm@lists.01.org, Toshi Kani <toshi.kani@hp.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>

On 09/11/2014 08:07 PM, Dave Hansen wrote:
<>
> 
> OK, that sounds like it will work.  The "leaked until the next mount"
> sounds disastrous, but I'm sure you'll fix that.  I can see how it might
> lead to some fragmentation if only small amounts are ever pinned, but
> not a deal-breaker.
> 

There is no such thing as fragmentation with memory mapped storage ;-)

<>
> I'm saying that, if we have a 'struct page' for the memory, we should
> try to make the mmap()s more normal.  This enables all kinds of things
> that DAX does not support today, like direct I/O.
> 

What? no! direct I/O is fully supported. Including all API's of it. Do
you mean open(O_DIRECT) and io_submit(..) Yes it is fully supported.

In fact all IO is direct IO. there is never page-cache on the way, hence direct

BTW: These patches enable something else. Say FSA is DAX and FSB is regular
disk FS then
	fda = open(/mnt/FSA);
	pa = mmap(fda, ...);

	fdb = open(/mnt/FSB, O_DIRECT);
	io_submit(fdb,..,pa ,..);
	/* I mean pa is put for IO into the passed iocb for fdb */

Before this patch above will not work and revert to buffered IO, but
with these patches it will work.
Please note this is true for the submitted pmem driver. With brd which
also supports DAX this will work, because brd always uses pages.

<>
> Great, so we at least agree that this adds complexity.
> 

But the complexity is already there DAX by Matthew is to go in soon I hope.
Surly these added pages do not add to the complexity that much.

<>
> 
> OK, so I think I at least understand the scope of the patch set and the
> limitations.  I think I've summarized the limitations:
> 
> 1. Approach requires all of RAM+Pmem to be direct-mapped (rules out
>    almost all 32-bit systems, or any 64-bit systems with more than 64TB
>    of RAM+pmem-storage)

Yes, for NOW

> 2. Approach is currently incompatible with some kernel code that
>    requires a 'struct page' (such as direct I/O), and all kernel code
>    that requires knowledge of zones or NUMA nodes.

NO!
Direct IO - supported
NUMA - supported

"all kernel code that requires knowledge of zones" - Not needed

> 3. Approach requires 1/64 of the amount of storage to be consumed by
>    RAM for a pseudo 'struct page'.  If you had 64GB of storage and 1GB
>    of RAM, you would simply run our of RAM.
> 

Yes so in a system as above of 64GB of pmem, 1GB of pmem will need to be
set aside and hotpluged as volatile memory. This already works today BTW
you can set aside a portion of NvDIMM and hotplug it as system memory.

We are already used to pay that ratio for RAM.
On a kernel-config choice that ratio can be also paid for pmem. This is
why I left it a configuration option

> Did I miss any?
> 

Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
