Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id D00FE6B004A
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 21:30:08 -0500 (EST)
Received: by vcbfk14 with SMTP id fk14so1449345vcb.14
        for <linux-mm@kvack.org>; Thu, 01 Mar 2012 18:30:07 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120301125119.dee770f8.akpm@linux-foundation.org>
References: <1330594374-13497-1-git-send-email-lliubbo@gmail.com>
	<1330594374-13497-2-git-send-email-lliubbo@gmail.com>
	<20120301125119.dee770f8.akpm@linux-foundation.org>
Date: Fri, 2 Mar 2012 10:30:07 +0800
Message-ID: <CAA_GA1fU-Ah6VpnJFyFg0GzGTpj_+4YpEd-XHc5AGbcrJiaK_Q@mail.gmail.com>
Subject: Re: [PATCH 2/2] ksm: cleanup: introduce ksm_check_mm()
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: hughd@google.com, rientjes@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, linux-mm@kvack.org

Hi Andrew,

On Fri, Mar 2, 2012 at 4:51 AM, Andrew Morton <akpm@linux-foundation.org> w=
rote:
> On Thu, 1 Mar 2012 17:32:54 +0800
> Bob Liu <lliubbo@gmail.com> wrote:
>
>> +static int ksm_check_mm(struct mm_struct *mm, struct vm_area_struct *vm=
a,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long addr)
>> +{
>> + =C2=A0 =C2=A0 if (ksm_test_exit(mm))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 0;
>> + =C2=A0 =C2=A0 vma =3D find_vma(mm, addr);
>> + =C2=A0 =C2=A0 if (!vma || vma->vm_start > addr)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 0;
>> + =C2=A0 =C2=A0 if (!(vma->vm_flags & VM_MERGEABLE) || !vma->anon_vma)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 0;
>> + =C2=A0 =C2=A0 return 1;
>> +}
>
> Can we please think of a suitable name for this check, other than
> "check"? =C2=A0IOW, give the function a meaningful name which describes w=
hat
> it is checking?
>
> And it's not checking the mm, is it? =C2=A0It is checking the address: to
> see whether it lies within a mergeable anon vma.
>
> So maybe
>
> --- a/mm/ksm.c~ksm-cleanup-introduce-ksm_check_mm-fix
> +++ a/mm/ksm.c
> @@ -375,17 +375,17 @@ static int break_ksm(struct vm_area_stru
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return (ret & VM_FAULT_OOM) ? -ENOMEM : 0;
> =C2=A0}
>
> -static int ksm_check_mm(struct mm_struct *mm, struct vm_area_struct *vma=
,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long addr)
> +static bool in_mergeable_anon_vma(struct mm_struct *mm,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct vm_area_struct *vma, unsign=
ed long addr)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (ksm_test_exit(mm))
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 0;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return false;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0vma =3D find_vma(mm, addr);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!vma || vma->vm_start > addr)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 0;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return false;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!(vma->vm_flags & VM_MERGEABLE) || !vma->a=
non_vma)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 0;
> - =C2=A0 =C2=A0 =C2=A0 return 1;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return false;
> + =C2=A0 =C2=A0 =C2=A0 return true;
> =C2=A0}
>
> =C2=A0static void break_cow(struct rmap_item *rmap_item)
> @@ -401,7 +401,7 @@ static void break_cow(struct rmap_item *
> =C2=A0 =C2=A0 =C2=A0 =C2=A0put_anon_vma(rmap_item->anon_vma);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0down_read(&mm->mmap_sem);
> - =C2=A0 =C2=A0 =C2=A0 if (ksm_check_mm(mm, vma, addr))
> + =C2=A0 =C2=A0 =C2=A0 if (in_mergeable_anon_vma(mm, vma, addr))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0break_ksm(vma, add=
r);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0up_read(&mm->mmap_sem);
> =C2=A0}
> @@ -428,7 +428,7 @@ static struct page *get_mergeable_page(s
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct page *page;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0down_read(&mm->mmap_sem);
> - =C2=A0 =C2=A0 =C2=A0 if (!ksm_check_mm(mm, vma, addr))
> + =C2=A0 =C2=A0 =C2=A0 if (!in_mergeable_anon_vma(mm, vma, addr))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto out;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0page =3D follow_page(vma, addr, FOLL_GET);
> _
>

Yeah, It looks much better than mine, Thanks!

--=20
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
