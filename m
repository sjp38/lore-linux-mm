Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id E50616B0005
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 02:14:50 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id y3so8065008qka.14
        for <linux-mm@kvack.org>; Mon, 12 Mar 2018 23:14:50 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id e132si6084896qkb.311.2018.03.12.23.14.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Mar 2018 23:14:49 -0700 (PDT)
Subject: Re: [RFC PATCH 00/13] SVM (share virtual memory) with HMM in nouveau
References: <20180310032141.6096-1-jglisse@redhat.com>
 <cae53b72-f99c-7641-8cb9-5cbe0a29b585@gmail.com>
 <20180312173009.GN8589@phenom.ffwll.local> <20180312175057.GC4214@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <39139ff7-76ad-960c-53f6-46b57525b733@nvidia.com>
Date: Mon, 12 Mar 2018 23:14:47 -0700
MIME-Version: 1.0
In-Reply-To: <20180312175057.GC4214@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>, christian.koenig@amd.com, dri-devel@lists.freedesktop.org, nouveau@lists.freedesktop.org, Evgeny Baskakov <ebaskakov@nvidia.com>, linux-mm@kvack.org, Ralph Campbell <rcampbell@nvidia.com>, Felix Kuehling <felix.kuehling@amd.com>, "Bridgman,
 John" <John.Bridgman@amd.com>

On 03/12/2018 10:50 AM, Jerome Glisse wrote:
> On Mon, Mar 12, 2018 at 06:30:09PM +0100, Daniel Vetter wrote:
>> On Sat, Mar 10, 2018 at 04:01:58PM +0100, Christian K??nig wrote:
>=20
> [...]
>=20
>>>> They are work underway to revamp nouveau channel creation with a new
>>>> userspace API. So we might want to delay upstreaming until this lands.
>>>> We can stil discuss one aspect specific to HMM here namely the issue
>>>> around GEM objects used for some specific part of the GPU. Some engine
>>>> inside the GPU (engine are a GPU block like the display block which
>>>> is responsible of scaning memory to send out a picture through some
>>>> connector for instance HDMI or DisplayPort) can only access memory
>>>> with virtual address below (1 << 40). To accomodate those we need to
>>>> create a "hole" inside the process address space. This patchset have
>>>> a hack for that (patch 13 HACK FOR HMM AREA), it reserves a range of
>>>> device file offset so that process can mmap this range with PROT_NONE
>>>> to create a hole (process must make sure the hole is below 1 << 40).
>>>> I feel un-easy of doing it this way but maybe it is ok with other
>>>> folks.
>>>
>>> Well we have essentially the same problem with pre gfx9 AMD hardware. F=
elix
>>> might have some advise how it was solved for HSA.
>>
>> Couldn't we do an in-kernel address space for those special gpu blocks? =
As
>> long as it's display the kernel needs to manage it anyway, and adding a
>> 2nd mapping when you pin/unpin for scanout usage shouldn't really matter
>> (as long as you cache the mapping until the buffer gets thrown out of
>> vram). More-or-less what we do for i915 (where we have an entirely
>> separate address space for these things which is 4G on the latest chips)=
.
>> -Daniel
>=20
> We can not do an in-kernel address space for those. We already have an
> in kernel address space but it does not apply for the object considered
> here.
>=20
> For NVidia (i believe this is the same for AMD AFAIK) the objects we
> are talking about are objects that must be in the same address space
> as the one against which process's shader/dma/... get executed.
>=20
> For instance command buffer submited by userspace must be inside a
> GEM object mapped inside the GPU's process address against which the
> command are executed. My understanding is that the PFIFO (the engine
> on nv GPU that fetch commands) first context switch to address space
> associated with the channel and then starts fetching commands with
> all address being interpreted against the channel address space.
>=20
> Hence why we need to reserve some range in the process virtual address
> space if we want to do SVM in a sane way. I mean we could just map
> buffer into GPU page table and then cross fingers and toes hopping that
> the process will never get any of its mmap overlapping those mapping :)
>=20
> Cheers,
> J=C3=A9r=C3=B4me
>=20

Hi Jerome and all,

Yes, on NVIDIA GPUs, the Host/FIFO unit is limited to 40-bit addresses, so
things such as the following need to be below (1 << 40), and also accessibl=
e=20
to both CPU (user space) and GPU hardware.=20
    -- command buffers (CPU user space driver fills them, GPU consumes them=
),=20
    -- semaphores (here, a GPU-centric term, rather than OS-type: these are
       memory locations that, for example, the GPU hardware might write to,=
 in
       order to indicate work completion; there are other uses as well),=20
    -- a few other things most likely (this is not a complete list).

So what I'd tentatively expect that to translate into in the driver stack i=
s,=20
approximately:

    -- User space driver code mmap's an area below (1 << 40). It's hard to =
avoid this,
       given that user space needs access to the area (for filling out comm=
and
       buffers and monitoring semaphores, that sort of thing). Then suballo=
cate
       from there using mmap's MAP_FIXED or (future-ish) MAP_FIXED_SAFE fla=
gs.

       ...glancing at the other fork of this thread, I think that is exactl=
y what
       Felix is saying, too. So that's good.

    -- The user space program sits above the user space driver, and althoug=
h the
       program could, in theory, interfere with this mmap'd area, that woul=
d be
       wrong in the same way that mucking around with malloc'd areas (outsi=
de of
       malloc() itself) is wrong. So I don't see any particular need to do =
much
       more than the above.

thanks,
--=20
John Hubbard
NVIDIA
