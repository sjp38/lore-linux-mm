Date: Fri, 14 Apr 2000 16:10:43 +0300 (EEST)
From: Stelios Xanthakis <root@ppp-pat132.tee.gr>
Reply-To: axanth@tee.gr
Subject: Re: Stack & policy
In-Reply-To: <20000413023528.D27244@pcep-jamie.cern.ch>
Message-ID: <Pine.LNX.3.95.1000414160418.421A-100000@ppp-pat132.tee.gr>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <lk@tantalophile.demon.co.uk>
Cc: James Antill <james@and.org>, axanth@tee.gr, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Thu, 13 Apr 2000, Jamie Lokier wrote:

> You'd use MADV_FREE, as it allows the app to reuse stack pages
> immediately without the overhead of them being unmapped, remapped and
> rezeroed -- if it reuses them before the kernel finds another use for
> them.  The most efficiently place to put this call is probably in a
> timer signal handler.
> 
> You still need to get the base of the mapped region though.  You can
> parse /proc/self/maps for this :-)


/proc/self/maps might not be the best solution because:
 - too slow. Need to fopen the file, read all the lines up to the last,
   parse and strtoul.
 - most important, the format of proc info tends to change:) I think
   /proc/net/dev is an example..

On the other hand the whole `unmap something maitnained by the kernel' is
very hackerish anyway.


It would be possible to have a specific system call, say prune_stack(),
which will be taking as argument a pointer that represents a stack pointer;
when called, prune_stack would walk through the memory mapped areas for the
one which (VM_GROWSDOWN && vm_start <= sp <= vm_end).
If such an area is found and the base address of this virtual memory area
is `too far' from what the caller passed as stack pointer madvise() is called
with MADV_FREE to release what what is supposed to be unused stack.

That would also work in the case of multiple stack segments.

Passing the desired minimum unused stack is also a good hint to the
procedure.

/* Sample Prototype */
prune_stack (void *stack_pointer, unsigned int min_unused)



When apps should use prune_stack()

An optimum location for prune_stack would be on the main loop of an
application and provided two conditions are met.
 1. Right after prune_stack a function that may block is called.
 2. The functions called in the main loop have unpredictable stack
requirements (a Rayleigh distribution comes in mind:)

For example:

	while (1) {
		fgets (/*command from client*/);
		process_command ();    /* No blocking up here */
		__asm__("mov %%esp,%0"::"m"(sp));
		prune_stack (sp, 8*PAGE_SIZE);
	}

The min_unused is yet important because the processing functions may have
standard stack requirements plus the upredictable ones.


Normally, prune_stack() in the wrong location and/or with wrong min_unused
might introduce a slowdown.
madvise protects us against this; it would be better to release bottom pages
first though? Should this be passed as desired MADV_policy or is it the
default behaviour?




There seem to be 3 alternatives:
 1. Write a prune_stack() generic stack segment pruning system call.
 2. Provide the base address of the std stack segment through prctl() and
   call madvise.
 3. Parse /proc/self/maps and call madvise (no kernel changes).


Stelios
<sxanth@ceid.upatras.gr>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
