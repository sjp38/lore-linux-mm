Subject: Re: [RFC/PATCH 0/15] Pass MAP_FIXED down to get_unmapped_area
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <46023055.1030004@yahoo.com.au>
References: <1174543217.531981.572863804039.qpush@grosgo>
	 <46023055.1030004@yahoo.com.au>
Content-Type: text/plain
Date: Thu, 22 Mar 2007 21:14:58 +1100
Message-Id: <1174558498.10836.30.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linux Memory Management <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> Great, this is long overdue for a cleanup.

Indeed... lots of redundant checks, dead code, etc...

> I haven't looked at all users of this, but does it make sense to switch
> to an API that takes an address range and modifies / filters it? Perhaps
> also filling in some other annotations (eg. alignment, topdown/bottom up).
> This way you could stack as many arch and driver callbacks as you need,
> while hopefully also having just a single generic allocator.
> 
> OTOH, that might end up being too inefficient or simply over engineered.
> Did you have any other thoughts about how to do this more generically?

I haven't quite managed to think about something that would fit
everybody...

The main problem is that the requirements are fairly arch specific in
nature... from page sizes, page attributes, to things like nommu who
want in some case to enfore virt=phys or to cache aliasing issues.

I think we can find a subset of "parameters" that represent the various
constraints... pgprot, page size, mostly. Then, we could stack up the
driver/fs g_u_a on top of the arch one, but it's not simple to do that
right. Who get's to pick an address first ? If the driver picks one but
the arch rejects it, the driver need a chance to pick another one ...

Or do we decide that only the arch knows, and thus the driver only
provides more detailed informations to the arch to pick something up...

That would be useful.. for example, some archs could really use knowing
at g_u_a time wether the mapping is to be cacheable or non cacheable.

I'm still thinking about it. I think my first patch set is a good step
to give some more flexibility to archs but is by no mean something to
settle on.

I need to simmer that more until my neurons manage to cough up some
nicer & generic abstraction/api to deal with that in a better way.

Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
