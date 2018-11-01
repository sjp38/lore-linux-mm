Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id E87796B0005
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 23:55:40 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id y73-v6so15569377pfi.16
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 20:55:40 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id v19-v6si12361878pfn.26.2018.10.31.20.55.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 31 Oct 2018 20:55:39 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: PIE binaries are no longer mapped below 4 GiB on ppc64le
In-Reply-To: <87k1lyf2x3.fsf@oldenburg.str.redhat.com>
References: <87k1lyf2x3.fsf@oldenburg.str.redhat.com>
Date: Thu, 01 Nov 2018 14:55:34 +1100
Message-ID: <87lg6dfo3t.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>, linuxppc-dev@lists.ozlabs.org
Cc: linux-mm@kvack.org, keescook@chromium.org, amodra@gmail.com

Hi Florian,

Florian Weimer <fweimer@redhat.com> writes:
> We tried to use Go to build PIE binaries, and while the Go toolchain is
> definitely not ready (it produces text relocations and problematic
> relocations in general), it exposed what could be an accidental
> userspace ABI change.
>
> With our 4.10-derived kernel, PIE binaries are mapped below 4 GiB, so
> relocations like R_PPC64_ADDR16_HA work:
>
> 21f00000-220d0000 r-xp 00000000 fd:00 36593493                           /root/extld
> 220d0000-220e0000 r--p 001c0000 fd:00 36593493                           /root/extld
> 220e0000-22100000 rw-p 001d0000 fd:00 36593493                           /root/extld
...
>
> With a 4.18-derived kernel (with the hashed mm), we get this instead:
>
> 120e60000-121030000 rw-p 00000000 fd:00 102447141                        /root/extld
> 121030000-121060000 rw-p 001c0000 fd:00 102447141                        /root/extld
> 121060000-121080000 rw-p 00000000 00:00 0 

I assume that's caused by:

  47ebb09d5485 ("powerpc: move ELF_ET_DYN_BASE to 4GB / 4MB")

Which did roughly:

  -#define ELF_ET_DYN_BASE	0x20000000
  +#define ELF_ET_DYN_BASE		(is_32bit_task() ? 0x000400000UL : \
  +					   0x100000000UL)

And went into 4.13.

> ...
> I'm not entirely sure what to make of this, but I'm worried that this
> could be a regression that matters to userspace.

It was a deliberate change, and it seemed to not break anything so we
merged it. But obviously we didn't test widely enough.

So I guess it clearly can matter to userspace, and it used to work, so
therefore it is a regression.

But at the same time we haven't had any other reports of breakage, so is
this somehow specific to something Go is doing? Or did we just get lucky
up until now? Or is no one actually testing on Power? ;)

cheers
