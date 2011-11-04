Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 0F7296B002D
	for <linux-mm@kvack.org>; Thu,  3 Nov 2011 22:41:07 -0400 (EDT)
Received: by gyg10 with SMTP id 10so2639463gyg.14
        for <linux-mm@kvack.org>; Thu, 03 Nov 2011 19:41:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAGW+__+=q6W92+0HZWeQsqKt+wiBu7sPU8jTOxbaR_JEfqo6Qw@mail.gmail.com>
References: <1320215670-10157-1-git-send-email-heguanbo@gmail.com>
	<CAJd=RBD7iov62=OdZOb3L4S+2ok6CEconGMmmPrzFnzWkQJ+Rg@mail.gmail.com>
	<CAGW+__+=q6W92+0HZWeQsqKt+wiBu7sPU8jTOxbaR_JEfqo6Qw@mail.gmail.com>
Date: Fri, 4 Nov 2011 10:41:05 +0800
Message-ID: <CAGW+__LrtzqXem-o77UOzd0Fr8ORrHM7r_eiyMK8aX5t63+vBw@mail.gmail.com>
Subject: Re: [PATCH][mm] adjust the logic of checking THP
From: GuanJun He <heguanbo@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: gjhe@suse.com

On Thu, Nov 3, 2011 at 10:19 AM, GuanJun He <heguanbo@gmail.com> wrote:
> On Wed, Nov 2, 2011 at 8:17 PM, Hillf Danton <dhillf@gmail.com> wrote:
>> On Wed, Nov 2, 2011 at 2:34 PM, Guanjun He <heguanbo@gmail.com> wrote:
>>>
>>> Acturally, pmd_trans_huge(orig_pmd) only checks the _PAGE_PSE bits,
>>> it's a pmd entry bits, only mark a size, not a flag;As one can easily
>>> create the same pmd entry bits for some special use,then the check
>>> will get confused.And this patch is to adjust the logic to use the flag=
,
>>> it can perfectly avoid this potential issuse,and basically no impact
>>> to the current code.
>>>
>>>
>>> Signed-off-by: Guanjun He <heguanbo@gmail.com>
>>> ---
>>> =A0mm/memory.c | =A0 28 +++++++++++++++-------------
>>> =A01 files changed, 15 insertions(+), 13 deletions(-)
>>>
>>> diff --git a/mm/memory.c b/mm/memory.c
>>> index a56e3ba..a76b17f 100644
>>> --- a/mm/memory.c
>>> +++ b/mm/memory.c
>>> @@ -3465,20 +3465,22 @@ int handle_mm_fault(struct mm_struct *mm, struc=
t vm_area_struct *vma,
>>> =A0 =A0 =A0 =A0pmd =3D pmd_alloc(mm, pud, address);
>>> =A0 =A0 =A0 =A0if (!pmd)
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return VM_FAULT_OOM;
>>> - =A0 =A0 =A0 if (pmd_none(*pmd) && transparent_hugepage_enabled(vma)) =
{
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!vma->vm_ops)
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return do_huge_pmd_anonym=
ous_page(mm, vma, address,
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pmd, flags);
>>> - =A0 =A0 =A0 } else {
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 pmd_t orig_pmd =3D *pmd;
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 barrier();
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pmd_trans_huge(orig_pmd)) {
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (flags & FAULT_FLAG_WR=
ITE &&
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 !pmd_write(orig_p=
md) &&
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 !pmd_trans_splitt=
ing(orig_pmd))
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return do=
_huge_pmd_wp_page(mm, vma, address,
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pmd, orig_pmd);
>>> + =A0 =A0 =A0 if (transparent_hugepage_enabled(vma)) {
>>
>> Well, how about THP not configured?
>
> What do you mean 'not configured'? assume not enabled.
> If THP not enabled, of course the transparent_hugepage_enabled(vma)
> will be false.

In the original logic,  it's possible that the code go into the logic
of THP while the THP is not enabled.
Just think, If build another module that make pmd with the same bits,
even THP is not enabled, the code can go into the logic of the THP.And
this adjust can avoid this.

best,
Guanjun

>
>>
>> Thanks,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0Hillf
>>
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pmd_none(*pmd)) {
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!vma->vm_ops)
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return do=
_huge_pmd_anonymous_page(mm, vma, address,
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pmd, flags);
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pmd_t orig_pmd =3D *pmd;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 barrier();
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pmd_trans_huge(orig_p=
md)) {
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (flags=
 & FAULT_FLAG_WRITE &&
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 !=
pmd_write(orig_pmd) &&
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 !=
pmd_trans_splitting(orig_pmd))
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 return do_huge_pmd_wp_page(mm, vma, address,
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pmd, orig_pm=
d);
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>>> =A0 =A0 =A0 =A0}
>>>
>>> --
>>> 1.7.7
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-kernel"=
 in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>>> Please read the FAQ at =A0http://www.tux.org/lkml/
>>>
>>>
>>>
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
