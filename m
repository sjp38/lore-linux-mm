Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 0F86E6B004D
	for <linux-mm@kvack.org>; Fri,  9 Dec 2011 17:49:51 -0500 (EST)
Received: by yenq10 with SMTP id q10so3639822yen.14
        for <linux-mm@kvack.org>; Fri, 09 Dec 2011 14:49:50 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1323466526.27746.29.camel@joe2Laptop>
References: <1323465781-2976-1-git-send-email-kosaki.motohiro@gmail.com> <1323466526.27746.29.camel@joe2Laptop>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Fri, 9 Dec 2011 17:49:27 -0500
Message-ID: <CAHGf_=pWrM3ToRw0Hwb+mY3FVibmpvm2ShK+VspunQwWBCy9bA@mail.gmail.com>
Subject: Re: [PATCH v2] mm: simplify find_vma_prev
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Shaohua Li <shaohua.li@intel.com>

>> diff --git a/mm/mmap.c b/mm/mmap.c
> []
>> @@ -1603,39 +1603,21 @@ struct vm_area_struct *find_vma(struct mm_struct=
 *mm, unsigned long addr)
>>
>> =A0EXPORT_SYMBOL(find_vma);
>>
>> -/* Same as find_vma, but also return a pointer to the previous VMA in *=
pprev. */
>> +/*
>> + * Same as find_vma, but also return a pointer to the previous VMA in *=
pprev.
>> + * Note: pprev is set to NULL when return value is NULL.
>> + */
>> =A0struct vm_area_struct *
>> -find_vma_prev(struct mm_struct *mm, unsigned long addr,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct vm_area_struct **pprev)
>
>> +find_vma_prev(struct mm_struct *mm, unsigned long addr, struct vm_area_=
struct **pprev)
>
> eh. =A0This declaration change seems gratuitous and it exceeds 80 columns=
.
>
>> + =A0 =A0 *pprev =3D NULL;
>> + =A0 =A0 vma =3D find_vma(mm, addr);
>> + =A0 =A0 if (vma)
>> + =A0 =A0 =A0 =A0 =A0 =A0 *pprev =3D vma->vm_prev;
>
> There's no need to possibly set *pprev twice.
>
> Maybe
> {
> =A0 =A0 =A0 =A0struct vm_area_struct *vma =3D find_vma(mm, addr);
>
> =A0 =A0 =A0 =A0*pprev =3D vma ? vma->vm_prev : NULL;
> or
> =A0 =A0 =A0 =A0if (vma)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*pprev =3D vma->vm_prev;
> =A0 =A0 =A0 =A0else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*pprev =3D NULL;
>
> =A0 =A0 =A0 =A0return vma;

Thank you for reviewing. Updated.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
