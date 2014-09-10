Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 2CF9E6B0036
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 12:11:02 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id kx10so8006995pab.3
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 09:11:01 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id es4si28244031pbb.195.2014.09.10.09.11.00
        for <linux-mm@kvack.org>;
        Wed, 10 Sep 2014 09:11:01 -0700 (PDT)
Message-ID: <541077DF.1060609@intel.com>
Date: Wed, 10 Sep 2014 09:10:07 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/9] mm: Let sparse_{add,remove}_one_section receive a
 node_id
References: <1409173922-7484-1-git-send-email-ross.zwisler@linux.intel.com> <540F1EC6.4000504@plexistor.com> <540F20AB.4000404@plexistor.com> <540F48BA.2090304@intel.com> <541022DB.9090000@plexistor.com>
In-Reply-To: <541022DB.9090000@plexistor.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jens Axboe <axboe@fb.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-nvdimm@lists.01.org, Toshi Kani <toshi.kani@hp.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>

On 09/10/2014 03:07 AM, Boaz Harrosh wrote:
> On 09/09/2014 09:36 PM, Dave Hansen wrote:
>> On 09/09/2014 08:45 AM, Boaz Harrosh wrote:
>>> This is for add_persistent_memory that will want a section of pages
>>> allocated but without any zone associated. This is because belonging
>>> to a zone will give the memory to the page allocators, but
>>> persistent_memory belongs to a block device, and is not available for
>>> regular volatile usage.
>>
>> I don't think we should be taking patches like this in to the kernel
>> until we've seen the other side of it.  Where is the page allocator code
>> which will see a page belonging to no zone?  Am I missing it in this set?
> 
> It is not missing. It will never be.
> 
> These pages do not belong to any allocator. They are not allocate-able
> pages. In fact they are not "memory" they are "storage"
> 
> These pages belong wholesomely to a block-device. In turn the block
> device grants ownership of a partition of this pages to an FS.
> The FS loaded has its own block allocation schema. Which internally
> circulate each pages usage around. But the page never goes beyond its
> FS.

I'm mostly worried about things that start with an mmap().

Imagine you mmap() a persistent memory file, fault some pages in, then
'cat /proc/$pid/numa_maps'.  That code will look at the page to see
which zone and node it is in.

Or, consider if you mmap() then put a futex in the page.  The page will
have get_user_pages() called on it by the futex code, and a reference
taken.  The reference can outlast the mmap().  We either have to put the
file somewhere special and scan the page's reference occasionally, or we
need to hook something under put_page() to make sure that we keep the
page out of the normal allocator.

>> I see about 80 or so calls to page_zone() in the kernel.  How will a
>> zone-less page look to all of these sites?
> 
> None of these 80 call site will be reached! the pages are always used
> below the FS, like send them on the network, or send them to a slower
> block device via a BIO. I have a full fledge FS on top of this code
> and it all works very smoothly, and stable. (And fast ;))

Does the fs support mmap()?

The idea of layering is a nice one, but mmap() is a big fat layering
violation. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
