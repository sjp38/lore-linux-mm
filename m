Received: from localhost (root@localhost)
	by ppp-pat141.tee.gr (8.8.5/8.8.5) with SMTP id RAA00467
	for <linux-mm@kvack.org>; Wed, 8 Mar 2000 17:06:04 +0200
Date: Wed, 8 Mar 2000 17:06:02 +0200 (EET)
From: Stelios Xanthakis <root@ppp-pat141.tee.gr>
Reply-To: axanth@tee.gr
Subject: Shrinking stack
Message-ID: <Pine.LNX.3.95.1000308170518.465B-100000@ppp-pat141.tee.gr>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Hi,

Consider this feature (I personally need very much:).

The stack of a process only expands, yes?
It is possible to release part of the unused stack by munmap() if we
know the start of the stack vma area.

Why is this interesting:

A classic question in C programming is, should we use the stack for
allocating temporary space? With the current implementation the following
code is bad:

void init ()
{
	int tmp [100000];
	....
}

The stack space will remain at 400kB even if the rest of the program only
needs up to 10kB. (I have a patch to view the unused stack through /proc)

Now the above code example is extreme but before a big project is started
we'll have to choose whether we will use malloc() or alloca() for
temporary space. alloca() is fast and efficient but with the
stack-only-expands policy (which is ok since stack usage occurs in
bursts and the kernel doesn't know when to release unused stack), it is
very possible to end up with lots of stack most of which is unused.

I can provide some examples of very-interesting code with alloca() which
is better in all aspects than a malloc() version (speed, fragmentation,
code size). In the case an entire program's functions are based on
alloca() we do indeed suffer from the "unused stack syndrome" though.

I've implemented a patch where the kernel provides the vma->vm_start of
the stack area through prctl() syscall. Its very simple and adds very
little to the kernel code.
Once this call exists in the kernel and application may declare:
-----------stackfix.h-------------
#include <linux/prctl.h>
#include <asm/page.h>

#ifdef PR_GET_STKBOTTOM		/* We have get_stack_bottom */

#define PAGE_ALIGN(x) ((x) & PAGE_MASK) /* Downwards alignment for esp */

#define STACKFIX {\
	unsigned long sb, esp, len;\
	prctl (PR_GET_STKBOTTOM, (unsigned long)&sb, 0, 0, 0);\
	__asm__ ("mov %%esp,%0"::"m"(esp));\
	len = (sb < PAGE_ALIGN(esp)) ? PAGE_ALIGN(esp)-sb : 0;\
	if (len) munmap ((void*)sb, len);\
	}

#else				/* system doesn't have get_stack_bottom */

#define STACKFIX ;

#endif
--------------------------------

Whenever STACKFIX is called from a program is will reduce the unused stack
to < PAGE_SIZE.
We can then apply STACKFIX on important program locations. For example
applications as we know usually spend a lot of time blocked on parts that
get/send external things (select(),ipc..).

void client()		/* Our true `main' */
{
	while (1) {
		fgets (/*Get a request from the client*/);
		do_calculations();
		STACKFIX        <-----------------Good Place
	}
}


It probably seems obsolete, but one feels different after heavy alloca()
usage.

I'd be interested to discuss in depth the stack vs. dataseg allocations
for temporary space.


Regards

Stelios
<axanth@tee.gr>




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
