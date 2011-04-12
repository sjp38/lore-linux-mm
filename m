Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id C99A6900086
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 12:19:17 -0400 (EDT)
Received: by pvg4 with SMTP id 4so3526667pvg.14
        for <linux-mm@kvack.org>; Tue, 12 Apr 2011 09:19:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTik6U21r91DYiUsz9A0P--=5QcsBrA@mail.gmail.com>
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
	<BANLkTimV1f1YDTWZUU9uvAtCO_fp6EKH9Q@mail.gmail.com>
	<BANLkTi=tavhpytcSV+nKaXJzw19Bo3W9XQ@mail.gmail.com>
	<alpine.LSU.2.00.1104060837590.4909@sister.anvils>
	<BANLkTi=-Zb+vrQuY6J+dAMsmz+cQDD-KUw@mail.gmail.com>
	<BANLkTim0MZfa8vFgHB3W6NsoPHp2jfirrA@mail.gmail.com>
	<BANLkTim-hyXpLj537asC__8exMo3o-WCLA@mail.gmail.com>
	<alpine.LSU.2.00.1104070718120.28555@sister.anvils>
	<BANLkTik_9YW5+64FHrzNy7kPz1FUWrw-rw@mail.gmail.com>
	<BANLkTiniyAN40p0q+2wxWsRZ5PJFn9zE0Q@mail.gmail.com>
	<BANLkTik6U21r91DYiUsz9A0P--=5QcsBrA@mail.gmail.com>
Date: Tue, 12 Apr 2011 18:17:45 +0200
Message-ID: <BANLkTik0oYcwtN5jzs4rfHfDyNUMYJdqhg@mail.gmail.com>
Subject: Re: [PATCH] mm: fix possible cause of a page_mapped BUG
From: =?UTF-8?B?Um9iZXJ0IMWad2nEmWNraQ==?= <robert@swiecki.net>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Miklos Szeredi <miklos@szeredi.hu>, Michel Lespinasse <walken@google.com>, "Eric W. Biederman" <ebiederm@xmission.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>

>>> So, if this case is not caught later on in the code, I guess it solves
>>> the problem. During the fuzzing I didn't experience any panic's, but
>>> some other problems arose, i.e. cannot read /proc/<pid>/maps for some
>>> processes (sys_read hangs, and such process cannot be killed or
>>> stopped with any signal, still it's running (R state) and using CPU -
>>> I'll submit another report for that).
>>
>> Hmm. Sounds like an endless loop in kernel mode.
>>
>> Use "perf record -ag" as root, it should show up very clearly in the rep=
ort.
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0Linus
>
> I've put some data here -
> http://groups.google.com/group/fa.linux.kernel/browse_thread/thread/4345d=
cc4f7750ce2
> - I think it's somewhat connected (sys_mlock appears on both cases).
>
> Attaching perf data (for 2.6.38) + kdb dumpall + procdump for process 141=
58
>
> Those 3 processes cannot be stopped/killed
>
> 14158 66.2 =C2=A00.0 =C2=A0 8380 =C2=A03012 ? =C2=A0RL =C2=A0/tmp/iknowth=
is
> 17100 63.6 =C2=A00.1 =C2=A018248 =C2=A04004 ? =C2=A0RL =C2=A0/tmp/iknowth=
is
> 19772 63.8 =C2=A00.0 =C2=A0 4000 =C2=A01888 ? =C2=A0 RL =C2=A0/tmp/iknowt=
his

Also, the system doesn't look usable after such fuzzing (executing a
few times some pretty deterministic program)

root@ise-test:~# gcc -m32 mlock.c  -o mlock

root@ise-test:~# ./mlock
./mlock: relocation error: ./mlock: symbol perror, version GLIBC_2.0
not defined in file libc.so.6 with link time reference

root@ise-test:~# ./mlock
mmap: Success
RET: 0xf751f000
mremap: Invalid argument
RET: 0xffffffff

root@ise-test:~# ./mlock
Segmentation fault

root@ise-test:~# dmesg | tail -n 1
[ 5164.961568] mlock[7097]: segfault at 0 ip           (null) sp
00000000ff8a00d4 error 14 in mlock[8048000+1000]

--=20
Robert =C5=9Awi=C4=99cki

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
