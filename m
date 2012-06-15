Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id E8BB86B0070
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 17:23:52 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so7090549pbb.14
        for <linux-mm@kvack.org>; Fri, 15 Jun 2012 14:23:52 -0700 (PDT)
Message-ID: <4FDBA7CC.6060407@vflare.org>
Date: Fri, 15 Jun 2012 14:23:24 -0700
From: Nitin Gupta <ngupta@vflare.org>
MIME-Version: 1.0
Subject: Re: [PATCH v2 3/3] x86: Support local_flush_tlb_kernel_range
References: <1337133919-4182-1-git-send-email-minchan@kernel.org> <1337133919-4182-3-git-send-email-minchan@kernel.org> <4FB4B29C.4010908@kernel.org> <1337266310.4281.30.camel@twins> <4FDB5107.3000308@linux.vnet.ibm.com> <7e925563-082b-468f-a7d8-829e819eeac0@default> <4FDB66B7.2010803@vflare.org> <10ea9d19-bd24-400c-8131-49f0b4e9e5ae@default> <4FDB8808.9010508@linux.vnet.ibm.com> <9c6c8ae0-0212-402d-a906-0d0c61e5e058@default> <4FDB92CF.1070603@vflare.org> <4ffbc3e8-900b-4669-b6ab-e8c066f28c63@default>
In-Reply-To: <4ffbc3e8-900b-4669-b6ab-e8c066f28c63@default>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Tejun Heo <tj@kernel.org>, David Howells <dhowells@redhat.com>, x86@kernel.org, Nick Piggin <npiggin@gmail.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>

On 06/15/2012 01:13 PM, Dan Magenheimer wrote:
>> From: Nitin Gupta [mailto:ngupta@vflare.org]
>> Subject: Re: [PATCH v2 3/3] x86: Support local_flush_tlb_kernel_range
>>
>> On 06/15/2012 12:39 PM, Dan Magenheimer wrote:
>>>> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
>>>>> The decompression path calls lzo1x directly and it would be
>>>>> a huge pain to make lzo1x smart about page boundaries.  BUT
>>>>> since we know that the decompressed result will always fit
>>>>> into a page (actually exactly a page), you COULD do an extra
>>>>> copy to the end of the target page (using the same smart-
>>>>> about-page-boundaries copying code from above) and then do
>>>>> in-place decompression, knowing that the decompression will
>>>>> not cross a page boundary.  So, with the extra copy, the "pair
>>>>> mapping" can be avoided for decompression as well.
>>>>
>>>> This is an interesting thought.
>>>>
>>>> But this does result in a copy in the decompression (i.e. page fault)
>>>> path, where right now, it is copy free.  The compressed data is
>>>> decompressed directly from its zsmalloc allocation to the page allocated
>>>> in the fault path.
>>>
>>> The page fault occurs as soon as the lzo1x compression code starts anyway,
>>> as do all the cache faults... both just occur earlier, so the only
>>> additional cost is the actual cpu instructions to move the sequence of
>>> (compressed) bytes from the zsmalloc-allocated area to the end
>>> of the target page.
>>>
>>> TLB operations can be very expensive, not to mention (as the
>>> subject of this thread attests) non-portable.
>>
>> Even if you go for copying chunks followed by decompression, it still
>> requires two kmaps and kunmaps. Each of these require one local TLB
>> invlpg. So, a total of 2 local maps + unmaps even with this approach.
> 
> That may be true for i386, but on a modern (non-highmem) machine those
> kmaps/kunmaps are free and "pair mappings" in the TLB are still expensive
> and not very portable.  Doesn't make sense to me to design for better
> performance on highmem and poorer performance on non-highmem.
>  

True, but it seem hard to believe that mapping+unmappig+two local TLB
invlpg's will be more costly than copying, on average, PAGE_SIZE/2 data.

Anyways, I just looked up the LZO documentation and it supposedly allows
in place decompression (hopefully we didn't mess up this feature during
kernel port). Considering cache effects, this may really make copying
overhead much less than expected.  Additionally, in case we go for
copying approach, we can further simplify compaction since any client
can never directly reference pool memory.


>> The only additional requirement of zsmalloc is that it requires two
>> mappings which are virtually contiguous. The cost is the same in both
>> approaches but the current zsmalloc approach presents a much cleaner
>> interface.
> 
> OK, it's your code and I'm just making a suggestion. I will shut up now ;-)
> 

I'm always glad to hear your opinions and was just trying to discuss the
points you raised. I apologize if I sounded rude.

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
