Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 397CC6B002E
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 11:56:50 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id d128so49332qkb.6
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 08:56:50 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id q45si487384qtq.122.2018.03.13.08.56.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Mar 2018 08:56:49 -0700 (PDT)
Date: Tue, 13 Mar 2018 11:56:46 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC PATCH 00/13] SVM (share virtual memory) with HMM in nouveau
Message-ID: <20180313155645.GD3828@redhat.com>
References: <20180310032141.6096-1-jglisse@redhat.com>
 <cae53b72-f99c-7641-8cb9-5cbe0a29b585@gmail.com>
 <20180312173009.GN8589@phenom.ffwll.local>
 <20180312175057.GC4214@redhat.com>
 <39139ff7-76ad-960c-53f6-46b57525b733@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <39139ff7-76ad-960c-53f6-46b57525b733@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: christian.koenig@amd.com, dri-devel@lists.freedesktop.org, nouveau@lists.freedesktop.org, Evgeny Baskakov <ebaskakov@nvidia.com>, linux-mm@kvack.org, Ralph Campbell <rcampbell@nvidia.com>, Felix Kuehling <felix.kuehling@amd.com>, "Bridgman, John" <John.Bridgman@amd.com>

On Mon, Mar 12, 2018 at 11:14:47PM -0700, John Hubbard wrote:
> On 03/12/2018 10:50 AM, Jerome Glisse wrote:

[...]

> Yes, on NVIDIA GPUs, the Host/FIFO unit is limited to 40-bit addresses, so
> things such as the following need to be below (1 << 40), and also accessible 
> to both CPU (user space) and GPU hardware. 
>     -- command buffers (CPU user space driver fills them, GPU consumes them), 
>     -- semaphores (here, a GPU-centric term, rather than OS-type: these are
>        memory locations that, for example, the GPU hardware might write to, in
>        order to indicate work completion; there are other uses as well), 
>     -- a few other things most likely (this is not a complete list).
> 
> So what I'd tentatively expect that to translate into in the driver stack is, 
> approximately:
> 
>     -- User space driver code mmap's an area below (1 << 40). It's hard to avoid this,
>        given that user space needs access to the area (for filling out command
>        buffers and monitoring semaphores, that sort of thing). Then suballocate
>        from there using mmap's MAP_FIXED or (future-ish) MAP_FIXED_SAFE flags.
> 
>        ...glancing at the other fork of this thread, I think that is exactly what
>        Felix is saying, too. So that's good.
> 
>     -- The user space program sits above the user space driver, and although the
>        program could, in theory, interfere with this mmap'd area, that would be
>        wrong in the same way that mucking around with malloc'd areas (outside of
>        malloc() itself) is wrong. So I don't see any particular need to do much
>        more than the above.

I am worried that rogue program (i am not worried about buggy program
if people shoot themself in the foot they should feel the pain) could
use that to abuse channel to do something harmful. I am not familiar
enough with the hardware to completely rule out such scenario.

I do believe hardware with userspace queue support have the necessary
boundary to keep thing secure as i would assume for those the hardware
engineers had to take security into consideration.

Note that in my patchset the code that monitor the special vma is small
something like 20lines of code that only get call if something happen
to the reserved area. So i believe it is worth having such thing, cost
is low for little extra peace of mind :)

Cheers,
Jerome
