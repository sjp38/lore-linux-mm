Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 5A06B6B022C
	for <linux-mm@kvack.org>; Sat, 24 Apr 2010 14:22:20 -0400 (EDT)
Message-ID: <4BD336CF.1000103@redhat.com>
Date: Sat, 24 Apr 2010 21:22:07 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: Frontswap [PATCH 0/4] (was Transcendent Memory): overview
References: <20100422134249.GA2963@ca-server1.us.oracle.com> <4BD06B31.9050306@redhat.com> <53c81c97-b30f-4081-91a1-7cef1879c6fa@default> <4BD07594.9080905@redhat.com> <b1036777-129b-4531-a730-1e9e5a87cea9@default> <4BD16D09.2030803@redhat.com> <b01d7882-1a72-4ba9-8f46-ba539b668f56@default> <4BD1A74A.2050003@redhat.com> <4830bd20-77b7-46c8-994b-8b4fa9a79d27@default 4BD1B427.9010905@redhat.com> <b559c57a-0acb-4338-af21-dbfc3b3c0de5@default>
In-Reply-To: <b559c57a-0acb-4338-af21-dbfc3b3c0de5@default>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hugh.dickins@tiscali.co.uk, ngupta@vflare.org, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On 04/23/2010 06:56 PM, Dan Magenheimer wrote:
>>> Each page is either in frontswap OR on the normal swap device,
>>> never both.  So, yes, both reads and writes are avoided if memory
>>> is available and there is no write issued to the io subsystem if
>>> memory is available.  The is_memory_available decision is determined
>>> by the hypervisor dynamically for each page when the guest attempts
>>> a "frontswap_put".  So, yes, you are indeed "swapping to the
>>> hypervisor" but, at least in the case of Xen, the hypervisor
>>> never swaps any memory to disk so there is never double swapping.
>>>        
>> I see.  So why not implement this as an ordinary swap device, with a
>> higher priority than the disk device?  this way we reuse an API and
>> keep
>> things asynchronous, instead of introducing a special purpose API.
>>      
> Because the swapping API doesn't adapt well to dynamic changes in
> the size and availability of the underlying "swap" device, which
> is very useful for swap to (bare-metal) hypervisor.
>    

Can we extend it?  Adding new APIs is easy, but harder to maintain in 
the long term.

>> Doesn't this commit the hypervisor to retain this memory?  If so, isn't
>> it simpler to give the page to the guest (so now it doesn't need to
>> swap at all)?
>>      
> Yes the hypervisor is committed to retain the memory.  In
> some ways, giving a page of memory to a guest (via ballooning)
> is simpler and in some ways not.  When a guest "owns" a page,
> it can do whatever it wants with it, independent of what is best
> for the "whole" virtualized system.  When the hypervisor
> "owns" the page on behalf of the guest but the guest can't
> directly address it, the hypervisor has more flexibility.
> For example, tmem optionally compresses all frontswap pages,
> effectively doubling the size of its available memory.
> In the future, knowing that a guest application can never
> access the pages directly, it might store all frontswap pages in
> (slower but still synchronous) phase change memory or "far NUMA"
> memory.
>    

Ok.  For non traditional RAM uses I really think an async API is 
needed.  If the API is backed by a cpu synchronous operation is fine, 
but once it isn't RAM, it can be all kinds of interesting things.

Note that even if you do give the page to the guest, you still control 
how it can access it, through the page tables.  So for example you can 
easily compress a guest's pages without telling it about it; whenever it 
touches them you decompress them on the fly.

>> I think it will be true in an overwhelming number of cases.  Flash is
>> new enough that most devices support scatter/gather.
>>      
> I wasn't referring to hardware capability but to the availability
> and timing constraints of the pages that need to be swapped.
>    

I have a feeling we're talking past each other here.  Swap has no timing 
constraints, it is asynchronous and usually to slow devices.


-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
