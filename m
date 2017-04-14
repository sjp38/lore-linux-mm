Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id A225F2806CB
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 20:25:58 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id c18so61266887ioa.23
        for <linux-mm@kvack.org>; Thu, 13 Apr 2017 17:25:58 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id u125si10644979itd.15.2017.04.13.17.25.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Apr 2017 17:25:57 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id i5so13243722pfc.3
        for <linux-mm@kvack.org>; Thu, 13 Apr 2017 17:25:57 -0700 (PDT)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH] mm: add VM_STATIC flag to vmalloc and prevent from removing the areas
From: Hoeun Ryu <hoeun.ryu@gmail.com>
In-Reply-To: <c900f2f4-8b0c-cc0e-afb7-a03cd1458e4c@linux.vnet.ibm.com>
Date: Fri, 14 Apr 2017 09:25:54 +0900
Content-Transfer-Encoding: quoted-printable
Message-Id: <A3946A32-F0DB-438C-B2E7-D8CB09B1C49F@gmail.com>
References: <1491973350-26816-1-git-send-email-hoeun.ryu@gmail.com> <c900f2f4-8b0c-cc0e-afb7-a03cd1458e4c@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Andreas Dilger <adilger@dilger.ca>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Chris Wilson <chris@chris-wilson.co.uk>, Ingo Molnar <mingo@kernel.org>, zijun_hu <zijun_hu@htc.com>, Matthew Wilcox <mawilcox@microsoft.com>, Thomas Garnier <thgarnie@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


> On Apr 13, 2017, at 1:17 PM, Anshuman Khandual <khandual@linux.vnet.ibm.co=
m> wrote:
>=20
>> On 04/12/2017 10:31 AM, Hoeun Ryu wrote:
>> vm_area_add_early/vm_area_register_early() are used to reserve vmalloc ar=
ea
>> during boot process and those virtually mapped areas are never unmapped.
>> So `OR` VM_STATIC flag to the areas in vmalloc_init() when importing
>> existing vmlist entries and prevent those areas from being removed from t=
he
>> rbtree by accident.
>=20
> I am wondering whether protection against accidental deletion
> of any vmap area should be done in remove_vm_area() function
> or the callers should take care of it. But I guess either way
> it works.
>=20
>>=20
>> Signed-off-by: Hoeun Ryu <hoeun.ryu@gmail.com>
>> ---
>> include/linux/vmalloc.h | 1 +
>> mm/vmalloc.c            | 9 ++++++---
>> 2 files changed, 7 insertions(+), 3 deletions(-)
>>=20
>> diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
>> index 46991ad..3df53fc 100644
>> --- a/include/linux/vmalloc.h
>> +++ b/include/linux/vmalloc.h
>> @@ -19,6 +19,7 @@ struct notifier_block;        /* in notifier.h */
>> #define VM_UNINITIALIZED    0x00000020    /* vm_struct is not fully initi=
alized */
>> #define VM_NO_GUARD        0x00000040      /* don't add guard page */
>> #define VM_KASAN        0x00000080      /* has allocated kasan shadow mem=
ory */
>> +#define VM_STATIC        0x00000200
>=20
> You might want to add some description in the comment saying
> its a sticky VM area which will never go away or something.
>=20

OK. I will add some description.

>> /* bits [20..32] reserved for arch specific ioremap internals */
>>=20
>> /*
>> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>> index 8ef8ea1..fb5049a 100644
>> --- a/mm/vmalloc.c
>> +++ b/mm/vmalloc.c
>> @@ -1262,7 +1262,7 @@ void __init vmalloc_init(void)
>>    /* Import existing vmlist entries. */
>>    for (tmp =3D vmlist; tmp; tmp =3D tmp->next) {
>>        va =3D kzalloc(sizeof(struct vmap_area), GFP_NOWAIT);
>> -        va->flags =3D VM_VM_AREA;
>> +        va->flags =3D VM_VM_AREA | VM_STATIC;
>>        va->va_start =3D (unsigned long)tmp->addr;
>>        va->va_end =3D va->va_start + tmp->size;
>>        va->vm =3D tmp;
>> @@ -1480,7 +1480,7 @@ struct vm_struct *remove_vm_area(const void *addr)
>>    might_sleep();
>>=20
>>    va =3D find_vmap_area((unsigned long)addr);
>> -    if (va && va->flags & VM_VM_AREA) {
>> +    if (va && va->flags & VM_VM_AREA && likely(!(va->flags & VM_STATIC))=
) {
>=20
>=20
> You might want to move the VM_STATIC check before the VM_VM_AREA
> check so in cases where the former is set we can save one more
> conditional check.
>=20

OK, I'll fix this in the next version

Thank you for the review.=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
