Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id EC26C8D003B
	for <linux-mm@kvack.org>; Tue,  5 Apr 2011 12:06:13 -0400 (EDT)
Received: from mail-iw0-f169.google.com (mail-iw0-f169.google.com [209.85.214.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p35G69Yc029411
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Tue, 5 Apr 2011 09:06:09 -0700
Received: by iwg8 with SMTP id 8so739141iwg.14
        for <linux-mm@kvack.org>; Tue, 05 Apr 2011 09:06:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTindeX9-ECPjgd_V62ZbXCd7iEG9_w@mail.gmail.com>
References: <alpine.LSU.2.00.1102232136020.2239@sister.anvils>
 <AANLkTi==MQV=_qq1HaCxGLRu8DdT6FYddqzBkzp1TQs7@mail.gmail.com>
 <AANLkTimv66fV1+JDqSAxRwddvy_kggCuhoJLMTpMTtJM@mail.gmail.com>
 <alpine.LSU.2.00.1103182158200.18771@sister.anvils> <BANLkTinoNMudwkcOOgU5d+imPUfZhDbWWQ@mail.gmail.com>
 <AANLkTimfArmB7judMW7Qd4ATtVaR=yTf_-0DBRAfCJ7w@mail.gmail.com>
 <BANLkTi=Limr3NUaG7RLoQLv5TuEDmm7Rqg@mail.gmail.com> <BANLkTi=UZcocVk_16MbbV432g9a3nDFauA@mail.gmail.com>
 <BANLkTi=KTdLRC_hRvxfpFoMSbz=vOjpObw@mail.gmail.com> <BANLkTindeX9-ECPjgd_V62ZbXCd7iEG9_w@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 5 Apr 2011 08:37:32 -0700
Message-ID: <BANLkTikcZK+AQvwe2ED=b0dLZ0hqg0B95w@mail.gmail.com>
Subject: Re: [PATCH] mm: fix possible cause of a page_mapped BUG
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?Um9iZXJ0IMWad2nEmWNraQ==?= <robert@swiecki.net>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Miklos Szeredi <miklos@szeredi.hu>, Michel Lespinasse <walken@google.com>, "Eric W. Biederman" <ebiederm@xmission.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>

On Tue, Apr 5, 2011 at 5:21 AM, Robert =C5=9Awi=C4=99cki <robert@swiecki.ne=
t> wrote:
>
> Here it is, I'll leave it in this state (kdb) in case you need some
> remote debugging
>
> <4>[ 1523.877666] WARNING: at mm/prio_tree.c:95 vma_prio_tree_add+0x43/0x=
110()
> <4>[ 1523.978650] vm_area_struct at ffff880120bda508:
> <4>[ 1523.983199] =C2=A0ffff88011eb5aa00 00000000f72f3000 00000000f73f000=
0 ffff88011b8eaa10
> <4>[ 1523.990674] =C2=A0ffff88011b8ea228 0000000000000027 00000000000101f=
f ffff88011b8ea6b1
> <4>[ 1523.998151] =C2=A0ffff88011e390820 ffff88011b8ea260 ffff88012079678=
0 ffff880120bdad40
> <4>[ 1524.005624] =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0(null) =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 (null) ffff88011ed5b910 ffff88011ed5b1f0
> <4>[ 1524.013103] =C2=A0ffff88011f72b168 ffffffff82427480 ffffffffffffff0=
3 ffff8800793ff0c0
> <4>[ 1524.020581] =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0(null) =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 (null) =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (null=
)

vma->vm_start/end is 0xf72f3000-0xf73f0000

> <4>[ 1524.026556] vm_area_struct at ffff880120bdacf0:
> <4>[ 1524.031110] =C2=A0ffff88011eb5a300 00000000f72f3000 00000000f740000=
0 ffff88011f6c6f18
> <4>[ 1524.038584] =C2=A0ffff88011b5c9da8 0000000000000027 00000000000101f=
f ffff8801206f0c71
> <4>[ 1524.046062] =C2=A0ffff88011f6c6f50 ffff88011b5c9de0 ffff880120bdad4=
0 ffff880120bdad40
> <4>[ 1524.053536] =C2=A0ffff880120bda558 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 (null) ffff88011f758ee0 ffff88011f7583a0
> <4>[ 1524.061016] =C2=A0ffff88011f556690 ffffffff82427480 ffffffffffffff0=
3 ffff8800793ff0c0
> <4>[ 1524.068491] =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0(null) =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 (null) =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (null=
)

vma->vm_start/end is 0xf72f3000-0xf7400000.

If I read those right, then the vm_pgoff (RADIX_INDEX for the
prio-tree) is ffffffffffffff03 for both cases. That doesn't look good.
How do we get a negative pg_off for a file mapping?

Also, since they have a different size, they should have a different
HEAP_INDEX. That's why we BUG_ON() - with a different HEAP_INDEX,
shouldn't that mean that the prio_tree_insert() logic should create a
new node for it?

I dunno. But that odd negative pg_off thing makes me think there is
some overflow issue (ie HEAP_INDEX being pg_off + size ends up
fluctuating between really big and really small). So I'd suspect THAT
as the main reason.

But maybe I'm mis-reading the dump, and the ffffffffffffff03 isn't
vm_pgoff at all.

Hugh?

                              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
