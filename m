Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 27BD26B009B
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 13:08:06 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id ft15so11617338pdb.11
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 10:08:05 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id mb10si2674003pdb.251.2014.09.11.10.08.04
        for <linux-mm@kvack.org>;
        Thu, 11 Sep 2014 10:08:04 -0700 (PDT)
Message-ID: <5411D6D9.5080107@intel.com>
Date: Thu, 11 Sep 2014 10:07:37 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/9] mm: Let sparse_{add,remove}_one_section receive a
 node_id
References: <1409173922-7484-1-git-send-email-ross.zwisler@linux.intel.com> <540F1EC6.4000504@plexistor.com> <540F20AB.4000404@plexistor.com> <540F48BA.2090304@intel.com> <541022DB.9090000@plexistor.com> <541077DF.1060609@intel.com> <5410899C.3030501@plexistor.com> <54109845.3050309@intel.com> <54115FAB.2050601@gmail.com>
In-Reply-To: <54115FAB.2050601@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <openosd@gmail.com>, Boaz Harrosh <boaz@plexistor.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jens Axboe <axboe@fb.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-nvdimm@lists.01.org, Toshi Kani <toshi.kani@hp.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>

On 09/11/2014 01:39 AM, Boaz Harrosh wrote:
> On 09/10/2014 09:28 PM, Dave Hansen wrote:
>> OK, so what happens when a page is truncated out of a file and this
>> "last" block reference is dropped while a get_user_pages() still has a
>> reference?
> 
> I have a very simple plan for this scenario, as I said, hang these pages
> with ref!=1 on a garbage list, and one of the clear threads can scan them
> periodically and release them.
> 
> I have this test in place, currently what I do is just drop the block
> and let it leak (that is, not be used any more) until a next mount where
> this will be returned to free store. Yes stupid I know. But I have a big
> fat message when this happens and I have not been able to reproduce it.
> So I'm still waiting for this test case, I guess DAX protects me.

OK, that sounds like it will work.  The "leaked until the next mount"
sounds disastrous, but I'm sure you'll fix that.  I can see how it might
lead to some fragmentation if only small amounts are ever pinned, but
not a deal-breaker.

>> From my perspective, DAX is complicated, but it is necessary because we
>> don't have a 'struct page'.  You're saying that even if we pay the cost
>> of a 'struct page' for the memory, we still don't get the benefit of
>> having it like getting rid of this DAX stuff?
> 
> No DAX is still necessary because we map storage directly to app space,
> and we still need it persistent. That is we can-not/need-not use an
> in-ram radix tree but directly use on-storage btrees.

Huh?  We obviously don't need/want persistent memory pages in the page
*cache*.  But, that's completely orthogonal to _having_ a 'struct page'
for them.

DAX does two major things:
1. avoids needing the page cache
2. creates "raw" page table entries that the VM does not manage
   for mmap()s

I'm not saying to put persistent memory in the page cache.

I'm saying that, if we have a 'struct page' for the memory, we should
try to make the mmap()s more normal.  This enables all kinds of things
that DAX does not support today, like direct I/O.

> Life is hard and we do need the two models all at the same time, to support
> all these different devices. So yes the complexity is added with the added
> choice. But please do not confuse, DAX is not the complicated part. Having
> a Choice is.

Great, so we at least agree that this adds complexity.

>> Also, about not having a zone for these pages.  Do you intend to support
>> 32-bit systems?  If so, I believe you will require the kmap() family of
>> functions to map the pages in order to copy data in and out.  kmap()
>> currently requires knowing the zone of the page.
> 
> No!!! This is strictly 64 bit. A 32bit system is able to have at maximum
> 3Gb of low-ram + storage.
> DAX implies always mapped. That is, no re-mapping. So this rules out
> more then a G of storage. Since that is a joke then No! 32bit is out.
> 
> You need to understand current HW std talks about DDR4 and there are
> DDR3 samples flouting around. So this is strictly 64bit, even on
> phones.

OK, so I think I at least understand the scope of the patch set and the
limitations.  I think I've summarized the limitations:

1. Approach requires all of RAM+Pmem to be direct-mapped (rules out
   almost all 32-bit systems, or any 64-bit systems with more than 64TB
   of RAM+pmem-storage)
2. Approach is currently incompatible with some kernel code that
   requires a 'struct page' (such as direct I/O), and all kernel code
   that requires knowledge of zones or NUMA nodes.
3. Approach requires 1/64 of the amount of storage to be consumed by
   RAM for a pseudo 'struct page'.  If you had 64GB of storage and 1GB
   of RAM, you would simply run our of RAM.

Did I miss any?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
