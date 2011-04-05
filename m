Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id C8E588D003B
	for <linux-mm@kvack.org>; Tue,  5 Apr 2011 08:21:43 -0400 (EDT)
Received: by pwi10 with SMTP id 10so208957pwi.14
        for <linux-mm@kvack.org>; Tue, 05 Apr 2011 05:21:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTi=KTdLRC_hRvxfpFoMSbz=vOjpObw@mail.gmail.com>
References: <alpine.LSU.2.00.1102232136020.2239@sister.anvils>
	<AANLkTi==MQV=_qq1HaCxGLRu8DdT6FYddqzBkzp1TQs7@mail.gmail.com>
	<AANLkTimv66fV1+JDqSAxRwddvy_kggCuhoJLMTpMTtJM@mail.gmail.com>
	<alpine.LSU.2.00.1103182158200.18771@sister.anvils>
	<BANLkTinoNMudwkcOOgU5d+imPUfZhDbWWQ@mail.gmail.com>
	<AANLkTimfArmB7judMW7Qd4ATtVaR=yTf_-0DBRAfCJ7w@mail.gmail.com>
	<BANLkTi=Limr3NUaG7RLoQLv5TuEDmm7Rqg@mail.gmail.com>
	<BANLkTi=UZcocVk_16MbbV432g9a3nDFauA@mail.gmail.com>
	<BANLkTi=KTdLRC_hRvxfpFoMSbz=vOjpObw@mail.gmail.com>
Date: Tue, 5 Apr 2011 14:21:39 +0200
Message-ID: <BANLkTindeX9-ECPjgd_V62ZbXCd7iEG9_w@mail.gmail.com>
Subject: Re: [PATCH] mm: fix possible cause of a page_mapped BUG
From: =?UTF-8?B?Um9iZXJ0IMWad2nEmWNraQ==?= <robert@swiecki.net>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Miklos Szeredi <miklos@szeredi.hu>, Michel Lespinasse <walken@google.com>, "Eric W. Biederman" <ebiederm@xmission.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>

>> Hi Hugh,
>>
>> I did two things, included your patch, and compiled with
>> CONFIG_CC_OPTIMIZE_FOR_SIZE=3Dy; the kernel didn't BUG() or Oopssed for
>> ~2 days under fuzzing (with getdents and readdir syscalls disabled in
>> the fuzzer). I don't think -Os has any bigger influence on how mm
>> internally works therefore I must attribute the change to your patch
>> (was it patch which fixes something or merely dumps vma structures in
>> case of any problem?).
>
> I'm sorry, I should have explained the patch a little more. =C2=A0Along
> with dumping out the vma structs, it does change the BUG or BUGs there
> to WARN_ONs, allowing the system to continue if it's not too badly
> corrupted, though leaking some structure memory (if the structs have
> been reused, it's probably not safe to assume we still have ownership
> of them). =C2=A0So if the problem has occurred again, it should be leavin=
g
> WARNING messages and vma struct dumps in your /var/log/messages -
> please look for them and send them in if found.

Here it is, I'll leave it in this state (kdb) in case you need some
remote debugging

<4>[ 1523.877666] WARNING: at mm/prio_tree.c:95 vma_prio_tree_add+0x43/0x11=
0()
<4>[ 1523.884381] Hardware name: Precision WorkStation 390
<4>[ 1523.889703] Pid: 13801, comm: iknowthis2 Not tainted 2.6.38 #2
<4>[ 1523.895544] Call Trace:
<4>[ 1523.898000]  [<ffffffff810b5d2a>] ? warn_slowpath_common+0x7a/0xb0
<4>[ 1523.904195]  [<ffffffff810b5d7a>] ? warn_slowpath_null+0x1a/0x20
<4>[ 1523.910210]  [<ffffffff8116b4b3>] ? vma_prio_tree_add+0x43/0x110
<4>[ 1523.916226]  [<ffffffff8116b5c1>] ? vma_prio_tree_insert+0x41/0x60
<4>[ 1523.922416]  [<ffffffff8117b69c>] ? __vma_link_file+0x4c/0x90
<4>[ 1523.928171]  [<ffffffff8117c078>] ? vma_adjust+0xe8/0x570
<4>[ 1523.933579]  [<ffffffff8117c641>] ? __split_vma+0x141/0x280
<4>[ 1523.939157]  [<ffffffff8117c7a5>] ? split_vma+0x25/0x30
<4>[ 1523.944391]  [<ffffffff811733f6>] ? sys_madvise+0x6a6/0x720
<4>[ 1523.949969]  [<ffffffff810a4e09>] ? sub_preempt_count+0xa9/0xe0
<4>[ 1523.955900]  [<ffffffff8224f809>] ? trace_hardirqs_on_thunk+0x3a/0x3c
<4>[ 1523.962347]  [<ffffffff8109a653>] ? ia32_sysret+0x0/0x5
<4>[ 1523.967580]  [<ffffffff8224f809>] ? trace_hardirqs_on_thunk+0x3a/0x3c
<4>[ 1523.974026] ---[ end trace c13483b7eb481afd ]---
<4>[ 1523.978650] vm_area_struct at ffff880120bda508:
<4>[ 1523.983199]  ffff88011eb5aa00 00000000f72f3000 00000000f73f0000
ffff88011b8eaa10
<4>[ 1523.990674]  ffff88011b8ea228 0000000000000027 00000000000101ff
ffff88011b8ea6b1
<4>[ 1523.998151]  ffff88011e390820 ffff88011b8ea260 ffff880120796780
ffff880120bdad40
<4>[ 1524.005624]            (null)           (null) ffff88011ed5b910
ffff88011ed5b1f0
<4>[ 1524.013103]  ffff88011f72b168 ffffffff82427480 ffffffffffffff03
ffff8800793ff0c0
<4>[ 1524.020581]            (null)           (null)           (null)
<4>[ 1524.026556] vm_area_struct at ffff880120bdacf0:
<4>[ 1524.031110]  ffff88011eb5a300 00000000f72f3000 00000000f7400000
ffff88011f6c6f18
<4>[ 1524.038584]  ffff88011b5c9da8 0000000000000027 00000000000101ff
ffff8801206f0c71
<4>[ 1524.046062]  ffff88011f6c6f50 ffff88011b5c9de0 ffff880120bdad40
ffff880120bdad40
<4>[ 1524.053536]  ffff880120bda558           (null) ffff88011f758ee0
ffff88011f7583a0
<4>[ 1524.061016]  ffff88011f556690 ffffffff82427480 ffffffffffffff03
ffff8800793ff0c0
<4>[ 1524.068491]            (null)           (null)           (null)

[1]kdb> pid
KDB current process is iknowthis2(pid=3D13801)

[1]kdb> btp 13801
Stack traceback for pid 13801
0xffff88011ec35cc0    13801     4516  1    1   R  0xffff88011ec36140 *iknow=
this2
<c> ffff88011c5d1d68<c> 0000000000000000<c> ffff88011f7a3eb8<c>
ffff88011c5d1d88<c>
<c> ffffffff8116b3b9<c> ffff88011b8ea730<c> ffff88011b8eaa10<c>
ffff88011c5d1e28<c>
<c> ffffffff8117c0cb<c> 00000000f73f0000<c> ffff88011eb5aa00<c>
ffff88011f72b168<c>
Call Trace:
 [<ffffffff8116b3b9>] ? vma_prio_tree_remove+0xc9/0x110
 [<ffffffff8117c0cb>] ? vma_adjust+0x13b/0x570
 [<ffffffff8117c641>] ? __split_vma+0x141/0x280
 [<ffffffff8117c7a5>] ? split_vma+0x25/0x30
 [<ffffffff811733f6>] ? sys_madvise+0x6a6/0x720
 [<ffffffff810a4e09>] ? sub_preempt_count+0xa9/0xe0
 [<ffffffff8224f809>] ? trace_hardirqs_on_thunk+0x3a/0x3c
 [<ffffffff8109a653>] ? ia32_sysret+0x0/0x5
 [<ffffffff8224f809>] ? trace_hardirqs_on_thunk+0x3a/0x3c

[1]kdb> rd
ax: ffff88011b8ea780  bx: ffff880120796678  cx: ffff8801207966c8
dx: ffff8801207966c8  si: ffff8801207966c8  di: ffff880027d3bec8
bp: ffff88011c5d1d68  sp: ffff88011c5d1d68  r8: 0000000000000000
r9: ffff88011c5d1946  r10: ffff88011c5d1945  r11: 0000000000000000
r12: ffff88011b8eaa10  r13: ffff880120bda508  r14: ffff880027d3bea8
r15: ffff88011eb5aa00  ip: ffffffff8158d935  flags: 00010297  cs: 00000010

--=20
Robert =C5=9Awi=C4=99cki

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
