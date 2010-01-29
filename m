Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 4518E6B009C
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 19:55:15 -0500 (EST)
Received: by pwj10 with SMTP id 10so1113627pwj.6
        for <linux-mm@kvack.org>; Thu, 28 Jan 2010 16:55:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4B61C83A.20301@redhat.com>
References: <20100128002000.2bf5e365@annuminas.surriel.com>
	 <1264696641.17063.32.camel@barrios-desktop>
	 <4B61C83A.20301@redhat.com>
Date: Fri, 29 Jan 2010 09:55:04 +0900
Message-ID: <28c262361001281655x70e5f77awf4d890d20f57ca83@mail.gmail.com>
Subject: Re: [PATCH -mm] change anon_vma linking to fix multi-process server
	scalability issue
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, lwoodman@redhat.com, akpm@linux-foundation.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

On Fri, Jan 29, 2010 at 2:24 AM, Rik van Riel <riel@redhat.com> wrote:
>>> -void vma_adjust(struct vm_area_struct *vma, unsigned long start,
>>> +int vma_adjust(struct vm_area_struct *vma, unsigned long start,
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long end, pgoff_t pgoff, struct vm_=
area_struct *insert)
>>> =C2=A0{
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct mm_struct *mm =3D vma->vm_mm;
>>> @@ -542,6 +541,29 @@ again: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 remove_next =3D 1 + (end>
>>> =C2=A0next->vm_end);
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>>>
>>> + =C2=A0 =C2=A0 =C2=A0 /*
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* When changing only vma->vm_end, we don't=
 really need
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* anon_vma lock.
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>>> + =C2=A0 =C2=A0 =C2=A0 if (vma->anon_vma&& =C2=A0(insert || importer ||=
 start !=3D
>>> vma->vm_start))
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 anon_vma =3D vma->an=
on_vma;
>>> + =C2=A0 =C2=A0 =C2=A0 if (anon_vma) {
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* Easily overl=
ooked: when mprotect shifts the boundary,
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* make sure th=
e expanding vma has anon_vma set if the
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* shrinking vm=
a had, to cover any anon pages imported.
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (importer&& =C2=
=A0!importer->anon_vma) {
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 /* Block reverse map lookups until things are set
>>> up. */
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 importer->vm_flags |=3D VM_LOCK_RMAP;
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 if (anon_vma_clone(importer, vma)) {
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 importer->vm_flags&=3D ~VM_LOCK_RMAP;
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -ENOMEM;
>>
>> If we fail in here during progressing on next vmas in case of mprotect
>> case 6,
>> the previous vmas would become inconsistent state.
>
> I've re-read the code, but I don't see what you are referring
> to. =C2=A0If vma_adjust bails out early, no VMAs will be adjusted
> and all the VMAs will stay the way they were before mprotect
> was called.
>
> What am I overlooking?

I also look at the code more detail and found me wrong.
In mprotect case 6,  the importer is fixed as head of vmas while next
is marched
on forward. So anon_vma_clone is just called once at first time.
So as what you said, It's no problem.
Totally, my mistake. Sorry for that, Rik.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
