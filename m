Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 675636B00CA
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 17:23:44 -0400 (EDT)
Received: by pzk36 with SMTP id 36so1864342pzk.12
        for <linux-mm@kvack.org>; Tue, 25 Aug 2009 14:23:45 -0700 (PDT)
Message-ID: <4A93033B.3050606@vflare.org>
Date: Tue, 25 Aug 2009 02:46:43 +0530
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] compcache: xvmalloc memory allocator
References: <200908241007.47910.ngupta@vflare.org>	 <84144f020908241033l4af09e7h9caac47d8d9b7841@mail.gmail.com>	 <4A92EBB4.1070101@vflare.org> <84144f020908241243y11f10e8eudc758b61527e0e9c@mail.gmail.com>
In-Reply-To: <84144f020908241243y11f10e8eudc758b61527e0e9c@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mm-cc@laptop.org
List-ID: <linux-mm.kvack.org>

On 08/25/2009 01:13 AM, Pekka Enberg wrote:
> On Mon, Aug 24, 2009 at 10:36 PM, Nitin Gupta<ngupta@vflare.org>  wrote:
>> On 08/24/2009 11:03 PM, Pekka Enberg wrote:
>>
>> <snip>
>>
>>> On Mon, Aug 24, 2009 at 7:37 AM, Nitin Gupta<ngupta@vflare.org>    wrote:
>>>>
>>>> +/**
>>>> + * xv_malloc - Allocate block of given size from pool.
>>>> + * @pool: pool to allocate from
>>>> + * @size: size of block to allocate
>>>> + * @pagenum: page no. that holds the object
>>>> + * @offset: location of object within pagenum
>>>> + *
>>>> + * On success,<pagenum, offset>    identifies block allocated
>>>> + * and 0 is returned. On failure,<pagenum, offset>    is set to
>>>> + * 0 and -ENOMEM is returned.
>>>> + *
>>>> + * Allocation requests with size>    XV_MAX_ALLOC_SIZE will fail.
>>>> + */
>>>> +int xv_malloc(struct xv_pool *pool, u32 size, u32 *pagenum, u32 *offset,
>>>> +                                                       gfp_t flags)
>>
>> <snip>
>>
>>>
>>> What's the purpose of passing PFNs around? There's quite a lot of PFN
>>> to struct page conversion going on because of it. Wouldn't it make
>>> more sense to return (and pass) a pointer to struct page instead?
>>
>> PFNs are 32-bit on all archs while for 'struct page *', we require 32-bit or
>> 64-bit depending on arch. ramzswap allocates a table entry<pagenum, offset>
>> corresponding to every swap slot. So, the size of table will unnecessarily
>> increase on 64-bit archs. Same is the argument for xvmalloc free list sizes.
>>
>> Also, xvmalloc and ramzswap itself does PFN ->  'struct page *' conversion
>> only when freeing the page or to get a deferencable pointer.
>
> I still don't see why the APIs have work on PFNs. You can obviously do
> the conversion once for store and load. Look at what the code does,
> it's converting struct page to PFN just to do the reverse for kmap().
> I think that could be cleaned by passing struct page around.
>


* Allocator side:
Since allocator stores PFN in internal freelists, so all internal routines
naturally use PFN instead of struct page (try changing them all to use struct
page instead to see the mess it will create). So, kmap will still end up doing
PFN -> struct page conversion since we just pass around PFNs.

What if we convert only the interfaces: xv_malloc() and xv_free()
to use struct page:
  - xv_malloc(): we will not save any PFN -> struct page conversion as we simply
move it from kmap wrapper to futher up in alloc routine.
  - xv_free(): same as above; we now move it down the function to pass to
internal routines


* ramzswap block driver side:
ramzswap also stores PFNs in swap slot table. Thus, due to reasons same as
above, number of conversions will not reduce.


Now, if code cleanup is the aim rather that reducing the no. of conversions,
then I think use of PFNs is still preferred due to minor implementation details
mentioned above.

So, I think the interface should be left in its current state.

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
