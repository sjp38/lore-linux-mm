Received: from edge01.upc.biz ([192.168.13.236]) by viefep12-int.chello.at
          (InterMail vM.7.08.02.00 201-2186-121-20061213) with ESMTP
          id <20080812081218.MVBZ25075.viefep12-int.chello.at@edge01.upc.biz>
          for <linux-mm@kvack.org>; Tue, 12 Aug 2008 10:12:18 +0200
Subject: Re: [PATCH 12/30] mm: memory reserve management
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <18593.16326.701825.625469@notabene.brown>
References: <20080724140042.408642539@chello.nl>
	 <20080724141530.127530749@chello.nl>
	 <18593.16326.701825.625469@notabene.brown>
Content-Type: text/plain
Date: Tue, 12 Aug 2008 10:12:20 +0200
Message-Id: <1218528740.10800.176.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Neil Brown <neilb@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Daniel Lezcano <dlezcano@fr.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Tue, 2008-08-12 at 17:46 +1000, Neil Brown wrote:
> On Thursday July 24, a.p.zijlstra@chello.nl wrote:
> > Generic reserve management code. 
> > 
> > It provides methods to reserve and charge. Upon this, generic alloc/free style
> > reserve pools could be build, which could fully replace mempool_t
> > functionality.
> 
> More comments on this patch .....
> 
> > +void *___kmalloc_reserve(size_t size, gfp_t flags, int node, void *ip,
> > +			 struct mem_reserve *res, int *emerg);
> > +
> > +static inline
> > +void *__kmalloc_reserve(size_t size, gfp_t flags, int node, void *ip,
> > +			struct mem_reserve *res, int *emerg)
> > +{
> > +	void *obj;
> > +
> > +	obj = __kmalloc_node_track_caller(size,
> > +			flags | __GFP_NOMEMALLOC | __GFP_NOWARN, node, ip);
> > +	if (!obj)
> > +		obj = ___kmalloc_reserve(size, flags, node, ip, res, emerg);
> > +
> > +	return obj;
> > +}
> > +
> > +#define kmalloc_reserve(size, gfp, node, res, emerg) 			\
> > +	__kmalloc_reserve(size, gfp, node, 				\
> > +			  __builtin_return_address(0), res, emerg)
> > +
> ......
> > +/*
> > + * alloc wrappers
> > + */
> > +
> > +void *___kmalloc_reserve(size_t size, gfp_t flags, int node, void *ip,
> > +			 struct mem_reserve *res, int *emerg)
> > +{
> > +	void *obj;
> > +	gfp_t gfp;
> > +
> > +	gfp = flags | __GFP_NOMEMALLOC | __GFP_NOWARN;
> > +	obj = __kmalloc_node_track_caller(size, gfp, node, ip);
> > +
> > +	if (obj || !(gfp_to_alloc_flags(flags) & ALLOC_NO_WATERMARKS))
> > +		goto out;
> > +
> > +	if (res && !mem_reserve_kmalloc_charge(res, size)) {
> > +		if (!(flags & __GFP_WAIT))
> > +			goto out;
> > +
> > +		wait_event(res->waitqueue,
> > +				mem_reserve_kmalloc_charge(res, size));
> > +
> > +		obj = __kmalloc_node_track_caller(size, gfp, node, ip);
> > +		if (obj) {
> > +			mem_reserve_kmalloc_charge(res, -size);
> > +			goto out;
> > +		}
> > +	}
> > +
> > +	obj = __kmalloc_node_track_caller(size, flags, node, ip);
> > +	WARN_ON(!obj);
> > +	if (emerg)
> > +		*emerg |= 1;
> > +
> > +out:
> > +	return obj;
> > +}
> 
> Two comments to be precise.
> 
> 1/ __kmalloc_reserve attempts a __GFP_NOMEMALLOC allocation, and then
>    if that fails, ___kmalloc_reserve immediately tries again.
>    Is that pointless?  Should the second one be removed?

Pretty pointless yes, except that it made ___kmalloc_reserve a nicer
function to read, and as its an utter slow path I couldn't be arsed to
optimize :-)

> 2/ mem_reserve_kmalloc_charge appears to assume that the 'mem_reserve'
>    has been 'connected' and so is active.

Hmm, that would be __mem_reserve_charge() then, because the callers
don't do much.

>    While callers probably only set GFP_MEMALLOC in cases where the
>    mem_reserve is connected, ALLOC_NO_WATERMARKS could get via
>    PF_MEMALLOC so we could end up calling mem_reserve_kmalloc_charge
>    when the mem_reserve is not connected.

Right..

>    That seems to be 'odd' at least.
>    It might even be 'wrong' as mem_reserve_connect doesn't add the
>    usage of the child to the parent - only the ->pages and ->limit.
> 
>    What is your position on this?  Mine is "still slightly confused".

Uhmm,. good point. Let me ponder this while I go for breakfast ;-)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
