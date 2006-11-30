Message-ID: <456E3ACE.4040804@yahoo.com.au>
Date: Thu, 30 Nov 2006 12:58:38 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC] Extract kmalloc.h and slob.h from slab.h
References: <Pine.LNX.4.64.0611272229290.6012@schroedinger.engr.sgi.com> <20061129082650.GB12734@infradead.org> <456D4722.2010202@yahoo.com.au> <Pine.LNX.4.64.0611291119480.16189@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0611291119480.16189@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Christoph Hellwig <hch@infradead.org>, akpm@osdl.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, mpm@selenic.com, Manfred Spraul <manfred@colorfullife.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Wed, 29 Nov 2006, Nick Piggin wrote:
> 
> 
>>>NACK.  This is utterly braindead, easily shown by things like the need
>>>to duplicate the kmem_cache_alloc prototype.
>>>
>>>What are you trying to solve with this?
> 
> 
> I am trying to detangle various things in the slab. Its a bit complex.
>  
> 
>>It does seem wrong, I agree. For another thing, there is no "slob API".
>>Slob is an implementation of the *slab API*.
> 
> 
> But the definitions vary a lot. Should I try to find the common 
> function declarations and keep them together?

The point is that it *is the same API*. Having the declarations for the slob
implementation in slob.h, and then including slab.h in slob.h seems completely
backwards.

I don't see that breaking them out gains you very much at all, but if you do
want to, then I'd rather have slob_defs.h and slab_defs.h, then have slab.h
include either one depending on the config.

>>kmalloc seems OK to be split. But given that it is built on top of the
>>slab, then it should not be going out of its way to avoid the slab.h
>>include, as Christoph H points out.
>>
>>If this whole exercise is to dispense with a few includes, then I'll
>>second Christoph's nack. This kinds of tricks does not make it easier
>>to untangle and redesign header dependencies properly in the long term.
> 
> 
> Right now the slab.h is difficult to understand. Separating things out 
> will make the .h files small and nicely focused on one thing.
> 
> We have some ugly things in kmalloc.h like the include of kmalloc_sizes.h 
> and the CACHE definitions. I think those should be separated and then 
> hopefully we can fix this up at some point.
> 
> Having kmalloc.h separate will also help if we put the definition of 
> struct kmem_cache in slab.c. Then the definition will be hidden from the 
> simple kmalloc users.

kmalloc.h uses the slab, and it calls kmem_cache_alloc. How could it be
an improvement to not include slab.h? I don't think hiding a data type
definition has any value, does it?

Other than that, I don't have any problem with moving kmalloc to its own
header.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
