Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id FAA17372
	for <linux-mm@kvack.org>; Thu, 22 Oct 1998 05:26:56 -0400
Date: Thu, 22 Oct 1998 11:25:32 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: MM with fragmented memory
In-Reply-To: <199810220750.JAA05796@lrcsun15.epfl.ch>
Message-ID: <Pine.LNX.3.96.981022112124.365A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Werner Almesberger <almesber@lrc.di.epfl.ch>
Cc: Linux MM <linux-mm@kvack.org>, linux-7110@redhat.com
List-ID: <linux-mm.kvack.org>

On Thu, 22 Oct 1998, Werner Almesberger wrote:

> [ Posted to linux-kernel and linux-7110 ]

linux-kernel replaced by linux-mm, since that is where the
MM folks hang around and linux-kernel is busy enough as it
is...

> I'd like to get some opinions on what could be a reasonable memory mapping
> for the Psion S5. The problem with this device is that its physical RAM is
> scattered over a 30 bit address space in little fragments of 512kB,
> aligned to multiples of 1MB. Since it's impossible to fit any useful
> kernel into 512kB, some creative memory layout is necessary.

;)

> I can see two viable approaches:
> 
>   (1) play linker tricks and insert holes in the kernel such that it skips
>       over the gaps in memory. Then map all the memory 1:1 and let
>       start_mem and end_mem each have one of the 512kB fragments for
>       linear allocation.
>   (2) use the MMU to create virtually continuous memory and let the kernel
>       manage that in the usual way.

The kernel needs to be aware of the physical mappings, so
it can't virtualize itself...

> The problems I see with (1) are:
>  - at least part of the memory layout needs to be known when linking the
>    kernel

We already do that on x86 and possibly some other
platforms.

>  - allocations from start_mem and end_mem are each limited to a total of
>    512kB

Allocations are limited to 128kB already. There's not much
point in worrying about this and we can keep it into mind
when changing the buddy allocator to something else.

>  - need to re-arrange VMALLOC_END, because on ARM-Linux it's 256 MB after
>    PAGE_OFFSET, but VMALLOC_START will already have to be about 278 MB
>    after that, due to the "exploded" address space. (But that change may
>    be harmless.)
> The problems I see with (2) are:
>  - virt_to_phys and phys_to_virt now need to perform lookups (in (1)
>    they're no-ops). With a few tricks, I can get each of them done in
>    about 10 clock cycles, clobbering two registers (out of 16), and
>    accessing memory once
>  - a little voice in the back of my head saying that something in the
>    kernel will certainly trip over a virtual:physical mapping that isn't
>    just an offset

I don't know about this -- Stephen, Ingo?

> While I'm attracted by the simplicity of (1), I'm a little worried about
> the limitation for linear allocations. Also, initrd needs a little work
> to function in such a scenario.
> 
> The disadvantage of (2) is clearly its complexity. Also, I don't like
> what that little voice is saying ...

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
