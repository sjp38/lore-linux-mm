Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 25E2D6B0006
	for <linux-mm@kvack.org>; Fri,  2 Nov 2018 05:41:59 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id d8-v6so1149982pls.22
        for <linux-mm@kvack.org>; Fri, 02 Nov 2018 02:41:59 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id 83si4674721pgf.572.2018.11.02.02.41.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 02 Nov 2018 02:41:58 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: PIE binaries are no longer mapped below 4 GiB on ppc64le
In-Reply-To: <20181101064911.GB29482@bubble.grove.modra.org>
References: <87k1lyf2x3.fsf@oldenburg.str.redhat.com> <87lg6dfo3t.fsf@concordia.ellerman.id.au> <20181101064911.GB29482@bubble.grove.modra.org>
Date: Fri, 02 Nov 2018 20:41:54 +1100
Message-ID: <87d0rnerz1.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alan Modra <amodra@gmail.com>
Cc: Florian Weimer <fweimer@redhat.com>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, keescook@chromium.org

Alan Modra <amodra@gmail.com> writes:
> On Thu, Nov 01, 2018 at 02:55:34PM +1100, Michael Ellerman wrote:
>> Hi Florian,
>> 
>> Florian Weimer <fweimer@redhat.com> writes:
>> > We tried to use Go to build PIE binaries, and while the Go toolchain is
>> > definitely not ready (it produces text relocations and problematic
>> > relocations in general), it exposed what could be an accidental
>> > userspace ABI change.
>> >
>> > With our 4.10-derived kernel, PIE binaries are mapped below 4 GiB, so
>> > relocations like R_PPC64_ADDR16_HA work:
>> >
>> > 21f00000-220d0000 r-xp 00000000 fd:00 36593493                           /root/extld
>> > 220d0000-220e0000 r--p 001c0000 fd:00 36593493                           /root/extld
>> > 220e0000-22100000 rw-p 001d0000 fd:00 36593493                           /root/extld
>> ...
>> >
>> > With a 4.18-derived kernel (with the hashed mm), we get this instead:
>> >
>> > 120e60000-121030000 rw-p 00000000 fd:00 102447141                        /root/extld
>> > 121030000-121060000 rw-p 001c0000 fd:00 102447141                        /root/extld
>> > 121060000-121080000 rw-p 00000000 00:00 0 
>> 
>> I assume that's caused by:
>> 
>>   47ebb09d5485 ("powerpc: move ELF_ET_DYN_BASE to 4GB / 4MB")
>> 
>> Which did roughly:
>> 
>>   -#define ELF_ET_DYN_BASE	0x20000000
>>   +#define ELF_ET_DYN_BASE		(is_32bit_task() ? 0x000400000UL : \
>>   +					   0x100000000UL)
>> 
>> And went into 4.13.
>> 
>> > ...
>> > I'm not entirely sure what to make of this, but I'm worried that this
>> > could be a regression that matters to userspace.
>> 
>> It was a deliberate change, and it seemed to not break anything so we
>> merged it. But obviously we didn't test widely enough.
>> 
>> So I guess it clearly can matter to userspace, and it used to work, so
>> therefore it is a regression.
>> 
>> But at the same time we haven't had any other reports of breakage, so is
>> this somehow specific to something Go is doing? Or did we just get lucky
>> up until now? Or is no one actually testing on Power? ;)
>
> Mapping PIEs above 4G should be fine.  It works for gcc C and C++
> after all.  The problem is that ppc64le Go is generating code not
> suitable for a PIE.  Dynamic text relocations are evidence of non-PIC
> object files.
>
> Quoting Lynn Boger <boger@us.ibm.com>:
> "When building a pie binary with golang, they should be using
> -buildmode=pie and not just pass -pie to the linker".

Thanks Alan.

So this isn't a kernel bug per se, but the the old behaviour falls in
the category of "shouldn't have worked but did by accident", and so the
question is just how wide spread is the userspace breakage.

At least so far it seems not very wide spread, so we'll leave things as
they are for now. As Florian said we can always add a personality flag
in future if we need to.

cheers
