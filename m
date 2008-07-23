Date: Wed, 23 Jul 2008 16:12:30 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: GRU driver feedback
Message-ID: <20080723141229.GB13247@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi Jack,

Some review of the GRU driver. Hope it helps. Some trivial.

- I would put all the driver into a single patch. It's a logical change,
  and splitting them out is not really logical. Unless for example you
  start with a minimally functional driver and build more things on it,
  I don't think there is any point avoiding the one big patch. You have to
  look at the whole thing to understand it properly anyway really.

  Although I guess you could leave the kernel API parts in another patch
  and maybe even leave them out until you have a good user of them...
  
- GRU driver -- gru_intr finds mm to fault pages from, does an "atomic pte
  lookup" which looks up the pte atomically using similar lockless pagetable
  walk from get_user_pages_fast. This only works because it can guarantee page
  table existence by disabling interrupts on the CPU where mm is currently
  running.  It looks like atomic pte lookup can be run on mms which are not
  presently running on the local CPU. This would have been noticed if it had
  been using a specialised function in arch/*/mm/gup.c, because it would not
  have provided an mm_struct parameter ;)

- Which leads me to my next observation, the GRU TLB fault code _really_ would
  like to work the same way as the CPU's fault handler, and that is to
  synchronously enter the kernel and run in process context of the faulting
  task.  I guess we can't do this because the GRU isn't going to be accessing
  pages synchronously as the commands are sent to it, right? I guess you could
  have a kernel thread to handle GRU faults... but that could get into fairness
  and parallelism issues, and also wouldn't be able to take advantage of
  lockless pagetable walking either (although maybe they're not such a big deal?
  I imagine that asking the user process to call into the kernel to process
  faults isn't optimal either). Is there a completely different approach that
  can be taken? Ideally we want the 

- "options" in non-static scope? Please change. Putting gru in any global
  symbols should be enough.

- gru_prefetch -- no users of this. This isn't intended to fault in a user
  virtual address, is it? (we already have generic kernel functions to do this).
  But as it isn't used, it may as well go away. And you have to remember if
  you need page tables set up then they can be torn down again at any time.
  Oh, maybe it is for possible vmalloc addresses? If so, then OK but please
  comment.

- start_instruction, wait_instruction_complete etc -- take a void pointer
  which is actually a pointer to one of a number of structures with a specific
  first int. Ugly. Don't know what the preferred form is, it's probably 
  something device writers have to deal with. Wouldn't something like this
  be better for typing?

  typedef unsigned int gru_insn_register_t; /* register with cmd bit as lsb */
  struct context_configuration_handle {
	union {
		gru_insn_register_t insn_reg;
		struct {
			unsigned int cmd:1;
			/* etc */
		};
	}
  };

  void start_instruction(gru_insn_register_t *reg);

  Even coding it as a macro would be better because you'd then avoid the
  void * -> cast and get the type checking.

- You're using gru_flush_cache for a lot of things. Is the device not coherent
  with CPU caches? (in which case, should the DMA api be used instead?) Or is it
  simply higher performing if you invalidate the CPU cache ahead of time so the
  GRU probe doesn't have to?

- In gru_fault, the while() should be an if(), it would be much nicer to use a
  waitqueue or semaphore to allocate gru contexts (and if you actively need to
  steal a context to prevent starvation, you can use eg down_timeout()).

- You use prefetchw around the place and say it is sometimes required for
  correctness. Except it would be free to be ignored (say if the CPU didn't
  have a TLB entry or full prefetch queue, or even the Linux implementatoin
  could be a noop).

- In gru_fault, I don't think you've validated the size of the vma, and it
  definitely seems like you haven't taken offset into the vma into account
  either. remap_pfn_range etc should probably validate the former because I'm
  sure this isn't the only driver that might get it wrong. The latter can't
  really be detected though. Please fix or make it more obviously correct (eg
  a comment).

  - And please make sure in general that this thing properly fixes/rejects
    nasty code and attempts to crash the kernel. I'm sure it can't be used,
    for example, write into readonly pages or read from kernel memory etc.
    (I'm sure you're very concious of this, but humour me! :P) 

- I have a rough handle on it, but can you sketch out exactly how it is used,
  and how the virtual/physical/etc memory activity happens? Unfortunately, in
  its present state, this is going to have to be something that mm/ developers
  will have to get an understanding of, and I'm a bit lost when it comes to
  driver code. (Or have I missed some piece of documentation?) Although there
  are a lot of comments, most are fairly low level. I want a high level
  overview and description of important interactions. I agree with Hugh in
  some respects GRU is special, the bar is a bit higher than the average
  driver.

  As far as I understand it A process can use GRU to accelerate some memory and
  simple transformation operations. This can only occur within the address
  space of a single mm (and by the looks you have some kernel kva<->kva
  interfaces there too?)

  OK, and the way for a user to operate the GRU you have provided is to mmap
  /dev/gru, which gives the process essentially an mmio control page (Oh, it's
  big, maybe that's more than a control area? Anyway let's call it a control
  area...).

  So the user can stuff some commands into it (that can't possibly take down
  the machine? Or if they could then /dev/gru is root only? ;)) Such as
  giving it some user virtual addresses and asking it to copy from one to
  the other or something much cooler.

  User faults writing to control area, driver steals context (by zapping ptes)
  from process currently using it, and hands it to us.
  
  Then GRU faults on the new virtual address it is being asked to operate on,
  and raises an interrupt. Interrupt handler finds the process's physical
  address from virtual and stuffs it into the GRU. The GRU and the process
  are each now merrily doing their own thing. If the process calls a fork()
  for example and some virtual addresses need to be write protected, we must
  also ensure the GRU can't write to these either so we need to invalidate
  its TLB before we can continue.

  GRU TLB invalidation is done with mmu notifiers... I'll think about this
  some more because I'll have more comments on mmu notifiers (and probably
  GRU TLB invalidation).

- Finally: what is it / can it be used for? What sort of performance numbers
  do you see? This whole TLB and control page scheme presumably is to avoid
  kernel entry at all costs... the thing is, the GRU is out on the IO bus
  anyway, and is going to be invalidating the CPU's cache in operation. It's
  going to need to be working on some pretty big memory areas in order to
  be a speedup I would have thought. In which case, how much extra overhead
  is a syscall or two? A syscall register and unregister the memory in
  question would alleviate the need for the whole TLB scheme, although
  obviously it would want to be unregistered or care taken with something
  like fork... So, a nice rationale, please. This is a fair hunk of
  complexity here :P

Meanwhile, I hope that gives a bit to go on. I'm sorry it has come relatively
late in the game, but I had a week off a while back then had (have) some
important work work I'm starting to get a handle on...

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
