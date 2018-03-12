Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2C3E66B000C
	for <linux-mm@kvack.org>; Mon, 12 Mar 2018 13:30:17 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id p2so9710127wre.19
        for <linux-mm@kvack.org>; Mon, 12 Mar 2018 10:30:17 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id q5sor3748784edj.54.2018.03.12.10.30.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 12 Mar 2018 10:30:15 -0700 (PDT)
Date: Mon, 12 Mar 2018 18:30:09 +0100
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [RFC PATCH 00/13] SVM (share virtual memory) with HMM in nouveau
Message-ID: <20180312173009.GN8589@phenom.ffwll.local>
References: <20180310032141.6096-1-jglisse@redhat.com>
 <cae53b72-f99c-7641-8cb9-5cbe0a29b585@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cae53b72-f99c-7641-8cb9-5cbe0a29b585@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: christian.koenig@amd.com
Cc: jglisse@redhat.com, dri-devel@lists.freedesktop.org, nouveau@lists.freedesktop.org, Evgeny Baskakov <ebaskakov@nvidia.com>, linux-mm@kvack.org, Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Felix Kuehling <felix.kuehling@amd.com>, "Bridgman, John" <John.Bridgman@amd.com>

On Sat, Mar 10, 2018 at 04:01:58PM +0100, Christian K??nig wrote:
> Good to have an example how to use HMM with an upstream driver.
> 
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
> I was hoping to do the same for my ATC/HMM work on radeonsi and as far as I
> know there are even piglit tests for that.

Yeah userptr seems like a reasonable bring-up use-case for stuff like
this, makes it all a bit more manageable. I suggested the same for the
i915 efforts. Definitely has my ack for upstream HMM/SVM uapi extensions.

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
> Well we have essentially the same problem with pre gfx9 AMD hardware. Felix
> might have some advise how it was solved for HSA.

Couldn't we do an in-kernel address space for those special gpu blocks? As
long as it's display the kernel needs to manage it anyway, and adding a
2nd mapping when you pin/unpin for scanout usage shouldn't really matter
(as long as you cache the mapping until the buffer gets thrown out of
vram). More-or-less what we do for i915 (where we have an entirely
separate address space for these things which is 4G on the latest chips).
-Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
http://blog.ffwll.ch
