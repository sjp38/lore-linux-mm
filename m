Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 2B7116B0044
	for <linux-mm@kvack.org>; Sat, 28 Apr 2012 09:22:01 -0400 (EDT)
Received: by iajr24 with SMTP id r24so3289713iaj.14
        for <linux-mm@kvack.org>; Sat, 28 Apr 2012 06:22:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1334903774.5922.35.camel@lappy>
References: <1334903774.5922.35.camel@lappy>
From: Sasha Levin <levinsasha928@gmail.com>
Date: Sat, 28 Apr 2012 15:21:40 +0200
Message-ID: <CA+1xoqf1mxbShV2OnLZCjacuyLAUvXwi_70ErOXb=hRTbx9Xcg@mail.gmail.com>
Subject: Re: mm: divide by zero in percpu_pagelist_fraction_sysctl_handler()
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, mel@csn.ul.ie, cl@linux-foundation.org
Cc: linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Ping? Still see it happening.

On Fri, Apr 20, 2012 at 8:36 AM, Sasha Levin <levinsasha928@gmail.com> wrot=
e:
> Hi all,
>
> I've stumbled on the following after some fuzzing using trinity inside a =
KVM tools guest, using a recent linux-next.
>
> It appears as though it caused a divide by zero in mm/page_alloc.c:5230:
>
> =A0 =A0 =A0 =A0high =3D zone->present_pages / percpu_pagelist_fraction;
>
> Here's the relevant disassembly:
>
> =A0 =A02360: =A0 =A0 =A0 48 8b 83 30 20 00 00 =A0 =A0mov =A0 =A00x2030(%r=
bx),%rax
> =A0 =A02367: =A0 =A0 =A0 31 d2 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 xor =
=A0 =A0%edx,%edx
> =A0 =A02369: =A0 =A0 =A0 89 c9 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mov =
=A0 =A0%ecx,%ecx
> =A0 =A0236b: =A0 =A0 =A0 4c 63 05 00 00 00 00 =A0 =A0movslq 0x0(%rip),%r8=
 =A0 =A0 =A0 =A0# 2372 <percpu_pagelist_fraction_sysctl_handler+0x72>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0236e: R_X86_64_PC32 =A0 =
=A0 percpu_pagelist_fraction+0xfffffffffffffffc
> =A0 =A02372: =A0 =A0 =A0 49 f7 f0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0div =A0 =
=A0%r8
>
> And finally, the dump:
>
> [ 1208.152452] divide error: 0000 [#1] PREEMPT SMP
> [ 1208.154780] CPU 0
> [ 1208.154780] Pid: 25153, comm: trinity Tainted: G =A0 =A0 =A0 =A0W =A0 =
=A03.4.0-rc3-next-20120419-sasha-dirty #86
> [ 1208.154780] RIP: 0010:[<ffffffff81179632>] =A0[<ffffffff81179632>] per=
cpu_pagelist_fraction_sysctl_handler+0x72/0xf0
> [ 1208.154780] RSP: 0018:ffff88003133dd48 =A0EFLAGS: 00010246
> [ 1208.154780] RAX: 0000000000000f4a RBX: ffff88000dfcf000 RCX: 000000000=
0000000
> [ 1208.154780] RDX: 0000000000000000 RSI: 0000000000000005 RDI: 000000000=
0000000
> [ 1208.154780] RBP: ffff88003133dd68 R08: 0000000000000000 R09: 000000000=
0000000
> [ 1208.154780] R10: 0000000000000000 R11: 0000000000000001 R12: ffffffff8=
3746760
> [ 1208.154780] R13: 0000000000000060 R14: 0000000000000001 R15: 000000000=
17f7100
> [ 1208.154780] FS: =A000007f98fb7ff700(0000) GS:ffff88000d800000(0000) kn=
lGS:0000000000000000
> [ 1208.154780] CS: =A00010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [ 1208.154780] CR2: 0000000000000000 CR3: 0000000031409000 CR4: 000000000=
00406f0
> [ 1208.154780] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 000000000=
0000000
> [ 1208.154780] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 000000000=
0000400
> [ 1208.154780] Process trinity (pid: 25153, threadinfo ffff88003133c000, =
task ffff880031320000)
> [ 1208.154780] Stack:
> [ 1208.154780] =A0ffff88000d45d388 ffffffff8323c2a0 0000000000000001 ffff=
88003133df48
> [ 1208.154780] =A0ffff88003133ddc8 ffffffff8124fb9e ffff88003133ddb8 0000=
000000000000
> [ 1208.154780] =A0ffff88003133ddb8 00000000017f7100 000000000116a08f 0000=
000000000001
> [ 1208.154780] Call Trace:
> [ 1208.154780] =A0[<ffffffff8124fb9e>] proc_sys_call_handler.clone.11+0x8=
e/0xc0
> [ 1208.154780] =A0[<ffffffff8124fbd0>] ? proc_sys_call_handler.clone.11+0=
xc0/0xc0
> [ 1208.154780] =A0[<ffffffff8124fbe3>] proc_sys_write+0x13/0x20
> [ 1208.154780] =A0[<ffffffff811dc8db>] do_loop_readv_writev+0x4b/0x90
> [ 1208.154780] =A0[<ffffffff811dcb76>] do_readv_writev+0x106/0x1e0
> [ 1208.154780] =A0[<ffffffff810b5e2a>] ? do_setitimer+0x1aa/0x1f0
> [ 1208.154780] =A0[<ffffffff8269f77b>] ? _raw_spin_unlock_irq+0x2b/0x80
> [ 1208.154780] =A0[<ffffffff810e45c1>] ? get_parent_ip+0x11/0x50
> [ 1208.154780] =A0[<ffffffff810e478e>] ? sub_preempt_count+0xae/0xe0
> [ 1208.154780] =A0[<ffffffff826a0e29>] ? sysret_check+0x22/0x5d
> [ 1208.154780] =A0[<ffffffff811dcce6>] vfs_writev+0x46/0x60
> [ 1208.154780] =A0[<ffffffff811dcdff>] sys_writev+0x4f/0xb0
> [ 1208.154780] =A0[<ffffffff826a0dfd>] system_call_fastpath+0x1a/0x1f
> [ 1208.154780] Code: 00 00 0f 1f 80 00 00 00 00 48 83 bb 30 20 00 00 00 7=
4 64 eb 7d 0f 1f 40 00 48 8b 83 30 20 00 00 31 d2 89 c9 4c 63 05 f6 c9 33 0=
3 <49> f7 f0 48 8b 53 60 48 03 14 cd a0 c2 73 83 48 89 c1 89 42 04
> [ 1208.154780] RIP =A0[<ffffffff81179632>] percpu_pagelist_fraction_sysct=
l_handler+0x72/0xf0
> [ 1208.154780] =A0RSP <ffff88003133dd48>
> [ 1208.315517] ---[ end trace a307b3ed40206b4b ]---
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
