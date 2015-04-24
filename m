Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 85EC26B0032
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 12:58:42 -0400 (EDT)
Received: by igbpi8 with SMTP id pi8so32259778igb.0
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 09:58:42 -0700 (PDT)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id s12si2442620igr.22.2015.04.24.09.58.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 24 Apr 2015 09:58:41 -0700 (PDT)
Date: Fri, 24 Apr 2015 11:58:39 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Interacting with coherent memory on external devices
In-Reply-To: <20150424164325.GD3840@gmail.com>
Message-ID: <alpine.DEB.2.11.1504241148420.10475@gentwo.org>
References: <1429664686.27410.84.camel@kernel.crashing.org> <alpine.DEB.2.11.1504221020160.24979@gentwo.org> <20150422163135.GA4062@gmail.com> <alpine.DEB.2.11.1504221206080.25607@gentwo.org> <1429756456.4915.22.camel@kernel.crashing.org>
 <alpine.DEB.2.11.1504230925250.32297@gentwo.org> <20150423161105.GB2399@gmail.com> <alpine.DEB.2.11.1504240912560.7582@gentwo.org> <20150424150829.GA3840@gmail.com> <alpine.DEB.2.11.1504241052240.9889@gentwo.org> <20150424164325.GD3840@gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, paulmck@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Fri, 24 Apr 2015, Jerome Glisse wrote:

> > What exactly is the more advanced version's benefit? What are the features
> > that the other platforms do not provide?
>
> Transparent access to device memory from the CPU, you can map any of the GPU
> memory inside the CPU and have the whole cache coherency including proper
> atomic memory operation. CAPI is not some mumbo jumbo marketing name there
> is real hardware behind it.

Got the hardware here but I am getting pretty sobered given what I heard
here. The IBM mumbo jumpo marketing comes down to "not much" now.

> On x86 you have to take into account the PCI bar size, you also have to take
> into account that PCIE transaction are really bad when it comes to sharing
> memory with CPU. CAPI really improve things here.

Ok that would be interesting for the general device driver case.  Can you
show a real performance benefit here of CAPI transactions vs. PCI-E
transactions?

> So on x86 even if you could map all the GPU memory it would still be a bad
> solution and thing like atomic memory operation might not even work properly.

That is solvable and doable in many other ways if needed. Actually I'd
prefer a Xeon Phi in that case because then we also have the same
instruction set. Having locks work right with different instruction sets
and different coherency schemes. Ewww...


> > Then you have the problem of fast memory access and you are proposing to
> > complicate that access path on the GPU.
>
> No, i am proposing to have a solution where people doing such kind of work
> load can leverage the GPU, yes it will not be as fast as people hand tuning
> and rewritting their application for the GPU but it will still be faster
> by a significant factor than only using the CPU.

Well the general purpose processors also also gaining more floating point
capabilities which increases the pressure on accellerators to become more
specialized.

> Moreover i am saying that this can happen without even touching a single
> line of code of many many applications, because many of them rely on library
> and those are the only one that would need to know about GPU.

Yea. We have heard this numerous times in parallel computing and it never
really worked right.

> Finaly i am saying that having a unified address space btw the GPU and CPU
> is a primordial prerequisite for this to happen in a transparent fashion
> and thus DAX solution is non-sense and does not provide transparent address
> space sharing. DAX solution is not even something new, this is how today
> stack is working, no need for DAX, userspace just mmap the device driver
> file and that's how they access the GPU accessible memory (which in most
> case is just system memory mapped through the device file to the user
> application).

Right this is how things work and you could improve on that. Stay with the
scheme. Why would that not work if you map things the same way in both
environments if both accellerator and host processor can acceess each
others memory?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
