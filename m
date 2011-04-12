Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B8ECB8D0040
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 05:58:40 -0400 (EDT)
Received: by pxi10 with SMTP id 10so3717018pxi.8
        for <linux-mm@kvack.org>; Tue, 12 Apr 2011 02:58:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1104070718120.28555@sister.anvils>
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
Date: Tue, 12 Apr 2011 11:58:36 +0200
Message-ID: <BANLkTik_9YW5+64FHrzNy7kPz1FUWrw-rw@mail.gmail.com>
Subject: Re: [PATCH] mm: fix possible cause of a page_mapped BUG
From: =?UTF-8?B?Um9iZXJ0IMWad2nEmWNraQ==?= <robert@swiecki.net>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Miklos Szeredi <miklos@szeredi.hu>, Michel Lespinasse <walken@google.com>, "Eric W. Biederman" <ebiederm@xmission.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>

On Thu, Apr 7, 2011 at 4:24 PM, Hugh Dickins <hughd@google.com> wrote:
> On Thu, 7 Apr 2011, Robert Swiecki wrote:
>> >
>> > Testing with Linus' patch. Will let you know in a few hours.
>>
>> Ok, nothing happened after ~20h. The bug, usually, was triggered within =
5-10h.
>>
>> I can add some printk in this condition, and let it run for a few days
>> (I will not have access to my testing machine throughout that time),
>> if you think this will confirm your hypothesis.
>
> That's great, thanks Robert. =C2=A0If the machine has nothing better to d=
o,
> then it would be nice to let it run a little longer (a few days if that's
> what suits you), but it does look good so far. =C2=A0Though I'm afraid yo=
u'll
> now discover something else entirely ;)

Ok, I added printk here:

        if (new_len > old_len) {
                unsigned long pgoff;

                if (vma->vm_flags & (VM_DONTEXPAND | VM_PFNMAP))
                        goto Efault;
                pgoff =3D (addr - vma->vm_start) >> PAGE_SHIFT;
                pgoff +=3D vma->vm_pgoff;
                if (pgoff + (new_len >> PAGE_SHIFT) < pgoff) {
                        printk("VMA_TO_RESIZE: ADDR:%lx OLD_LEN:%lx
NEW_LEN:%lx PGOFF: %lx VMA->VM_START:%lx VMA->VM_FLAGS:%lx",
                                addr, old_len, new_len, pgoff,
vma->vm_start, vma->vm_flags);

                        goto Einval;
                }
        }


and after a few mins of fuzzing I get:

[  584.224028] VMA_TO_RESIZE: ADDR:f751f000 OLD_LEN:6000 NEW_LEN:c000
PGOFF: fffffffffffffffa VMA->VM_START:f751f000 VMA->VM_FLAGS:2321fa
[  639.777561] VMA_TO_RESIZE: ADDR:f751f000 OLD_LEN:6000 NEW_LEN:b000
PGOFF: fffffffffffffffa VMA->VM_START:f751f000 VMA->VM_FLAGS:2301f8

So, if this case is not caught later on in the code, I guess it solves
the problem. During the fuzzing I didn't experience any panic's, but
some other problems arose, i.e. cannot read /proc/<pid>/maps for some
processes (sys_read hangs, and such process cannot be killed or
stopped with any signal, still it's running (R state) and using CPU -
I'll submit another report for that).

--=20
Robert =C5=9Awi=C4=99cki

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
