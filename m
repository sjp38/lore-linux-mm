Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5759B6B0003
	for <linux-mm@kvack.org>; Tue, 22 May 2018 15:31:42 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id c56-v6so15334402wrc.5
        for <linux-mm@kvack.org>; Tue, 22 May 2018 12:31:42 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id u22-v6si7566359lfc.401.2018.05.22.12.31.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 May 2018 12:31:40 -0700 (PDT)
From: Song Liu <songliubraving@fb.com>
Subject: Re: [PATCH] mm/THP: use hugepage_vma_check() in
 khugepaged_enter_vma_merge()
Date: Tue, 22 May 2018 19:31:31 +0000
Message-ID: <714CDE40-F3F2-4366-8765-C738EC66D8FD@fb.com>
References: <20180521193853.3089484-1-songliubraving@fb.com>
 <20180522121319.GB30663@dhcp22.suse.cz>
In-Reply-To: <20180522121319.GB30663@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <DD885E4D76821C47B2225D8DC9991200@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Kernel Team <Kernel-team@fb.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>

On May 22, 2018, at 5:13 AM, Michal Hocko <mhocko@kernel.org> wrote:
>=20
> [CC Kirill]
>=20
> On Mon 21-05-18 12:38:53, Song Liu wrote:
>> khugepaged_enter_vma_merge() is using a different approach to check
>> whether a vma is valid for khugepaged_enter():
>>=20
>>    if (!vma->anon_vma)
>>            /*
>>             * Not yet faulted in so we will register later in the
>>             * page fault if needed.
>>             */
>>            return 0;
>>    if (vma->vm_ops || (vm_flags & VM_NO_KHUGEPAGED))
>>            /* khugepaged not yet working on file or special mappings */
>>            return 0;
>>=20
>> This check has some problems. One of the obvious problems is that
>> it doesn't check shmem_file(), so that vma backed with shmem files
>> will not call khugepaged_enter().
>>=20
>> This patch fixes these problems by reusing hugepage_vma_check() in
>> khugepaged_enter_vma_merge().
>=20
> It would be great to be more explicit about what are the actual
> consequences. khugepaged_enter_vma_merge is called from multiple
> context. Some of then do not really care about !anon case (e.g. stack
> expansion). hugepage_madvise is quite convoluted so I am not really sure
> from a quick look (are we simply not going to merge vmas even if we
> could?).

Yes, it does fix madvise for shmem with huge=3Dadvise option. I had made
a mistake in this version. I will send v2 with the more details on what
is fixed.=20

> Have you noticed this by a code inspection or you have seen this
> happening in real workloads (aka, is this worth backporting to stable
> trees)?

I noticed this when reading the code. I think this might worth back=20
porting. However, I don't know whether it fixes anything else other
than shmem, so I am not sure which versions need this fix.=20

Thanks,
Song


>> Signed-off-by: Song Liu <songliubraving@fb.com>
>> ---
>> mm/khugepaged.c | 12 ++++--------
>> 1 file changed, 4 insertions(+), 8 deletions(-)
>>=20
>> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
>> index d7b2a4b..e50c2bd 100644
>> --- a/mm/khugepaged.c
>> +++ b/mm/khugepaged.c
>> @@ -430,18 +430,14 @@ int __khugepaged_enter(struct mm_struct *mm)
>> 	return 0;
>> }
>>=20
>> +static bool hugepage_vma_check(struct vm_area_struct *vma);
>> +
>> int khugepaged_enter_vma_merge(struct vm_area_struct *vma,
>> 			       unsigned long vm_flags)
>> {
>> 	unsigned long hstart, hend;
>> -	if (!vma->anon_vma)
>> -		/*
>> -		 * Not yet faulted in so we will register later in the
>> -		 * page fault if needed.
>> -		 */
>> -		return 0;
>> -	if (vma->vm_ops || (vm_flags & VM_NO_KHUGEPAGED))
>> -		/* khugepaged not yet working on file or special mappings */
>> +
>> +	if (!hugepage_vma_check(vma))
>> 		return 0;
>> 	hstart =3D (vma->vm_start + ~HPAGE_PMD_MASK) & HPAGE_PMD_MASK;
>> 	hend =3D vma->vm_end & HPAGE_PMD_MASK;
>> --=20
>> 2.9.5
>=20
> --=20
> Michal Hocko
> SUSE Labs
