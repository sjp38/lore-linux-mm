Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9F92B8D003B
	for <linux-mm@kvack.org>; Wed,  6 Apr 2011 10:47:49 -0400 (EDT)
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id p36Ellu6007767
	for <linux-mm@kvack.org>; Wed, 6 Apr 2011 07:47:47 -0700
Received: from vxc40 (vxc40.prod.google.com [10.241.33.168])
	by kpbe19.cbf.corp.google.com with ESMTP id p36ElVcC032542
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 6 Apr 2011 07:47:46 -0700
Received: by vxc40 with SMTP id 40so1829606vxc.16
        for <linux-mm@kvack.org>; Wed, 06 Apr 2011 07:47:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTikcZK+AQvwe2ED=b0dLZ0hqg0B95w@mail.gmail.com>
References: <alpine.LSU.2.00.1102232136020.2239@sister.anvils>
	<AANLkTi==MQV=_qq1HaCxGLRu8DdT6FYddqzBkzp1TQs7@mail.gmail.com>
	<AANLkTimv66fV1+JDqSAxRwddvy_kggCuhoJLMTpMTtJM@mail.gmail.com>
	<alpine.LSU.2.00.1103182158200.18771@sister.anvils>
	<BANLkTinoNMudwkcOOgU5d+imPUfZhDbWWQ@mail.gmail.com>
	<AANLkTimfArmB7judMW7Qd4ATtVaR=yTf_-0DBRAfCJ7w@mail.gmail.com>
	<BANLkTi=Limr3NUaG7RLoQLv5TuEDmm7Rqg@mail.gmail.com>
	<BANLkTi=UZcocVk_16MbbV432g9a3nDFauA@mail.gmail.com>
	<BANLkTi=KTdLRC_hRvxfpFoMSbz=vOjpObw@mail.gmail.com>
	<BANLkTindeX9-ECPjgd_V62ZbXCd7iEG9_w@mail.gmail.com>
	<BANLkTikcZK+AQvwe2ED=b0dLZ0hqg0B95w@mail.gmail.com>
Date: Wed, 6 Apr 2011 07:47:41 -0700
Message-ID: <BANLkTimV1f1YDTWZUU9uvAtCO_fp6EKH9Q@mail.gmail.com>
Subject: Re: [PATCH] mm: fix possible cause of a page_mapped BUG
From: Hugh Dickins <hughd@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: =?UTF-8?B?Um9iZXJ0IMWad2nEmWNraQ==?= <robert@swiecki.net>, Andrew Morton <akpm@linux-foundation.org>, Miklos Szeredi <miklos@szeredi.hu>, Michel Lespinasse <walken@google.com>, "Eric W. Biederman" <ebiederm@xmission.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>

On Tue, Apr 5, 2011 at 8:37 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Tue, Apr 5, 2011 at 5:21 AM, Robert =C5=9Awi=C4=99cki <robert@swiecki.=
net> wrote:
>>
>> Here it is, I'll leave it in this state (kdb) in case you need some
>> remote debugging
>>
>> <4>[ 1523.877666] WARNING: at mm/prio_tree.c:95 vma_prio_tree_add+0x43/0=
x110()
>> <4>[ 1523.978650] vm_area_struct at ffff880120bda508:
>> <4>[ 1523.983199] =C2=A0ffff88011eb5aa00 00000000f72f3000 00000000f73f00=
00 ffff88011b8eaa10
>> <4>[ 1523.990674] =C2=A0ffff88011b8ea228 0000000000000027 00000000000101=
ff ffff88011b8ea6b1
>> <4>[ 1523.998151] =C2=A0ffff88011e390820 ffff88011b8ea260 ffff8801207967=
80 ffff880120bdad40
>> <4>[ 1524.005624] =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0(null) =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (null) ffff88011ed5b910 ffff88011ed5b1f0
>> <4>[ 1524.013103] =C2=A0ffff88011f72b168 ffffffff82427480 ffffffffffffff=
03 ffff8800793ff0c0
>> <4>[ 1524.020581] =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0(null) =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (null) =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (nul=
l)
>
> vma->vm_start/end is 0xf72f3000-0xf73f0000
>
>> <4>[ 1524.026556] vm_area_struct at ffff880120bdacf0:
>> <4>[ 1524.031110] =C2=A0ffff88011eb5a300 00000000f72f3000 00000000f74000=
00 ffff88011f6c6f18
>> <4>[ 1524.038584] =C2=A0ffff88011b5c9da8 0000000000000027 00000000000101=
ff ffff8801206f0c71
>> <4>[ 1524.046062] =C2=A0ffff88011f6c6f50 ffff88011b5c9de0 ffff880120bdad=
40 ffff880120bdad40
>> <4>[ 1524.053536] =C2=A0ffff880120bda558 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 (null) ffff88011f758ee0 ffff88011f7583a0
>> <4>[ 1524.061016] =C2=A0ffff88011f556690 ffffffff82427480 ffffffffffffff=
03 ffff8800793ff0c0
>> <4>[ 1524.068491] =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0(null) =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (null) =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (nul=
l)
>
> vma->vm_start/end is 0xf72f3000-0xf7400000.
>
> If I read those right, then the vm_pgoff (RADIX_INDEX for the
> prio-tree) is ffffffffffffff03 for both cases. That doesn't look good.
> How do we get a negative pg_off for a file mapping?

Yes, I think that's probably at the root of it.  Robert is using a
fuzzer, and it's a 32-bit executable running on a 64-bit kernel: I
suspect there's somewhere on our compat path where we've not validated
incoming mmap offset properly.

Hmm, but I don't see anything wrong there.

>
> Also, since they have a different size, they should have a different
> HEAP_INDEX. That's why we BUG_ON() - with a different HEAP_INDEX,
> shouldn't that mean that the prio_tree_insert() logic should create a
> new node for it?

Yes.

>
> I dunno. But that odd negative pg_off thing makes me think there is
> some overflow issue (ie HEAP_INDEX being pg_off + size ends up
> fluctuating between really big and really small). So I'd suspect THAT
> as the main reason.

Yes, one of the vmas is such that the end offset (pgoff of next page
after) would be 0, and for the other it would be 16.  There's sure to
be places, inside the prio_tree code and outside it, where we rely
upon pgoff not wrapping around - wrap should be prevented by original
validation of arguments.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
