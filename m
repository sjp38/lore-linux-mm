Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A61766B00AE
	for <linux-mm@kvack.org>; Fri,  7 Jan 2011 08:05:58 -0500 (EST)
Received: by iyj17 with SMTP id 17so16967272iyj.14
        for <linux-mm@kvack.org>; Fri, 07 Jan 2011 05:05:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <AANLkTi=S3TLY92RE3VZdzZ3MpzyWEOtxMaUPtm7miCA9@mail.gmail.com>
References: <AANLkTinbqG7sXxf82wc516snLoae1DtCWjo+VtsPx2P3@mail.gmail.com>
	<20101122154754.e022d935.akpm@linux-foundation.org>
	<AANLkTi=AiJ1MekBXZbVj3f2pBtFe52BtCxtbRq=u-YOR@mail.gmail.com>
	<20101129152500.000c380b.akpm@linux-foundation.org>
	<alpine.LSU.2.00.1011300939520.6633@tigran.mtv.corp.google.com>
	<alpine.LSU.2.00.1012291231540.22566@sister.anvils>
	<AANLkTi=ZuOJ07yN-nqso_pX_NS90eKrPD=vG9-_a59vG@mail.gmail.com>
	<AANLkTi=S3TLY92RE3VZdzZ3MpzyWEOtxMaUPtm7miCA9@mail.gmail.com>
Date: Fri, 7 Jan 2011 14:05:57 +0100
Message-ID: <AANLkTin75LdO653Q1eX4Ws1X-s2Dae+aRyGhx_a7yh9n@mail.gmail.com>
Subject: Re: kernel BUG at /build/buildd/linux-2.6.35/mm/filemap.c:128!
From: =?UTF-8?B?Um9iZXJ0IMWad2nEmWNraQ==?= <robert@swiecki.net>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: Miklos Szeredi <miklos@szeredi.hu>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@kernel.dk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jan 7, 2011 at 2:02 PM, Robert =C5=9Awi=C4=99cki <robert@swiecki.ne=
t> wrote:
> =C2=A0but will be happy if someone else beats me to it.
>>>
>>> I have since found an omission in the restart_addr logic: looking back
>>> at the October 2004 history of vm_truncate_count, I see that originally
>>> I designed it to work one way, but hurriedly added a 7/6 redesign when
>>> vma splitting turned out to leave an ambiguity. =C2=A0I should have upd=
ated
>>> the protection in mremap move at that time, but missed it.
>>>
>>> Robert, please try out the patch below (should apply fine to 2.6.35):
>>
>> In the beginning =C2=A0of Jan (3-4) at earliest I'm afraid, i.e. when I
>> manage to get to my console-over-rs232 setup.
>
> I cannot reproduce it even with the unpatched kernel, cause I get the
> following oops (3 times out of 3 tries) relatively quickly. Still
> trying.
>
> Entering kdb (current=3D0xffff88006b525ac0, pid 12468) on processor 1 Oop=
s: (null)
> due to oops @ 0xffffffff810c2a1b
> CPU 1 <c>
> <d>Pid: 12468, comm: iknowthis Not tainted 2.6.37-rc2 #1

Hm.. wrong kernel, trying now with 2.6.35 - anyway this proc readdir
oops appears also on 2.6.35

> 0GH911/Precision WorkStation 390
> <d>RIP: 0010:[<ffffffff810c2a1b>] =C2=A0[<ffffffff810c2a1b>] next_pidmap+=
0x4b/0xa0
> <d>RSP: 0000:ffff88006bc6fd78 =C2=A0EFLAGS: 00010206
> <d>RAX: 001ffffffffd2010 RBX: 001fffff829eee38 RCX: 0000000000000034
> <d>RDX: 0000000000001bd7 RSI: 00000000e9009bd6 RDI: ffffffff82a1ce20
> <d>RBP: ffff88006bc6fd98 R08: c000000000000000 R09: 4fb0000000000000
> <d>R10: 7d80000000000000 R11: 0000000000000000 R12: ffffffff82a1d628
> <d>R13: ffffffff82a1ce20 R14: ffff880123768000 R15: ffffffff811d98e0
> <d>FS: =C2=A00000000000000000(0000) GS:ffff8800cfc40000(0063) knlGS:00000=
000f74aa6c0
> <d>CS: =C2=A00010 DS: 002b ES: 002b CR0: 000000008005003b
> <d>CR2: 000000000808865c CR3: 000000011b1a4000 CR4: 00000000000006e0
> <d>DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> <d>DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process iknowthis (pid: 12468, threadinfo ffff88006bc6e000, task
> ffff88006b525ac0)
> <0>Stack:
> <c> ffff88006bc6fe78<c> 00000000e9009bd6<c> 0000000000000000<c>
> ffffffff82a1ce20<c>
> <c> ffff88006bc6fdc8<c> ffffffff810c2aac<c> ffff880018cfc410<c>
> ffffffff82a1ce20<c>
> <c> 00000000e9009bd6<c> ffffffff811d98e0<c> ffff88006bc6fe28<c>
> ffffffff811f3dab<c>
> <0>Call Trace:
> [1]more>
> Only 'q' or 'Q' are processed at more prompt, input ignored
> <0> [<ffffffff810c2aac>] find_ge_pid+0x3c/0x50
> <0> [<ffffffff811d98e0>] ? compat_fillonedir+0x0/0xe0
> <0> [<ffffffff811f3dab>] next_tgid+0x3b/0xc0
> <0> [<ffffffff811d98e0>] ? compat_fillonedir+0x0/0xe0
> <0> [<ffffffff811f42ec>] proc_pid_readdir+0x13c/0x1d0
> <0> [<ffffffff811d98e0>] ? compat_fillonedir+0x0/0xe0
> <0> [<ffffffff811f03fa>] proc_root_readdir+0x4a/0x60
> <0> [<ffffffff811d98e0>] ? compat_fillonedir+0x0/0xe0
> <0> [<ffffffff811a58d0>] vfs_readdir+0xc0/0xe0
> <0> [<ffffffff811d8435>] compat_sys_old_readdir+0x45/0x70
> <0> [<ffffffff8108b023>] ia32_sysret+0x0/0x5
> <0>Code: 89 fd 48 c1 e8 0f 48 c1 e0 04 48 8d 5c 07 08 4c 39 e3 73 54
> 81 e2 ff 7f 00 00 eb 0f eb 02 90 90 48 83 c3 10 31 d2 49 39 dc 76 3d
> <48> 8b 7b 08 48 85 ff 74 ec 48 63 d2 be 00 80 00 00 e8 6f a4 41
> Call Trace:
> =C2=A0[<ffffffff810c2aac>] find_ge_pid+0x3c/0x50
> =C2=A0[<ffffffff811d98e0>] ? compat_fillonedir+0x0/0xe0
> =C2=A0[<ffffffff811f3dab>] next_tgid+0x3b/0xc0
> =C2=A0[<ffffffff811d98e0>] ? compat_fillonedir+0x0/0xe0
> =C2=A0[<ffffffff811f42ec>] proc_pid_readdir+0x13c/0x1d0
> =C2=A0[<ffffffff811d98e0>] ? compat_fillonedir+0x0/0xe0
> =C2=A0[<ffffffff811f03fa>] proc_root_readdir+0x4a/0x60
> =C2=A0[<ffffffff811d98e0>] ? compat_fillonedir+0x0/0xe0
> =C2=A0[<ffffffff811a58d0>] vfs_readdir+0xc0/0xe0
> [1]more>
> Only 'q' or 'Q' are processed at more prompt, input ignored
> =C2=A0[<ffffffff811d8435>] compat_sys_old_readdir+0x45/0x70
> =C2=A0[<ffffffff8108b023>] ia32_sysret+0x0/0x5
>
>
>
> --
> Robert =C5=9Awi=C4=99cki
>



--=20
Robert =C5=9Awi=C4=99cki

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
