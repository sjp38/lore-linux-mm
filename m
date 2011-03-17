Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E63D48D003F
	for <linux-mm@kvack.org>; Thu, 17 Mar 2011 11:41:01 -0400 (EDT)
Received: by yxt33 with SMTP id 33so1526675yxt.14
        for <linux-mm@kvack.org>; Thu, 17 Mar 2011 08:40:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTi==MQV=_qq1HaCxGLRu8DdT6FYddqzBkzp1TQs7@mail.gmail.com>
References: <alpine.LSU.2.00.1102232136020.2239@sister.anvils>
	<AANLkTi==MQV=_qq1HaCxGLRu8DdT6FYddqzBkzp1TQs7@mail.gmail.com>
Date: Thu, 17 Mar 2011 16:40:47 +0100
Message-ID: <AANLkTimv66fV1+JDqSAxRwddvy_kggCuhoJLMTpMTtJM@mail.gmail.com>
Subject: Re: [PATCH] mm: fix possible cause of a page_mapped BUG
From: =?UTF-8?B?Um9iZXJ0IMWad2nEmWNraQ==?= <robert@swiecki.net>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Miklos Szeredi <miklos@szeredi.hu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi,

On Tue, Mar 1, 2011 at 12:35 AM, Robert =C5=9Awi=C4=99cki <robert@swiecki.n=
et> wrote:
>> But rather than exporting the notion of restart_addr from memory.c, or
>> converting to restart_pgoff throughout, simply reset vm_truncate_count
>> to 0 to force a rescan if mremap move races with preempted truncation.
>>
>> We have no confirmation that this fixes Robert's BUG,
>> but it is a fix that's worth making anyway.
>
> Hi, I don't have currently access to my rs232/console testing machine
> (lame excuse but it helps a lot;), cause I'm working currently OOtO,
> so I'll try to test it asap - which is probably Mar 15th or so.

So, I compiled 2.6.38 and started fuzzing it. I'm bumping into other
problems, and never seen anything about mremap in 2.6.38 (yet), as it
had been happening in 2.6.37-rc2. The output goes to
http://alt.swiecki.net/linux_kernel/ - I'm still trying.

> Btw, the fuzzer is here: http://code.google.com/p/iknowthis/
>
> I think i was trying it with this revision:
> http://code.google.com/p/iknowthis/source/detail?r=3D11 (i386 mode,
> newest 'iknowthis' supports x86-64 natively), so feel free to try it.
>
> It used to crash the machine (it's BUG_ON but the system became
> unusable) in matter of hours. Btw, when I was testing it for the last
> time it Ooopsed much more frequently in proc_readdir (I sent report in
> one of earliet e-mails).
>
>> Signed-off-by: Hugh Dickins <hughd@google.com>
>> ---
>>
>> =C2=A0mm/mremap.c | =C2=A0 =C2=A04 +---
>> =C2=A01 file changed, 1 insertion(+), 3 deletions(-)
>>
>> --- 2.6.38-rc6/mm/mremap.c =C2=A0 =C2=A0 =C2=A02011-01-18 22:04:56.00000=
0000 -0800
>> +++ linux/mm/mremap.c =C2=A0 2011-02-23 15:29:52.000000000 -0800
>> @@ -94,9 +94,7 @@ static void move_ptes(struct vm_area_str
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mapping =3D vma->=
vm_file->f_mapping;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock(&mappin=
g->i_mmap_lock);
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (new_vma->vm_trunc=
ate_count &&
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 new_vma=
->vm_truncate_count !=3D vma->vm_truncate_count)
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 new_vma->vm_truncate_count =3D 0;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 new_vma->vm_truncate_=
count =3D 0;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
>>
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
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
