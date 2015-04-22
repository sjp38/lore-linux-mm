Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id A336C900015
	for <linux-mm@kvack.org>; Tue, 21 Apr 2015 21:01:38 -0400 (EDT)
Received: by qcyk17 with SMTP id k17so85634037qcy.1
        for <linux-mm@kvack.org>; Tue, 21 Apr 2015 18:01:38 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id gn1si3628873qcb.26.2015.04.21.18.01.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 21 Apr 2015 18:01:37 -0700 (PDT)
Message-ID: <1429664486.27410.83.camel@kernel.crashing.org>
Subject: Re: Interacting with coherent memory on external devices
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 22 Apr 2015 11:01:26 +1000
In-Reply-To: <alpine.DEB.2.11.1504211942040.6294@gentwo.org>
References: <20150421214445.GA29093@linux.vnet.ibm.com>
	 <alpine.DEB.2.11.1504211839120.6294@gentwo.org>
	 <20150422000538.GB6046@gmail.com>
	 <alpine.DEB.2.11.1504211942040.6294@gentwo.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Jerome Glisse <j.glisse@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Tue, 2015-04-21 at 19:50 -0500, Christoph Lameter wrote:

> With a filesystem the migration can be controlled by the application. It
> can copy stuff whenever it wants to.Having the OS do that behind my back
> is not something that feels safe and secure.

But this is not something the user wants. The filesystem model is
completely the wrong model for us.

This is fundamentally the same model as memory migrating between NUMA
nodes except that one of these is a co-processor with its local memory.

You want to malloc() some stuff or get a pointer provided by an app to
your library and be able to farm that job out to the co-processor. No
filesystem in the picture here.

> > By allowing transparent migration you allow library to just start using
> > the GPU without the application being non the wiser about that. More
> > over when you start playing with data set that use more advance design
> > pattern (list, tree, vector, a mix of all the above) you do not want
> > to have to duplicate the list for the GPU address space and for the
> > regular CPU address space (which you would need to do in case of a
> > filesystem solution).
> 
> There is no need for duplication if both address spaces use the same
> addresses. F.e. DAX would allow you to mmap arbitrary portions of memory
> of the GPU into a process space. Since this is cache coherent both
> processor cache and coprocessor cache would be able to hold cachelines
> from the device or from main memory.

But it won't give you transparent migration which is what this is *all*
about.

> > So the corner stone of HMM and Paul requirement are the same, we want
> > to be able to move normal anonymous memory as well as regular file
> > backed page to device memory for some period of time while at the same
> > time allowing the usual memory management to keep going as if nothing
> > was different.
> 
> This still sounds pretty wild and is doing major changes to core OS
> mechanisms with little reason from that I can see. There are already
> mechanisms in place that do what you want.

What "major" changes ? HMM has some changes yes, what we propose is
about using existing mechanisms with possibly *few* changes, but we are
trying to get that discussion going.

> > Paul is working on a platform that is more advance that the one HMM try
> > to address and i believe the x86 platform will not have functionality
> > such a CAPI, at least it is not part of any roadmap i know about for
> > x86.
> 
> We will be one of the first users of Paul's Platform. Please do not do
> crazy stuff but give us a sane solution where we can control the
> hardware. No strange VM hooks that automatically move stuff back and forth
> please. If you do this we will have to disable them anyways because they
> would interfere with our needs to have the code not be disturbed by random
> OS noise. We need detailed control as to when and how we move data.

There is strictly nothing *sane* about requiring the workload to be put
into files that have to be explicitly moved around. This is utterly
backward. We aren't talking about CAPI based flash storage here, we are
talking about a coprocessor that can be buried under library,
accelerating existing APIs, which are going to take existing pointers
themselves being mmap'ed file, anonymous memory, or whatever else the
application choses to use.

This is the model that GPU *users* have been pushing for over and over
again, that some NIC vendors want as well (with HMM initially) etc... 

Ben.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
