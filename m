Date: Mon, 2 Apr 2007 14:53:34 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/2] Generic Virtual Memmap suport for SPARSEMEM
In-Reply-To: <1175550151.22373.116.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0704021449200.2272@schroedinger.engr.sgi.com>
References: <20070401071024.23757.4113.sendpatchset@schroedinger.engr.sgi.com>
  <1175547000.22373.89.camel@localhost.localdomain>
 <Pine.LNX.4.64.0704021351590.1224@schroedinger.engr.sgi.com>
 <1175548924.22373.109.camel@localhost.localdomain>
 <Pine.LNX.4.64.0704021428340.2272@schroedinger.engr.sgi.com>
 <1175550151.22373.116.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <hansendc@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Martin Bligh <mbligh@google.com>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Apr 2007, Dave Hansen wrote:

> > The slab allocator purposes is to deliver small sub page sized chunks.
> > The page allocator is there to allocate pages. Both are optimized for its 
> > purpose.
> 
> I understand that, in general, but how does that optimization help,
> here, exactly?  My argument is that if we use the slab, it means more
> code sharing with existing code in sparse.c.  Other than ideology, what
> practical reasons are there in this case that keep us from doing that
> otherwise attractive code sharing.

F.e. you are wasting memory that the slab needs to uselessly track these 
allocations. You would need to create a special slab that has page sized
(or huge page sized) alignment to have the proper allocation behavior. Not 
good.

The rest of sparse is not MMU bound. So you may be fine. I'd recommend 
though to use the page allocator if you are doing large allocations. I do 
not see the point of using slab there.

> I don't think the pagetable walks are generic enough to ever get used on
> ppc, unless they start walking the Linux pagetables for the kernel
> virtual address area.  I was trying to poke you into getting the
> pagetable walks out of sparse.c. ;)

If I would be doing that then we would end up adding these pagetable walks
to multiple architectures. I already need to cover IA64 and x86_64 and 
this will also do i386. Lets try to keep them generic. PPC may need to 
disable these walks and do its own thing.

> > Well think about how to handle the case that the allocatiopn of a page 
> > table page or a vmemmap block fails. Once we have that sorted out then we 
> > can cleanup the higher layers.
> 
> I think it is best to just completely replace
> sparse_early_mem_map_alloc() for the vmemmap case.  It really is a
> completely different beast.  You'd never, for instance, have
> alloc_remap() come into play.

What is the purpose of alloc_remap? Could not figure that one out.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
