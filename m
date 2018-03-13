Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0894F6B0007
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 06:46:51 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id h33so11501824wrh.10
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 03:46:50 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c7sor158534edi.56.2018.03.13.03.46.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Mar 2018 03:46:49 -0700 (PDT)
Date: Tue, 13 Mar 2018 11:46:44 +0100
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [RFC PATCH 00/13] SVM (share virtual memory) with HMM in nouveau
Message-ID: <20180313104644.GB4788@phenom.ffwll.local>
References: <20180310032141.6096-1-jglisse@redhat.com>
 <cae53b72-f99c-7641-8cb9-5cbe0a29b585@gmail.com>
 <20180312173009.GN8589@phenom.ffwll.local>
 <20180312175057.GC4214@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180312175057.GC4214@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: christian.koenig@amd.com, dri-devel@lists.freedesktop.org, nouveau@lists.freedesktop.org, Evgeny Baskakov <ebaskakov@nvidia.com>, linux-mm@kvack.org, Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Felix Kuehling <felix.kuehling@amd.com>, "Bridgman, John" <John.Bridgman@amd.com>

On Mon, Mar 12, 2018 at 01:50:58PM -0400, Jerome Glisse wrote:
> On Mon, Mar 12, 2018 at 06:30:09PM +0100, Daniel Vetter wrote:
> > On Sat, Mar 10, 2018 at 04:01:58PM +0100, Christian K??nig wrote:
> 
> [...]
> 
> > > > They are work underway to revamp nouveau channel creation with a new
> > > > userspace API. So we might want to delay upstreaming until this lands.
> > > > We can stil discuss one aspect specific to HMM here namely the issue
> > > > around GEM objects used for some specific part of the GPU. Some engine
> > > > inside the GPU (engine are a GPU block like the display block which
> > > > is responsible of scaning memory to send out a picture through some
> > > > connector for instance HDMI or DisplayPort) can only access memory
> > > > with virtual address below (1 << 40). To accomodate those we need to
> > > > create a "hole" inside the process address space. This patchset have
> > > > a hack for that (patch 13 HACK FOR HMM AREA), it reserves a range of
> > > > device file offset so that process can mmap this range with PROT_NONE
> > > > to create a hole (process must make sure the hole is below 1 << 40).
> > > > I feel un-easy of doing it this way but maybe it is ok with other
> > > > folks.
> > > 
> > > Well we have essentially the same problem with pre gfx9 AMD hardware. Felix
> > > might have some advise how it was solved for HSA.
> > 
> > Couldn't we do an in-kernel address space for those special gpu blocks? As
> > long as it's display the kernel needs to manage it anyway, and adding a
> > 2nd mapping when you pin/unpin for scanout usage shouldn't really matter
> > (as long as you cache the mapping until the buffer gets thrown out of
> > vram). More-or-less what we do for i915 (where we have an entirely
> > separate address space for these things which is 4G on the latest chips).
> > -Daniel
> 
> We can not do an in-kernel address space for those. We already have an
> in kernel address space but it does not apply for the object considered
> here.
> 
> For NVidia (i believe this is the same for AMD AFAIK) the objects we
> are talking about are objects that must be in the same address space
> as the one against which process's shader/dma/... get executed.
> 
> For instance command buffer submited by userspace must be inside a
> GEM object mapped inside the GPU's process address against which the
> command are executed. My understanding is that the PFIFO (the engine
> on nv GPU that fetch commands) first context switch to address space
> associated with the channel and then starts fetching commands with
> all address being interpreted against the channel address space.
> 
> Hence why we need to reserve some range in the process virtual address
> space if we want to do SVM in a sane way. I mean we could just map
> buffer into GPU page table and then cross fingers and toes hopping that
> the process will never get any of its mmap overlapping those mapping :)

Ah, from the example I got the impression it's just the display engine
that has this restriction. CS/PFIFO having the same restriction is indeed
more fun.
-Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
http://blog.ffwll.ch
