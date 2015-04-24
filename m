Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f181.google.com (mail-qk0-f181.google.com [209.85.220.181])
	by kanga.kvack.org (Postfix) with ESMTP id 6A1F66B0032
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 11:08:39 -0400 (EDT)
Received: by qkhg7 with SMTP id g7so31551110qkh.2
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 08:08:39 -0700 (PDT)
Received: from mail-qk0-x229.google.com (mail-qk0-x229.google.com. [2607:f8b0:400d:c09::229])
        by mx.google.com with ESMTPS id e5si11653013qkh.30.2015.04.24.08.08.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Apr 2015 08:08:38 -0700 (PDT)
Received: by qkgx75 with SMTP id x75so31612360qkg.1
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 08:08:38 -0700 (PDT)
Date: Fri, 24 Apr 2015 11:08:30 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: Interacting with coherent memory on external devices
Message-ID: <20150424150829.GA3840@gmail.com>
References: <1429663372.27410.75.camel@kernel.crashing.org>
 <20150422005757.GP5561@linux.vnet.ibm.com>
 <1429664686.27410.84.camel@kernel.crashing.org>
 <alpine.DEB.2.11.1504221020160.24979@gentwo.org>
 <20150422163135.GA4062@gmail.com>
 <alpine.DEB.2.11.1504221206080.25607@gentwo.org>
 <1429756456.4915.22.camel@kernel.crashing.org>
 <alpine.DEB.2.11.1504230925250.32297@gentwo.org>
 <20150423161105.GB2399@gmail.com>
 <alpine.DEB.2.11.1504240912560.7582@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.DEB.2.11.1504240912560.7582@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, paulmck@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Fri, Apr 24, 2015 at 09:29:12AM -0500, Christoph Lameter wrote:
> On Thu, 23 Apr 2015, Jerome Glisse wrote:
> 
> > No this not have been solve properly. Today solution is doing an explicit
> > copy and again and again when complex data struct are involve (list, tree,
> > ...) this is extremly tedious and hard to debug. So today solution often
> > restrict themself to easy thing like matrix multiplication. But if you
> > provide a unified address space then you make things a lot easiers for a
> > lot more usecase. That's a fact, and again OpenCL 2.0 which is an industry
> > standard is a proof that unified address space is one of the most important
> > feature requested by user of GPGPU. You might not care but the rest of the
> > world does.
> 
> You could use page tables on the kernel side to transfer data on demand
> from the GPU. And you can use a device driver to establish mappings to the
> GPUs memory.
> 
> There is no copy needed with these approaches.

So you are telling me to do get_user_page() ? If so you aware that this pins
memory ? So what happens when the GPU wants to access a range of 32GB of
memory ? I pin everything ?

I am not talking about only transfrom from GPU to system memory i am talking
about application that have :
   dataset = mmap(datatset, 32<<30);
   // ...
   dl_open(superlibrary)
   superlibrary.dosomething(dataset);

So the application here have no clue about GPU and we do not want to change
that yes this is a valid usecase and countless user ask for it.

How can the superlibrary give access to the GPU to the dataset ? Does it
have to go get_user_page() on all single page effectively pinning memory ?
Should it allocate GPU memory through special API and memcpy ?


What HMM does is allow to share the process page table with the GPU and GPU
can transparently access the dataset (no pinning whatsover). Will there be
pagefault ? It can happens and if it does the assumption is that you have
more threads that do not get a pagefault than one that does, so GPU keeps
being saturated (ie all its unit are feed with something to do) while the
pagefault are resolve. For some workload yes you will see the penalty of the
pagefault ie you will have a group of thread that finish late but the thing
you seem to fail to get is that all the other GPU thread can make process
and finish even before the pagefault is resolved. It all depends on the
application. Moreover if you have several application then GPU can switch
to different application and make progress on them too.

Overall the throughput of the GPU will stay close to its theoritical maximum
if you have enough other thread that can progress and this is very common.

> 
> > > I think these two things need to be separated. The shift-the-memory-back-
> > > and-forth approach should be separate and if someone wants to use the
> > > thing then it should also work on other platforms like ARM and Intel.
> >
> > What IBM does with there platform is there choice, they can not force ARM
> > or Intel or AMD to do the same. Each of those might have different view
> > on what is their most important target. For instance i highly doubt ARM
> > cares about any of this.
> 
> Well but the kernel code submitted should allow for easy use on other
> platform. I.e. Intel processors should be able to implement the
> "transparent" memory by establishing device mappings to PCI-E space
> and/or transferring data from the GPU and signaling the GPU to establish
> such a mapping.

HMM does that, it only require the GPU to have a certain set of features
and the only requirement for the platform is to offer a bus which allow
cache coherent system memory access such as PCIE.

But IBM here want to go further and to provide a more advance solution,
so their need are specific to there platform and we can not know if AMD,
ARM or Intel will want to go down the same road, they do not seem to be
interested. Does it means we should not support IBM ? I think it would be
wrong.

> 
> > Only time critical application care about latency, everyone else cares
> > about throughput, where the applications can runs for days, weeks, months
> > before producing any useable/meaningfull results. Many of which do not
> > care a tiny bit about latency because they can perform independant
> > computation.
> 
> Computationally intensive high performance application care about
> random latency introduced to computational threads because that is
> delaying the data exchange and thus slows everything down. And that is the
> typical case of a GPUI.

You assume that all HPC application have strong data exchange, i gave
you example of application where there is 0 data exchange btw threads
what so ever. Those use case exist and we want to support them too.

Yes for thread where there is data exchange page fault stall jobs but
again we are talking about HPC where several _different_ application
run in // and share resources so while page fault can block part of
an application, other applications can still make progress as GPU can
switch to work on them.

Moreover the expectation is thate pagefault will remain a rare events,
as proper application should make sure that the dataset they are working
on it hot in memory.

> 
> > Take a company rendering a movie for instance, they want to render the
> > millions of frame as fast as possible but each frame can be rendered
> > independently, they only share data is the input geometry, textures and
> > lighting but this are constant, the rendering of one frame does not
> > depend on the rendering of the previous (leaving post processing like
> > motion blur aside).
> 
> The rendering would be done by the GPU and this will involve concurrency
> rapidly accessing data. Performance is certainly impacted if the GPU
> cannot use its own RAM designed for the proper feeding of its processing.
> And if you add a paging layer and swivel stuff below then this will be
> very bad.
> 
> At minimum you need to shovel blocks of data into the GPU to allow it to
> operate undisturbed for a while on the data and do its job.

You completely misunderstand the design of what we are trying to achieve
we are not trying to have a kernel thread that constantly move data around.
For the autonuma case you start by mapping the system memory to the GPU
the GPU start working on it, after a bit the GPU reports statistics and
autonuma kicks in and migrate memory to GPU memory transparently without
interruption for the GPU, so GPU keeps running. While it might start the
job being limited by the bus bandwidth, it will end the job using the full
bandwidth.

Now this is only with autonuma, and we never intended this to be the only
factor on the contrary the primary factor is decision made by the device
driver. So device driver that get information from userspace can migrate
the memory even before the job start on the GPU and in this case you will
never have autonuma do anything to your data whatsoever.


> 
> > Same apply if you do some data mining. You want might want to find all
> > occurence of a specific sequence in a large data pool. You can slice
> > your data pool and have an independant job per slice and only aggregate
> > the result of each jobs at the end (or as they finish).
> 
> This sounds more like a case for a general purpose processor. If it is a
> special device then it will typically also have special memory to allow
> fast searches.

No this kind of thing can be fast on a GPU, with GPU you easily have x500
more cores than CPU cores, so you can slice the dataset even more and have
each of the GPU core perform the search. Note that i am not only thinking
of stupid memcmp here it can be something more complex like searching a
pattern that allow variation and that require a whole program to decide if
a chunk falls under the variation rules or not.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
