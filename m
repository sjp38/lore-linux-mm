From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC] Make the slab allocator observe NUMA policies
Date: Fri, 11 Nov 2005 04:06:23 +0100
References: <Pine.LNX.4.62.0511101401390.16481@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0511101401390.16481@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200511110406.24838.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: steiner@sgi.com, linux-mm@kvack.org, alokk@calsoftinc.com
List-ID: <linux-mm.kvack.org>

On Thursday 10 November 2005 23:04, Christoph Lameter wrote:
> Currently the slab allocator simply allocates slabs from the current node
> or from the node indicated in kmalloc_node().
>
> This change came about with the NUMA slab allocator changes in 2.6.14.
> Before 2.6.14 the slab allocator was obeying memory policies in the sense
> that the pages were allocated in the policy context of the currently
> executing process (which could allocate a page according to MPOL_INTERLEAVE
> for one process and then use the free entries in that page for another
> process that did not have this policy set).
>
> The following patch adds NUMA memory policy support. This means that the
> slab entries (and therefore also the pages containing them) will be
> allocated according to memory policy.

You're adding a check and potential cache line miss to a really really hot 
path. I would prefer  it to do the policy check only in the slower path of 
slab that gets memory from the backing page allocator. While not 100% exact 
this should be  good enough for just spreading memory around during 
initialization. And I cannot really think of any other uses of this.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
