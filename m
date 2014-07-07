Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id 0C1B96B0039
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 06:37:19 -0400 (EDT)
Received: by mail-qg0-f47.google.com with SMTP id q108so3505374qgd.6
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 03:37:18 -0700 (PDT)
Received: from na01-bn1-obe.outbound.protection.outlook.com (mail-bn1blp0182.outbound.protection.outlook.com. [207.46.163.182])
        by mx.google.com with ESMTPS id f4si29987771qga.81.2014.07.07.03.37.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 07 Jul 2014 03:37:17 -0700 (PDT)
Message-ID: <1404729368.20343.21.camel@tlv-gabbay-ws.amd.com>
Subject: Re: [PATCH 1/6] mmput: use notifier chain to call subsystem exit
 handler.
From: Oded Gabbay <oded.gabbay@amd.com>
In-Reply-To: <20140707101158.GD1958@8bytes.org>
References: <20140630183556.GB3280@gmail.com>
	 <20140701091535.GF26537@8bytes.org>
	 <019CCE693E457142B37B791721487FD91806DD8B@storexdag01.amd.com>
	 <20140701110018.GH26537@8bytes.org> <20140701193343.GB3322@gmail.com>
	 <20140701210620.GL26537@8bytes.org> <20140701213208.GC3322@gmail.com>
	 <20140703183024.GA3306@gmail.com> <20140703231541.GR26537@8bytes.org>
	 <019CCE693E457142B37B791721487FD918085329@storexdag01.amd.com>
	 <20140707101158.GD1958@8bytes.org>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 7 Jul 2014 13:36:08 +0300
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "joro@8bytes.org" <joro@8bytes.org>
Cc: "dpoole@nvidia.com" <dpoole@nvidia.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "jweiner@redhat.com" <jweiner@redhat.com>, "mhairgrove@nvidia.com" <mhairgrove@nvidia.com>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "j.glisse@gmail.com" <j.glisse@gmail.com>, "Bridgman, John" <John.Bridgman@amd.com>, "Deucher,
 Alexander" <Alexander.Deucher@amd.com>, "Lewycky, Andrew" <Andrew.Lewycky@amd.com>, "sgutti@nvidia.com" <sgutti@nvidia.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com" <hpa@zytor.com>, "aarcange@redhat.com" <aarcange@redhat.com>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "riel@redhat.com" <riel@redhat.com>, "arvindg@nvidia.com" <arvindg@nvidia.com>, "SCheung@nvidia.com" <SCheung@nvidia.com>, "jakumar@nvidia.com" <jakumar@nvidia.com>, "jhubbard@nvidia.com" <jhubbard@nvidia.com>, "Cornwall, Jay" <Jay.Cornwall@amd.com>, "mgorman@suse.de" <mgorman@suse.de>, "cabuschardt@nvidia.com" <cabuschardt@nvidia.com>, "ldunning@nvidia.com" <ldunning@nvidia.com>

On Mon, 2014-07-07 at 12:11 +0200, joro@8bytes.org wrote:
> On Sun, Jul 06, 2014 at 07:25:18PM +0000, Gabbay, Oded wrote:
> > Once we can agree on that, than I think we can agree that kfd and hmm
> > can and should be bounded to mm struct and not file descriptors.
> 
> The file descriptor concept is the way it works in the rest of the
> kernel. It works for numerous drivers and subsystems (KVM, VFIO, UIO,
> ...), when you close a file descriptor handed out from any of those
> drivers (already in the kernel) all related resources will be freed. I
> don't see a reason why HSA drivers should break these expectations and
> be different.
> 
> 
> 	Joerg
> 
> 
As Jerome pointed out, there are a couple of subsystems/drivers who
don't rely on file descriptors but on the tear-down of mm struct, e.g.
aio, ksm, uprobes, khugepaged

So, based on this fact, I don't think that the argument of "The file
descriptor concept is the way it works in the rest of the kernel" and
only HSA/HMM now wants to change the rules, is a valid argument.

Jerome and I are saying that HMM and HSA, respectively, are additional
use cases of binding to mm struct. If you don't agree with that, than I
would like to hear why, but you can't say that no one else in the kernel
needs notification of mm struct tear-down.

As for the reasons why HSA drivers should follow aio,ksm,etc. and not
other drivers, I will repeat that our ioctls operate on a process
context and not on a device context. Moreover, the calling process
actually is sometimes not aware on which device it runs! 

A prime example of why HSA is not a regular device-driver, and operates
in context of a process and not a specific device is the fact that in
the near future (3-4 months), kfd_open() will actually bind a process
address space to a *set* of devices, each of which could have its *own*
device driver (eg radeon for the CI device, other amd drivers for future
devices). I Assume HMM can be considered in the same way. 

	Oded



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
