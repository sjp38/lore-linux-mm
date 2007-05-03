Date: Thu, 3 May 2007 23:41:15 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: 2.6.22 -mm merge plans: slub on PowerPC
In-Reply-To: <Pine.LNX.4.64.0705031408360.13387@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0705032332500.16661@blonde.wat.veritas.com>
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0705011846590.10660@blonde.wat.veritas.com>
 <20070501125559.9ab42896.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0705012101410.26170@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0705011403470.26819@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0705021330001.16517@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0705021017270.32635@schroedinger.engr.sgi.com>
 <20070503011515.0d89082b.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0705030936120.5165@blonde.wat.veritas.com>
 <20070503015729.7496edff.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0705031011020.9826@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0705032143420.7589@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0705031408360.13387@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Paul Mackerras <paulus@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 3 May 2007, Christoph Lameter wrote:
> 
> There are SLUB patches pending (not in rc7-mm2 as far as I can recall) 
> that reduce the default page order sizes to head off this issue. The 
> defaults were initially too large (and they still default to large
> for testing if Mel's Antifrag work is detected to be active).

Sounds good.

> > -	return kmem_cache_alloc(pgtable_cache[PTE_CACHE_NUM],
> > -				GFP_KERNEL|__GFP_REPEAT);
> > +	return quicklist_alloc(0, GFP_KERNEL|__GFP_REPEAT, NULL);
> 
> __GFP_REPEAT is unusual here but this was carried over from the 
> kmem_cache_alloc it seems. Hmm... There is some variance on how we do this 
> between arches. Should we uniformly set or not set this flag?

Not something to get into in this patch, but it did surprise me too.
I believe __GFP_REPEAT should be avoided, and I don't see justification
for it here (but need to remember not to do a blind virt_to_page on the
result in some places if it might return NULL - which IIRC it actually
can do even if __GFP_REPEAT, when chosen for OOM kill).  But I've a
suspicion it got put in there for some good reason I don't know about.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
