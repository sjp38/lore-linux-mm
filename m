Message-ID: <48D2E65A.6020004@redhat.com>
Date: Thu, 18 Sep 2008 16:38:02 -0700
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: Populating multiple ptes at fault time
References: <48D142B2.3040607@goop.org> <48D17E75.80807@redhat.com> <48D1851B.70703@goop.org> <48D18919.9060808@redhat.com> <48D18C6B.5010407@goop.org> <48D2B970.7040903@redhat.com> <48D2D3B2.10503@goop.org>
In-Reply-To: <48D2D3B2.10503@goop.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickens <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Avi Kivity <avi@qumranet.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Marcelo Tosatti <mtosatti@redhat.com>
List-ID: <linux-mm.kvack.org>

Jeremy Fitzhardinge wrote:
> Avi Kivity wrote:
>   
>>> Do you need to set the A bit synchronously?  
>>>       
>> Yes, of course (if no guest cooperation).
>>     
>
> Is the A bit architecturally guaranteed to be synchronously set?  

I believe so.  The cpu won't cache tlb entries with the A bit clear 
(much like the shadow code), and will rmw the pte on first access.

> Can
> speculative accesses set it?  

Yes, but don't abuse this.

>> If we add an async mode for guests that can cope, maybe this is
>> workable.  I guess this is what you're suggesting.
>>
>>     
>
> Yes.  At worst Linux would underestimate the process RSS a bit
> (depending on how many unsynchronized ptes you leave lying around).  I
>   

Not the RSS (that's pte.present pages) but the working set (aka active 
list).

> bet there's an appropriate pvop hook you could use to force
> synchronization just before the kernel actually inspects the bits
> (leaving lazy mode sounds good).
>   

It would have to be a new lazy mode, not the existing one, I think.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
