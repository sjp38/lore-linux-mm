Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 658E26B002B
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 11:32:35 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id e17so4743pgv.5
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 08:32:35 -0700 (PDT)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0089.outbound.protection.outlook.com. [104.47.32.89])
        by mx.google.com with ESMTPS id b62si311569pfl.409.2018.03.13.08.32.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 13 Mar 2018 08:32:32 -0700 (PDT)
Subject: Re: [RFC PATCH 00/13] SVM (share virtual memory) with HMM in nouveau
References: <20180310032141.6096-1-jglisse@redhat.com>
 <cae53b72-f99c-7641-8cb9-5cbe0a29b585@gmail.com>
 <ef3d82cd-6c39-a50a-c4cb-d9d9ba13e31b@amd.com>
 <20180313142759.GB3828@redhat.com>
From: Felix Kuehling <felix.kuehling@amd.com>
Message-ID: <689b24d0-e428-3a69-3e59-9f65bfd9b374@amd.com>
Date: Tue, 13 Mar 2018 11:32:24 -0400
MIME-Version: 1.0
In-Reply-To: <20180313142759.GB3828@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-CA
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: christian.koenig@amd.com, dri-devel@lists.freedesktop.org, nouveau@lists.freedesktop.org, Evgeny Baskakov <ebaskakov@nvidia.com>, linux-mm@kvack.org, Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, "Bridgman, John" <John.Bridgman@amd.com>

On 2018-03-13 10:28 AM, Jerome Glisse wrote:
> On Mon, Mar 12, 2018 at 02:28:42PM -0400, Felix Kuehling wrote:
>> On 2018-03-10 10:01 AM, Christian KA?nig wrote:
>>>> To accomodate those we need to
>>>> create a "hole" inside the process address space. This patchset have
>>>> a hack for that (patch 13 HACK FOR HMM AREA), it reserves a range of
>>>> device file offset so that process can mmap this range with PROT_NONE
>>>> to create a hole (process must make sure the hole is below 1 << 40).
>>>> I feel un-easy of doing it this way but maybe it is ok with other
>>>> folks.
>>> Well we have essentially the same problem with pre gfx9 AMD hardware.
>>> Felix might have some advise how it was solved for HSA. 
>> For pre-gfx9 hardware we reserve address space in user mode using a big
>> mmap PROT_NONE call at application start. Then we manage the address
>> space in user mode and use MAP_FIXED to map buffers at specific
>> addresses within the reserved range.
>>
>> The big address space reservation causes issues for some debugging tools
>> (clang-sanitizer was mentioned to me), so with gfx9 we're going to get
>> rid of this address space reservation.
> What do you need those mapping for ? What kind of object (pm4 packet
> command buffer, GPU semaphore | fence, ...) ? Kernel private object ?
> On nv we need it for the main command buffer ring which we do not want
> to expose to application.

On pre-gfx9 hardware the GPU virtual address space is limted to 40 bits
for all hardware blocks. So all GPU-accessible memory must be below 40-bits.

> Thus for nv gpu we need kernel to monitor this PROT_NONE region to make
> sure that i never got unmapped, resize, move ... this is me fearing a
> rogue userspace that munmap and try to abuse some bug in SVM/GPU driver
> to abuse object map behind those fix mapping.

We mmap PROT_NONE anonymous memory and we don't have any safeguards
against rogue code unmapping it or modifying the mappings. The same
argument made by John Hubbard applies. If applications mess with
existing memory mappings, they are broken anyway. Why do our mappings
need special protections, but a mapping of e.g. libc doesn't?

In our case, we don't have HMM (yet), so in most cases changing the
memory mapping on the CPU side won't affect the GPU mappings. The
exception to that would be userptr mappings where a rogue unmap would
trigger an MMU notifier and result in updating the GPU mapping, which
could lead to a GPU VM fault later on.

Regards,
A  Felix

>
> Cheers,
> JA(C)rA'me
