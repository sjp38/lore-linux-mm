From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 1/4] x86_64: Switch to SPARSE_VIRTUAL
Date: Mon, 2 Apr 2007 17:44:39 +0200
References: <20070401071024.23757.4113.sendpatchset@schroedinger.engr.sgi.com> <200704011246.52238.ak@suse.de> <Pine.LNX.4.64.0704020832320.30394@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0704020832320.30394@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200704021744.39880.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Martin Bligh <mbligh@google.com>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Monday 02 April 2007 17:37, Christoph Lameter wrote:
> On Sun, 1 Apr 2007, Andi Kleen wrote:
> 
> > Hmm, this means there is at least 2MB worth of struct page on every node?
> > Or do you have overlaps with other memory (I think you have)
> > In that case you have to handle the overlap in change_page_attr()
> 
> Correct. 2MB worth of struct page is 128 mb of memory. Are there nodes 
> with smaller amounts of memory? 

Yes the discontigmem minimum is 64MB and there are some setups
(mostly with numa emulation) where you end up with nodes that small.

BTW there is no guarantee the node size is a multiple of 128MB so
you likely need to handle the overlap case. Otherwise we can 
get cache corruptions

> Note also that the default sparsemem 
> section size is (include/asm-x86_64/sparsemem.h)
> 
> #define SECTION_SIZE_BITS       27 /* matt - 128 is convenient right now */
> 
> 128MB ....
> 
> So you currently cannot have smaller sections of memory anyways.

Sparsemem is still quite experimental; discontigmem is the default
on x86-64.

> 
> > Also your "generic" vmemmap code doesn't look very generic, but
> > rather x86 specific. I didn't think huge pages could be easily
> > set up this way in many other architectures.  
> 
> We do this pmd special casing in other parts of the core VM. I have also a 
> patch for IA64 that workks with this.
> 
> > Do you have any benchmarks numbers to prove it? There seem to be a few
> > benchmarks where the discontig virt_to_page is a problem
> > (although I know ways to make it more efficient), and sparsemem
> > is normally slower. Still some numbers would be good.
> 
> You want a benchmark to prove that the removal of memory references and 
> code improves performance?

You're just moving them into MMU, not really removing it.  And need more TLB entries.
It might be faster or it might not. There are some unexpected issues, like most x86-64 
CPUs have a quite small number of large TLBs so you can get thrashing etc.

So numbers with TLB intensive workloads would be good. 

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
