Date: Wed, 5 Jun 2002 17:45:33 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Oops in pte_chain_alloc (rmap 12h applied to vanilla 2.4.18) (fwd)
Message-ID: <Pine.LNX.4.44L.0206051744060.20636-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Michael Chapman <mchapman@student.usyd.edu.au>
List-ID: <linux-mm.kvack.org>

forwarded to linux-mm ... I'm still on holidays ;)

In the mean time, do you have your test program available
somewhere so other people can reproduce the problem ?

---------- Forwarded message ----------
Date: Thu, 6 Jun 2002 06:21:08 +1000 (EST)
From: Michael Chapman <mchapman@beren.hn.org>
Reply-To: Michael Chapman <mchapman@student.usyd.edu.au>
To: riel@nl.linux.org
Subject: Oops in pte_chain_alloc (rmap 12h applied to vanilla 2.4.18)

Firstly, my apologies for mailing you directly. Please tell me if it is
more appropriate to bring this issue to the kernel mailing list instead
(or directly to you _and_ lkml?)

I am able to consistently cause kernel 2.4.18, patched only with rmap 12h,
to oops in the pte_chain_alloc function in rmap.c.

Under normal load the system would remain up for a few hours before
crashing, however I've found that a simple program that allocates and
frees memory all over the place fairly randomly is able to cause it to
oops almost immediately. Every single oops is on the same line in the
function:

static inline struct pte_chain * pte_chain_alloc(void)
{
        struct pte_chain * pte_chain;

        /* Allocate new pte_chain structs as needed. */
        if (!pte_chain_freelist)
                alloc_new_pte_chains();

        /* Grab the first pte_chain from the freelist. */
        pte_chain = pte_chain_freelist;
        pte_chain_freelist = pte_chain->next;  // *** OOPS OCCURS HERE
        pte_chain->next = NULL;

        return pte_chain;
}

It seems to be independent of any modules I have loaded at the time. In
fact, I have been able to cause the oops even in runlevel 1, with only the
ext3 and jbd modules loaded.

I compiled this kernel with gcc 2.96. The machine is an i686, with 384
Meg ram. The configuration I used was kernel-2.4.18-i686-debug.config
provided in Red Hat's 2.4.18-4 kernel source package. My reason for using
this config was that I had originally seen this oops occur with the Red
Hat kernel, and I wanted this 2.4.18+rmap kernel to be configured as
close as possible to the Red Hat one.

I've done extensive tests with memtest86 and cpuburn. Neither of these
indicated any problems at all.

I'm happy to provide more info if you need it.

Michael Chapman
mchapman@student.usyd.edu.au


----
  Oops trace: (ksymoops run post-mortem on 2.4.16)

ksymoops 2.4.4 on i686 2.4.16.  Options used
     -V (default)
     -K (specified)
     -L (specified)
     -O (specified)
     -m /boot/System.map-2.4.18 (specified)

Reading Oops report from the terminal
Jun  3 09:58:02 beren kernel: Unable to handle kernel paging request at
virtual address 14000000
Jun  3 09:58:03 beren kernel: c0134845
Jun  3 09:58:03 beren kernel: *pde = 00000000
Jun  3 09:58:03 beren kernel: Oops: 0000
Jun  3 09:58:03 beren kernel: CPU:    0
Jun  3 09:58:03 beren kernel: EIP:    0010:[<c0134845>]    Not tainted
Using defaults from ksymoops -t elf32-i386 -a i386
Jun  3 09:58:03 beren kernel: EFLAGS: 00010206
Jun  3 09:58:03 beren kernel: eax: 00000048   ebx: c1419818   ecx:
c0247764   edx: 14000000
Jun  3 09:58:03 beren kernel: esi: d2154d2c   edi: 12bdb067   ebp:
00000025   esp: d49e9e64
Jun  3 09:58:03 beren kernel: ds: 0018   es: 0018   ss: 0018
Jun  3 09:58:03 beren kernel: Process crash (pid: 1202,
stackpage=d49e9000)
Jun  3 09:58:03 beren kernel: Stack: c013454e c1419818 d2154d2c c01244b6
00000001 d7812494 40f4b000 00000001
Jun  3 09:58:07 beren kernel:        c01244f7 d7812494 d6fbb65c d2154d2c
00000001 40f4b000 d49e8000 40eb1000
Jun  3 09:58:07 beren kernel:        d494840c d7812494 d6fbb65c d7812494
40f4b000 00000001 c012479a d7812494
Jun  3 09:58:07 beren kernel: Call Trace: [<c013454e>] [<c01244b6>]
[<c01244f7>] [<c012479a>] [<c0124c34>]
Jun  3 09:58:07 beren kernel:    [<c0113a2a>] [<da8c98ad>] [<da8c98c0>]
[<da8c98cb>] [<c011e3c3>] [<c011ac1b>]
Jun  3 09:58:07 beren kernel:    [<c0114632>] [<c01138a0>] [<c010700c>]
Jun  3 09:58:07 beren kernel: Code: 8b 02 a3 c8 d7 2a c0 89 d0 c7 02 00 00
00 00 c3 8d 74 26 00

>>EIP; c0134845 <pte_chain_alloc+15/30>   <=====
Trace; c013454e <page_add_rmap+2e/40>
Trace; c01244b6 <do_anonymous_page+f6/100>
Trace; c01244f7 <do_no_page+37/210>
Trace; c012479a <handle_mm_fault+ca/150>
Trace; c0124c34 <__vma_link+64/c0>
Trace; c0113a2a <do_page_fault+18a/4cb>
Trace; da8c98ad <END_OF_CODE+1a5de255/????>
Trace; da8c98c0 <END_OF_CODE+1a5de268/????>
Trace; da8c98cb <END_OF_CODE+1a5de273/????>
Trace; c011e3c3 <timer_bh+213/250>
Trace; c011ac1b <bh_action+1b/50>
Trace; c0114632 <schedule+2f2/320>
Trace; c01138a0 <do_page_fault+0/4cb>
Trace; c010700c <error_code+34/3c>
Code;  c0134845 <pte_chain_alloc+15/30>
00000000 <_EIP>:
Code;  c0134845 <pte_chain_alloc+15/30>   <=====
   0:   8b 02                     mov    (%edx),%eax   <=====
Code;  c0134847 <pte_chain_alloc+17/30>
   2:   a3 c8 d7 2a c0            mov    %eax,0xc02ad7c8
Code;  c013484c <pte_chain_alloc+1c/30>
   7:   89 d0                     mov    %edx,%eax
Code;  c013484e <pte_chain_alloc+1e/30>
   9:   c7 02 00 00 00 00         movl   $0x0,(%edx)
Code;  c0134854 <pte_chain_alloc+24/30>
   f:   c3                        ret
Code;  c0134855 <pte_chain_alloc+25/30>
  10:   8d 74 26 00               lea    0x0(%esi,1),%esi

----
  Program that causes the kernel to oops almost immediately:

#include <malloc.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>

/*
  This program is crude, but effective. Expect to oops the kernel
  after just a couple of seconds!

  Tweak these #defines as necessary.
  The current values work nicely for a box with 384 Megs of RAM.
*/
#define NUM_BUFFERS 100
#define MAX_BUFFER_SIZE 6553600

void main() {
        char* buffers[NUM_BUFFERS];
        int i, size;

        srandom(time(NULL));
        memset(buffers, 0, sizeof(void*) * NUM_BUFFERS);
        while (1) {
                for (i = 0; i < NUM_BUFFERS; ++i) {
                        if (buffers[i])
                                free(buffers[i]);
                        size = random() % (MAX_BUFFER_SIZE - 1) + 1;
                        buffers[i] = malloc(size);
                        memset(buffers[i], 1, size);
                }
        }
}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
