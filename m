Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 04D3F6B06B9
	for <linux-mm@kvack.org>; Fri, 18 May 2018 22:05:44 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e16-v6so5757002pfn.5
        for <linux-mm@kvack.org>; Fri, 18 May 2018 19:05:43 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id z15-v6si7064084pgr.615.2018.05.18.19.05.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 May 2018 19:05:42 -0700 (PDT)
Received: from mail-wr0-f174.google.com (mail-wr0-f174.google.com [209.85.128.174])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id DA88320867
	for <linux-mm@kvack.org>; Sat, 19 May 2018 02:05:41 +0000 (UTC)
Received: by mail-wr0-f174.google.com with SMTP id p18-v6so10871211wrm.1
        for <linux-mm@kvack.org>; Fri, 18 May 2018 19:05:41 -0700 (PDT)
MIME-Version: 1.0
References: <20180517233510.24996-1-dima@arista.com> <1526600442.28243.39.camel@arista.com>
 <CALCETrUDX=4FHU0e8SZ9Rr_AnAes+5jjzKCrrVmS1mddHQyeVQ@mail.gmail.com> <CAJwJo6ZwEZiQYDQqLkfP0+mRgmc+X=H02M=fFZZykWN4A3s-FQ@mail.gmail.com>
In-Reply-To: <CAJwJo6ZwEZiQYDQqLkfP0+mRgmc+X=H02M=fFZZykWN4A3s-FQ@mail.gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Fri, 18 May 2018 19:05:28 -0700
Message-ID: <CALCETrXV1Dnpms2_naBsY=pwFOFtBs4gWVpobHivbzJA=4GR_A@mail.gmail.com>
Subject: Re: [PATCH] x86/mm: Drop TS_COMPAT on 64-bit exec() syscall
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <0x7f454c46@gmail.com>
Cc: Andrew Lutomirski <luto@kernel.org>, Dmitry Safonov <dima@arista.com>, LKML <linux-kernel@vger.kernel.org>, izbyshev@ispras.ru, Alexander Monakov <amonakov@ispras.ru>, Borislav Petkov <bp@suse.de>, Cyrill Gorcunov <gorcunov@openvz.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Linux-MM <linux-mm@kvack.org>, X86 ML <x86@kernel.org>, stable <stable@vger.kernel.org>

> On May 18, 2018, at 4:10 PM, Dmitry Safonov <0x7f454c46@gmail.com> wrote:

> Hi Andy,

> 2018-05-18 23:03 GMT+01:00 Andy Lutomirski <luto@kernel.org>:
>>> On Thu, May 17, 2018 at 4:40 PM Dmitry Safonov <dima@arista.com> wrote:
>>> Some selftests are failing, but the same way as before the patch
>>> (ITOW, it's not regression):
>>> [root@localhost self]# grep FAIL out
>>> [FAIL]  Reg 1 mismatch: requested 0x0; got 0x3
>>> [FAIL]  Reg 15 mismatch: requested 0x8badf00d5aadc0de; got
>>> 0xffffff425aadc0de
>>> [FAIL]  Reg 15 mismatch: requested 0x8badf00d5aadc0de; got
>>> 0xffffff425aadc0de
>>> [FAIL]  Reg 15 mismatch: requested 0x8badf00d5aadc0de; got
>>> 0xffffff425aadc0de

>> Are you on AMD?  Can you try this patch:


https://git.kernel.org/pub/scm/linux/kernel/git/luto/linux.git/commit/?h=3D=
x86/fixes&id=3Dc88aa6d53840e48970c54f9ef70c79415033b32d

>> and give me a Tested-by if it fixes it for you?

> Sure.
> I'm on Intel actually:
> cpu family    : 6
> model        : 142
> model name    : Intel(R) Core(TM) i7-7600U CPU @ 2.80GHz

> But I usually test kernels in VM. So, I use virt-manager as it's
> easier to manage
> multiple VMs. The thing is that I've chosen "Copy host CPU configuration"
> and for some reason, I don't quite follow virt-manager makes model
"Opteron_G4".
> I'm on Fedora 27, virt-manager 1.4.3, qemu 2.9.1(qemu-2.9.1-2.fc26).
> So, cpuinfo in VM says:
> cpu family    : 21
> model        : 1
> model name    : AMD Opteron 62xx class CPU

What does guest cpuinfo say for vendor_id?

There are multiple potential screwups here.

1. (What I *thought* was going on) AMD CPUs have screwy IRET behavior
that=E2=80=99s different from Intel=E2=80=99s, and the test case was defini=
tely wrong. But
KVM has no way to influence it.  Are you sure you=E2=80=99re using KVM and =
not QEMU
TCG? Anyway, the IRET thing is minor compared to your other problems, so
let=E2=80=99s try to fix them first.

2. Compat fast syscalls are wildly different on AMD and Intel. Because of
this issue, QEMU with KVM is supposed to always report the real vendor_id
no matter -cpu asks for.  If we get the wrong vendor_id, then we=E2=80=99re=
 at the
mercy of KVM=E2=80=99s emulation and performance will suck.  On older kerne=
ls, this
would cause hideous kernel crashes.  On new kernels, I would expect it to
merely crash 32-bit user programs or be slow.

> What's worse than registers changes is that some selftests actually lead
to
> Oops's. The same reason for criu-ia32 fails.
> I've tested so far v4.15 and v4.16 releases besides master (2c71d338bef2)=
,
> so it looks to be not a recent regression.

> Full Oopses:
> [  189.100174] BUG: unable to handle kernel paging request at
00000000417bafe8
> [  189.100174] PGD 69ed4067 P4D 69ed4067 PUD 707fc067 PMD 6c535067 PTE
6991f067
> [  189.100174] Oops: 0001 [#3] SMP NOPTI

Whoa there!  0001 means a failed *kernel* access.

> [  189.100174] Modules linked in:
> [  189.100174] CPU: 0 PID: 2443 Comm: sysret_ss_attrs Tainted: G

Was this sysret_ss_attrs_32 or sysret_ss_attrs_64?

> D           4.17.0-rc5+ #11
> [  189.103187] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
> BIOS 1.10.2-1.fc26 04/01/2014
> [  189.103187] RIP: 0033:0x40085a

The oops was caused from CPL 3 at what looks like a totally sensible user
address.  Can you disassemble the offending binary and tell me what the
code at 0x40085a is?

> [  189.103187] RSP: 002b:00000000417bafe8 EFLAGS: 00000206
> [  189.103187] RAX: 0000000000000000 RBX: 00000000000003e8 RCX:
0000000000000000
> [  189.103187] RDX: 0000000000000000 RSI: 0000000000400830 RDI:
00000000417baff8
> [  189.103187] RBP: 00000000417baff8 R08: 0000000000000000 R09:
0000000000000077
> [  189.103187] R10: 0000000000000006 R11: 0000000000000000 R12:
00000000417ba000
> [  189.103187] R13: 00007ffc05207840 R14: 0000000000000000 R15:
0000000000000000
> [  189.103187] FS:  00007f98566ecb40(0000) GS:ffff9740ffc00000(0000)
> knlGS:0000000000000000
> [  189.103187] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033

CS here is the value of CS that the *kernel* has, so 0x10 is normal.

> [  189.103187] CR2: 00000000417bafe8 CR3: 0000000069dc4000 CR4:
00000000007406f0

CR2 is in user space.

So the big question is: what happened here?  Why did the CPU (or emulated
CPU) attempt a privileged access to a user address while running user code?
