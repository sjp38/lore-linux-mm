Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8F19D6B025E
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 13:45:51 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id b75so12851469lfg.3
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 10:45:51 -0700 (PDT)
Received: from mail-lf0-x235.google.com (mail-lf0-x235.google.com. [2a00:1450:4010:c07::235])
        by mx.google.com with ESMTPS id h10si3390464lfe.220.2016.10.19.10.45.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Oct 2016 10:45:49 -0700 (PDT)
Received: by mail-lf0-x235.google.com with SMTP id x79so37612732lff.0
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 10:45:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LRH.2.02.1610191329500.29288@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1610191311010.24555@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.LRH.2.02.1610191329500.29288@file01.intranet.prod.int.rdu2.redhat.com>
From: Dmitry Safonov <0x7f454c46@gmail.com>
Date: Wed, 19 Oct 2016 20:45:29 +0300
Message-ID: <CAJwJo6Z3bxWQDnkj-7=cjjMJ9z7BPjDALFEWHDjt4YsA4UxsPg@mail.gmail.com>
Subject: Re: x32 is broken in 4.9-rc1 due to "x86/signal: Add
 SA_{X32,IA32}_ABI sa_flags"
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Dmitry Safonov <dsafonov@virtuozzo.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, Cyrill Gorcunov <gorcunov@openvz.org>, Pavel Emelyanov <xemul@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, open list <linux-kernel@vger.kernel.org>

2016-10-19 20:33 GMT+03:00 Mikulas Patocka <mpatocka@redhat.com>:
>
>
> On Wed, 19 Oct 2016, Mikulas Patocka wrote:
>
>> Hi
>>
>> In the kernel 4.9-rc1, the x32 support is seriously broken, a x32 proces=
s
>> is killed with SIGKILL after returning from any signal handler.
>
> I should have said they are killed with SIGSEGV, not SIGKILL.
>
>> I use Debian sid x64-64 distribution with x32 architecture added from
>> debian-ports.
>>
>> I bisected the bug and found out that it is caused by the patch
>> 6846351052e685c2d1428e80ead2d7ca3d7ed913 ("x86/signal: Add
>> SA_{X32,IA32}_ABI sa_flags").
>>
>> example (strace of a process after receiving the SIGWINCH signal):
>>
>> epoll_wait(10, 0xef6890, 32, -1)        =3D -1 EINTR (Interrupted system=
 call)
>> --- SIGWINCH {si_signo=3DSIGWINCH, si_code=3DSI_USER, si_pid=3D1772, si_=
uid=3D0} ---
>> poll([{fd=3D4, events=3DPOLLOUT}], 1, 0)    =3D 1 ([{fd=3D4, revents=3DP=
OLLOUT}])
>> write(4, "\0", 1)                       =3D 1
>> rt_sigreturn({mask=3D[INT QUIT ILL TRAP BUS KILL SEGV USR2 PIPE ALRM STK=
FLT TSTP TTOU URG XCPU XFSZ VTALRM IO PWR SYS RTMIN]}) =3D 0
>> --- SIGSEGV {si_signo=3DSIGSEGV, si_code=3DSI_KERNEL, si_addr=3DNULL} --=
-
>> +++ killed by SIGSEGV +++
>> Neopr=C3=A1vn=C3=ACn=C3=BD p=C3=B8=C3=ADstup do pam=C3=ACti (SIGSEGV)
>>
>> Mikulas
>
> BTW. when I take core dump of the killed x32 process, it shows:
>
> ELF Header:
>   Magic:   7f 45 4c 46 01 01 01 00 00 00 00 00 00 00 00 00
>   Class:                             ELF32
>   Data:                              2's complement, little endian
>   Version:                           1 (current)
>   OS/ABI:                            UNIX - System V
>   ABI Version:                       0
>   Type:                              CORE (Core file)
>   Machine:                           Intel 80386
>                                 ^^^^^^^^^^^^^^^^^^^
>
> So, the kernel somehow thinks that it is i386 process, not x32 process. A
> core dump of a real x32 process shows "Class: ELF32, Machine: Advanced
> Micro Devices X86-64".

Thanks for catching, will check it today.

--=20
             Dmitry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
