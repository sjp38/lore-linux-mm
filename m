Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id BF6046B0009
	for <linux-mm@kvack.org>; Sat, 10 Mar 2018 10:02:02 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id n12so2250860wmc.5
        for <linux-mm@kvack.org>; Sat, 10 Mar 2018 07:02:02 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h14sor1549374wrb.30.2018.03.10.07.02.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 10 Mar 2018 07:02:01 -0800 (PST)
Reply-To: christian.koenig@amd.com
Subject: Re: [RFC PATCH 00/13] SVM (share virtual memory) with HMM in nouveau
References: <20180310032141.6096-1-jglisse@redhat.com>
From: =?UTF-8?Q?Christian_K=c3=b6nig?= <ckoenig.leichtzumerken@gmail.com>
Message-ID: <cae53b72-f99c-7641-8cb9-5cbe0a29b585@gmail.com>
Date: Sat, 10 Mar 2018 16:01:58 +0100
MIME-Version: 1.0
In-Reply-To: <20180310032141.6096-1-jglisse@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com, dri-devel@lists.freedesktop.org, nouveau@lists.freedesktop.org
Cc: Evgeny Baskakov <ebaskakov@nvidia.com>, linux-mm@kvack.org, Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Felix Kuehling <felix.kuehling@amd.com>, "Bridgman, John" <John.Bridgman@amd.com>

Good to have an example how to use HMM with an upstream driver.

Am 10.03.2018 um 04:21 schrieb jglisse@redhat.com:
> This patchset adds SVM (Share Virtual Memory) using HMM (Heterogeneous
> Memory Management) to the nouveau driver. SVM means that GPU threads
> spawn by GPU driver for a specific user process can access any valid
> CPU address in that process. A valid pointer is a pointer inside an
> area coming from mmap of private, share or regular file. Pointer to
> a mmap of a device file or special file are not supported.

BTW: The recent IOMMU patches which generalized the PASID handling calls 
this SVA for shared virtual address space.

We should probably sync up with those guys at some point what naming to use.

> This is an RFC for few reasons technical reasons listed below and also
> because we are still working on a proper open source userspace (namely
> a OpenCL 2.0 for nouveau inside mesa). Open source userspace being a
> requirement for the DRM subsystem. I pushed in [1] a simple standalone
> program that can be use to test SVM through HMM with nouveau. I expect
> we will have a somewhat working userspace in the coming weeks, work
> being well underway and some patches have already been posted on mesa
> mailing list.

You could use the OpenGL extensions to import arbitrary user pointers as 
bringup use case for this.

I was hoping to do the same for my ATC/HMM work on radeonsi and as far 
as I know there are even piglit tests for that.

> They are work underway to revamp nouveau channel creation with a new
> userspace API. So we might want to delay upstreaming until this lands.
> We can stil discuss one aspect specific to HMM here namely the issue
> around GEM objects used for some specific part of the GPU. Some engine
> inside the GPU (engine are a GPU block like the display block which
> is responsible of scaning memory to send out a picture through some
> connector for instance HDMI or DisplayPort) can only access memory
> with virtual address below (1 << 40). To accomodate those we need to
> create a "hole" inside the process address space. This patchset have
> a hack for that (patch 13 HACK FOR HMM AREA), it reserves a range of
> device file offset so that process can mmap this range with PROT_NONE
> to create a hole (process must make sure the hole is below 1 << 40).
> I feel un-easy of doing it this way but maybe it is ok with other
> folks.

Well we have essentially the same problem with pre gfx9 AMD hardware. 
Felix might have some advise how it was solved for HSA.

Regards,
Christian.
