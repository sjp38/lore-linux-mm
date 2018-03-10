Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8DB666B0005
	for <linux-mm@kvack.org>; Sat, 10 Mar 2018 12:55:32 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id d85so4051665qke.11
        for <linux-mm@kvack.org>; Sat, 10 Mar 2018 09:55:32 -0800 (PST)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id v10si3418561qth.127.2018.03.10.09.55.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 10 Mar 2018 09:55:31 -0800 (PST)
Date: Sat, 10 Mar 2018 12:55:28 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC PATCH 00/13] SVM (share virtual memory) with HMM in nouveau
Message-ID: <20180310175528.GA3394@redhat.com>
References: <20180310032141.6096-1-jglisse@redhat.com>
 <cae53b72-f99c-7641-8cb9-5cbe0a29b585@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <cae53b72-f99c-7641-8cb9-5cbe0a29b585@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: christian.koenig@amd.com
Cc: dri-devel@lists.freedesktop.org, nouveau@lists.freedesktop.org, Evgeny Baskakov <ebaskakov@nvidia.com>, linux-mm@kvack.org, Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Felix Kuehling <felix.kuehling@amd.com>, "Bridgman, John" <John.Bridgman@amd.com>

On Sat, Mar 10, 2018 at 04:01:58PM +0100, Christian Konig wrote:
> Good to have an example how to use HMM with an upstream driver.

I have tried to keep hardware specific bits and overal HMM logic separated
so people can use it as an example without needing to understand NVidia GPU.
I think i can still split patches a bit some more along that line.

> Am 10.03.2018 um 04:21 schrieb jglisse@redhat.com:
> > This patchset adds SVM (Share Virtual Memory) using HMM (Heterogeneous
> > Memory Management) to the nouveau driver. SVM means that GPU threads
> > spawn by GPU driver for a specific user process can access any valid
> > CPU address in that process. A valid pointer is a pointer inside an
> > area coming from mmap of private, share or regular file. Pointer to
> > a mmap of a device file or special file are not supported.
> 
> BTW: The recent IOMMU patches which generalized the PASID handling calls
> this SVA for shared virtual address space.
> 
> We should probably sync up with those guys at some point what naming to use.

Let's create a committee to decide on the name ;)

> 
> > This is an RFC for few reasons technical reasons listed below and also
> > because we are still working on a proper open source userspace (namely
> > a OpenCL 2.0 for nouveau inside mesa). Open source userspace being a
> > requirement for the DRM subsystem. I pushed in [1] a simple standalone
> > program that can be use to test SVM through HMM with nouveau. I expect
> > we will have a somewhat working userspace in the coming weeks, work
> > being well underway and some patches have already been posted on mesa
> > mailing list.
> 
> You could use the OpenGL extensions to import arbitrary user pointers as
> bringup use case for this.
> 
> I was hoping to do the same for my ATC/HMM work on radeonsi and as far
> as I know there are even piglit tests for that.

OpenGL extensions are bit too limited when i checked them long time ago.
I think we rather have something like OpenCL ready so that it is easier
to justify some of the more compute only features. My timeline is 4.18
for HMM inside nouveau upstream (roughly) as first some other changes to
nouveau need to land. So i am thinking (hoping :)) that all the stars
will be properly align by then.


> > They are work underway to revamp nouveau channel creation with a new
> > userspace API. So we might want to delay upstreaming until this lands.
> > We can stil discuss one aspect specific to HMM here namely the issue
> > around GEM objects used for some specific part of the GPU. Some engine
> > inside the GPU (engine are a GPU block like the display block which
> > is responsible of scaning memory to send out a picture through some
> > connector for instance HDMI or DisplayPort) can only access memory
> > with virtual address below (1 << 40). To accomodate those we need to
> > create a "hole" inside the process address space. This patchset have
> > a hack for that (patch 13 HACK FOR HMM AREA), it reserves a range of
> > device file offset so that process can mmap this range with PROT_NONE
> > to create a hole (process must make sure the hole is below 1 << 40).
> > I feel un-easy of doing it this way but maybe it is ok with other
> > folks.
> 
> Well we have essentially the same problem with pre gfx9 AMD hardware.
> Felix might have some advise how it was solved for HSA.

Here my concern is around API expose to userspace for this "hole"/reserved
area. I considered several options:
  - Have userspace allocate all object needed by GPU and mmap them
    at proper VA (Virtual Address) this need kernel to do special
    handling for those like blocking userspace access for sensitive
    object (page table, command buffer, ...) so a lot of kernel
    changes. This somewhat make sense with some of the nouveau API
    rework that have not landed yet.
  - Have kernel directly create a PROT_NONE vma against device file. Nice
    thing is that it is easier in kernel to find a hole of proper size
    in proper range. But this is ugly and i think i would be stone to
    death if i were to propose that.
  - just pick a range and cross finger that userspace never got any of
    its allocation in it (at least any allocation it want to use on the
    GPU).
  - Have userspace mmap with PROT_NONE a specific region of the device
    file to create this hole (this is what this patchset does). Note
    that PROT_NONE is not strictly needed but this is what it would get
    as device driver block any access to it.

Any other solution i missed ?

I don't like any of the above ... but this is more of a taste thing. The
last option is the least ugly in my view. Also in this patchset if user-
space munmap() the hole or any part of it, it does kill HMM for the
process. This is an important details for security and consistant result
in front of buggy/rogue applications.

Other aspect bother me too, like should i create a region in device file
so that mmap need to happen in the region, or should i just pick a single
offset that would trigger the special mmap path. Nowadays i think none
of the drm driver properly handle mmap that cross the DRM_FILE_OFFSET
boundary, but we don't expect those to happen either. So latter option
(single offset) would make sense.

Cheers,
Jerome
