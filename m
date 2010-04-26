Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id BD0CE6B01E3
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 02:06:22 -0400 (EDT)
Message-ID: <4BD52D55.3070803@redhat.com>
Date: Mon, 26 Apr 2010 09:06:13 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: Frontswap [PATCH 0/4] (was Transcendent Memory): overview
References: <20100422134249.GA2963@ca-server1.us.oracle.com> <4BD06B31.9050306@redhat.com> <53c81c97-b30f-4081-91a1-7cef1879c6fa@default> <4BD07594.9080905@redhat.com> <b1036777-129b-4531-a730-1e9e5a87cea9@default> <4BD16D09.2030803@redhat.com> <b01d7882-1a72-4ba9-8f46-ba539b668f56@default 4BD1A74A.2050003@redhat.com> <4830bd20-77b7-46c8-994b-8b4fa9a79d27@default> <4BD1B427.9010905@redhat.com> <4BD24E37.30204@vflare.org> <4BD33822.2000604@redhat.com> <4BD3B2D1.8080203@vflare.org> <4BD4329A.9010509@redhat.com> <4BD4684E.9040802@vflare.org>
In-Reply-To: <4BD4684E.9040802@vflare.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: ngupta@vflare.org
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hugh.dickins@tiscali.co.uk, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On 04/25/2010 07:05 PM, Nitin Gupta wrote:
>
>>> Increasing the frequency of discards is also not an option:
>>>    - Creating discard bio requests themselves need memory and these
>>> swap devices
>>> come into picture only under low memory conditions.
>>>
>>>        
>> That's fine, swap works under low memory conditions by using reserves.
>>
>>      
> Ok, but still all this bio allocation and block layer overhead seems
> unnecessary and is easily avoidable. I think frontswap code needs
> clean up but at least it avoids all this bio overhead.
>    

Ok.  I agree it is silly to go through the block layer and end up 
servicing it within the kernel.

>>>    - We need to regularly scan swap_map to issue these discards.
>>> Increasing discard
>>> frequency also means more frequent scanning (which will still not be
>>> fast enough
>>> for ramzswap needs).
>>>
>>>        
>> How does frontswap do this?  Does it maintain its own data structures?
>>
>>      
> frontswap simply calls frontswap_flush_page() in swap_entry_free() i.e. as
> soon as a swap slot is freed. No bio allocation etc.
>    

The same code could also issue the discard?

>> Even for copying to RAM an async API is wanted, so you can dma it
>> instead of copying.
>>
>>      
> Maybe incremental development is better? Stabilize and refine existing
> code and gradually move to async API, if required in future?
>    

Incremental development is fine, especially for ramzswap where the APIs 
are all internal.  I'm more worried about external interfaces, these 
stick around a lot longer and if not done right they're a pain forever.

-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
