Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 298266B00CE
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 09:25:22 -0400 (EDT)
Message-ID: <4FE32083.4000805@redhat.com>
Date: Thu, 21 Jun 2012 09:24:19 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm 4/7] mm: make page colouring code generic
References: <1340057126-31143-1-git-send-email-riel@redhat.com> <1340057126-31143-5-git-send-email-riel@redhat.com> <20120621123743.GA7121@aftab.osrc.amd.com>
In-Reply-To: <20120621123743.GA7121@aftab.osrc.amd.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@amd64.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com, peterz@infradead.org, minchan@gmail.com, kosaki.motohiro@gmail.com, andi@firstfloor.org, hannes@cmpxchg.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org, Rik van Riel <riel@surriel.com>

On 06/21/2012 08:37 AM, Borislav Petkov wrote:

>> -unsigned long align_addr(unsigned long addr, struct file *filp,
>> -			 enum align_flags flags)
>> +unsigned long arch_align_addr(unsigned long addr, struct file *filp,
>> +			unsigned long pgoff, unsigned long flags,
>> +			enum mmap_allocation_direction direction)
>
> Arguments vertical alignment too, not only addr alignment :-)

Will do.

>>   {
>> -	unsigned long tmp_addr;
>> +	unsigned long tmp_addr = PAGE_ALIGN(addr);
>
> I'm guessing addr coming from arch_get_unmapped_area(_topdown) might not
> be page-aligned in all cases?

That is my guess, too :)

In some places arch_get_unmapped_area(_topdown) called
PAGE_ALIGN(addr), so we should make sure it is called.

It is probably masking bugs in some old old application,
and calling it here really should not hurt.

>> -	if (!(current->flags&  PF_RANDOMIZE))
>> -		return addr;
>> +	/* Always allow MAP_FIXED. Colouring is a performance thing only. */
>> +	if (flags&  MAP_FIXED)
>> +		return tmp_addr;
>
> Why here? Maybe we should push this MAP_FIXED check up in the
> arch_get_unmapped_area(_topdown) and not call arch_align_addr() for
> MAP_FIXED requests?
>
> Or do you want to save some code duplication?

The problem is that certain other architectures have
data cache alignment requirements, where mis-aligning
somebody's mmap of a file could result in actual data
corruption.

This means that, for those architectures, we have to
refuse non-colour-aligned MAP_FIXED mappings.

On x86 we can allow them, so we do. But that decision
needs to be taken in architecture specific code, not
in the shared arch_get_unmapped_area(_topdown) :)

>> +	/*
>> +	 * When aligning down, make sure we did not accidentally go up.
>> +	 * The caller will check for underflow.
>> +	 */
>
> Can we add this comment to the x86-64 version of arch_align_addr too pls?

Will do.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
