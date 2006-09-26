Message-ID: <451917C4.1050603@shadowen.org>
Date: Tue, 26 Sep 2006 13:06:28 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: virtual mmap basics
References: <Pine.LNX.4.64.0609240959060.18227@schroedinger.engr.sgi.com> <4517CB69.9030600@shadowen.org> <Pine.LNX.4.64.0609250922040.23266@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0609250958370.23475@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0609251401260.24262@schroedinger.engr.sgi.com> <45185698.5080009@shadowen.org> <Pine.LNX.4.64.0609251631060.25028@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0609251631060.25028@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Mon, 25 Sep 2006, Andy Whitcroft wrote:
> 
>>> Using a virtual memmap there would allow relocation of the memmap array 
>>> into high memory and would double the available low memory. So may be 
>>> worth even on this 32 bit platform to sacrifice 1/8th of the virtual 
>>> address space for memmap.
>> How does moving to a virtual memmap help here.  The virtual mem_map also
>> has to be allocated in KVA, any KVA used for it is not available to and
>> thereby shrinks the size of zone NORMAL?  The size of NORMAL in x86 is
>> defined by the addressable space in kernel mode (by KVA size), 1GB less
>> other things we have mapped.  Virtual map would be one of those.
> 
> Hmmm... Strange architecture and I may be a bit ignorant on this one. You 
> could reserve the 1G for kernel 1-1 mapped. 2nd G for VMALLOC / virtual 
> memmap and the remaining 2G for user space? Probably wont work since you 
> would have to decrease user space from 3G to 2G?

Not strange?  Limited.  Any 32bit architecture has this limitation.
They can only map a limited amount of memory into the kernel at the same
time.

Yes some users already change their U/K split on 32bit do do this, but
as you say its not a general solution here.

> Having the virtual memmap in high memory also allows you to place the 
> sections of the memmap that map files of that node into the memory of the 
> node itself. This alone would get you a nice performance boost.

We already do this.  We don't allocate mem_map out of zone normal, we
pull it from the end of each node.  This is then mapped after the end of
zone normal and before vmap space.  mem_map is physically node local,
but mapped into KVA.

>>> So far I am not seeing any convincing case for the current sparsemem table 
>>> lookups. But there must have been some reason that such an implementation 
>>> was chosen. What was it?
>> As I said the problem is not memory but KVA space.  Zone normal is all
>> the pages we can map into the kernel address space, its 1Gb less the
>> kernel itself, less vmap space.  In the current NUMA scheme its then
>> less the mem_map allocated out of HIGHMEM but mapped into KVA.  In
>> vmem_map its allocated out of HIGHMEM but mapped into KVA.  The loss is
>> the same.
> 
> Yup the only way around would be to decrease user space sizes.
> 
> But then we are talking about a rare breed of NUMA machine, right?

We are talking about any 32bit NUMA.  Getting rarer yes.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
