Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id A50E06B01F9
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 09:50:11 -0400 (EDT)
Received: by pwi10 with SMTP id 10so2371685pwi.14
        for <linux-mm@kvack.org>; Mon, 26 Apr 2010 06:50:07 -0700 (PDT)
Message-ID: <4BD59956.7050508@vflare.org>
Date: Mon, 26 Apr 2010 19:17:02 +0530
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
MIME-Version: 1.0
Subject: Re: Frontswap [PATCH 0/4] (was Transcendent Memory): overview
References: <20100422134249.GA2963@ca-server1.us.oracle.com> <4BD06B31.9050306@redhat.com> <53c81c97-b30f-4081-91a1-7cef1879c6fa@default> <4BD07594.9080905@redhat.com> <b1036777-129b-4531-a730-1e9e5a87cea9@default> <4BD16D09.2030803@redhat.com> <b01d7882-1a72-4ba9-8f46-ba539b668f56@default 4BD1A74A.2050003@redhat.com> <4830bd20-77b7-46c8-994b-8b4fa9a79d27@default> <4BD1B427.9010905@redhat.com> <4BD24E37.30204@vflare.org> <4BD33822.2000604@redhat.com> <4BD3B2D1.8080203@vflare.org> <4BD4329A.9010509@redhat.com> <4BD4684E.9040802@vflare.org> <4BD52D55.3070803@redhat.com>
In-Reply-To: <4BD52D55.3070803@redhat.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hugh.dickins@tiscali.co.uk, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On 04/26/2010 11:36 AM, Avi Kivity wrote:
> On 04/25/2010 07:05 PM, Nitin Gupta wrote:
>>
>>>> Increasing the frequency of discards is also not an option:
>>>>    - Creating discard bio requests themselves need memory and these
>>>> swap devices
>>>> come into picture only under low memory conditions.
>>>>
>>>>        
>>> That's fine, swap works under low memory conditions by using reserves.
>>>
>>>      
>> Ok, but still all this bio allocation and block layer overhead seems
>> unnecessary and is easily avoidable. I think frontswap code needs
>> clean up but at least it avoids all this bio overhead.
>>    
> 
> Ok.  I agree it is silly to go through the block layer and end up
> servicing it within the kernel.
> 
>>>>    - We need to regularly scan swap_map to issue these discards.
>>>> Increasing discard
>>>> frequency also means more frequent scanning (which will still not be
>>>> fast enough
>>>> for ramzswap needs).
>>>>
>>>>        
>>> How does frontswap do this?  Does it maintain its own data structures?
>>>
>>>      
>> frontswap simply calls frontswap_flush_page() in swap_entry_free()
>> i.e. as
>> soon as a swap slot is freed. No bio allocation etc.
>>    
> 
> The same code could also issue the discard?
> 


No, we cannot issue discard bio at this place since swap_lock
spinlock is held.


Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
