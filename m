Received: from DELTA2001.deltacomputer.de (delta2001.delnet [194.175.217.229])
	by exchange.deltacomputer.de (Postfix) with SMTP id 247C77B78C
	for <linux-mm@kvack.org>; Tue, 14 Oct 2008 11:43:02 +0200 (CEST)
Received: from [194.175.217.230] (helo=exchange.deltacomputer.de)
	by DELTA2001.deltacomputer.de with AVK MailGateway;
	for <linux-mm@kvack.org>; Tue, 14 Oct 2008 11:43:01 +0200
Received: from exchange.deltacomputer.de (localhost [127.0.0.1])
	by exchange.deltacomputer.de (Postfix) with ESMTP id 2A2157B299
	for <linux-mm@kvack.org>; Tue, 14 Oct 2008 11:43:00 +0200 (CEST)
Message-ID: <2793369.1223977380170.SLOX.WebMail.wwwrun@exchange.deltacomputer.de>
Date: Tue, 14 Oct 2008 11:43:00 +0200 (CEST)
From: Oliver Weihe <o.weihe@deltacomputer.de>
Subject: NUMA allocator on Opteron systems does non-local allocation on node0
In-Reply-To: <1449471.1223892929572.SLOX.WebMail.wwwrun@exchange.deltacomputer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
References: <1449471.1223892929572.SLOX.WebMail.wwwrun@exchange.deltacomputer.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

I've sent this to Andi Kleen and posted this on lkml. Andi suggested to
sent it to this mailing list.


--- cut here (part 1) ---

> Hi Andi,
> 
> I'm not sure if you're the right person for this but I hope you are!
> 
> I've notived that the memory allocation on NUMA systems (Opterons)
> does
> memory allocation on non-local nodes for processes running node0 even
> if
> local memory is available. (Kernel 2.6.25 and above)
> 
> Currently I'm playing around with a quadsocket quadcore Opteron but
> I've
> observed this behavior on other Opteron systems aswell.
> 
> Hardware specs:
> 1x Supermicro H8QM3-2
> 4x Quadcore Opteron
> 16x 2GiB (8 GiB memory per node)
> 
> OS:
> currently openSUSE 10.3 but I've observed this on other distros aswell
> Kernel: 2.6.22.* (openSUSE) / 2.6.25.4 / 2.6.25.5 / 2.6.27 (vanilla
> config)
> 
> Steps to reproduce:
> Start an application which needs alot of memory and watch the memory
> usage per node (I'm using "watch -n 1 numastat --hardware" to watch
> the
> memory usage per node)
> A quick&dirty code which allocates a big array and writes data into
> the
> array is enough!
> 
> In my setup I'm allocating an array of ~7GiB memory size in a
> singlethreaded application.
> Startup: numactl --cpunodebind=X ./app
> For X=1,2,3 it works as expected, all memory is allocated on the local
> node.
> For X=0 I can see the memory beeing allocated on node0 as long as
> ~3GiB
> are "free" on node0. At this point the kernel starts using memory from
> node1 for the app!
> 
> For parallel realworld apps I've seen a performance penalty of 30%
> compared to older kernels!
> 
> numactl --cpunodebind=0 --membind=0 ./app "solves" the problem in this
> case but thats not the point!
> 
> -- 
> 
> Regards,
> Oliver Weihe

--- cut here (part 2) ---

> Hello,
> 
> it seems that my reproducer is not very good. :(
> It "works" much better when you start several processes at once.
> 
> for i in `seq 0 3`
> do
>   numactl --cpunodebind=${i} ./app &
> done
> wait
> 
> "app" still allocates some memory (7GiB per process) and fills the
> array
> with data.
> 
> 
> I've noticed this behaviour during some HPL (Linpack benchmark
> from/for
> top500.org) runs. For small data sets there's no difference in speed
> between the kernels while for big data sets (allmost the whole memory)
> 2.6.23 and newer kernels are slower than 2.6.22.
> I'm using OpenMPI with the runtime option "--mca mpi_paffinity_alone
> 1"
> to pin each process on a specific CPU.
> 
> The bad news is: I can crash allmost every Quadcore Opteron system
> with
> kernels 2.6.21.x to 2.6.24.x with "parallel memory allocation and
> filling the memory with data" (parallel means: there is one process
> per
> core doing this). While it takes some time on dualsocket machines it
> takes often less than 1 minute on quadsocket quadcores until the
> system
> freezes.
> Yust for the case it is some vendor specific BIOS bug: we're using
> supermicro mainboards.
> 
> > [Another copy of the reply with linux-kernel added this time]
> > 
> > > In my setup I'm allocating an array of ~7GiB memory size in a
> > > singlethreaded application.
> > > Startup: numactl --cpunodebind=X ./app
> > > For X=1,2,3 it works as expected, all memory is allocated on the
> > > local
> > > node.
> > > For X=0 I can see the memory beeing allocated on node0 as long as
> > > ~3GiB
> > > are "free" on node0. At this point the kernel starts using memory
> > > from
> > > node1 for the app!
> > 
> > Hmm, that sounds like it doesn't want to use the 4GB DMA zone.
> > 
> > Normally there should be no protection on it, but perhaps something 
> > broke.
> > 
> > What does cat /proc/sys/owmem_reserve_ratio say?
> 
> 2.6.22.x:
> # cat /proc/sys/vm/lowmem_reserve_ratio
> 256     256
> 
> 2.6.23.8 (and above)
> # cat /proc/sys/vm/lowmem_reserve_ratio
> 256     256     32
> 
> 
> > > For parallel realworld apps I've seen a performance penalty of 30%
> > > compared to older kernels!
> > 
> > Compared to what older kernels? When did it start?
> 
> I've tested some kernel Versions that I've laying around here...
> working fine: 2.6.22.18-0.2-default (openSUSE) / 2.6.22.9 (kernel.org)
> showing the described behaviour: 2.6.23.8; 2.6.24.4; 2.6.25.4;
> 2.6.26.5;
> 2.6.27
> 
> 
> > 
> > -Andi
> > 
> > -- 
> > ak@linux.intel.com
> > 
> 
> 
> -- 
> 
> Regards,
> Oliver Weihe

--- cut here ---


Regards,
 Oliver Weihe



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
