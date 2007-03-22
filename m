Message-ID: <46025A6E.60603@yahoo.com.au>
Date: Thu, 22 Mar 2007 21:29:02 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC/PATCH 0/15] Pass MAP_FIXED down to get_unmapped_area
References: <1174543217.531981.572863804039.qpush@grosgo>	 <46023055.1030004@yahoo.com.au> <1174558498.10836.30.camel@localhost.localdomain>
In-Reply-To: <1174558498.10836.30.camel@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Linux Memory Management <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Benjamin Herrenschmidt wrote:
>>Great, this is long overdue for a cleanup.
> 
> 
> Indeed... lots of redundant checks, dead code, etc...
> 
> 
>>I haven't looked at all users of this, but does it make sense to switch
>>to an API that takes an address range and modifies / filters it? Perhaps
>>also filling in some other annotations (eg. alignment, topdown/bottom up).
>>This way you could stack as many arch and driver callbacks as you need,
>>while hopefully also having just a single generic allocator.
>>
>>OTOH, that might end up being too inefficient or simply over engineered.
>>Did you have any other thoughts about how to do this more generically?
> 
> 
> I haven't quite managed to think about something that would fit
> everybody...
> 
> The main problem is that the requirements are fairly arch specific in
> nature... from page sizes, page attributes, to things like nommu who
> want in some case to enfore virt=phys or to cache aliasing issues.
> 
> I think we can find a subset of "parameters" that represent the various
> constraints... pgprot, page size, mostly. Then, we could stack up the
> driver/fs g_u_a on top of the arch one, but it's not simple to do that
> right. Who get's to pick an address first ? If the driver picks one but
> the arch rejects it, the driver need a chance to pick another one ...
> 
> Or do we decide that only the arch knows, and thus the driver only
> provides more detailed informations to the arch to pick something up...

Well if we use a set of valid ranges, then we can start with generic code
that will set up ranges allowed by the syscall semantics.

Then the arch code could be called with that set of ranges, and perform
its modifications to that set.

Then driver/fs code could be called and perform its modifications.

Note that each call would only ever exclude ranges of virtual addresses,
increase alignment, and decrease permissions (or fail). So nobody steps
on anybody's toes. When the final set of ranges come out the other end,
you can run a generic allocator on them.

A range could be something like

struct {
	unsigned long start, end;
	pgprot prot;
	unsigned int align_bits;
	unsigned int other_flags;	
};

The problem I see with this is that it could be computationally too
expensive to have each layer process and validate/modify them. And
simply might just be overengineered for the job.


> That would be useful.. for example, some archs could really use knowing
> at g_u_a time wether the mapping is to be cacheable or non cacheable.

This would add some constraint onto the ordering of whether driver or
arch gets called first, but still wouldn't invalidate the above...


> I'm still thinking about it. I think my first patch set is a good step
> to give some more flexibility to archs but is by no mean something to
> settle on.

Yeah definitely a nice start. And of course things should be done
incrementally rather than thinking about a complete rewrite first ;)

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
