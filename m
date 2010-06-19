Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 72A666B01AF
	for <linux-mm@kvack.org>; Sat, 19 Jun 2010 04:23:38 -0400 (EDT)
Message-ID: <4C1C7E68.8080700@kernel.org>
Date: Sat, 19 Jun 2010 10:23:04 +0200
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] percpu: make @dyn_size always mean min dyn_size in
 first chunk init functions
References: <alpine.DEB.2.00.1006151406120.10865@router.home> <alpine.DEB.2.00.1006151409240.10865@router.home> <4C189119.5050801@kernel.org> <alpine.DEB.2.00.1006161131520.4554@router.home> <4C190748.7030400@kernel.org> <alpine.DEB.2.00.1006161231420.6361@router.home> <4C19E19D.2020802@kernel.org> <alpine.DEB.2.00.1006170842410.22997@router.home> <4C1BA59C.6000309@kernel.org> <alpine.DEB.2.00.1006181229310.13915@router.home> <4C1BAF51.8020702@kernel.org> <alpine.DEB.2.00.1006181300320.14715@router.home>
In-Reply-To: <alpine.DEB.2.00.1006181300320.14715@router.home>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

On 06/18/2010 08:03 PM, Christoph Lameter wrote:
>> Yeah, something like that but I would add some buffer there for
>> alignment and whatnot.
> 
> Only the percpu allocator would know the waste for alignment and
> "whatnot". What would you like me to add to the above formula to make it
> safe?

I'm not sure, some sensible slack.  :-)

>>> What is the role of SLOTS?
>>
>> It's allocation map.  Each consecutive allocs consume one if alignment
>> doesn't require padding but two if it does.  ie. It limits how many
>> items one can allocate.
>>
>>> Each kmem_cache_cpu structure is a separate percpu allocation.
>>
>> If it's a single item.  Nothing to worry about.
> 
> ok so
> 
> BUILD_BUG_ON(SLUB_PAGE_SHIFT * <fuzz-factor> > SLOTS);
> 
> I dont know what fuzz factor would be needed.
> 
> Maybe its best to have a macro provided by percpu?
> 
> VERIFY_EARLY_ALLOCS(<nr-of-allocs>,<total-size-consumed>)
> 
> The macro would generate the proper BUILD_BUG_ON?

The problem is that alignment of each item and their allocation order
also matter.  Even the percpu allocator itself can't tell for sure
before actually allocating it.  As it's gonna be used only by the slab
allocator at least for now && those preallocated areas aren't wasted
anyway, just giving it enough should work good enough, I think.  Say,
multiply everything by two.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
