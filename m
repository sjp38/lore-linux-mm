Date: Sun, 15 Sep 2002 15:44:24 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Obtaining the kernel's PTEs
Message-ID: <20020915224424.GT2179@holomorphy.com>
References: <20020913221032.GM2179@holomorphy.com> <614E162E-C8EE-11D6-97BB-000393829FA4@cs.amherst.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <614E162E-C8EE-11D6-97BB-000393829FA4@cs.amherst.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Scott Kaplan <sfkaplan@cs.amherst.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Sep 15, 2002 at 05:02:01PM -0400, Scott Kaplan wrote:
> A-ha.  Not surprising, and it does look like it wouldn't be hard to force 
> the kernel to map its space using small pages.  Of course, that begs the 
> question, ``How much overhead will be introduced by using small pages?''  
> Increased space use for page table consumption and increased TLB misses 
> _could_ be significant, but it depends on the reference patterns of the 
> applications and the kernel itself.

Well, the worst case is losing around 8MB of ZONE_NORMAL to kernel PTE's
and some TLB thrashing overhead.


On Friday, September 13, 2002, at 06:10 PM, William Lee Irwin III wrote:
>> (1) Pagetables are only meaningful to a couple of machines, most notably
>>	i386 and m68k. The rest is pretty much software TLB or inverted.
>>	So there's zero accounting of the direct-mapping within the kernel
>>	for some machines, not sure which since I've not gone about the
>>	task of hunting for the answer to "What does everyone do when
>>	they've taken a TLB miss on kernelspace?" My suspicion is TLB
>>	entries are generated on the fly for what is not bolted.

On Sun, Sep 15, 2002 at 05:02:01PM -0400, Scott Kaplan wrote:
> First, the essentials (for me):  I just want to implement some 
> kernel-level changes for experimental purposes.  It needs to run only on 
> one platform.  So, if it just works on i386, that's fine for me.

Well, for that case one need only bear in mind the pagetable structures
are interpreted by hardware on i386, so utilizing PTE's to store
information may result in the installation of garbage translations or
confusing the swap handling code (which stores block addresses in PTE's).


On Sun, Sep 15, 2002 at 05:02:01PM -0400, Scott Kaplan wrote:
> Second, my curiosity:  I confess that I don't understand how a software 
> TLB or inverted page table obviates the need for a virtual->physical 
> mapping for the kernel.  Those are simply different mechanisms for 
> supporting the mapping task.  While the mapping information may be stored 
> and handled differently for other architectures, the kernel must have its 
> address space mapped onto the physical address space.  Or am I completely 
> misunderstanding you?

Linux' strategy with ZONE_NORMAL etc. uses a direct mapping, so virtual
to physical translation may be simply calculated via addition and
subtraction for kernel accesses to that region. The Linux pagetable
structures are relevant only for bookkeeping process translations and
dynamically configured kernel translations on such machines. I'm still
unaware if that's actually done by any of the software TLB architectures.


On Friday, September 13, 2002, at 06:10 PM, William Lee Irwin III wrote:
>> (2) The kernel is often mapped out using various tidbits of TLB magic not
>>	handled by user PTE manipulation routines. e.g. the G and PS bits
>>	on i386. i386 is even worse, as the PAT bit in a PTE has the same
>>	position as the PS bit in a PMD so a priori knowledge of mapping
>>	size is required.

On Sun, Sep 15, 2002 at 05:02:01PM -0400, Scott Kaplan wrote:
> What is the ``PAT bit''?  Wait, doesn't the PS bit on the PGD entry tell 
> you whether it points to a 4 MB page or whether the levels of indirection 
> to 4 KB pages continues?  Again, this issue seems to be more one of 
> curiosity for me, and not something essential to what I'm trying to do -- 
> but I would like to know to what you're referring, because I'm having 
> trouble understanding it.

The PAT bit selects translation attributes that I believe have to do
with cacheing. The PS bit does exactly what you suspect.


On Friday, September 13, 2002, at 06:10 PM, William Lee Irwin III wrote:
>>	Also, since the kernel translations at least on i386 use the G
>>	bit which is basically "invalidate the TLB entry only when a
>>	specific page is targeted." This is also not a particularly
>>	friendly feature...

On Sun, Sep 15, 2002 at 05:02:01PM -0400, Scott Kaplan wrote:
> I don't think this feature is a problem for what I want to do.  I'm aiming 
> to change the protection on individual pages, so changing the PTE and then 
> invalidating that specific mapping in the TLB is exactly what I want.

You could probably get away with trapping in-kernel accesses so long as
do_page_fault() reinstates the translation after the access is trapped
and allocations aren't required to do so, and maybe doublecheck to be
sure page_fault() (the assembly fault handler installed in the IDT that
jumps to do_page_fault() etc.) won't shoot you for faulting on it. Also
beware of taking faults prior to the set_intr_gate() for page_fault()
in trap_init(), done right after parse_options() in start_kernel().


Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
