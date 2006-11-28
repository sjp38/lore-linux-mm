Message-ID: <456C4A81.4080706@yahoo.com.au>
Date: Wed, 29 Nov 2006 01:41:05 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: The VFS cache is not freed when there is not enough free  memory
 to allocate
References: <6.1.1.1.0.20061128072553.01ed05e0@10.64.204.105>
In-Reply-To: <6.1.1.1.0.20061128072553.01ed05e0@10.64.204.105>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Getz <rgetz@blackfin.uclinux.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Robin Getz wrote:
> Nick wrote:
> 
>> And your patch is just a hack that happens to mask the issue in the 
>> case you tested, and it will probably blow up in production at some stage
> 
> 
> Ok - that would be bad - back to the drawing board.
> 
> Maybe we need to take a step back, and describe the original problem, 
> and someone can maybe point us in the correct direction, so we can 
> figure out the proper way to fix things.
> 
> As Aubrey stated:
> 
>> When there is no enough free memory, the kernel kprints an OOM, and 
>> kills the application, instead of freeing VFS cache, no matter how big 
>> the value of /proc/sys/vm/vfs_cache_pressure is set to.
> 
> 
> This seems to happen with application allocations as small as one page. 
> Larger allocations just make this happen faster.

It might be caused by the fact that nommu uses slab, which can perform
higher order allocations for the slab, even if the object is smaller
than a page. Maybe it could fall back to using the page allocator in
this case? I don't know if the slab API gives a way to prevent this
higher-order packing.

If you get this problem via an actual order-0 allocation, then there must
be some bug or genuine OOM condition.

> By doing a periodic "echo 3 > /proc/sys/vm/drop_caches" in a different 
> terminal, seems to make the problem go away.
> 
>  From what I understand, as documented in 
> ./Documentation/filesystem/proc.txt we should be able to control the 
> size of vfs cache, but it does not seem to work. vfs cache on noMMU 
> seems to grow, and grow, and grow, until a) you drop caches manually, or 
> b) the system does a OOM.
> 
> Any pointers to the correct place to start investigating this would be 
> appreciated.

The easiest might be to do it in kswapd, perhaps if kswapd_max_order is > 0,
and kswapd reclaim is unable to solve the shortage? This at least would get
you calling from a valid context, and so avoid deadlock problems of calling
drop_caches directly from the allocator.

Nick

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
