Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id DE47F6B0032
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 12:43:30 -0400 (EDT)
Received: by qgeb100 with SMTP id b100so25295617qge.3
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 09:43:30 -0700 (PDT)
Received: from mail-qg0-x231.google.com (mail-qg0-x231.google.com. [2607:f8b0:400d:c04::231])
        by mx.google.com with ESMTPS id i1si11891686qcf.30.2015.04.24.09.43.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Apr 2015 09:43:30 -0700 (PDT)
Received: by qgdy78 with SMTP id y78so25379561qgd.0
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 09:43:29 -0700 (PDT)
Date: Fri, 24 Apr 2015 12:43:26 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: Interacting with coherent memory on external devices
Message-ID: <20150424164325.GD3840@gmail.com>
References: <1429664686.27410.84.camel@kernel.crashing.org>
 <alpine.DEB.2.11.1504221020160.24979@gentwo.org>
 <20150422163135.GA4062@gmail.com>
 <alpine.DEB.2.11.1504221206080.25607@gentwo.org>
 <1429756456.4915.22.camel@kernel.crashing.org>
 <alpine.DEB.2.11.1504230925250.32297@gentwo.org>
 <20150423161105.GB2399@gmail.com>
 <alpine.DEB.2.11.1504240912560.7582@gentwo.org>
 <20150424150829.GA3840@gmail.com>
 <alpine.DEB.2.11.1504241052240.9889@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.DEB.2.11.1504241052240.9889@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, paulmck@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Fri, Apr 24, 2015 at 11:03:52AM -0500, Christoph Lameter wrote:
> On Fri, 24 Apr 2015, Jerome Glisse wrote:
> 
> > On Fri, Apr 24, 2015 at 09:29:12AM -0500, Christoph Lameter wrote:
> > > On Thu, 23 Apr 2015, Jerome Glisse wrote:
> > >
> > > > No this not have been solve properly. Today solution is doing an explicit
> > > > copy and again and again when complex data struct are involve (list, tree,
> > > > ...) this is extremly tedious and hard to debug. So today solution often
> > > > restrict themself to easy thing like matrix multiplication. But if you
> > > > provide a unified address space then you make things a lot easiers for a
> > > > lot more usecase. That's a fact, and again OpenCL 2.0 which is an industry
> > > > standard is a proof that unified address space is one of the most important
> > > > feature requested by user of GPGPU. You might not care but the rest of the
> > > > world does.
> > >
> > > You could use page tables on the kernel side to transfer data on demand
> > > from the GPU. And you can use a device driver to establish mappings to the
> > > GPUs memory.
> > >
> > > There is no copy needed with these approaches.
> >
> > So you are telling me to do get_user_page() ? If so you aware that this pins
> > memory ? So what happens when the GPU wants to access a range of 32GB of
> > memory ? I pin everything ?
> 
> Use either a device driver to create PTEs pointing to the data or do
> something similar like what DAX does. Pinning can be avoided if you use
> mmu_notifiers. Those will give you a callback before the OS removes the
> data and thus you can operate without pinning.

So you are actualy telling me to do as i am doing inside the HMM patchset ?
Because what you seem to say here is exactly what the HMM patchset does.
So you are acknowledging that we need work inside the kernel ?

That being said Paul have the chance to have a more advance platform where
what i am doing would actualy be under using the capabilities of the platform.
So he needs a different solution.

> 
> > Overall the throughput of the GPU will stay close to its theoritical maximum
> > if you have enough other thread that can progress and this is very common.
> 
> GPUs operate on groups of threads not single ones. If you stall
> then there will be a stall of a whole group of them. We are dealing with
> accellerators here that are different for performance reasons. They are
> not to be treated like regular processor, nor is memory like
> operating like host mmemory.

Again i know how GPU works, they work on group of thread i am well aware of
that, the group size is often 32 or 64 threads. But they keep in the hardware
a large pool of thread group, something like 2^11 or 2^12 thread group in
flight for 2^4 or 2^5 unit capable working on thread group (in thread count
this is 2^15/2^16 thread in flight for 2^9/2^10 cores). So again like on
the CPU we do not exepect the whole 2^11/2^12 group of thread to hit a
pagefault and i am saying as long as only a small number of group hit one
let say 2^3 group (2^8/2^9 thread) then you still have a large number of
thread group that can make progress without being impacted whatsoever.

And you can bet that GPU designer are also improving this by allowing to
swap out faulting thread and swapin runnable one so the overall 2^16 threads
in flight might be lot bigger in future hardware giving even more chance
to hide page fault.

GPU can operate on host memory and you can still saturate GPU with host
memory as long as the workload you are running are not bandwidth starved.
I know this is unlikely for GPU but again think several _different_
application some of thos application might already have their dataset
in the GPU memory and thus can run along side slower thread that are
limited by the system memory bandwidth. But still you can saturate your
GPU that way.

> 
> > But IBM here want to go further and to provide a more advance solution,
> > so their need are specific to there platform and we can not know if AMD,
> > ARM or Intel will want to go down the same road, they do not seem to be
> > interested. Does it means we should not support IBM ? I think it would be
> > wrong.
> 
> What exactly is the more advanced version's benefit? What are the features
> that the other platforms do not provide?

Transparent access to device memory from the CPU, you can map any of the GPU
memory inside the CPU and have the whole cache coherency including proper
atomic memory operation. CAPI is not some mumbo jumbo marketing name there
is real hardware behind it.

On x86 you have to take into account the PCI bar size, you also have to take
into account that PCIE transaction are really bad when it comes to sharing
memory with CPU. CAPI really improve things here.

So on x86 even if you could map all the GPU memory it would still be a bad
solution and thing like atomic memory operation might not even work properly.

> 
> > > This sounds more like a case for a general purpose processor. If it is a
> > > special device then it will typically also have special memory to allow
> > > fast searches.
> >
> > No this kind of thing can be fast on a GPU, with GPU you easily have x500
> > more cores than CPU cores, so you can slice the dataset even more and have
> > each of the GPU core perform the search. Note that i am not only thinking
> > of stupid memcmp here it can be something more complex like searching a
> > pattern that allow variation and that require a whole program to decide if
> > a chunk falls under the variation rules or not.
> 
> Then you have the problem of fast memory access and you are proposing to
> complicate that access path on the GPU.

No, i am proposing to have a solution where people doing such kind of work
load can leverage the GPU, yes it will not be as fast as people hand tuning
and rewritting their application for the GPU but it will still be faster
by a significant factor than only using the CPU.

Moreover i am saying that this can happen without even touching a single
line of code of many many applications, because many of them rely on library
and those are the only one that would need to know about GPU.

Finaly i am saying that having a unified address space btw the GPU and CPU
is a primordial prerequisite for this to happen in a transparent fashion
and thus DAX solution is non-sense and does not provide transparent address
space sharing. DAX solution is not even something new, this is how today
stack is working, no need for DAX, userspace just mmap the device driver
file and that's how they access the GPU accessible memory (which in most
case is just system memory mapped through the device file to the user
application).

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
