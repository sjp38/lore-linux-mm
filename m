Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f51.google.com (mail-qa0-f51.google.com [209.85.216.51])
	by kanga.kvack.org (Postfix) with ESMTP id ED2816B0038
	for <linux-mm@kvack.org>; Fri, 29 Aug 2014 15:10:25 -0400 (EDT)
Received: by mail-qa0-f51.google.com with SMTP id j7so2522966qaq.24
        for <linux-mm@kvack.org>; Fri, 29 Aug 2014 12:10:25 -0700 (PDT)
Received: from mail-qg0-x232.google.com (mail-qg0-x232.google.com [2607:f8b0:400d:c04::232])
        by mx.google.com with ESMTPS id v4si1420791qcf.33.2014.08.29.12.10.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 29 Aug 2014 12:10:25 -0700 (PDT)
Received: by mail-qg0-f50.google.com with SMTP id q108so2672507qgd.37
        for <linux-mm@kvack.org>; Fri, 29 Aug 2014 12:10:25 -0700 (PDT)
From: j.glisse@gmail.com
Subject: [RFC PATCH 0/6] HMM (heterogeneous memory management) v4
Date: Fri, 29 Aug 2014 15:10:09 -0400
Message-Id: <1409339415-3626-1-git-send-email-j.glisse@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Haggai Eran <haggaie@mellanox.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>

This is an updated patchset for HMM (Heterogeneous Memory Management). In
a nutshell HMM is a subsystem that provide an easy to use api to mirror a
process address on a device with minimal hardware requirement. The device
must be able to handle page fault (missing entry inside its page table),
must be support read only mapping. It does not rely on ATS and PASID PCIE
extensions. It intends to supersede those extensions by allowing to move
system memory to device memory in a transparent fashion for core kernel mm
code (ie cpu page fault on page residing in device memory will trigger
migration back to system memory).

I think it has been establish in previous discussion of HMM that device
memory, specificaly in GPU case, is a thing that will remains revealent
given that device memory bandwith keep growing faster than system memory
bandwidth. You can find link to previous discussion at bottom of this
email.

Even the case of CPU with GPU in same package (same die or not) associated
with pool of fast memory (either in same package or in same die like stack
memory) can leverage HMM. Current implementation of package memory manage
it like another level of cache making it transparent for the operating
system but adding a management cost and being less flexible and in some
case making worse decision on what should be cached or not.


In this version of the patchset i wanted to address the request of device
driver folks that want to abstract the handling of the iommu mapping of
pages of a process. To achieve this patch 5 introduce a new iommu domain
api that allow to map a directory of page into a specific domain and to
later on update this directory mapping.

Before going further down that patch i would like to gather feedback and
see if such api have a change to be accepted. I should stress that while
i demonstrate how it is intended to be use inside HMM in patch 6. This api
can also be use by thing such as dma-buf for more legacy GPU workload and
i am sure there are others driver that might find this api usefull.

It does however rely on exposing which domain a device is bound to. This
domain should not change as long as a driver is bind to the device (at
least this is my understanding). So i believe it is fine to expose this.


To avoid writting over and over the same code patch 2 introduce a generic
lockless arch independant page table. I have made it very flexible leading
to quite a lot of fields but if it sounds more reasonable to only care
about two case (unsigned long and uint64 namely) then code and structure
can be simplify.

It has been designed to be a suitable replacement for AMD and Intel IOMMU
driver code. Thought for AMD case there is still some work that needs to
be done to support level skipping. Before adding that i wanted to gather
interest about of converting AMD and Intel IOMMU driver to use that code.

The HMM have been lightly tested and the IOMMU part is untested at this
point. But if there is no objection with the IOMMU API i will go ahead
and implement it for AMD and Intel IOMMU. Then i will take a stab at
converting mlx5 driver to use HMM.


As usual comments are more then welcome. Thanks in advance to anyone that
take a look at this code.

Previous patchset posting :
  v1 http://lwn.net/Articles/597289/
  v2 https://lkml.org/lkml/2014/6/12/559 (cover letter did not make it to ml)
  v3 https://lkml.org/lkml/2014/6/13/633


Cheers,
JA(C)rA'me

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
