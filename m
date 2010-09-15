Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 99F956B007D
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 04:02:51 -0400 (EDT)
Date: Wed, 15 Sep 2010 10:02:35 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [RFC][PATCH] Cross Memory Attach
Message-ID: <20100915080235.GA13152@elte.hu>
References: <20100915104855.41de3ebf@lilo>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100915104855.41de3ebf@lilo>
Sender: owner-linux-mm@kvack.org
To: Christopher Yeoh <cyeoh@au1.ibm.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


(Interesting patch found on lkml, more folks Cc:-ed)

* Christopher Yeoh <cyeoh@au1.ibm.com> wrote:

> The basic idea behind cross memory attach is to allow MPI programs 
> doing intra-node communication to do a single copy of the message 
> rather than a double copy of the message via shared memory.
> 
> The following patch attempts to achieve this by allowing a destination 
> process, given an address and size from a source process, to copy 
> memory directly from the source process into its own address space via 
> a system call. There is also a symmetrical ability to copy from the 
> current process's address space into a destination process's address 
> space.
> 
> Use of vmsplice instead was considered, but has problems. Since you 
> need the reader and writer working co-operatively if the pipe is not 
> drained then you block. Which requires some wrapping to do non 
> blocking on the send side or polling on the receive. In all to all 
> communication it requires ordering otherwise you can deadlock. And in 
> the example of many MPI tasks writing to one MPI task vmsplice 
> serialises the copying.
> 
> I've added the use of this capability to OpenMPI and run some MPI 
> benchmarks on a 64-way (with SMT off) Power6 machine which see 
> improvements in the following areas:
> 
> HPCC results:
> =============
> 
> MB/s			Num Processes	
> Naturally Ordered	4	8	16	32
> Base			1235	935	622	419
> CMA			4741	3769	1977	703
> 
> 			
> MB/s			Num Processes	
> Randomly Ordered	4	8	16	32
> Base			1227	947	638	412
> CMA			4666	3682	1978	710
> 				
> MB/s			Num Processes	
> Max Ping Pong		4	8	16	32
> Base			2028	1938	1928	1882
> CMA			7424	7510	7598	7708
> 
> 
> NPB:
> ====
> BT - 12% improvement
> FT - 15% improvement
> IS - 30% improvement
> SP - 34% improvement
> 
> IMB:
> ===
> 		
> Ping Pong - ~30% improvement
> Ping Ping - ~120% improvement
> SendRecv - ~100% improvement
> Exchange - ~150% improvement
> Gather(v) - ~20% improvement
> Scatter(v) - ~20% improvement
> AlltoAll(v) - 30-50% improvement
> 
> Patch is as below. Any comments?

Impressive numbers!

What did those OpenMPI facilities use before your patch - shared memory 
or sockets?

I have an observation about the interface:

> +asmlinkage long sys_copy_from_process(pid_t pid, unsigned long addr,
> +				      unsigned long len,
> +				      char __user *buf, int flags);
> +asmlinkage long sys_copy_to_process(pid_t pid, unsigned long addr,
> +				    unsigned long len,
> +				    char __user *buf, int flags);

A small detail: 'int flags' should probably be 'unsigned long flags' - 
it leaves more space.

Also, note that there is a further performance optimization possible 
here: if the other task's ->mm is the same as this task's (they share 
the MM), then the copy can be done straight in this process context, 
without GUP. User-space might not necessarily be aware of this so it 
might make sense to express this special case in the kernel too.

More fundamentally, wouldnt it make sense to create an iovec interface 
here? If the Gather(v) / Scatter(v) / AlltoAll(v) workloads have any 
fragmentation on the user-space buffer side then the copy of multiple 
areas could be done in a single syscall. (the MM lock has to be touched 
only once, target task only be looked up only once, etc.)

Plus, a small naming detail, shouldnt the naming be more IO like:

  sys_process_vm_read()
  sys_process_vm_write()

Basically a regular read()/write() interface, but instead of fd's we'd 
have (PID,addr) identifiers for remote buffers, and instant execution 
(no buffering).

This makes these somewhat special syscalls a bit less special :-)

[ In theory we could also use this new ABI in a way to help the various 
  RDMA efforts as well - but it looks way too complex. RDMA is rather 
  difficult from an OS design POV - and this special case you have 
  implemented is much easier to do, as we are in a single trust domain. ]

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
