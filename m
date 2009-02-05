Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B7BCD6B003D
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 14:11:08 -0500 (EST)
Date: Thu, 5 Feb 2009 20:10:17 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: pud_bad vs pud_bad
Message-ID: <20090205191017.GF20470@elte.hu>
References: <498B2EBC.60700@goop.org> <20090205184355.GF5661@elte.hu> <498B35F9.601@goop.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <498B35F9.601@goop.org>
Sender: owner-linux-mm@kvack.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: William Lee Irwin III <wli@holomorphy.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


* Jeremy Fitzhardinge <jeremy@goop.org> wrote:

> Ingo Molnar wrote:
>> * Jeremy Fitzhardinge <jeremy@goop.org> wrote:
>>
>>   
>>> I'm looking at unifying the 32 and 64-bit versions of pud_bad.
>>>
>>> 32-bits defines it as:
>>>
>>> static inline int pud_bad(pud_t pud)
>>> {
>>> 	return (pud_val(pud) & ~(PTE_PFN_MASK | _KERNPG_TABLE | _PAGE_USER)) != 0;
>>> }
>>>
>>> and 64 as:
>>>
>>> static inline int pud_bad(pud_t pud)
>>> {
>>> 	return (pud_val(pud) & ~(PTE_PFN_MASK | _PAGE_USER)) != _KERNPG_TABLE;
>>> }
>>>
>>>
>>> I'm inclined to go with the 64-bit version, but I'm wondering if 
>>> there's something subtle I'm missing here.
>>>     
>>
>> Why go with the 64-bit version? The 32-bit check looks more compact and 
>> should result in smaller code.
>>   
>
> Well, its stricter.  But I don't really understand what condition its  
> actually testing for.

Well it tests: "beyond the bits covered by PTE_PFN|_PAGE_USER, the rest 
must only be _KERNPG_TABLE".

The _KERNPG_TABLE bits are disjunct from PTE_PFN|_PAGE_USER bits, so this 
makes sense.

But the 32-bit check does the exact same thing but via a single binary 
operation: it checks whether any bits outside of those bits are zero - just 
via a simpler test that compiles to more compact code.

So i'd go with the 32-bit version. (unless there are some sign-extension 
complications i'm missing - but i think we got rid of those already.)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
