Date: Mon, 25 Sep 2006 16:37:23 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: virtual mmap basics
In-Reply-To: <45185698.5080009@shadowen.org>
Message-ID: <Pine.LNX.4.64.0609251631060.25028@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609240959060.18227@schroedinger.engr.sgi.com>
 <4517CB69.9030600@shadowen.org> <Pine.LNX.4.64.0609250922040.23266@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0609250958370.23475@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0609251401260.24262@schroedinger.engr.sgi.com>
 <45185698.5080009@shadowen.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-mm@kvack.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

On Mon, 25 Sep 2006, Andy Whitcroft wrote:

> > Using a virtual memmap there would allow relocation of the memmap array 
> > into high memory and would double the available low memory. So may be 
> > worth even on this 32 bit platform to sacrifice 1/8th of the virtual 
> > address space for memmap.
> 
> How does moving to a virtual memmap help here.  The virtual mem_map also
> has to be allocated in KVA, any KVA used for it is not available to and
> thereby shrinks the size of zone NORMAL?  The size of NORMAL in x86 is
> defined by the addressable space in kernel mode (by KVA size), 1GB less
> other things we have mapped.  Virtual map would be one of those.

Hmmm... Strange architecture and I may be a bit ignorant on this one. You 
could reserve the 1G for kernel 1-1 mapped. 2nd G for VMALLOC / virtual 
memmap and the remaining 2G for user space? Probably wont work since you 
would have to decrease user space from 3G to 2G?

Having the virtual memmap in high memory also allows you to place the 
sections of the memmap that map files of that node into the memory of the 
node itself. This alone would get you a nice performance boost.

> > So far I am not seeing any convincing case for the current sparsemem table 
> > lookups. But there must have been some reason that such an implementation 
> > was chosen. What was it?
> 
> As I said the problem is not memory but KVA space.  Zone normal is all
> the pages we can map into the kernel address space, its 1Gb less the
> kernel itself, less vmap space.  In the current NUMA scheme its then
> less the mem_map allocated out of HIGHMEM but mapped into KVA.  In
> vmem_map its allocated out of HIGHMEM but mapped into KVA.  The loss is
> the same.

Yup the only way around would be to decrease user space sizes.

But then we are talking about a rare breed of NUMA machine, right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
