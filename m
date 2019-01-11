Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 19FF48E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 00:01:40 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id o5so254030wmf.9
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 21:01:40 -0800 (PST)
Received: from mail-40130.protonmail.ch (mail-40130.protonmail.ch. [185.70.40.130])
        by mx.google.com with ESMTPS id x15si34020517wrl.31.2019.01.10.21.01.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 21:01:38 -0800 (PST)
Date: Fri, 11 Jan 2019 05:01:36 +0000
From: Esme <esploit@protonmail.ch>
Reply-To: Esme <esploit@protonmail.ch>
Subject: Re: PROBLEM: syzkaller found / pool corruption-overwrite / page in user-area or NULL
Message-ID: <rYrcPMrGmYbPe_xgNEV6Q0jqc5XuPYmL2AFSyeNmg1gW531bgZnBGfEUK5_ktqDBaNW37b-NP2VXvlliM7_PsBRhSfB649MaW1Ne7zT9lHc=@protonmail.ch>
In-Reply-To: <3b3184e0-d913-6519-0f9d-2f01ef795650@lca.pw>
References: <t78EEfgpy3uIwPUvqvmuQEYEWKG9avWzjUD3EyR93Qaf_tfx1gqt4XplrqMgdxR1U9SsrVdA7G9XeUZacgUin0n6lBzoxJHVJ9Ko0yzzrxI=@protonmail.ch>
 <4u36JfbOrbu9CXLDErzQKvorP0gc2CzyGe60rBmZsGAGIw6RacZnIfoSsAF0I0TCnVx0OvcqCZFN6ntbgicJ66cWew9cOXRgcuWxSPdL3ko=@protonmail.ch>
 <1547154231.6911.10.camel@lca.pw>
 <hFmbfypBKySVyM6ITf55xUsPWifgqJy6MZ-kFJcYna61S-u2hoClrqr87QTF4F2LhW-K42T2lcCbvsEyGAL0dJTq5CndQBiMT6JnlW4xmdc=@protonmail.ch>
 <1547159604.6911.12.camel@lca.pw>
 <olV6qm38nrHhMMH3bq9cY3h60MaHsW5U9n6xn3_PVP1UkFNJBNbVuS-8P_FdCazGJX6GZX_Qqe2Nj8_hbLJsgto76Xo-gLQ8We-hsc_vRKk=@protonmail.ch>
 <7416c812-f452-9c23-9d0c-37eac0174231@lca.pw>
 <fkYi1Hgt2t5U6zQt5Kz4ej-TFyVsn2Qp2OLrMbmt2418U1rn20DPZGqgCN-rmCZgFgGKXhl3-IGciCJ-G9fV_lkBuy_Vb7QFouBhwBE--Eo=@protonmail.ch>
 <3b3184e0-d913-6519-0f9d-2f01ef795650@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qian Cai <cai@lca.pw>
Cc: James Bottomley <jejb@linux.ibm.com>, "dgilbert@interlog.com" <dgilbert@interlog.com>, "martin.petersen@oracle.com" <martin.petersen@oracle.com>, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90 Original Me=
ssage =E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90
On Thursday, January 10, 2019 11:52 PM, Qian Cai <cai@lca.pw> wrote:

> On 1/10/19 10:15 PM, Esme wrote:
>
> > > > [ 75.793150] RIP: 0010:rb_insert_color+0x189/0x1480
> > >
> > > What's in that line? Try,
> > > $ ./scripts/faddr2line vmlinux rb_insert_color+0x189/0x1480
> >
> > rb_insert_color+0x189/0x1480:
> > __rb_insert at /home/files/git/linux/lib/rbtree.c:131
> > (inlined by) rb_insert_color at /home/files/git/linux/lib/rbtree.c:452
>
> gparent =3D rb_red_parent(parent);
>
> tmp =3D gparent->rb_right; <-- GFP triggered here.
>
> It suggests gparent is NULL. Looks like it misses a check there because p=
arent
> is the top node.
>
> > > What's steps to reproduce this?
> >
> > The steps is the kernel config provided (proc.config) and I double chec=
ked the attached C code from the qemu image (attached here). If the kernel =
does not immediately crash, a ^C will cause the fault to be noticed. The re=
port from earlier is the report from the same code, my assumption was that =
the possible pool/redzone corruption is making it a bit tricky to pin down.
> > If you would like alternative kernel settings please let me know, I can=
 do that, also, my current test-bench has about 256 core's on x64, 64 of th=
em are bare metal and 32 are arm64. Any possible preferred configuration tw=
eaks I'm all ears, I'll be including some of these steps you suggested to m=
e in any/additional upcoming threads (Thank you for that so far and future =
suggestions).
> > Also, there is some occasionally varying stacks depending on the corrup=
tion, so this stack just now (another execution of test3.c);
>
> I am unable to reproduce any of those here. What's is the output of
> /proc/cmdline in your guest when this happens?

console=3DttyS0 root=3D/dev/sda debug earlyprintk=3Dserial slub_debug=3DQUZ
