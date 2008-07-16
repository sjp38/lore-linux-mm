Message-ID: <487E628A.3050207@redhat.com>
Date: Wed, 16 Jul 2008 17:05:14 -0400
From: Chris Snook <csnook@redhat.com>
MIME-Version: 1.0
Subject: Re: madvise(2) MADV_SEQUENTIAL behavior
References: <1216163022.3443.156.camel@zenigma>	<1216210495.5232.47.camel@twins> <20080716105025.2daf5db2@cuia.bos.redhat.com>
In-Reply-To: <20080716105025.2daf5db2@cuia.bos.redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Eric Rannaud <eric.rannaud@gmail.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> On Wed, 16 Jul 2008 14:14:55 +0200
> Peter Zijlstra <peterz@infradead.org> wrote:
> 
>> On Tue, 2008-07-15 at 23:03 +0000, Eric Rannaud wrote:
>>> mm/madvise.c and madvise(2) say:
>>>
>>>  *  MADV_SEQUENTIAL - pages in the given range will probably be accessed
>>>  *		once, so they can be aggressively read ahead, and
>>>  *		can be freed soon after they are accessed.
>>>
>>>
>>> But as the sample program at the end of this post shows, and as I
>>> understand the code in mm/filemap.c, MADV_SEQUENTIAL will only increase
>>> the amount of read ahead for the specified page range, but will not
>>> influence the rate at which the pages just read will be freed from
>>> memory.
>> Correct, various attempts have been made to actually implement this, but
>> non made it through.
>>
>> My last attempt was:
>>   http://lkml.org/lkml/2007/7/21/219
>>
>> Rik recently tried something else based on his split-lru series:
>>   http://lkml.org/lkml/2008/7/15/465
> 
> M patch is not going to help with mmap, though.
> 
> I believe that for mmap MADV_SEQUENTIAL, we will have to do
> an unmap-behind from the fault path.  Not every time, but
> maybe once per megabyte, unmapping the megabyte behind us.
> 
> That way the normal page cache policies (use once, etc) can
> take care of page eviction, which should help if the file
> is also in use by another process.
> 

Wouldn't it just be easier to not move pages to the active list when 
they're referenced via an MADV_SEQUENTIAL mapping?  If we keep them on 
the inactive list, they'll be candidates for reclaiming, but they'll 
still be in pagecache when another task scans through, as long as we're 
not under memory pressure.

-- Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
