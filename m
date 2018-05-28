Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id CCE6E6B0005
	for <linux-mm@kvack.org>; Mon, 28 May 2018 14:04:09 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z69-v6so10969700wrb.20
        for <linux-mm@kvack.org>; Mon, 28 May 2018 11:04:09 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id l187-v6si11382888wma.69.2018.05.28.11.04.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 May 2018 11:04:08 -0700 (PDT)
From: Song Liu <songliubraving@fb.com>
Subject: Re: [PATCH v2] mm/THP: use hugepage_vma_check() in
 khugepaged_enter_vma_merge()
Date: Mon, 28 May 2018 18:04:00 +0000
Message-ID: <8F62086E-03E5-4A65-99F3-E4ABB4FFFC70@fb.com>
References: <20180522194430.426688-1-songliubraving@fb.com>
 <20180528105724.okg6c7i72r3v3jno@kshutemo-mobl1>
In-Reply-To: <20180528105724.okg6c7i72r3v3jno@kshutemo-mobl1>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <8DD54734F576FF429948A0393436350D@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Kernel Team <Kernel-team@fb.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mhocko@kernel.org" <mhocko@kernel.org>, "rientjes@google.com" <rientjes@google.com>, "aarcange@redhat.com" <aarcange@redhat.com>



> On May 28, 2018, at 3:57 AM, Kirill A. Shutemov <kirill@shutemov.name> wr=
ote:
>=20
> On Tue, May 22, 2018 at 12:44:30PM -0700, Song Liu wrote:
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
>> will not call khugepaged_enter(). Here is an example of failed madvise()=
:
>>=20
>>   /* mount /dev/shm with huge=3Dadvise:
>>    *     mount -o remount,huge=3Dadvise /dev/shm */
>>   /* create file /dev/shm/huge */
>>   #define HUGE_FILE "/dev/shm/huge"
>>=20
>>   fd =3D open(HUGE_FILE, O_RDONLY);
>>   ptr =3D mmap(NULL, FILE_SIZE, PROT_READ, MAP_PRIVATE, fd, 0);
>>   ret =3D madvise(ptr, FILE_SIZE, MADV_HUGEPAGE);
>>=20
>> madvise() will return 0, but this memory region is never put in huge
>> page (check from /proc/meminfo: ShmemHugePages).
>>=20
>> This patch fixes these problems by reusing hugepage_vma_check() in
>> khugepaged_enter_vma_merge().
>>=20
>> vma->vm_flags is not yet updated in khugepaged_enter_vma_merge(),
>> so we need to pass the new vm_flags to hugepage_vma_check() through
>> a separate argument.
>>=20
>> Signed-off-by: Song Liu <songliubraving@fb.com>
>> ---
>> mm/khugepaged.c | 26 ++++++++++++--------------
>> 1 file changed, 12 insertions(+), 14 deletions(-)
>>=20
>> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
>> index d7b2a4b..9f74e51 100644
>> --- a/mm/khugepaged.c
>> +++ b/mm/khugepaged.c
>> @@ -430,18 +430,15 @@ int __khugepaged_enter(struct mm_struct *mm)
>> 	return 0;
>> }
>>=20
>> +static bool hugepage_vma_check(struct vm_area_struct *vma,
>> +			       unsigned long vm_flags);
>> +
>=20
> The patch looks good to me.
>=20
> But can we move hugepage_vma_check() here to avoid forward declaration of
> the function?

Thanks for the feedback! I will send v3 with this change.=20

Song
