Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 42C536B0098
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 09:49:59 -0500 (EST)
Received: by pzk27 with SMTP id 27so1503483pzk.12
        for <linux-mm@kvack.org>; Thu, 17 Dec 2009 06:49:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1261036879.27920.11.camel@laptop>
References: <20091217114630.d353907a.minchan.kim@barrios-desktop>
	 <1261036879.27920.11.camel@laptop>
Date: Thu, 17 Dec 2009 23:49:16 +0900
Message-ID: <28c262360912170649q30890dbay7892a15faf90135f@mail.gmail.com>
Subject: Re: Question about pte_offset_map_lock
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-mm <linux-mm@kvack.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Christoph Lameter <cl@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi, Peter.

On Thu, Dec 17, 2009 at 5:01 PM, Peter Zijlstra <peterz@infradead.org> wrot=
e:
> On Thu, 2009-12-17 at 11:46 +0900, Minchan Kim wrote:
>> It may be a dumb question.
>>
>> As I read the code of pte_lock, I have a question.
>> Now, there is pte_offset_map_lock following as.
>>
>> #define pte_offset_map_lock(mm, pmd, address, ptlp) =C2=A0 =C2=A0 \
>> ({ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0\
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 spinlock_t *__ptl =3D pte_lockptr(mm, pmd); =
=C2=A0 =C2=A0 =C2=A0 \
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 pte_t *__pte =3D pte_offset_map(pmd, address=
); =C2=A0 =C2=A0\
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 *(ptlp) =3D __ptl; =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0\
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_lock(__ptl); =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 \
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 __pte; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0\
>> })
>>
>> Why do we grab the lock after getting __pte?
>> Is it possible that __pte might be changed before we grab the spin_lock?
>>
>> Some codes in mm checks original pte by pte_same.
>> There are not-checked cases in proc. As looking over the cases,
>> It seems no problem. But in future, new user of pte_offset_map_lock
>> could mistake with that?
>
> I think currently mmap_sem serializes all that. Cases like faults that
> take the mmap_sem for reading sometimes need the pte validation to check
> if they didn't race with another fault etc.
>
> But since mmap_sem is held for reading the vma can't dissapear and the
> memory map is stable in the sense that the page tables will be present
> (or can be instantiated when needed), since munmap removes the
> pagetables for vmas.

Thanks for answering dumb question.

It means sometimes pte split lock depends on mmap_sem.
First of all, Shouldn't we remove this dependency by reordering spinlock(__=
ptl)
in pte_offset_map_lock  for range locking?

>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
