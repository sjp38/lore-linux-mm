Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id D00EB6B0038
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 14:29:22 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id ey11so9822850pad.6
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 11:29:22 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id hb5si28770541pbb.186.2014.09.10.11.29.21
        for <linux-mm@kvack.org>;
        Wed, 10 Sep 2014 11:29:22 -0700 (PDT)
Message-ID: <54109845.3050309@intel.com>
Date: Wed, 10 Sep 2014 11:28:21 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/9] mm: Let sparse_{add,remove}_one_section receive a
 node_id
References: <1409173922-7484-1-git-send-email-ross.zwisler@linux.intel.com> <540F1EC6.4000504@plexistor.com> <540F20AB.4000404@plexistor.com> <540F48BA.2090304@intel.com> <541022DB.9090000@plexistor.com> <541077DF.1060609@intel.com> <5410899C.3030501@plexistor.com>
In-Reply-To: <5410899C.3030501@plexistor.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jens Axboe <axboe@fb.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-nvdimm@lists.01.org, Toshi Kani <toshi.kani@hp.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>

On 09/10/2014 10:25 AM, Boaz Harrosh wrote:
> Yes the block_allocator of the pmem-FS always holds the final REF on this
> page, as long as there is valid data on this block. Even cross boots, the
> mount code re-initializes references. The only internal state that frees
> these blocks is truncate, which only then return these pages to the block
> allocator, all this is common practice in filesystems so the page-ref on
> these blocks only ever drops to zero after they loose all visibility. And
> yes the block allocator uses a special code to drop the count to zero
> not using put_page().

OK, so what happens when a page is truncated out of a file and this
"last" block reference is dropped while a get_user_pages() still has a
reference?

> On 09/10/2014 07:10 PM, Dave Hansen wrote:
>> Does the fs support mmap()?
>>
> No!
> 
> Yes the FS supports mmap, but through the DAX patchset. Please see
> Matthew's DAX patchset how he implements mmap without using pages
> at all, direct PFN to virtual_addr. So these pages do not get exposed
> to the top of the FS.
> 
> My FS uses his technics exactly only when it wants to spill over to
> slower device it will use these pages copy-less.

>From my perspective, DAX is complicated, but it is necessary because we
don't have a 'struct page'.  You're saying that even if we pay the cost
of a 'struct page' for the memory, we still don't get the benefit of
having it like getting rid of this DAX stuff?

Also, about not having a zone for these pages.  Do you intend to support
32-bit systems?  If so, I believe you will require the kmap() family of
functions to map the pages in order to copy data in and out.  kmap()
currently requires knowing the zone of the page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
