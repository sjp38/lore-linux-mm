Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f178.google.com (mail-qc0-f178.google.com [209.85.216.178])
	by kanga.kvack.org (Postfix) with ESMTP id 540E26B006C
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 13:20:03 -0400 (EDT)
Received: by qcbii10 with SMTP id ii10so29281856qcb.2
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 10:20:03 -0700 (PDT)
Received: from mail-qk0-x22b.google.com (mail-qk0-x22b.google.com. [2607:f8b0:400d:c09::22b])
        by mx.google.com with ESMTPS id 16si11904817qhu.131.2015.04.24.10.20.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Apr 2015 10:20:02 -0700 (PDT)
Received: by qkgx75 with SMTP id x75so34091303qkg.1
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 10:20:02 -0700 (PDT)
Date: Fri, 24 Apr 2015 13:19:58 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: Interacting with coherent memory on external devices
Message-ID: <20150424171957.GE3840@gmail.com>
References: <20150422163135.GA4062@gmail.com>
 <alpine.DEB.2.11.1504221206080.25607@gentwo.org>
 <1429756456.4915.22.camel@kernel.crashing.org>
 <alpine.DEB.2.11.1504230925250.32297@gentwo.org>
 <20150423161105.GB2399@gmail.com>
 <alpine.DEB.2.11.1504240912560.7582@gentwo.org>
 <20150424150829.GA3840@gmail.com>
 <alpine.DEB.2.11.1504241052240.9889@gentwo.org>
 <20150424164325.GD3840@gmail.com>
 <alpine.DEB.2.11.1504241148420.10475@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.DEB.2.11.1504241148420.10475@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, paulmck@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Fri, Apr 24, 2015 at 11:58:39AM -0500, Christoph Lameter wrote:
> On Fri, 24 Apr 2015, Jerome Glisse wrote:
> 
> > > What exactly is the more advanced version's benefit? What are the features
> > > that the other platforms do not provide?
> >
> > Transparent access to device memory from the CPU, you can map any of the GPU
> > memory inside the CPU and have the whole cache coherency including proper
> > atomic memory operation. CAPI is not some mumbo jumbo marketing name there
> > is real hardware behind it.
> 
> Got the hardware here but I am getting pretty sobered given what I heard
> here. The IBM mumbo jumpo marketing comes down to "not much" now.
> 
> > On x86 you have to take into account the PCI bar size, you also have to take
> > into account that PCIE transaction are really bad when it comes to sharing
> > memory with CPU. CAPI really improve things here.
> 
> Ok that would be interesting for the general device driver case.  Can you
> show a real performance benefit here of CAPI transactions vs. PCI-E
> transactions?

I am sure IBM will show benchmark here when they have everything in place. I
am not working on CAPI personnaly, i just went through some of the specification
for it.

> > So on x86 even if you could map all the GPU memory it would still be a bad
> > solution and thing like atomic memory operation might not even work properly.
> 
> That is solvable and doable in many other ways if needed. Actually I'd
> prefer a Xeon Phi in that case because then we also have the same
> instruction set. Having locks work right with different instruction sets
> and different coherency schemes. Ewww...
> 

Well then go the Xeon Phi solution way and let people that want to provide a
different simpler (from programmer point of view) solution work on it.

> 
> > > Then you have the problem of fast memory access and you are proposing to
> > > complicate that access path on the GPU.
> >
> > No, i am proposing to have a solution where people doing such kind of work
> > load can leverage the GPU, yes it will not be as fast as people hand tuning
> > and rewritting their application for the GPU but it will still be faster
> > by a significant factor than only using the CPU.
> 
> Well the general purpose processors also also gaining more floating point
> capabilities which increases the pressure on accellerators to become more
> specialized.
> 
> > Moreover i am saying that this can happen without even touching a single
> > line of code of many many applications, because many of them rely on library
> > and those are the only one that would need to know about GPU.
> 
> Yea. We have heard this numerous times in parallel computing and it never
> really worked right.

Because you had split userspace, a pointer value was not pointing to the same
thing on the GPU as on the CPU so porting library or application is hard and
troublesome. AMD is already working on porting general application or library
to leverage the brave new world of share address space (libreoffice, gimp, ...).

Other people keep presuring for same address space, again this is the corner
stone of OpenCL 2.0.

I can not predict if it will work this time, if all meaning full and usefull
library will start leveraging GPU. All i am trying to do is solve the split
address space problem. Problem that you seem to ignore completely because you
are happy the way things are. Other people are not happy.


> 
> > Finaly i am saying that having a unified address space btw the GPU and CPU
> > is a primordial prerequisite for this to happen in a transparent fashion
> > and thus DAX solution is non-sense and does not provide transparent address
> > space sharing. DAX solution is not even something new, this is how today
> > stack is working, no need for DAX, userspace just mmap the device driver
> > file and that's how they access the GPU accessible memory (which in most
> > case is just system memory mapped through the device file to the user
> > application).
> 
> Right this is how things work and you could improve on that. Stay with the
> scheme. Why would that not work if you map things the same way in both
> environments if both accellerator and host processor can acceess each
> others memory?

Again and again share address space, having a pointer means the same thing
for the GPU than it means for the CPU ie having a random pointer point to
the same memory whether it is accessed by the GPU or the CPU. While also
keeping the property of the backing memory. It can be share memory from
other process, a file mmaped from disk or simply anonymous memory and
thus we have no control whatsoever on how such memory is allocated.

Then you had transparent migration (transparent in the sense that we can
handle CPU page fault on migrated memory) and you will see that you need
to modify the kernel to become aware of this and provide a common code
to deal with all this.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
