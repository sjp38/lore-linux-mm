Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id F35706B0031
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 15:33:50 -0400 (EDT)
Received: by mail-qg0-f49.google.com with SMTP id f51so3724384qge.22
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 12:33:50 -0700 (PDT)
Received: from mail-qc0-x231.google.com (mail-qc0-x231.google.com [2607:f8b0:400d:c01::231])
        by mx.google.com with ESMTPS id m6si23178821qag.85.2014.07.01.12.33.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 01 Jul 2014 12:33:50 -0700 (PDT)
Received: by mail-qc0-f177.google.com with SMTP id r5so8795217qcx.36
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 12:33:49 -0700 (PDT)
Date: Tue, 1 Jul 2014 15:33:44 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH 1/6] mmput: use notifier chain to call subsystem exit
 handler.
Message-ID: <20140701193343.GB3322@gmail.com>
References: <1403920822-14488-1-git-send-email-j.glisse@gmail.com>
 <1403920822-14488-2-git-send-email-j.glisse@gmail.com>
 <019CCE693E457142B37B791721487FD91806B836@storexdag01.amd.com>
 <20140630154042.GD26537@8bytes.org>
 <20140630160604.GF1956@gmail.com>
 <20140630181623.GE26537@8bytes.org>
 <20140630183556.GB3280@gmail.com>
 <20140701091535.GF26537@8bytes.org>
 <019CCE693E457142B37B791721487FD91806DD8B@storexdag01.amd.com>
 <20140701110018.GH26537@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20140701110018.GH26537@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: "Gabbay, Oded" <Oded.Gabbay@amd.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "Lewycky, Andrew" <Andrew.Lewycky@amd.com>, "Cornwall, Jay" <Jay.Cornwall@amd.com>, "Bridgman, John" <John.Bridgman@amd.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mgorman@suse.de" <mgorman@suse.de>, "hpa@zytor.com" <hpa@zytor.com>, "peterz@infraread.org" <peterz@infraread.org>, "aarcange@redhat.com" <aarcange@redhat.com>, "riel@redhat.com" <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, Mark Hairgrove <mhairgrove@nvidia.com>, Jatin Kumar <jakumar@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>

On Tue, Jul 01, 2014 at 01:00:18PM +0200, Joerg Roedel wrote:
> On Tue, Jul 01, 2014 at 09:29:49AM +0000, Gabbay, Oded wrote:
> > In the KFD, we need to maintain a notion of each compute process.
> > Therefore, we have an object called "kfd_process" that is created for
> > each process that uses the KFD. Naturally, we need to be able to track
> > the process's shutdown in order to perform cleanup of the resources it
> > uses (compute queues, virtual address space, gpu local memory
> > allocations, etc.).
> 
> If it is only that, you can also use the task_exit notifier already in
> the kernel.

No task_exit will happen per thread not once per mm.

> 
> > To enable this tracking mechanism, we decided to associate the
> > kfd_process with mm_struct to ensure that a kfd_process object has
> > exactly the same lifespan as the process it represents. We preferred to
> > use the mm_struct and not a file description because using a file
> > descriptor to track a??processa?? shutdown is wrong in two ways:
> > 
> > * Technical: file descriptors can be passed to unrelated processes using
> > AF_UNIX sockets. This means that a process can exit while the file stays
> > open. Even if we implement this a??correctlya?? i.e. holding the address
> > space & page tables alive until the file is finally released, ita??s
> > really dodgy.
> 
> No, its not in this case. The file descriptor is used to connect a
> process address space with a device context. Thus without the mappings
> the file-descriptor is useless and the mappings should stay in-tact
> until the fd is closed.
> 
> It would be a very bad semantic for userspace if a fd that is passed on
> fails on the other side because the sending process died.
> 

Consider use case where there is no file associated with the mmu_notifier
ie there is no device file descriptor that could hold and take care of
mmu_notifier destruction and cleanup. We need this call chain for this
case.

Anyother idea than task_exit ?

Cheers,
JA(C)rA'me

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
