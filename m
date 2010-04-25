Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 84FEF6B0234
	for <linux-mm@kvack.org>; Sat, 24 Apr 2010 23:14:16 -0400 (EDT)
Received: by pvf33 with SMTP id 33so368454pvf.14
        for <linux-mm@kvack.org>; Sat, 24 Apr 2010 20:14:15 -0700 (PDT)
Message-ID: <4BD3B2D1.8080203@vflare.org>
Date: Sun, 25 Apr 2010 08:41:13 +0530
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
MIME-Version: 1.0
Subject: Re: Frontswap [PATCH 0/4] (was Transcendent Memory): overview
References: <20100422134249.GA2963@ca-server1.us.oracle.com> <4BD06B31.9050306@redhat.com> <53c81c97-b30f-4081-91a1-7cef1879c6fa@default> <4BD07594.9080905@redhat.com> <b1036777-129b-4531-a730-1e9e5a87cea9@default> <4BD16D09.2030803@redhat.com> <b01d7882-1a72-4ba9-8f46-ba539b668f56@default 4BD1A74A.2050003@redhat.com> <4830bd20-77b7-46c8-994b-8b4fa9a79d27@default> <4BD1B427.9010905@redhat.com> <4BD24E37.30204@vflare.org> <4BD33822.2000604@redhat.com>
In-Reply-To: <4BD33822.2000604@redhat.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hugh.dickins@tiscali.co.uk, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On 04/24/2010 11:57 PM, Avi Kivity wrote:
> On 04/24/2010 04:49 AM, Nitin Gupta wrote:
>>
>>> I see.  So why not implement this as an ordinary swap device, with a
>>> higher priority than the disk device?  this way we reuse an API and keep
>>> things asynchronous, instead of introducing a special purpose API.
>>>
>>>      
>> ramzswap is exactly this: an ordinary swap device which stores every page
>> in (compressed) memory and its enabled as highest priority swap.
>> Currently,
>> it stores these compressed chunks in guest memory itself but it is not
>> very
>> difficult to send these chunks out to host/hypervisor using virtio.
>>
>> However, it suffers from unnecessary block I/O layer overhead and
>> requires
>> weird hooks in swap code, say to get notification when a swap slot is
>> freed.
>>    
> 
> Isn't that TRIM?

No: trim or discard is not useful. The problem is that we require a callback
_as soon as_ a page (swap slot) is freed. Otherwise, stale data quickly accumulates
in memory defeating the whole purpose of in-memory compressed swap devices (like ramzswap).

Increasing the frequency of discards is also not an option:
 - Creating discard bio requests themselves need memory and these swap devices
come into picture only under low memory conditions.
 - We need to regularly scan swap_map to issue these discards. Increasing discard
frequency also means more frequent scanning (which will still not be fast enough
for ramzswap needs).

> 
>> OTOH frontswap approach gets rid of any such artifacts and overheads.
>> (ramzswap: http://code.google.com/p/compcache/)
>>    
> 
> Maybe we should optimize these overheads instead.  Swap used to always
> be to slow devices, but swap-to-flash has the potential to make swap act
> like an extension of RAM.
> 

Spending lot of effort optimizing an overhead which can be completely avoided
is probably not worth it.

Also, I think the choice of a synchronous style API for frontswap and cleancache
is justified as they want to send pages to host *RAM*. If you want to use other
devices like SSDs, then these should be just added as another swap device as
we do currently -- these should not be used as frontswap storage directly.

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
