Received: from neumann.ece.iit.edu ([216.47.144.224])
	by kvack.org (8.8.7/8.8.7) with ESMTP id UAA16134
	for <linux-mm@kvack.org>; Tue, 9 Mar 1999 20:53:48 -0500
Date: Tue, 9 Mar 1999 19:51:32 -0600 (EST)
Message-Id: <199903100151.TAA00665@neumann.ece.iit.edu>
From: marco saraniti <saraniti@neumann.ece.iit.edu>
Subject: weird calloc problem
Reply-to: saraniti@ece.iit.edu
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi there,

I'm having a calloc problem that made me waste three weeks, at this point
I'm out of options, and I was wondering if this can be a kernel- or
MM-related problem. Furthermore, the system is a relatively big machine and
I'd like to share my experience with other people who are interested in
using Linux for number crunching.

The problem is trivial: calloc returns a NULL, even if there is a lot
of free memory. Yes, both arguments of calloc are always > 0.

The code is a big Monte Carlo simulation program, developed by myself
(mostly) and by several other people. The whole thing is more 60000
lines of C. What I can say is:

1) no use of sbrk, just malloc,calloc,realloc,free. There's no heavy
use of the calloc/free couple or of realloc.  The allocation occurs in
a cycle: data are computed in a statically allocated buffer, then the
right amount of memory is allocated, and the buffer is memcpyed into
the freshly allocated memory. Then the whole thing starts again for a
new set of data (using the same buffer). The dimension of the
allocated memory varies, from very small to several hundred KB. After
several thousand iterations (and five hours!)  calloc gives a
NULL. The problem doesn't occur if the program is forced to start a
few iterations before the critical one.

2) the process size increases exactly as the memory allocation counter
implemented in the program. This is the last vmstat report *before* the
calloc failure:

 procs                  memory    swap        io    system         cpu
 r b w  swpd  free  buff cache  si  so   bi   bo   in   cs  us  sy  id
 2 0 0     0 914960 387020 78600   0   0    0    0  117   53  49   3  48

3) when used, dmalloc (which uses sbrk) gives no errors, it just exits
complaining for not being able to increase the heap size.

4) the error is reproduced perfectly in subsequent runs, but it occurs at
different iterations if dmalloc is used, or if the compiler is changed, or
if the kernel is changed.

5) I tried kernel 2.2.1 and 2.2.3, compilers gcc2.7.2.3, pgcc1.1, egcs1.1.

6) I tried to swap the memory banks on the motherboard, no change.

The machine is a dual PII (400MHz) on a mboard supermicro P6DGE with
2GB of *non* ECC SDRAM (PC100). No IDE disks, everything is SCSI
(controller AHA 2940UW). The kernel has been compiled enabling SMP,
and after changing the value 0xC0000000 to 0x80000000 in
/usr/src/linux/arch/i386/vmlinux.lds and
/usr/src/linux/include/asm-i386/page.h. No "mem=" directive is used in
lilo.conf. I have four swap partitions, 128MB each. The netcard is a
SMC Etherpower II (10/100 PCI). There's also a awe64 soundcard. The
videocard is a matrox millennium G200 AGP.  The Linux distribution is
a plain RH5.2, Xserver Accelerated X and CDE, both from X-inside.

The question is even more trivial than the problem: what's wrong? Why
calloc refuses to allocate memory if there's a full GB of (apparently)
free RAM?

thanks a lot for your help, *any* suggestion will be appreciated.

                                              marco

PS please reply also to my email address, I'm not a subscriber of the
   mail list.



====================================================================
Marco Saraniti
Assistant Professor of Electrical and Computer Engineering

Department of Electrical and Computer Engineering #SH329
Illinois Institute of Technology - Main Campus
3301 South Dearborn
Chicago, IL 60616

Tel:   (312) 567 8813
Fax:   (312) 567 8976
email: saraniti@ece.iit.edu
www:   www.ece.iit.edu/Faculty/marco.html   
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
