Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7B20A6B06BD
	for <linux-mm@kvack.org>; Fri, 18 May 2018 22:25:45 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id m24-v6so6799537ioh.5
        for <linux-mm@kvack.org>; Fri, 18 May 2018 19:25:45 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m3-v6sor5555107iof.177.2018.05.18.19.25.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 18 May 2018 19:25:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1526696547.13166.6.camel@arista.com>
References: <20180517233510.24996-1-dima@arista.com> <1526600442.28243.39.camel@arista.com>
 <CALCETrUDX=4FHU0e8SZ9Rr_AnAes+5jjzKCrrVmS1mddHQyeVQ@mail.gmail.com>
 <CAJwJo6ZwEZiQYDQqLkfP0+mRgmc+X=H02M=fFZZykWN4A3s-FQ@mail.gmail.com>
 <CALCETrXV1Dnpms2_naBsY=pwFOFtBs4gWVpobHivbzJA=4GR_A@mail.gmail.com> <1526696547.13166.6.camel@arista.com>
From: Dmitry Safonov <0x7f454c46@gmail.com>
Date: Sat, 19 May 2018 03:25:23 +0100
Message-ID: <CAJwJo6YNqEBxbnJURL-+p_3S9rMBmJHNfE+WqwUF5nVkpRZ3nw@mail.gmail.com>
Subject: Re: [PATCH] x86/mm: Drop TS_COMPAT on 64-bit exec() syscall
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dima@arista.com>
Cc: Andy Lutomirski <luto@kernel.org>, LKML <linux-kernel@vger.kernel.org>, izbyshev@ispras.ru, Alexander Monakov <amonakov@ispras.ru>, Borislav Petkov <bp@suse.de>, Cyrill Gorcunov <gorcunov@openvz.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Linux-MM <linux-mm@kvack.org>, X86 ML <x86@kernel.org>, stable <stable@vger.kernel.org>

2018-05-19 3:22 GMT+01:00 Dmitry Safonov <dima@arista.com>:
> On Fri, 2018-05-18 at 19:05 -0700, Andy Lutomirski wrote:
>> > On May 18, 2018, at 4:10 PM, Dmitry Safonov <0x7f454c46@gmail.com>
>> > cpu family    : 6
>> > model        : 142
>> > model name    : Intel(R) Core(TM) i7-7600U CPU @ 2.80GHz
>> > But I usually test kernels in VM. So, I use virt-manager as it's
>> > easier to manage
>> > multiple VMs. The thing is that I've chosen "Copy host CPU
>> > configuration"
>> > and for some reason, I don't quite follow virt-manager makes model
>>
>> "Opteron_G4".
>> > I'm on Fedora 27, virt-manager 1.4.3, qemu 2.9.1(qemu-2.9.1-
>> > 2.fc26).
>> > So, cpuinfo in VM says:
>> > cpu family    : 21
>> > model        : 1
>> > model name    : AMD Opteron 62xx class CPU
>>
>> What does guest cpuinfo say for vendor_id?
>>
>> There are multiple potential screwups here.
>>
>> 1. (What I *thought* was going on) AMD CPUs have screwy IRET behavior
>> that=E2=80=99s different from Intel=E2=80=99s, and the test case was def=
initely
>> wrong. But
>> KVM has no way to influence it.  Are you sure you=E2=80=99re using KVM a=
nd
>> not QEMU
>> TCG? Anyway, the IRET thing is minor compared to your other problems,
>> so
>> let=E2=80=99s try to fix them first.
>>
>> 2. Compat fast syscalls are wildly different on AMD and Intel.
>> Because of
>> this issue, QEMU with KVM is supposed to always report the real
>> vendor_id
>> no matter -cpu asks for.  If we get the wrong vendor_id, then we=E2=80=
=99re
>> at the
>> mercy of KVM=E2=80=99s emulation and performance will suck.  On older
>> kernels, this
>> would cause hideous kernel crashes.  On new kernels, I would expect
>> it to
>> merely crash 32-bit user programs or be slow.
>
> Heh, I didn't know those details, so it looks like it's (2),
> vendor_id       : AuthenticAMD
> in guest.
>
>>
>> > What's worse than registers changes is that some selftests actually
>> > lead
>>
>> to
>> > Oops's. The same reason for criu-ia32 fails.
>> > I've tested so far v4.15 and v4.16 releases besides master
>> > (2c71d338bef2),
>> > so it looks to be not a recent regression.
>> > Full Oopses:
>> > [  189.100174] BUG: unable to handle kernel paging request at
>>
>> 00000000417bafe8
>> > [  189.100174] PGD 69ed4067 P4D 69ed4067 PUD 707fc067 PMD 6c535067
>> > PTE
>>
>> 6991f067
>> > [  189.100174] Oops: 0001 [#3] SMP NOPTI
>>
>> Whoa there!  0001 means a failed *kernel* access.
>>
>> > [  189.100174] Modules linked in:
>> > [  189.100174] CPU: 0 PID: 2443 Comm: sysret_ss_attrs Tainted: G
>>
>> Was this sysret_ss_attrs_32 or sysret_ss_attrs_64?
>
> sysret_ss_attrs_32 survives
>
>>
>> > D           4.17.0-rc5+ #11
>> > [  189.103187] Hardware name: QEMU Standard PC (i440FX + PIIX,
>> > 1996),
>> > BIOS 1.10.2-1.fc26 04/01/2014
>> > [  189.103187] RIP: 0033:0x40085a
>>
>> The oops was caused from CPL 3 at what looks like a totally sensible
>> user
>> address.  Can you disassemble the offending binary and tell me what
>> the
>> code at 0x40085a is?
>
> Here is the function:
> 0000000000400842 <call32_from_64>:
>   400842:       53                      push   %rbx
>   400843:       55                      push   %rbp
>   400844:       41 54                   push   %r12
>   400846:       41 55                   push   %r13
>   400848:       41 56                   push   %r14
>   40084a:       41 57                   push   %r15
>   40084c:       9c                      pushfq
>   40084d:       48 89 27                mov    %rsp,(%rdi)
>   400850:       48 89 fc                mov    %rdi,%rsp
>   400853:       6a 23                   pushq  $0x23
>   400855:       68 5c 08 40 00          pushq  $0x40085c
>   40085a:       48 cb                   lretq
>   40085c:       ff d6                   callq  *%rsi
>   40085e:       ea                      (bad)
>   40085f:       65 08 40 00             or     %al,%gs:0x0(%rax)
>   400863:       33 00                   xor    (%rax),%eax
>   400865:       48 8b 24 24             mov    (%rsp),%rsp
>   400869:       9d                      popfq
>   40086a:       41 5f                   pop    %r15
>   40086c:       41 5e                   pop    %r14
>   40086e:       41 5d                   pop    %r13
>   400870:       41 5c                   pop    %r12
>   400872:       5d                      pop    %rbp
>   400873:       5b                      pop    %rbx
>   400874:       c3                      retq
>   400875:       66 2e 0f 1f 84 00 00    nopw   %cs:0x0(%rax,%rax,1)
>   40087c:       00 00 00
>   40087f:       90                      nop
>
> Looks like mov between registers caused it? The hell.

Oh, it's not 400850, I missloked, but 40085a so lretq might case it.

>
>>
>> > [  189.103187] RSP: 002b:00000000417bafe8 EFLAGS: 00000206
>> > [  189.103187] RAX: 0000000000000000 RBX: 00000000000003e8 RCX:
>>
>> 0000000000000000
>> > [  189.103187] RDX: 0000000000000000 RSI: 0000000000400830 RDI:
>>
>> 00000000417baff8
>> > [  189.103187] RBP: 00000000417baff8 R08: 0000000000000000 R09:
>>
>> 0000000000000077
>> > [  189.103187] R10: 0000000000000006 R11: 0000000000000000 R12:
>>
>> 00000000417ba000
>> > [  189.103187] R13: 00007ffc05207840 R14: 0000000000000000 R15:
>>
>> 0000000000000000
>> > [  189.103187] FS:  00007f98566ecb40(0000)
>> > GS:ffff9740ffc00000(0000)
>> > knlGS:0000000000000000
>> > [  189.103187] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>>
>> CS here is the value of CS that the *kernel* has, so 0x10 is normal.
>>
>> > [  189.103187] CR2: 00000000417bafe8 CR3: 0000000069dc4000 CR4:
>>
>> 00000000007406f0
>>
>> CR2 is in user space.
>>
>> So the big question is: what happened here?  Why did the CPU (or
>> emulated
>> CPU) attempt a privileged access to a user address while running user
>> code?
>
> No idea, but looks like it's not a kernel fault.
>
> --
> Thanks,
>              Dmitry



--=20
             Dmitry
