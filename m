Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6FD6F8E0002
	for <linux-mm@kvack.org>; Sun, 13 Jan 2019 22:59:12 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id e1so1372354wmg.0
        for <linux-mm@kvack.org>; Sun, 13 Jan 2019 19:59:12 -0800 (PST)
Received: from mail-40130.protonmail.ch (mail-40130.protonmail.ch. [185.70.40.130])
        by mx.google.com with ESMTPS id v84si18636518wma.79.2019.01.13.19.59.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 13 Jan 2019 19:59:10 -0800 (PST)
Date: Mon, 14 Jan 2019 03:59:04 +0000
From: Esme <esploit@protonmail.ch>
Reply-To: Esme <esploit@protonmail.ch>
Subject: Re: [PATCH v2] rbtree: fix the red root
Message-ID: <UKsodHRZU8smIdO2MHHL4Yzde_YB4iWX43TaHI1uY2tMo4nii4ucbaw4XC31XIY-Pe4oEovjF62qbkeMsIMTrvT1TdCCP4Fs_fxciAzXYVc=@protonmail.ch>
In-Reply-To: <c6265fc0-4089-9d1a-ba7c-b267b847747e@interlog.com>
References: <20190111181600.GJ6310@bombadil.infradead.org>
 <20190111205843.25761-1-cai@lca.pw>
 <a783f23d-77ab-a7d3-39d1-4008d90094c3@lechnology.com>
 <CANN689G0zbk7sMbQ+p9NQGQ=NWq-Q0mQOOjeFkLp19YrTfgcLg@mail.gmail.com>
 <864d6b85-3336-4040-7c95-7d9615873777@lechnology.com>
 <b1033d96-ebdd-e791-650a-c6564f030ce1@lca.pw>
 <8v11ZOLyufY7NLAHDFApGwXOO_wGjVHtsbw1eiZ__YvI9EZCDe_4FNmlp0E-39lnzGQHhHAczQ6Q6lQPzVU2V6krtkblM8IFwIXPHZCuqGE=@protonmail.ch>
 <c6265fc0-4089-9d1a-ba7c-b267b847747e@interlog.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "dgilbert@interlog.com" <dgilbert@interlog.com>
Cc: Qian Cai <cai@lca.pw>, David Lechner <david@lechnology.com>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>, "jejb@linux.ibm.com" <jejb@linux.ibm.com>, "martin.petersen@oracle.com" <martin.petersen@oracle.com>, "joeypabalinas@gmail.com" <joeypabalinas@gmail.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90 Original Me=
ssage =E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90
On Sunday, January 13, 2019 10:52 PM, Douglas Gilbert <dgilbert@interlog.co=
m> wrote:

> On 2019-01-13 10:07 p.m., Esme wrote:
>
> > =E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90 Origina=
l Message =E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=
=90
> > On Sunday, January 13, 2019 9:33 PM, Qian Cai cai@lca.pw wrote:
> >
> > > On 1/13/19 9:20 PM, David Lechner wrote:
> > >
> > > > On 1/11/19 8:58 PM, Michel Lespinasse wrote:
> > > >
> > > > > On Fri, Jan 11, 2019 at 3:47 PM David Lechner david@lechnology.co=
m wrote:
> > > > >
> > > > > > On 1/11/19 2:58 PM, Qian Cai wrote:
> > > > > >
> > > > > > > A GPF was reported,
> > > > > > > kasan: CONFIG_KASAN_INLINE enabled
> > > > > > > kasan: GPF could be caused by NULL-ptr deref or user memory a=
ccess
> > > > > > > general protection fault: 0000 [#1] SMP KASAN
> > > > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 kasan_=
die_handler.cold.22+0x11/0x31
> > > > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 notifi=
er_call_chain+0x17b/0x390
> > > > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 atomic=
_notifier_call_chain+0xa7/0x1b0
> > > > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 notify=
_die+0x1be/0x2e0
> > > > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 do_gen=
eral_protection+0x13e/0x330
> > > > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 genera=
l_protection+0x1e/0x30
> > > > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 rb_ins=
ert_color+0x189/0x1480
> > > > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 create=
_object+0x785/0xca0
> > > > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 kmemle=
ak_alloc+0x2f/0x50
> > > > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 kmem_c=
ache_alloc+0x1b9/0x3c0
> > > > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 getnam=
e_flags+0xdb/0x5d0
> > > > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 getnam=
e+0x1e/0x20
> > > > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 do_sys=
_open+0x3a1/0x7d0
> > > > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 __x64_=
sys_open+0x7e/0xc0
> > > > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 do_sys=
call_64+0x1b3/0x820
> > > > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 entry_=
SYSCALL_64_after_hwframe+0x49/0xbe
> > > > > > > It turned out,
> > > > > > > gparent =3D rb_red_parent(parent);
> > > > > > > tmp =3D gparent->rb_right; <-- GPF was triggered here.
> > > > > > > Apparently, "gparent" is NULL which indicates "parent" is rbt=
ree's root
> > > > > > > which is red. Otherwise, it will be treated properly a few li=
nes above.
> > > > > > > /*
> > > > > > > =C2=A0=C2=A0 * If there is a black parent, we are done.
> > > > > > > =C2=A0=C2=A0 * Otherwise, take some corrective action as,
> > > > > > > =C2=A0=C2=A0 * per 4), we don't want a red root or two
> > > > > > > =C2=A0=C2=A0 * consecutive red nodes.
> > > > > > > =C2=A0=C2=A0 */
> > > > > > > if(rb_is_black(parent))
> > > > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 break;
> > > > > > > Hence, it violates the rule #1 (the root can't be red) and ne=
ed a fix
> > > > > > > up, and also add a regression test for it. This looks like wa=
s
> > > > > > > introduced by 6d58452dc06 where it no longer always paint the=
 root as
> > > > > > > black.
> > > > > > > Fixes: 6d58452dc06 (rbtree: adjust root color in rb_insert_co=
lor() only
> > > > > > > when necessary)
> > > > > > > Reported-by: Esme esploit@protonmail.ch
> > > > > > > Tested-by: Joey Pabalinas joeypabalinas@gmail.com
> > > > > > > Signed-off-by: Qian Cai cai@lca.pw
> > > > > >
> > > > > > Tested-by: David Lechner david@lechnology.com
> > > > > > FWIW, this fixed the following crash for me:
> > > > > > Unable to handle kernel NULL pointer dereference at virtual add=
ress 00000004
> > > > >
> > > > > Just to clarify, do you have a way to reproduce this crash withou=
t the fix ?
> > > >
> > > > I am starting to suspect that my crash was caused by some new code
> > > > in the drm-misc-next tree that might be causing a memory corruption=
.
> > > > It threw me off that the stack trace didn't contain anything relate=
d
> > > > to drm.
> > > > See: https://patchwork.freedesktop.org/patch/276719/
> > >
> > > It may be useful for those who could reproduce this issue to turn on =
those
> > > memory corruption debug options to narrow down a bit.
> > > CONFIG_DEBUG_PAGEALLOC=3Dy
> > > CONFIG_DEBUG_PAGEALLOC_ENABLE_DEFAULT=3Dy
> > > CONFIG_KASAN=3Dy
> > > CONFIG_KASAN_GENERIC=3Dy
> > > CONFIG_SLUB_DEBUG_ON=3Dy
> >
> > I have been on SLAB, I configured SLAB DEBUG with a fresh pull from git=
hub. Linux syzkaller 5.0.0-rc2 #9 SMP Sun Jan 13 21:57:40 EST 2019 x86_64
> > ...
> > In an effort to get a different stack into the kernel, I felt that noth=
ing works better than fork bomb? :)
> > Let me know if that helps.
> > root@syzkaller:~# gcc -o test3 test3.c
> > root@syzkaller:~# while : ; do ./test3 & done
>
> And is test3 the same multi-threaded program that enters the kernel via
> /dev/sg0 and then calls SCSI_IOCTL_SEND_COMMAND which goes to the SCSI
> mid-level and thence to the block layer?
>
> And please remind me, does it also fail on lk 4.20.2 ?
>
> Doug Gilbert

Yes, the same C repro from the earlier thread.  It was a 4.20.0 kernel wher=
e it was first detected.  I can move to 4.20.2 and see if that changes anyt=
hing.

Esme
