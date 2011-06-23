Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 799C2900194
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 18:00:04 -0400 (EDT)
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p5NLm8Fm006727
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 17:48:08 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5NLxvCM721070
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 18:00:02 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5NLxvnD016089
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 17:59:57 -0400
Message-ID: <4E03B75A.9040203@linux.vnet.ibm.com>
Date: Thu, 23 Jun 2011 16:59:54 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: frontswap/zcache: xvmalloc discussion
References: <4E023F61.8080904@linux.vnet.ibm.com> <0a3a5959-5d8f-4f62-a879-34266922c59f@default>
In-Reply-To: <0a3a5959-5d8f-4f62-a879-34266922c59f@default>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-mm <linux-mm@kvack.org>, Nitin Gupta <ngupta@vflare.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Brian King <brking@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@suse.de>

On 06/23/2011 11:38 AM, Dan Magenheimer wrote:
>> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
>> Cc: Dan Magenheimer; Nitin Gupta; Robert Jennings; Brian King; Greg Kroah-Hartman
>> Subject: frontswap/zcache: xvmalloc discussion
>>
>> Dan, Nitin,
> 
> Hi Seth --
> 
> Thanks for your interest in frontswap and zcache!

Thanks for your quick response!

> 
>> I have been experimenting with the frontswap v4 patches and the latest
>> zcache in the mainline drivers/staging.  There is a particular issue I'm
>> seeing when using pages of different compressibilities.
>>
>> When the pages compress to less than PAGE_SIZE/2, I get good compression
>> and little external fragmentation in the xvmalloc pool.  However, when
>> the pages have a compressed size greater than PAGE_SIZE/2, it is a very
>> different story.  Basically, because xvmalloc allocations can't span
>> multiple pool pages, grow_pool() is called on each allocation, reducing
>> the effective compression (total_pages_in_frontswap /
>> total_pages_in_xvmalloc_pool) to 0 and drastically increasing external
>> fragmentation to up to 50%.
>>
>> The likelihood that the size of a compressed page is greater than
>> PAGE_SIZE/2 is high, considering that lzo1x-1 sacrifices compressibility
>> for speed.  In my experiments, pages of English text only compressed to
>> 75% of their original size with 1zo1x-1.
> 
> Wow, I'm surprised to hear that.  I suppose it is very workload
> dependent, but I agree that consistently poor compression can create
> issues for frontswap.
>
 
Yes, I was surprised as well with how little it compressed.  I guess I'm 
used to gzip level compression, which was around 50% on the same data set.

>> In order to calculate the effective compression of frontswap, you need
>> the number of pages stored by frontswap, provided by frontswap's
>> curr_pages sysfs attribute, and the number of pages in the xvmalloc
>> pool.  There isn't a sysfs attribute for this, so I made a patch that
>> creates a new zv_pool_pages_count attribute for zcache that provides
>> this value (patch is in a follow-up message).  I have also included my
>> simple test program at the end of this email.  It just allocates and
>> stores random pages of from a text file (in my case, a text file of Moby
>> Dick).
>>
>> The real problem here is compressing pages of size x and storing them in
>> a pool that has "chunks", if you will, also of size x, where allocations
>> can't span multiple chunks.  Ideally, I'd like to address this issue by
>> expanding the size of the xvmalloc pool chunks from one page to four
>> pages (I can explain why four is a good number, just didn't want to make
>> this note too long).
> 
> Nitin is the expert on compression and xvmalloc... I mostly built on top
> of his earlier work... so I will wait for him to comment on compression
> and xvmalloc issues.
>

Yes, I do need Nitin to weigh in on this since any changes to the xvmalloc
code would impact zcache and zram.
 
> BUT... I'd be concerned with increasing the pool chunk, at least without
> a fallback.  When memory is constrained, finding chunks in the kernel
> of even two consecutive pages might be a challenge, let alone four.
> Since frontswap only is invoked if swapping is occurring, memory
> is definitely already constrained.
> 
> If it is possible to modify xvmalloc (or possibly the pool creation
> calls from zcache) to juggle multiple pools, one with chunkorder==2,
> one with chunkorder==1, and one with chunkorder=0, with a fallback
> sequence if a higher chunkorder is not available, might that be
> helpful?  Still I worry that the same problems might occur because
> the higher chunkorders might never be available after some time
> passes.
>

To avoid the problem with getting one large set (up to 4 pages) of 
contiguous space, I'm looking into using vm_map_ram() to map
chunks that are multiple noncontiguous pages into a single contiguous 
address space.  I don't know what the overhead is yet.

I do like the idea of having a few pools with different chunk sizes.
 
>> After a little playing around, I've found this isn't entirely trivial to
>> do because of the memory mapping implications; more specifically the use
>> of kmap/kunamp in the xvmalloc and zcache layers.  I've looked into
>> using vmap to map multiple pages into a linear address space, but it
>> seems like there is a lot of memory overhead in doing that.
>>
>> Do you have any feedback on this issue or suggestion solution?
> 
> One neat feature of frontswap (and the underlying Transcendent
> Memory definition) is that ANY PUT may be rejected**.  So zcache
> could keep track of the distribution of "zsize" and if the number
> of pages with zsize>PAGE_SIZE/2 greatly exceeds the number of pages
> with "complementary zsize", the frontswap code in zcache can reject
> the larger pages until balance/sanity is restored.
> 
> Might that help?  

We could do that, but I imagine that would let a lot of pages through 
on most workloads.  Ideally, I'd like to find a solution that would
capture and (efficiently) store pages that compressed to up to 80% of 
their original size.

> If so, maybe your new sysfs value could be
> replaced with the ratio (zv_pool_pages_count/frontswap_curr_pages)
> and this could be _writeable_ to allow the above policy target to
> be modified at runtime.   Even better, the fraction could be
> represented by number-of-bytes ("target_zsize"), which could default
> to something like (3*PAGE_SIZE)/4... if the ratio above
> exceeds target_zsize and the zsize of the page-being-put exceeds
> target_zsize, then the put is rejected.
> 
> Thanks,
> Dan
> 
> ** The "put" shouldn't actually be rejected outright... it should
> be converted to a "flush" so that, if a previous put was
> performed for the matching handle, the space can be reclaimed.
> (Let me know if you need more explanation of this.)

Thanks again for your reply, Dan.  I'll explore this more next week.

--
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
