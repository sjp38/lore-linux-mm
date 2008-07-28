Date: Mon, 28 Jul 2008 12:36:05 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: Re: GRU driver feedback
Message-ID: <20080728173605.GB28480@sgi.com>
References: <20080723141229.GB13247@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080723141229.GB13247@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

I appreciate the thorough review. The GRU is a complicated device. I
tried to provide comments in the code but I know it is still difficult
to understand.

You appear to have a pretty good idea of how it works. I've added a
few new comments to the code to make it clearer in a few cases.



> 
> - I would put all the driver into a single patch. It's a logical change,
>   and splitting them out is not really logical. Unless for example you
>   start with a minimally functional driver and build more things on it,
>   I don't think there is any point avoiding the one big patch. You have to
>   look at the whole thing to understand it properly anyway really.
> 
>   Although I guess you could leave the kernel API parts in another patch
>   and maybe even leave them out until you have a good user of them...

The GRU driver is divided into multiple files - each supporting a
different functional area. I thought it was clearer to send the files
as separate patches to 1) make the function of the file/patch more
obvious, and 2) reduce the size of individual  patches. In the future,
if the community would prefer single patches (except for kernel API
changes, etc) for new drivers, I can do that.  However, I think it is
too late for the GRU. If Andrew prefers, however, I can resend as a
single patch.


>   
> - GRU driver -- gru_intr finds mm to fault pages from, does an "atomic pte
>   lookup" which looks up the pte atomically using similar lockless pagetable
>   walk from get_user_pages_fast. This only works because it can guarantee page
>   table existence by disabling interrupts on the CPU where mm is currently
>   running.  It looks like atomic pte lookup can be run on mms which are not
>   presently running on the local CPU. This would have been noticed if it had
>   been using a specialised function in arch/*/mm/gup.c, because it would not
>   have provided an mm_struct parameter ;)

Existence of the mm is guaranteed thru an indirect path. The  mm
struct cannot go away until the GRU context that caused the interrupt
is unloaded.  When the GRU hardware sends an interrupt, it locks the
context & prevents it from being unloaded until the interrupt is
serviced.  If the atomic pte is successful, the subsequent TLB dropin
will unlock the context to allow it to be unloaded. The mm can't go
away until the context is unloaded.

If the atomic pte fails, the TLB miss is converted to a different kind
of TLB miss that must be handled in user context. This is done using
"tfh_user_polling_mode(tfh)" (see failupm:). This also unlocks the
context and allows it to be unloaded - possibly without ever having
serviced the fault.

Does this cover the case you are concerned about or did I
misunderstand your question?


> 
> - Which leads me to my next observation, the GRU TLB fault code _really_ would
>   like to work the same way as the CPU's fault handler, and that is to
>   synchronously enter the kernel and run in process context of the faulting
>   task.  I guess we can't do this because the GRU isn't going to be accessing
>   pages synchronously as the commands are sent to it, right? I guess you could
>   have a kernel thread to handle GRU faults... but that could get into fairness
>   and parallelism issues, and also wouldn't be able to take advantage of
>   lockless pagetable walking either (although maybe they're not such a big deal?
>   I imagine that asking the user process to call into the kernel to process
>   faults isn't optimal either). Is there a completely different approach that
>   can be taken? Ideally we want the 

(Did some text get dropped from the above).

Your observation is correct. However, some GRU instructions can take a
considerable amount of time to complete and faults can occur at
various points thruout the execution of the instruction. For example,
a user could do a bcopy of a TB of data. I'm not sure how long that
takes but it is not quick (wish it was :-).

The user can also have up to 128 instructions simulataneously active
on each GRU context (usually 1 per task but could be more).

Using interrupts for TLB miss notification seems like the only viable
solution.  Long term, we do plan to support a kernel thread for TLB
dropins.

Another option that has been discussed is to use the buddy HT in the
same cpu core as a helper to do the dropins. The buddy HT is generally
not useful for many classes of HPC codes. Using the HT to perform TLB
dropins is an intriguing idea.


> 
> - "options" in non-static scope? Please change. Putting gru in any global
>   symbols should be enough.

Yuck...  Fixed.


> 
> - gru_prefetch -- no users of this. This isn't intended to fault in a user
>   virtual address, is it? (we already have generic kernel functions to do this).
>   But as it isn't used, it may as well go away. And you have to remember if
>   you need page tables set up then they can be torn down again at any time.
>   Oh, maybe it is for possible vmalloc addresses? If so, then OK but please
>   comment.

Fixed (deleted).


> 
> - start_instruction, wait_instruction_complete etc -- take a void pointer
>   which is actually a pointer to one of a number of structures with a specific
>   first int. Ugly. Don't know what the preferred form is, it's probably 
>   something device writers have to deal with. Wouldn't something like this
>   be better for typing?
> 
>   typedef unsigned int gru_insn_register_t; /* register with cmd bit as lsb */
>   struct context_configuration_handle {
> 	union {
> 		gru_insn_register_t insn_reg;
> 		struct {
> 			unsigned int cmd:1;
> 			/* etc */
> 		};
> 	}
>   };
> 
>   void start_instruction(gru_insn_register_t *reg);
> 
>   Even coding it as a macro would be better because you'd then avoid the
>   void * -> cast and get the type checking.

I'll put this idea on a list for future consideration.


> 
> - You're using gru_flush_cache for a lot of things. Is the device not coherent
>   with CPU caches? (in which case, should the DMA api be used instead?) Or is it
>   simply higher performing if you invalidate the CPU cache ahead of time so the
>   GRU probe doesn't have to?

The device IS coherent. All GRU ontexts are mapped as normal WB memory.

The gru_flush_cache serves several purposes.  For new instructions,
the cpu needs to kick the instruction out of the cpu caches in order
for it to be seen by the GRU. In other cases, the flushes improve
performance by eliminating GRU probes.

> 
> - In gru_fault, the while() should be an if(), it would be much nicer to use a
>   waitqueue or semaphore to allocate gru contexts (and if you actively need to
>   steal a context to prevent starvation, you can use eg down_timeout()).

Fixed.

The logic to steal contexts is a terrible hack. Although it works, it
would do a poor job of handling oversubscription of GRU resources of a
real workload.  This area will be replaced but first we need to decide
how reservation of GRU resources will be done. May involve changes to
the batch scheduler.

I'll keep down_timeout() in mind...


> 
> - You use prefetchw around the place and say it is sometimes required for
>   correctness. Except it would be free to be ignored (say if the CPU didn't
>   have a TLB entry or full prefetch queue, or even the Linux implementatoin
>   could be a noop).

AFAICT, all of the calls to prefetchw() are performance optimizations.
Nothing breaks if the requests are ignored. The one exception is when
running on the hardware simulator. prefetchw() is required on the
simulator.

Most calls to prefetchw() have the comment:
	/* Helps on hardware, required for emulator */

I added comments where it was missing.


> 
> - In gru_fault, I don't think you've validated the size of the vma, and it
>   definitely seems like you haven't taken offset into the vma into account
>   either. remap_pfn_range etc should probably validate the former because I'm
>   sure this isn't the only driver that might get it wrong. The latter can't
>   really be detected though. Please fix or make it more obviously correct (eg
>   a comment).

ZZZ


> 
>   - And please make sure in general that this thing properly fixes/rejects
>     nasty code and attempts to crash the kernel. I'm sure it can't be used,
>     for example, write into readonly pages or read from kernel memory etc.
>     (I'm sure you're very concious of this, but humour me! :P) 
> 
> - I have a rough handle on it, but can you sketch out exactly how it is used,
>   and how the virtual/physical/etc memory activity happens? Unfortunately, in
>   its present state, this is going to have to be something that mm/ developers
>   will have to get an understanding of, and I'm a bit lost when it comes to
>   driver code. (Or have I missed some piece of documentation?) Although there
>   are a lot of comments, most are fairly low level. I want a high level
>   overview and description of important interactions. I agree with Hugh in
>   some respects GRU is special, the bar is a bit higher than the average
>   driver.

I added some text and a diagram to "grutables.h".


> 
>   As far as I understand it A process can use GRU to accelerate some memory and
>   simple transformation operations. This can only occur within the address
>   space of a single mm (and by the looks you have some kernel kva<->kva
>   interfaces there too?)

Correct.

The GRU driver also exports a few interfaces to the XPC/XPMEM drivers.
These allow for use oif the GRU for cross partition access. The GRU
uses physical addressing mode for all kernel level instructions.


> 
>   OK, and the way for a user to operate the GRU you have provided is to mmap
>   /dev/gru, which gives the process essentially an mmio control page (Oh, it's
>   big, maybe that's more than a control area? Anyway let's call it a control
>   area...).

Correct (although we refer to it as a gru context). And it's not mmio.


> 
>   So the user can stuff some commands into it (that can't possibly take down
>   the machine?

Correct.


> Or if they could then /dev/gru is root only? ;)) Such as
>   giving it some user virtual addresses and asking it to copy from one to
>   the other or something much cooler.

The GRU is user-safe. GRU instructions in general can't do anything
that a user could not do using normal load/store/AMO instructions. The
one exception is that users can directly reference across SSIs using
numalink. However, these references still go thru the GRU TLB and have
full validation of all accesses.


> 
>   User faults writing to control area, driver steals context (by zapping ptes)
>   from process currently using it, and hands it to us.

Correct, although in theory no "steal" is needed because a batch
scheduler did the necessary resource reservation. However, in some
cases, a "steal" may occur.


>   
>   Then GRU faults on the new virtual address it is being asked to operate on,
>   and raises an interrupt. Interrupt handler finds the process's physical
>   address from virtual and stuffs it into the GRU. The GRU and the process
>   are each now merrily doing their own thing. If the process calls a fork()
>   for example and some virtual addresses need to be write protected, we must
>   also ensure the GRU can't write to these either so we need to invalidate
>   its TLB before we can continue.

Correct.


> 
>   GRU TLB invalidation is done with mmu notifiers... I'll think about this
>   some more because I'll have more comments on mmu notifiers (and probably
>   GRU TLB invalidation).

Correct.


> 
> - Finally: what is it / can it be used for? What sort of performance numbers
>   do you see? This whole TLB and control page scheme presumably is to avoid
>   kernel entry at all costs... the thing is, the GRU is out on the IO bus

No. The GRU is not on an IO bus. It is an integral part of the
chipset. Specifically, it is on the node-controller that connects
directly to a port on the cpu socket.



>   anyway, and is going to be invalidating the CPU's cache in operation. It's
>   going to need to be working on some pretty big memory areas in order to
>   be a speedup I would have thought. In which case, how much extra overhead
>   is a syscall or two? A syscall register and unregister the memory in
>   question would alleviate the need for the whole TLB scheme, although
>   obviously it would want to be unregistered or care taken with something
>   like fork... So, a nice rationale, please. This is a fair hunk of
>   complexity here :P
> 

A single GRU (in the node controler) can support up to 16 user
contexts, each running asynchronously and all sharing the same TLB.
Since each user can potentially access ANY virtual address, it is not
practical to explicitly lock addresses. GRU instructions can also be
strided or can use scater/gather lists. Again, explicit locking is not
practical because the number of entries that would need to be locked
is unbounded.


On Thu, Jul 24, 2008 at 12:41:50PM +1000, Nick Piggin wrote:
> 
> Couple of other things I noticed today before I launch into the mmu
> notifier and TLB invalidate code proper.
> 
> - gru_invalidate_range_end -- atomic_dec can filter into wake_up_all, past
>   the spin_lock in __wake_up, and past the loading of the list of tasks. So
>   you can lose a wakeup I believe (not on x86, but on ia64 with release
>   ordering spinlocks it would be possible). atomic_dec_and_test should do
>   the trick, and you might also want to consider memory ordering of the
>   atomic_inc (haven't really looked, but it seems quite suspicious to allow
>   it be reordered).

Fixed. (Nice catch... I wonder if we could ever have debugged this failure)


> 
> - you seem to be using cache flushes and memory barriers in different ways
>   but each to push out things to the GRU device. For example start_instruction
>   does a wmb() then a store, then a CPU cache flush.

Correct. Setting bit 0 (cmd bit) MUST be done last. Starting a new instruction
consists of a number of stores of instruction parameters followed by setting
the cmd bit to indicate a new instructions. The wmb() ensures that all parameters
are in the instruction BEFORE the cmd bit is set.

After setting the cmd bit, the cacheline is flushed to the GRU to start the
instruction.


> 
>   I'm lost as to how the mmio protocol actually works (not the low level
>   protocol, but exactly what cache attributes are used, and how the CPU
>   pushes things to the device and vice versa).

Not MMIO. All GRU accesses use fully coherent WB memory.


> 
>   For example, if you are using wmb(), this I think implies you are using
>   UC or WC memory to map the device, in which case I don't see why you need
>   the gru_flush_cache (which would suggest WB memory). Is this documented
>   somewhere?

Added to the new text in gruhandles.h.


Here is a copy of the text I added:

-----------------------------------------------------------------
/*
 * GRU Chiplet:
 *   The GRU is a user addressible memory accelerator. It provides
 *   several forms of load, store, memset, bcopy instructions. In addition, it
 *   contains special instructions for AMOs, sending messages to message
 *   queues, etc.
 *
 *   The GRU is an integral part of the node controller. It connects
 *   directly to the cpu socket. In its current implementation, there are 2
 *   GRU chiplets in the node controller on each blade (~node).
 *
 *   The entire context is fully coherent and cacheable by the cpus.
 *
 *   Each GRU chiplet has a physical memory map that looks like the following:
 *
 *      +-----------------+
 *      |/////////////////|
 *      |/////////////////|
 *      |/////////////////|
 *      |/////////////////|
 *      |/////////////////|
 *      |/////////////////|
 *      |/////////////////|
 *      |/////////////////|
 *      +-----------------+
 *      |  system control |
 *      +-----------------+        _______ +-------------+
 *      |/////////////////|       /        |             |
 *      |/////////////////|      /         |             |
 *      |/////////////////|     /          | instructions|
 *      |/////////////////|    /           |             |
 *      |/////////////////|   /            |             |
 *      |/////////////////|  /             |-------------|
 *      |/////////////////| /              |             |
 *      +-----------------+                |             |
 *      |   context 15    |                |  data       |
 *      +-----------------+                |             |
 *      |    ......       | \              |             |
 *      +-----------------+  \____________ +-------------+
 *      |   context 1     |
 *      +-----------------+
 *      |   context 0     |
 *      +-----------------+
 *
 *   Each of the "contexts" is a chunk of memory that can be mmaped into user
 *   space. The context consists of 2 parts:
 *
 *      - an instruction space that can be directly accessed by the user
 *        to issue GRU instructions and to check instruction status.
 *
 *      - a data area that acts as normal RAM.
 *
 *   User instructions contain virtual addresses of data to be accessed by the
 *   GRU. The GRU contains a TLB that is used to convert these user virtual
 *   addresses to physical addresses.
 *
 *   The "system control" area of the GRU chiplet is used by the kernel driver
 *   to manage user contexts and to perform functions such as TLB dropin and
 *   purging.
 *
 *   One context may be reserved for the kernel and used for cross-partition
 *   communication. The GRU will also be used to asynchronously zero out
 *   large blocks of memory (not currently implemented).

--- jack

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
