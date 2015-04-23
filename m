Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id C75E56B006C
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 12:11:09 -0400 (EDT)
Received: by qgeb100 with SMTP id b100so10350266qge.3
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 09:11:09 -0700 (PDT)
Received: from mail-qk0-x236.google.com (mail-qk0-x236.google.com. [2607:f8b0:400d:c09::236])
        by mx.google.com with ESMTPS id 89si8561800qkr.25.2015.04.23.09.11.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Apr 2015 09:11:09 -0700 (PDT)
Received: by qkhg7 with SMTP id g7so13528139qkh.2
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 09:11:08 -0700 (PDT)
Date: Thu, 23 Apr 2015 12:11:05 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: Interacting with coherent memory on external devices
Message-ID: <20150423161105.GB2399@gmail.com>
References: <20150421214445.GA29093@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1504211839120.6294@gentwo.org>
 <1429663372.27410.75.camel@kernel.crashing.org>
 <20150422005757.GP5561@linux.vnet.ibm.com>
 <1429664686.27410.84.camel@kernel.crashing.org>
 <alpine.DEB.2.11.1504221020160.24979@gentwo.org>
 <20150422163135.GA4062@gmail.com>
 <alpine.DEB.2.11.1504221206080.25607@gentwo.org>
 <1429756456.4915.22.camel@kernel.crashing.org>
 <alpine.DEB.2.11.1504230925250.32297@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.DEB.2.11.1504230925250.32297@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, paulmck@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Thu, Apr 23, 2015 at 09:38:15AM -0500, Christoph Lameter wrote:
> On Thu, 23 Apr 2015, Benjamin Herrenschmidt wrote:

[...]

> > You have something in memory, whether you got it via malloc, mmap'ing a file,
> > shmem with some other application, ... and you want to work on it with the
> > co-processor that is residing in your address space. Even better, pass a pointer
> > to it to some library you don't control which might itself want to use the
> > coprocessor ....
> 
> Yes that works already. Whats new about this? This seems to have been
> solved on the Intel platform f.e.

No this not have been solve properly. Today solution is doing an explicit
copy and again and again when complex data struct are involve (list, tree,
...) this is extremly tedious and hard to debug. So today solution often
restrict themself to easy thing like matrix multiplication. But if you
provide a unified address space then you make things a lot easiers for a
lot more usecase. That's a fact, and again OpenCL 2.0 which is an industry
standard is a proof that unified address space is one of the most important
feature requested by user of GPGPU. You might not care but the rest of the
world does.

> 
> > What you propose can simply not provide that natural usage model with any
> > efficiency.
> 
> There is no effiecency anymore if the OS can create random events in a
> computational stream that is highly optimized for data exchange of
> multiple threads at defined time intervals. If transparency or the natural
> usage model can avoid this then ok but what I see here proposed is some
> behind-the-scenes model that may severely degrate performance. And this
> does seem to go way beyond CAPI. At leasdt the way I so far thought about
> this as a method for cache coherency at the cache line level and about a
> way to simplify the coordination of page tables and TLBs across multiple
> divergent architectures.

Again you restrict yourself to your usecase. Many HPC workload do not have
stringent time constraint and synchronization point.

> 
> I think these two things need to be separated. The shift-the-memory-back-
> and-forth approach should be separate and if someone wants to use the
> thing then it should also work on other platforms like ARM and Intel.

What IBM does with there platform is there choice, they can not force ARM
or Intel or AMD to do the same. Each of those might have different view
on what is their most important target. For instance i highly doubt ARM
cares about any of this.

> 
> CAPI needs to be implemented as a way to potentially improve the existing
> communication paths between devices and the main processor. F.e the
> existing Infiniband MMU synchronization issues and RDMA registration
> problems could be addressed with this. The existing mechanisms for GPU
> communication could become much cleaner and easier to handle. This is all
> good but independant of any "transparent" memory implementation.

No, transparent memory implementation is a prerequisite to leverage to
cache coherency. If address for a same process does not means the same
thing on a device that on the CPU then doing cache coherency becomes a
lot harder because you need to track several address for same physical
backing storage. N (virtual) to 1 (physical) mapping is hard.

Same address on the other hand means that it is lot easier to have cache
coherency distributed accross device and CPU because they will all agree
on what physical memory is backing each address of a given process.
1 (virtual) to 1 (physical) is easier.

> > It might not be *your* model based on *your* application but that doesn't mean
> > it's not there, and isn't relevant.
> 
> Sadly this is the way that an entire industry does its thing.

Again no, you are wrong, the HPC industry is not only about latency.
Only time critical application care about latency, everyone else cares
about throughput, where the applications can runs for days, weeks, months
before producing any useable/meaningfull results. Many of which do not
care a tiny bit about latency because they can perform independant
computation.

Take a company rendering a movie for instance, they want to render the
millions of frame as fast as possible but each frame can be rendered
independently, they only share data is the input geometry, textures and
lighting but this are constant, the rendering of one frame does not
depend on the rendering of the previous (leaving post processing like
motion blur aside).

Same apply if you do some data mining. You want might want to find all
occurence of a specific sequence in a large data pool. You can slice
your data pool and have an independant job per slice and only aggregate
the result of each jobs at the end (or as they finish).

I will not go on and on and on about all the thing that do not care
about latency, i am just trying to open your eyes on the world that
exist out there.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
