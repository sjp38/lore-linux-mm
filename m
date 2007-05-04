Date: Fri, 4 May 2007 11:46:54 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 08/40] mm: kmem_cache_objsize
In-Reply-To: <463B7E5C.8030201@cs.helsinki.fi>
Message-ID: <Pine.LNX.4.64.0705041142350.24625@schroedinger.engr.sgi.com>
References: <20070504102651.923946304@chello.nl>  <20070504103157.215424767@chello.nl>
  <Pine.LNX.4.64.0705040932200.22033@schroedinger.engr.sgi.com>
 <1178301545.24217.56.camel@twins>  <Pine.LNX.4.64.0705041104110.23539@schroedinger.engr.sgi.com>
 <1178302904.2767.6.camel@lappy> <Pine.LNX.4.64.0705041128270.24283@schroedinger.engr.sgi.com>
 <463B7E5C.8030201@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, James Bottomley <James.Bottomley@SteelEye.com>, Mike Christie <michaelc@cs.wisc.edu>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

On Fri, 4 May 2007, Pekka Enberg wrote:

> > which would calculate the worst case memory scenario for allocation the
> > number of indicated objects?
> 
> IIRC this looks more or less what Peter had initially. I don't like the API
> because there's no way for slab (perhaps this is different for slub) how many
> pages you really need due to per-node and per-cpu caches, etc.

SLAB can calculate exactly how many pages are needed. The per 
cpu and per node stuff is setup at boot and does not change. We are 
talking about the worst case scenario here. True in case of an off slab
we have additional overhead that would also have to go into worst case 
scenario.

> It's better that the slab tells you what it actually knows and lets the
> callers figure out what a worst-case upper bound is.

They do not have the data. For that they would need to know how to deal 
with alignments, (in case of SLAB) the location of the struct slab, the 
distinction between the differrent sizes, padding etc. I think this has to 
be done by the allocator. If we ever have another allocator with another 
structure then this will nicely isolate that functionality. Otherwise we 
may have to change the callers depending on how the slab organizes its 
data.

SLUB organizes its data more effectively so SLUB will return a lower 
number than SLAB f.e.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
