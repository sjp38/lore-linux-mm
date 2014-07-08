Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f180.google.com (mail-vc0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id 522316B0036
	for <linux-mm@kvack.org>; Tue,  8 Jul 2014 13:04:06 -0400 (EDT)
Received: by mail-vc0-f180.google.com with SMTP id im17so5818624vcb.11
        for <linux-mm@kvack.org>; Tue, 08 Jul 2014 10:04:06 -0700 (PDT)
Received: from mail-qc0-x233.google.com (mail-qc0-x233.google.com [2607:f8b0:400d:c01::233])
        by mx.google.com with ESMTPS id w7si19899613veu.73.2014.07.08.10.04.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 08 Jul 2014 10:04:05 -0700 (PDT)
Received: by mail-qc0-f179.google.com with SMTP id x3so5611087qcv.10
        for <linux-mm@kvack.org>; Tue, 08 Jul 2014 10:04:04 -0700 (PDT)
Date: Tue, 8 Jul 2014 13:03:56 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH 1/6] mmput: use notifier chain to call subsystem exit
 handler.
Message-ID: <20140708170355.GA2469@gmail.com>
References: <20140701110018.GH26537@8bytes.org>
 <20140701193343.GB3322@gmail.com>
 <20140701210620.GL26537@8bytes.org>
 <20140701213208.GC3322@gmail.com>
 <20140703183024.GA3306@gmail.com>
 <20140703231541.GR26537@8bytes.org>
 <019CCE693E457142B37B791721487FD918085329@storexdag01.amd.com>
 <20140707101158.GD1958@8bytes.org>
 <1404729783.31606.1.camel@tlv-gabbay-ws.amd.com>
 <20140708080059.GF1958@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20140708080059.GF1958@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "joro@8bytes.org" <joro@8bytes.org>
Cc: Oded Gabbay <oded.gabbay@amd.com>, "dpoole@nvidia.com" <dpoole@nvidia.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "jweiner@redhat.com" <jweiner@redhat.com>, "mhairgrove@nvidia.com" <mhairgrove@nvidia.com>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Bridgman, John" <John.Bridgman@amd.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "Lewycky, Andrew" <Andrew.Lewycky@amd.com>, "sgutti@nvidia.com" <sgutti@nvidia.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com" <hpa@zytor.com>, "aarcange@redhat.com" <aarcange@redhat.com>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "riel@redhat.com" <riel@redhat.com>, "arvindg@nvidia.com" <arvindg@nvidia.com>, "SCheung@nvidia.com" <SCheung@nvidia.com>, "jakumar@nvidia.com" <jakumar@nvidia.com>, "jhubbard@nvidia.com" <jhubbard@nvidia.com>, "Cornwall, Jay" <Jay.Cornwall@amd.com>, "mgorman@suse.de" <mgorman@suse.de>, "cabuschardt@nvidia.com" <cabuschardt@nvidia.com>, "ldunning@nvidia.com" <ldunning@nvidia.com>

On Tue, Jul 08, 2014 at 10:00:59AM +0200, joro@8bytes.org wrote:
> On Mon, Jul 07, 2014 at 01:43:03PM +0300, Oded Gabbay wrote:
> > As Jerome pointed out, there are a couple of subsystems/drivers who
> > don't rely on file descriptors but on the tear-down of mm struct, e.g.
> > aio, ksm, uprobes, khugepaged
> 
> What you name here is completly different from what HSA offers. AIO,
> KSM, uProbes and THP are not drivers or subsystems of their own but
> extend existing subsystems. KSM and THP also work in the background and
> do not need a fd to setup things (in some cases only new flags to
> existing system calls).
> 
> What HSA does is offering a new service to userspace applications.  This
> either requires new system calls or, as currently implemented, a device
> file which can be opened to use the services.  In this regard it is much
> more similar to VFIO or KVM, which also offers a new service and which
> use file descriptors as their interface to userspace and tear everything
> down when the fd is closed.

Thing is we are closer to AIO than to KVM. Unlike kvm, hmm stores a pointer
to its structure inside mm_struct and those we already add ourself to the
mm_init function ie we do have the same lifespan as the mm_struct not the
same lifespan as a file.

Now regarding the device side, if we were to cleanup inside the file release
callback than we would be broken in front of fork. Imagine the following :
  - process A open device file and mirror its address space (hmm or kfd)
    through a device file.
  - process A forks itself (child is B) while having the device file open.
  - process A quits

Now the file release will not be call until child B exit which might infinite.
Thus we would be leaking memory. As we already pointed out we can not free the
resources from the mmu_notifier >release callback.

One hacky way to do it would be to schedule some delayed job from >release
callback but then again we would have no way to properly synchronize ourself
with other mm destruction code ie the delayed job could run concurently with
other mm destruction code and interfer badly.

So as i am desperatly trying to show you, there is no other clean way to free
resources associated with hmm and same apply to kfd. Only way is by adding a
callback inside mmput.


Another thing you must understand, the kfd or hmm can be share among different
devices each of them having their own device file. So one and one hmm per mm
struct but several device using that hmm structure. Obviously the lifetime of
this hmm structure has first tie to mm struct, all ties to device file are
secondary and i can foresee situation where their would be absolutely no device
file open but still an hmm for mm struct (think another process is using the
process address through a device driver because it provide some api for that).


I genuinely fails to see how to do it properly using file device as i said
the file lifespan is not tie to an mm struct while the struct we want to
cleanup are tie to the mm struct.

Again hmm or kfd is like aio. Not like kvm.

Cheers,
Jerome

> 
> > Jerome and I are saying that HMM and HSA, respectively, are additional
> > use cases of binding to mm struct. If you don't agree with that, than I
> > would like to hear why, but you can't say that no one else in the kernel
> > needs notification of mm struct tear-down.
> 
> In the first place HSA is a service that allows applications to send
> compute jobs to peripheral devices (usually GPUs) and read back the
> results. That the peripheral device can access the process address space
> is a feature of that service that is handled in the driver.
> 
> > As for the reasons why HSA drivers should follow aio,ksm,etc. and not
> > other drivers, I will repeat that our ioctls operate on a process
> > context and not on a device context. Moreover, the calling process
> > actually is sometimes not aware on which device it runs!
> 
> KFD can very well hide the fact that there are multiple devices as the
> IOMMU drivers usually also hide the details about how many IOMMUs are in
> the system.
> 
> 
> 	Joerg
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
