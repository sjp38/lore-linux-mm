Date: Fri, 11 Nov 2005 09:40:52 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [RFC] Make the slab allocator observe NUMA policies
In-Reply-To: <200511110406.24838.ak@suse.de>
Message-ID: <Pine.LNX.4.62.0511110934110.20360@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0511101401390.16481@schroedinger.engr.sgi.com>
 <200511110406.24838.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: steiner@sgi.com, linux-mm@kvack.org, alokk@calsoftinc.com
List-ID: <linux-mm.kvack.org>

On Fri, 11 Nov 2005, Andi Kleen wrote:

> > The following patch adds NUMA memory policy support. This means that the
> > slab entries (and therefore also the pages containing them) will be
> > allocated according to memory policy.
> 
> You're adding a check and potential cache line miss to a really really hot 
> path. I would prefer  it to do the policy check only in the slower path of 
> slab that gets memory from the backing page allocator. While not 100% exact 
> this should be  good enough for just spreading memory around during 
> initialization. And I cannot really think of any other uses of this.

Hmm. Thats not easy to do since the slab allocator is managing the pages 
in terms of the nodes where they are located. The whole thing is geared to 
first inspect the lists for one node and then expand if no page is 
available.

The cacheline already in use by the page allocator, the page allocator 
will continually reference current->mempolicy. See alloc_page_vma and 
alloc_pages_current. So its likely that the cacheline is already active 
and the impact on the hot code patch is likely negligible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
