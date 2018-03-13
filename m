Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 153176B026C
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 10:28:05 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id 13so10567445qkg.23
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 07:28:05 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id w23si334584qtj.181.2018.03.13.07.28.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Mar 2018 07:28:03 -0700 (PDT)
Date: Tue, 13 Mar 2018 10:28:00 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC PATCH 00/13] SVM (share virtual memory) with HMM in nouveau
Message-ID: <20180313142759.GB3828@redhat.com>
References: <20180310032141.6096-1-jglisse@redhat.com>
 <cae53b72-f99c-7641-8cb9-5cbe0a29b585@gmail.com>
 <ef3d82cd-6c39-a50a-c4cb-d9d9ba13e31b@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <ef3d82cd-6c39-a50a-c4cb-d9d9ba13e31b@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Felix Kuehling <felix.kuehling@amd.com>
Cc: christian.koenig@amd.com, dri-devel@lists.freedesktop.org, nouveau@lists.freedesktop.org, Evgeny Baskakov <ebaskakov@nvidia.com>, linux-mm@kvack.org, Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, "Bridgman, John" <John.Bridgman@amd.com>

On Mon, Mar 12, 2018 at 02:28:42PM -0400, Felix Kuehling wrote:
> On 2018-03-10 10:01 AM, Christian Konig wrote:
> >> To accomodate those we need to
> >> create a "hole" inside the process address space. This patchset have
> >> a hack for that (patch 13 HACK FOR HMM AREA), it reserves a range of
> >> device file offset so that process can mmap this range with PROT_NONE
> >> to create a hole (process must make sure the hole is below 1 << 40).
> >> I feel un-easy of doing it this way but maybe it is ok with other
> >> folks.
> >
> > Well we have essentially the same problem with pre gfx9 AMD hardware.
> > Felix might have some advise how it was solved for HSA. 
> 
> For pre-gfx9 hardware we reserve address space in user mode using a big
> mmap PROT_NONE call at application start. Then we manage the address
> space in user mode and use MAP_FIXED to map buffers at specific
> addresses within the reserved range.
> 
> The big address space reservation causes issues for some debugging tools
> (clang-sanitizer was mentioned to me), so with gfx9 we're going to get
> rid of this address space reservation.

What do you need those mapping for ? What kind of object (pm4 packet
command buffer, GPU semaphore | fence, ...) ? Kernel private object ?
On nv we need it for the main command buffer ring which we do not want
to expose to application.

Thus for nv gpu we need kernel to monitor this PROT_NONE region to make
sure that i never got unmapped, resize, move ... this is me fearing a
rogue userspace that munmap and try to abuse some bug in SVM/GPU driver
to abuse object map behind those fix mapping.

Cheers,
Jerome
