Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id AB5A86B0038
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 06:07:31 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lj1so6185513pab.1
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 03:07:31 -0700 (PDT)
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
        by mx.google.com with ESMTPS id et5si26922678pbb.177.2014.09.10.03.07.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 03:07:30 -0700 (PDT)
Received: by mail-pd0-f172.google.com with SMTP id v10so12081719pde.3
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 03:07:30 -0700 (PDT)
Message-ID: <541022DB.9090000@plexistor.com>
Date: Wed, 10 Sep 2014 13:07:23 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/9] mm: Let sparse_{add,remove}_one_section receive a
 node_id
References: <1409173922-7484-1-git-send-email-ross.zwisler@linux.intel.com> <540F1EC6.4000504@plexistor.com> <540F20AB.4000404@plexistor.com> <540F48BA.2090304@intel.com>
In-Reply-To: <540F48BA.2090304@intel.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jens Axboe <axboe@fb.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-nvdimm@lists.01.org, Toshi Kani <toshi.kani@hp.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>

On 09/09/2014 09:36 PM, Dave Hansen wrote:
> On 09/09/2014 08:45 AM, Boaz Harrosh wrote:
>> This is for add_persistent_memory that will want a section of pages
>> allocated but without any zone associated. This is because belonging
>> to a zone will give the memory to the page allocators, but
>> persistent_memory belongs to a block device, and is not available for
>> regular volatile usage.
> 
> I don't think we should be taking patches like this in to the kernel
> until we've seen the other side of it.  Where is the page allocator code
> which will see a page belonging to no zone?  Am I missing it in this set?
> 

It is not missing. It will never be.

These pages do not belong to any allocator. They are not allocate-able
pages. In fact they are not "memory" they are "storage"

These pages belong wholesomely to a block-device. In turn the block
device grants ownership of a partition of this pages to an FS.
The FS loaded has its own block allocation schema. Which internally
circulate each pages usage around. But the page never goes beyond its
FS.

> I see about 80 or so calls to page_zone() in the kernel.  How will a
> zone-less page look to all of these sites?
> 

None of these 80 call site will be reached! the pages are always used
below the FS, like send them on the network, or send them to a slower
block device via a BIO. I have a full fledge FS on top of this code
and it all works very smoothly, and stable. (And fast ;))

It is up to the pMem-based FS to manage its pages's ref count so they are
never released outside of its own block allocator.

at the end of the day, struct pages has nothing to do with zones
and allocators and "memory", as it says in Documentation struct
page is a facility to track the state of a physical page in the
system. All the other structures are higher in the stack above
the physical layer, struct-pages for me are the upper API of the
memory physical layer. Which are in common with pmem, higher
on the stack where with memory we have a zone, pmem has a block-device.
Higher where we have page allocators, pmem has an FS block allocator,
higher where we have a slab, pmem has files for user consumption.

pmem is storage, which shares the physical layer with memory, and
this is what this patch describes. There will be no more mm interaction
at all for pmem. The rest of the picture is all there in plain site as
part of this patchset, the pmem.c driver then an FS on top of that. What
else do you need to see?

Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
