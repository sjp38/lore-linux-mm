Received: from localhost (root@localhost)
	by ppp-pat138.tee.gr (8.8.5/8.8.5) with SMTP id RAA00814
	for <linux-mm@kvack.org>; Wed, 12 Apr 2000 17:46:01 +0300
Date: Wed, 12 Apr 2000 17:45:59 +0300 (EEST)
From: Stelios Xanthakis <root@ppp-pat138.tee.gr>
Reply-To: axanth@tee.gr
Subject: Stack & policy
Message-ID: <Pine.LNX.3.95.1000412174014.810A-100000@ppp-pat138.tee.gr>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi 

Some time ago I posted a message about a kernel feature where the
application can request the vma->vm_start of its stack virtual memory area
in order to unmap part of the unused stack (esp - vma->vm_start).

Such a feature is very useful for an alternative programming technique.

gcc and libc provide a function called alloca(x). This function allocates x
bytes in the stack frame of the caller, and therefore this space is
automatically available to the program as soon as the function which invoked
alloca returns.

alloca has a few major advantages:
 - very elegant code since we do not worry for freeing the allocated space.
 - very fast allocations because of no fragmentation in the stack space

Here is an example of a nice alloca use. Suppose the function getline()
which gets a line of any size from a client.

char *getline (FILE *f)
{
#define CHUNK_SIZE 200
#define MAX_LINE 1024*1024
	struct chunk {
		char txt [CHUNK_SIZE];
		struct chunk *next;
	} first_chunk, *cur = &first_chunk;
	int i, j, k;
	char *c;

	for (j = 0;; j++) {
		if (j >= MAX_LINE / CHUNK_SIZE) return NULL;
		i = fread (cur->txt, 1, CHUNK_SIZE, f);
		if (i < CHUNK_SIZE) break;
		cur->next = (struct chunk*) alloca (sizeof (struct chunk));
		cur = cur->next;
	}

	c = (char*) malloc (j * CHUNK_SIZE + i);
	for (cur = &first_chunk, k = 0; k < j; k++, cur = cur->next)
		memcpy (c + k * CHUNK_SIZE, cur->txt, CHUNK_SIZE);
	memcpy (c + j * CHUNK_SIZE, cur->txt, i);
	c [j * CHUNK_SIZE + i + 1] = 0;

	return c;
}

Its a beauty!
No need to free the chunk list and we can even return NULL at any time.
On the other hand a version using malloc() would end up being 
"Doug Lea's Nightmare of malloc fragmentation" after some time.

There are many similar pieces of code in which stack allocations prove
efficient and result in great code.

However the above example suffers from one weakness. The kernel has a
stack-only-expands policy (and rightly so); therefore if our function gets a
very big line and expands the stack to 1MB, this huge stack segment will
remain until the termination of the program even if the rest calls to it get
the stack to 300 bytes.

This is the same reason why the code:

void init ()
{
	int tmp [10000];
	...
}

is a shooting offence.


The C Programming language, implies that automatic variables (and alloca()s
in our case) are only used until their scope ends. In the words of OS that
means that space for automatic variables is not returned to the OS after the
function which declared them returns, but they are reserved by the program
for future stack requirements.

I propose a way where an application will be able to release part of its
unused stack if it wants.
We can use the already existing prctl() system call with a new option
PR_GET_STKBOTTOM in order to get the vma->vm_start of the stack area.
Then we can unmap part of the unused stack.

Application will be able to define a directive:
--------------------------------
#include <linux/prctl.h>
#include <asm/page.h>

#define MIN_UNUSED_STACK 2*PAGE_SIZE

#ifdef PR_GET_STKBOTTOM

#define PAGE_DALIGN(x) ((x) & PAGE_MASK))  /* downwards alignment for esp */

#define STACKFIX {\
	unsigned long sb, esp, len;\
	prctl (PR_GET_STKBOTTOM, (unsinged long*)&sb, 0, 0, 0);\
	__asm__ ("mov %%esp,%0"::"m"(esp));\
	len = (sb < PAGE_DALIGN(esp)) ? PAGE_DALIGN(esp)-sb : 0;\
	if (len >= MIN_UNUSED_STACK) munmap ((void*)sb, len);\
	}

#else

#define STACKFIX ;

#endif
-----------------------------------


Calling STACKFIX will return pages from the unused stack to the operating
system. This is a good thing to do occasionaly and on strategic locations in
our application.

In the previous message, Kanoj pointed that:
 1. Only if the app touches the stack pages will they be allocated.

 - indeed but the declaration of an automatic variable implies its usage.
   If there are automatic variables that may not be used then the function
   should be broken in to more functions so we use 100% what we declare.

 2. Programs might have multiple stack segments. Pthreads?

 - the kernel does not have to do anything dangerous. Just provide the
   vma->vm_start to us. 99% of the programs may use this info to release
   stack. If a program has multiple stack segments the authors will avoid
   using this feature. I think pthreads should be Ok BTW.

 3. We can get the same info from /proc/pid/maps.

 - that is very slow to be actually usable in our loops.


I have a patch for the new version of prctl() with the PR_GET_STKBOTTOM
option. I'm not very happy with the fact that in order to get to the stack
vmarea we have to walk through the entire mm->mmap list since the stack vma
is always the last?
Is there a faster way to get to the vm_start of the last mmap'd area?


Your comments?


Cheers

Stelios
<axanth@tee.gr>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
