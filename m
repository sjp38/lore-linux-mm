Message-ID: <417FC5CB.9040204@pobox.com>
Date: Wed, 27 Oct 2004 11:59:07 -0400
From: Jeff Garzik <jgarzik@pobox.com>
MIME-Version: 1.0
Subject: Re: news about IDE PIO HIGHMEM bug (was: Re: 2.6.9-mm1)
References: <58cb370e041027074676750027@mail.gmail.com> <417FBB6D.90401@pobox.com> <1246230000.1098892359@[10.10.2.4]>
In-Reply-To: <1246230000.1098892359@[10.10.2.4]>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, "Randy.Dunlap" <rddunlap@osdl.org>, William Lee Irwin III <wli@holomorphy.com>, Jens Axboe <axboe@suse.de>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

Martin J. Bligh wrote:
>>Bartlomiej Zolnierkiewicz wrote:
>>
>>>We have stuct page of the first page and a offset.
>>>We need to obtain struct page of the current page and map it.
>>
>>
>>Opening this question to a wider audience.
>>
>>struct scatterlist gives us struct page*, and an offset+length pair. The struct page* is the _starting_ page of a potentially multi-page run of data.
>>
>>The question:  how does one get struct page* for the second, and successive pages in a known-contiguous multi-page run, if one only knows the first page?
> 
> 
> If it's a higher order allocation, just page+1 should be safe. If it just
> happens to be contig, it might cross a discontig boundary, and not obey
> that rule. Very unlikely, but possible.


Unfortunately, it's not.

The block layer just tells us "it's a contiguous run of memory", which 
implies nothing really about the allocation size.

Bart and I (and others?) essentially need a "page+1" thing (for 2.4.x 
too!), that won't break in the face of NUMA/etc.

Alternatively (or additionally), we may need to make sure the block 
layer doesn't merge across zones or NUMA boundaries or whatnot.

	Jeff


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
