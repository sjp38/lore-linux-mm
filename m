Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id JAA01853
	for <linux-mm@kvack.org>; Thu, 10 Oct 2002 09:53:11 -0700 (PDT)
Message-ID: <3DA5B077.215D7626@digeo.com>
Date: Thu, 10 Oct 2002 09:53:11 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: Hangs in 2.5.41-mm1
References: <3DA4A06A.B84D4C05@digeo.com> <1034264750.30975.83.camel@plars>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Larson <plars@linuxtestproject.org>, Manfred Spraul <manfred@colorfullife.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Paul Larson wrote:
> 
> On Wed, 2002-10-09 at 16:32, Andrew Morton wrote:
> > -mm2 will cure all ills ;)
> 
> If only we could be so lucky! :)
> 
> Linux-2.5.41-mm2
> # echo 768 > /proc/sys/vm/nr_hugepages
> # echo 1610612736 > /proc/sys/kernel/shmmax
> # ./shmt01
> ./shmt01: IPC Shared Memory TestSuite program
> 
>         Get shared memory segment (67108864 bytes)
> 
>         Attach shared memory segment to process
> 
>         Index through shared memory segment ...
> 
>         Release shared memory
> 
> successful!
> # ./shmt01 -s 1610612736./shmt01: IPC Shared Memory TestSuite program
> 
>         Get shared memory segment (1610612736 bytes)
> 
>         Attach shared memory segment to process
> 
>         Index through shared memory segment ...
> 
>         Release shared memory
> 
> successful!
> #
> *HANG*
> 

This is easy to reproduce; thanks for that.

I took an NMI watchdog hit in the slab code.  It would appear
that the loop in cache_alloc_refill() has gone infinite.

I assume slabp->inuse is >= cachep->num, so we're never
decrementing batchcount and the loop does not terminate.



Program received signal SIGEMT, Emulation trap.
0xc01357c7 in cache_alloc_refill (cachep=0xf7ffc740, flags=464) at mm/slab.c:1580
1580                    if (entry == &l3->slabs_partial) {
(gdb) bt
#0  0xc01357c7 in cache_alloc_refill (cachep=0xf7ffc740, flags=464) at mm/slab.c:1580
#1  0xc0135b1a in kmem_cache_alloc (cachep=0xf7ffc740, flags=464) at mm/slab.c:1670
#2  0xc0159c72 in alloc_inode (sb=0xf7f8a400) at fs/inode.c:99
#3  0xc015a3c5 in new_inode (sb=0xf7f8a400) at fs/inode.c:505
#4  0xc014f7ae in get_pipe_inode () at fs/pipe.c:510
#5  0xc014f867 in do_pipe (fd=0xf6693fb4) at fs/pipe.c:559
#6  0xc010ce01 in sys_pipe (fildes=0xbffff83c) at arch/i386/kernel/sys_i386.c:35
#7  0xc01070f3 in syscall_call () at net/sunrpc/stats.c:204
#8  0x0805c426 in ?? () at net/sunrpc/stats.c:204
#9  0x400177c0 in ?? () at net/sunrpc/stats.c:204
#10 0x0000001c in af_unix_exit () at arch/i386/kernel/cpuid.c:168
Cannot access memory at address 0x1
(gdb) p batchcount
$1 = 6
(gdb) p slabp->inuse
No symbol "slabp" in current context.
(gdb) p cachep->num
$2 = 12
(gdb) p/x *slabp
No symbol "slabp" in current context.
(gdb) p/x *cachep
$3 = {cpudata = {0xc3fe8000, 0xc3fe8200, 0xc3fe8400, 0xc3fe8600}, batchcount = 0x3c, limit = 0x78, lists = {slabs_partial = {
      next = 0xf6ace060, prev = 0xf7ed5000}, slabs_full = {next = 0xc3e67080, prev = 0xf7ff5000}, slabs_free = {
      next = 0xf7ffc768, prev = 0xf7ffc768}, free_objects = 0x20, free_touched = 0x0, next_reap = 0x1f9e4}, objsize = 0x140, 
  flags = 0x2000, num = 0xc, free_limit = 0x138, spinlock = {lock = 0xfe}, gfporder = 0x0, gfpflags = 0x0, colour = 0x5, 
  colour_off = 0x20, colour_next = 0x1, slabp_cache = 0x0, dflags = 0x0, ctor = 0xc0159f3c, dtor = 0x0, name = 0xc0271c05, 
  next = {next = 0xf7ffc738, prev = 0xf7ffc838}}
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
