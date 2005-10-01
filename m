Date: Sat, 1 Oct 2005 18:52:54 -0300
From: Marcelo <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH] per-page SLAB freeing (only dcache for now)
Message-ID: <20051001215254.GA19736@xeon.cnet>
References: <20050930193754.GB16812@xeon.cnet> <Pine.LNX.4.62.0509301934390.31011@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.62.0509301934390.31011@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Marcelo <marcelo.tosatti@cyclades.com>, linux-mm@kvack.org, akpm@osdl.org, dgc@sgi.com, dipankar@in.ibm.com, mbligh@mbligh.org, manfred@colorfullife.com
List-ID: <linux-mm.kvack.org>

On Fri, Sep 30, 2005 at 07:46:31PM -0700, Christoph Lameter wrote:
> On Fri, 30 Sep 2005, Marcelo wrote:
> 
> > I don't see any fundamental problems with this approach, are there any?
> > I'll clean it up and proceed to write the inode cache equivalent 
> > if there aren't.
> 
> Hmm. I think this needs to be some generic functionality in the slab 
> allocator. If the allocator determines that the number of entries in a 
> page become reasonably low then call a special function provided at 
> slab creation time to try to free up the leftover entries.
> 
> Something like
> 
> int slab_try_free(void *);
> 
> ?
> 
> return true/false depending on success of attempt to free the entry.

I thought about having a mini-API for this such as "struct slab_reclaim_ops" 
implemented by each reclaimable cache, invoked by a generic SLAB function.

Problem is that locking involved into looking at the SLAB elements is 
cache specific (eg dcache_lock for the dcache, inode_lock for the icache, 
and so on), so making a generic function seems pretty tricky, ie. you 
need cache specific information in the generic function which is not so 
easily "generifiable", if there's such a word.
                                                                                                                                               
> This method may also be useful to attempt to migrate slab pages to
> different nodes. If such a method is available then one can try to free
> all entries in a page relying on their recreation on another node if they
> are needed again.

Yep, haven't thought of that before, but it might be interesting to have 
NUMA migration of cache elements.

Additionaly one can try to migrate recently referenced elements, instead 
of freeing them, moving them to some partially used SLAB free slot 
(Martin suggested that on IRC).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
