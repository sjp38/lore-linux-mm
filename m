Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l32LgaOx021170
	for <linux-mm@kvack.org>; Mon, 2 Apr 2007 17:42:36 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l32LgaC3185964
	for <linux-mm@kvack.org>; Mon, 2 Apr 2007 15:42:36 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l32LgZdh021733
	for <linux-mm@kvack.org>; Mon, 2 Apr 2007 15:42:36 -0600
Subject: Re: [PATCH 1/2] Generic Virtual Memmap suport for SPARSEMEM
From: Dave Hansen <hansendc@us.ibm.com>
In-Reply-To: <Pine.LNX.4.64.0704021428340.2272@schroedinger.engr.sgi.com>
References: <20070401071024.23757.4113.sendpatchset@schroedinger.engr.sgi.com>
	 <1175547000.22373.89.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0704021351590.1224@schroedinger.engr.sgi.com>
	 <1175548924.22373.109.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0704021428340.2272@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 02 Apr 2007 14:42:31 -0700
Message-Id: <1175550151.22373.116.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Martin Bligh <mbligh@google.com>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-04-02 at 14:31 -0700, Christoph Lameter wrote:
> On Mon, 2 Apr 2007, Dave Hansen wrote:
> 
> > > > Hmmmmmmm.  Can we combine this with sparse_index_alloc()?  Also, why not
> > > > just use the slab for this?
> > > 
> > > Use a slab for page sized allocations? No.
> > 
> > Why not?  We use it above for sparse_index_alloc() and if it is doing
> > something wrong, I'd love to fix it.  Can you elaborate?
> 
> The slab allocator purposes is to deliver small sub page sized chunks.
> The page allocator is there to allocate pages. Both are optimized for its 
> purpose.

I understand that, in general, but how does that optimization help,
here, exactly?  My argument is that if we use the slab, it means more
code sharing with existing code in sparse.c.  Other than ideology, what
practical reasons are there in this case that keep us from doing that
otherwise attractive code sharing.

> > > I just extended this in V2 to also work on IA64. Its pretty generic.
> > 
> > Can you extend it to work on ppc? ;)
> 
> I do not know enough about how ppc handles large pages.

I don't think the pagetable walks are generic enough to ever get used on
ppc, unless they start walking the Linux pagetables for the kernel
virtual address area.  I was trying to poke you into getting the
pagetable walks out of sparse.c. ;)

> > > > Then, do whatever magic you want in alloc_vmemmap().
> > > 
> > > That would break if alloc_vmemmap returns NULL because it cannot allocate 
> > > memory.
> > 
> > OK, that makes sense.  However, it would still be nice to hide that
> > #ifdef somewhere that people are a bit less likely to run into it.  It's
> > just one #ifdef, so if you can kill it, great.  Otherwise, they pile up
> > over time and _do_ cause real readability problems.
> 
> Well think about how to handle the case that the allocatiopn of a page 
> table page or a vmemmap block fails. Once we have that sorted out then we 
> can cleanup the higher layers.

I think it is best to just completely replace
sparse_early_mem_map_alloc() for the vmemmap case.  It really is a
completely different beast.  You'd never, for instance, have
alloc_remap() come into play.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
