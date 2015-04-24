Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f171.google.com (mail-ie0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id 1B57D6B0032
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 10:29:14 -0400 (EDT)
Received: by iedfl3 with SMTP id fl3so95394685ied.1
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 07:29:13 -0700 (PDT)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id ku4si2155135igb.21.2015.04.24.07.29.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 24 Apr 2015 07:29:13 -0700 (PDT)
Date: Fri, 24 Apr 2015 09:29:12 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Interacting with coherent memory on external devices
In-Reply-To: <20150423161105.GB2399@gmail.com>
Message-ID: <alpine.DEB.2.11.1504240912560.7582@gentwo.org>
References: <20150421214445.GA29093@linux.vnet.ibm.com> <alpine.DEB.2.11.1504211839120.6294@gentwo.org> <1429663372.27410.75.camel@kernel.crashing.org> <20150422005757.GP5561@linux.vnet.ibm.com> <1429664686.27410.84.camel@kernel.crashing.org>
 <alpine.DEB.2.11.1504221020160.24979@gentwo.org> <20150422163135.GA4062@gmail.com> <alpine.DEB.2.11.1504221206080.25607@gentwo.org> <1429756456.4915.22.camel@kernel.crashing.org> <alpine.DEB.2.11.1504230925250.32297@gentwo.org>
 <20150423161105.GB2399@gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, paulmck@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Thu, 23 Apr 2015, Jerome Glisse wrote:

> No this not have been solve properly. Today solution is doing an explicit
> copy and again and again when complex data struct are involve (list, tree,
> ...) this is extremly tedious and hard to debug. So today solution often
> restrict themself to easy thing like matrix multiplication. But if you
> provide a unified address space then you make things a lot easiers for a
> lot more usecase. That's a fact, and again OpenCL 2.0 which is an industry
> standard is a proof that unified address space is one of the most important
> feature requested by user of GPGPU. You might not care but the rest of the
> world does.

You could use page tables on the kernel side to transfer data on demand
from the GPU. And you can use a device driver to establish mappings to the
GPUs memory.

There is no copy needed with these approaches.

> > I think these two things need to be separated. The shift-the-memory-back-
> > and-forth approach should be separate and if someone wants to use the
> > thing then it should also work on other platforms like ARM and Intel.
>
> What IBM does with there platform is there choice, they can not force ARM
> or Intel or AMD to do the same. Each of those might have different view
> on what is their most important target. For instance i highly doubt ARM
> cares about any of this.

Well but the kernel code submitted should allow for easy use on other
platform. I.e. Intel processors should be able to implement the
"transparent" memory by establishing device mappings to PCI-E space
and/or transferring data from the GPU and signaling the GPU to establish
such a mapping.

> Only time critical application care about latency, everyone else cares
> about throughput, where the applications can runs for days, weeks, months
> before producing any useable/meaningfull results. Many of which do not
> care a tiny bit about latency because they can perform independant
> computation.

Computationally intensive high performance application care about
random latency introduced to computational threads because that is
delaying the data exchange and thus slows everything down. And that is the
typical case of a GPUI.

> Take a company rendering a movie for instance, they want to render the
> millions of frame as fast as possible but each frame can be rendered
> independently, they only share data is the input geometry, textures and
> lighting but this are constant, the rendering of one frame does not
> depend on the rendering of the previous (leaving post processing like
> motion blur aside).

The rendering would be done by the GPU and this will involve concurrency
rapidly accessing data. Performance is certainly impacted if the GPU
cannot use its own RAM designed for the proper feeding of its processing.
And if you add a paging layer and swivel stuff below then this will be
very bad.

At minimum you need to shovel blocks of data into the GPU to allow it to
operate undisturbed for a while on the data and do its job.

> Same apply if you do some data mining. You want might want to find all
> occurence of a specific sequence in a large data pool. You can slice
> your data pool and have an independant job per slice and only aggregate
> the result of each jobs at the end (or as they finish).

This sounds more like a case for a general purpose processor. If it is a
special device then it will typically also have special memory to allow
fast searches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
