Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1CBB46B000A
	for <linux-mm@kvack.org>; Mon, 12 Mar 2018 13:51:02 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id b7so11926590ywe.17
        for <linux-mm@kvack.org>; Mon, 12 Mar 2018 10:51:02 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id g60si3558138qtd.331.2018.03.12.10.51.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Mar 2018 10:51:00 -0700 (PDT)
Date: Mon, 12 Mar 2018 13:50:58 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC PATCH 00/13] SVM (share virtual memory) with HMM in nouveau
Message-ID: <20180312175057.GC4214@redhat.com>
References: <20180310032141.6096-1-jglisse@redhat.com>
 <cae53b72-f99c-7641-8cb9-5cbe0a29b585@gmail.com>
 <20180312173009.GN8589@phenom.ffwll.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180312173009.GN8589@phenom.ffwll.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: christian.koenig@amd.com, dri-devel@lists.freedesktop.org, nouveau@lists.freedesktop.org, Evgeny Baskakov <ebaskakov@nvidia.com>, linux-mm@kvack.org, Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Felix Kuehling <felix.kuehling@amd.com>, "Bridgman, John" <John.Bridgman@amd.com>

On Mon, Mar 12, 2018 at 06:30:09PM +0100, Daniel Vetter wrote:
> On Sat, Mar 10, 2018 at 04:01:58PM +0100, Christian K??nig wrote:

[...]

> > > They are work underway to revamp nouveau channel creation with a new
> > > userspace API. So we might want to delay upstreaming until this lands.
> > > We can stil discuss one aspect specific to HMM here namely the issue
> > > around GEM objects used for some specific part of the GPU. Some engine
> > > inside the GPU (engine are a GPU block like the display block which
> > > is responsible of scaning memory to send out a picture through some
> > > connector for instance HDMI or DisplayPort) can only access memory
> > > with virtual address below (1 << 40). To accomodate those we need to
> > > create a "hole" inside the process address space. This patchset have
> > > a hack for that (patch 13 HACK FOR HMM AREA), it reserves a range of
> > > device file offset so that process can mmap this range with PROT_NONE
> > > to create a hole (process must make sure the hole is below 1 << 40).
> > > I feel un-easy of doing it this way but maybe it is ok with other
> > > folks.
> > 
> > Well we have essentially the same problem with pre gfx9 AMD hardware. Felix
> > might have some advise how it was solved for HSA.
> 
> Couldn't we do an in-kernel address space for those special gpu blocks? As
> long as it's display the kernel needs to manage it anyway, and adding a
> 2nd mapping when you pin/unpin for scanout usage shouldn't really matter
> (as long as you cache the mapping until the buffer gets thrown out of
> vram). More-or-less what we do for i915 (where we have an entirely
> separate address space for these things which is 4G on the latest chips).
> -Daniel

We can not do an in-kernel address space for those. We already have an
in kernel address space but it does not apply for the object considered
here.

For NVidia (i believe this is the same for AMD AFAIK) the objects we
are talking about are objects that must be in the same address space
as the one against which process's shader/dma/... get executed.

For instance command buffer submited by userspace must be inside a
GEM object mapped inside the GPU's process address against which the
command are executed. My understanding is that the PFIFO (the engine
on nv GPU that fetch commands) first context switch to address space
associated with the channel and then starts fetching commands with
all address being interpreted against the channel address space.

Hence why we need to reserve some range in the process virtual address
space if we want to do SVM in a sane way. I mean we could just map
buffer into GPU page table and then cross fingers and toes hopping that
the process will never get any of its mmap overlapping those mapping :)

Cheers,
Jerome
