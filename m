Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2CA186B000D
	for <linux-mm@kvack.org>; Thu,  1 Nov 2018 02:49:18 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id z13-v6so13690757pgv.18
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 23:49:18 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y40-v6sor12436478pla.26.2018.10.31.23.49.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Oct 2018 23:49:17 -0700 (PDT)
Date: Thu, 1 Nov 2018 17:19:11 +1030
From: Alan Modra <amodra@gmail.com>
Subject: Re: PIE binaries are no longer mapped below 4 GiB on ppc64le
Message-ID: <20181101064911.GB29482@bubble.grove.modra.org>
References: <87k1lyf2x3.fsf@oldenburg.str.redhat.com>
 <87lg6dfo3t.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87lg6dfo3t.fsf@concordia.ellerman.id.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Florian Weimer <fweimer@redhat.com>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, keescook@chromium.org

On Thu, Nov 01, 2018 at 02:55:34PM +1100, Michael Ellerman wrote:
> Hi Florian,
> 
> Florian Weimer <fweimer@redhat.com> writes:
> > We tried to use Go to build PIE binaries, and while the Go toolchain is
> > definitely not ready (it produces text relocations and problematic
> > relocations in general), it exposed what could be an accidental
> > userspace ABI change.
> >
> > With our 4.10-derived kernel, PIE binaries are mapped below 4 GiB, so
> > relocations like R_PPC64_ADDR16_HA work:
> >
> > 21f00000-220d0000 r-xp 00000000 fd:00 36593493                           /root/extld
> > 220d0000-220e0000 r--p 001c0000 fd:00 36593493                           /root/extld
> > 220e0000-22100000 rw-p 001d0000 fd:00 36593493                           /root/extld
> ...
> >
> > With a 4.18-derived kernel (with the hashed mm), we get this instead:
> >
> > 120e60000-121030000 rw-p 00000000 fd:00 102447141                        /root/extld
> > 121030000-121060000 rw-p 001c0000 fd:00 102447141                        /root/extld
> > 121060000-121080000 rw-p 00000000 00:00 0 
> 
> I assume that's caused by:
> 
>   47ebb09d5485 ("powerpc: move ELF_ET_DYN_BASE to 4GB / 4MB")
> 
> Which did roughly:
> 
>   -#define ELF_ET_DYN_BASE	0x20000000
>   +#define ELF_ET_DYN_BASE		(is_32bit_task() ? 0x000400000UL : \
>   +					   0x100000000UL)
> 
> And went into 4.13.
> 
> > ...
> > I'm not entirely sure what to make of this, but I'm worried that this
> > could be a regression that matters to userspace.
> 
> It was a deliberate change, and it seemed to not break anything so we
> merged it. But obviously we didn't test widely enough.
> 
> So I guess it clearly can matter to userspace, and it used to work, so
> therefore it is a regression.
> 
> But at the same time we haven't had any other reports of breakage, so is
> this somehow specific to something Go is doing? Or did we just get lucky
> up until now? Or is no one actually testing on Power? ;)

Mapping PIEs above 4G should be fine.  It works for gcc C and C++
after all.  The problem is that ppc64le Go is generating code not
suitable for a PIE.  Dynamic text relocations are evidence of non-PIC
object files.

Quoting Lynn Boger <boger@us.ibm.com>:
"When building a pie binary with golang, they should be using
-buildmode=pie and not just pass -pie to the linker".

-- 
Alan Modra
Australia Development Lab, IBM
