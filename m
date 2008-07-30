Message-ID: <4890C8BF.4050908@linux-foundation.org>
Date: Wed, 30 Jul 2008 15:02:07 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [PATCH 06/30] mm: kmem_alloc_estimate()
References: <20080724140042.408642539@chello.nl>	 <20080724141529.716339226@chello.nl>	 <1217420503.7813.170.camel@penberg-laptop> <1217424662.8157.58.camel@twins>
In-Reply-To: <1217424662.8157.58.camel@twins>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Daniel Lezcano <dlezcano@fr.ibm.com>, Neil Brown <neilb@suse.de>
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:

>>> +/*
>>> + * Calculate the upper bound of pages requires to sequentially allocate @bytes
>>> + * from kmalloc in an unspecified number of allocations of nonuniform size.
>>> + */
>>> +unsigned kmalloc_estimate_variable(gfp_t flags, size_t bytes)
>>> +{
>>> +	int i;
>>> +	unsigned long pages;
>>> +
>>> +	/*
>>> +	 * multiply by two, in order to account the worst case slack space
>>> +	 * due to the power-of-two allocation sizes.
>>> +	 */
>>> +	pages = DIV_ROUND_UP(2 * bytes, PAGE_SIZE);
>> For bytes > PAGE_SIZE this doesn't look right (for SLUB). We do page
>> allocator pass-through which means that we'll be grabbing high order
>> pages which can be bigger than what 'pages' is here.
> 
> Satisfying allocations from a bucket distribution with power-of-two
> (which page alloc order satisfies) has a worst case slack space of:
> 
> S(x) = 2^n - (2^(n-1)) - 1, n = ceil(log2(x))
> 
> This can be seen for the cases where x = 2^i + 1.

The needed bytes for a kmalloc allocation with size > PAGE_SIZE is

get_order(size) << PAGE_SHIFT bytes.

See kmalloc_large().



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
