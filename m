Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 869356B0003
	for <linux-mm@kvack.org>; Fri,  2 Nov 2018 05:37:50 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 14-v6so1111080pfk.22
        for <linux-mm@kvack.org>; Fri, 02 Nov 2018 02:37:50 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id t33si9345501pgk.466.2018.11.02.02.37.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 02 Nov 2018 02:37:49 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: PIE binaries are no longer mapped below 4 GiB on ppc64le
In-Reply-To: <871s85kprh.fsf@oldenburg.str.redhat.com>
References: <87k1lyf2x3.fsf@oldenburg.str.redhat.com> <87lg6dfo3t.fsf@concordia.ellerman.id.au> <871s85kprh.fsf@oldenburg.str.redhat.com>
Date: Fri, 02 Nov 2018 20:37:45 +1100
Message-ID: <87ftwjes5y.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, keescook@chromium.org, amodra@gmail.com

Florian Weimer <fweimer@redhat.com> writes:
> * Michael Ellerman:
>
>> Hi Florian,
>>
>> Florian Weimer <fweimer@redhat.com> writes:
>>> We tried to use Go to build PIE binaries, and while the Go toolchain is
>>> definitely not ready (it produces text relocations and problematic
>>> relocations in general), it exposed what could be an accidental
>>> userspace ABI change.
>>>
>>> With our 4.10-derived kernel, PIE binaries are mapped below 4 GiB, so
>>> relocations like R_PPC64_ADDR16_HA work:
>>>
>>> 21f00000-220d0000 r-xp 00000000 fd:00 36593493                         =
  /root/extld
>>> 220d0000-220e0000 r--p 001c0000 fd:00 36593493                         =
  /root/extld
>>> 220e0000-22100000 rw-p 001d0000 fd:00 36593493                         =
  /root/extld
>> ...
>>>
>>> With a 4.18-derived kernel (with the hashed mm), we get this instead:
>>>
>>> 120e60000-121030000 rw-p 00000000 fd:00 102447141                      =
  /root/extld
>>> 121030000-121060000 rw-p 001c0000 fd:00 102447141                      =
  /root/extld
>>> 121060000-121080000 rw-p 00000000 00:00 0=20
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
>>> ...
>>> I'm not entirely sure what to make of this, but I'm worried that this
>>> could be a regression that matters to userspace.
>>
>> It was a deliberate change, and it seemed to not break anything so we
>> merged it. But obviously we didn't test widely enough.
>
> * Michael Ellerman:
>
>>> I'm not entirely sure what to make of this, but I'm worried that this
>>> could be a regression that matters to userspace.
>>
>> It was a deliberate change, and it seemed to not break anything so we
>> merged it. But obviously we didn't test widely enough.
>
> Thanks for moving back the discussion to kernel matters. 8-)

I don't know anything about toolchains so I can't comment on that part
of the thread :)

>> So I guess it clearly can matter to userspace, and it used to work, so
>> therefore it is a regression.
>
> Is there a knob to get back the old base address?

No.

>> But at the same time we haven't had any other reports of breakage, so is
>> this somehow specific to something Go is doing?
>
> Go uses 32-bit run-time relocations which (I think) were primarily
> designed as link-time relocations for programs mapped under 4 GiB.  It's
> amazing that the binaries work at all under old kernels.  On other
> targets, the link editor refuses to produce an executable, or may even
> produce a binary which crashes at run time.
>
>> Or did we just get lucky up until now? Or is no one actually testing
>> on Power? ;)
>
> I'm not too worried about it.  It looks like a well-understood change to
> me.  The glibc dynamic linker prints a reasonably informative error
> message (in the sense that it doesn't crash without printing anything).
> I think we can wait and see if someone comes up with a more compelling
> case for backwards compatibility than the broken Go binaries (which we
> will rebuild anyway because we don't want text relocations).  I assume
> that it will be possible to add a personality flag if it ever proves
> necessary=E2=80=94or maybe map the executable below 4 GiB in case of ASLR=
 is
> disabled, so that people have at least a workaround to get old binaries
> going again.

Yeah we could do something like that if it becomes necessary.

I've actually wondered in the past if we should have an explicit syscall
for configuring this sort of address space layout stuff. For example
we always put mmaps at ~128T and growing down, even though we have free
address space above that, and there's no way to control that.

> But right now, that doesn't seem necessary.

OK thanks.

cheers
