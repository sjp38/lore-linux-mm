Message-ID: <3D08C984.3010308@shaolinmicro.com>
Date: Fri, 14 Jun 2002 00:34:12 +0800
From: David Chow <davidchow@shaolinmicro.com>
MIME-Version: 1.0
Subject: Re: slab cache
References: <3D036BBE.4030603@shaolinmicro.com> <20020610095750.B2571@redhat.com> <3D076339.1070301@shaolinmicro.com> <20020612162941.M12834@redhat.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Stephen C. Tweedie wrote:

>Hi,
>
>On Wed, Jun 12, 2002 at 11:05:29PM +0800, David Chow wrote:
>
>>>Using 4k buffers does not limit your ability to use larger data
>>>structures --- you can still chain 4k buffers together by creating an
>>>array of struct page* pointers via which you can access the data.
>>>
>
>>Yes, but for me it is very hard. When doing compression code, most of 
>>the stuff is not even byte aligned, most of them might be bitwise 
>>operated, it need very change to existing code. 
>>
>
>Perhaps, but the VM basically doesn't give you any primitives that you
>can use for arbitrarily large chunks of linear data; things like
>vmalloc are limited in the amount of data they can use, total, and it
>is _slow_ to set up and tear down vmalloc mappings.
>
>>get_free_page to allocate memory that is 4k to avoid some stress to the 
>>vm, I have no idea about the difference of get_fee_page and the slab 
>>cache. All my linear buffers stuff is already using array of page 
>>pointers, if there any benefits for changing them to use slabcache? 
>>Please advice, thanks.
>>
>
>It might be if you are allocating and deallocating large numbers of
>them in bunches, since the slab cache can then keep a few pages cached
>for immediate reuse rather than going to the global page allocator for
>every single page.  The per-cpu slab stuff would also help to keep the
>pages concerned hot in the cache of the local cpu, and that is likely
>to be a big performance improvement in some cases.
>
>--Stephen
>

Thanks for comment, since you mention about cache, do you mean CPU L2 
caches? I don't use to dynamic alloc and dealloc pages, I have a fixed 
sized cache per CPU, even using vmalloc I will only do it only once 
during module initialize, and dealloc only on unload, so the performance 
about allocation does not matter me, but it would be interesting to do 
something to keep those allocations higher chance to cached by the CPU's 
L2 cache. I experience 512K cache CPU's are lot faster .

-- David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
