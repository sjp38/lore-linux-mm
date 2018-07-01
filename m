Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2627E6B0003
	for <linux-mm@kvack.org>; Sun,  1 Jul 2018 02:46:05 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id c12-v6so7115310wrs.13
        for <linux-mm@kvack.org>; Sat, 30 Jun 2018 23:46:05 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id o6-v6si3093116wrw.329.2018.06.30.23.46.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 Jun 2018 23:46:03 -0700 (PDT)
From: Song Liu <songliubraving@fb.com>
Subject: Re: [PATCH] mm: thp: passing correct vm_flags to hugepage_vma_check
Date: Sun, 1 Jul 2018 06:31:36 +0000
Message-ID: <F6855BF6-20DE-4AC8-8DA8-116F1AF52DBE@fb.com>
References: <20180629181752.792831-1-songliubraving@fb.com>
 <20180629192503.b41ce9e68d5c267595677a0d@linux-foundation.org>
In-Reply-To: <20180629192503.b41ce9e68d5c267595677a0d@linux-foundation.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <FF8592FF956B7C43B818F9E997606ECE@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Kernel Team <Kernel-team@fb.com>, Yang Shi <yang.shi@linux.alibaba.com>, "Kirill A .
 Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@surriel.com>



> On Jun 29, 2018, at 7:25 PM, Andrew Morton <akpm@linux-foundation.org> wr=
ote:
>=20
> On Fri, 29 Jun 2018 11:17:52 -0700 Song Liu <songliubraving@fb.com> wrote=
:
>=20
>> Back in May, I sent patch similar to 02b75dc8160d:
>>=20
>> https://patchwork.kernel.org/patch/10416233/  (v1)
>>=20
>> This patch got positive feedback. However, I realized there is a problem=
,
>> that vma->vm_flags in khugepaged_enter_vma_merge() is stale. The separat=
e
>> argument vm_flags contains the latest value. Therefore, it is
>> necessary to pass this vm_flags into hugepage_vma_check(). To fix this
>> problem,  I resent v2 and v3 of the work:
>>=20
>> https://patchwork.kernel.org/patch/10419527/   (v2)
>> https://patchwork.kernel.org/patch/10433937/   (v3)
>>=20
>> To my surprise, after I thought we all agreed on v3 of the work. Yang's
>> patch, which is similar to correct looking (but wrong) v1, got applied.
>> So we still have the issue of stale vma->vm_flags. This patch fixes this
>> issue. Please apply.
>=20
> That's a ueful history lesson but most of it isn't relevant to this
> change.  So I'd suggest this changelog:
>=20
> : khugepaged_enter_vma_merge() passes a stale vma->vm_flags to
> : hugepage_vma_check().  The argument vm_flags contains the latest value.=
=20
> : Therefore, it is necessary to pass this vm_flags into
> : hugepage_vma_check().

This looks good. Thanks!

> Also, please (as always) tell us the user-visible runtime effects of
> this bug so that others can decide which kernel(s) need the fix?

With this bug, madvise(MADV_HUGEPAGE) for mmap files in shmem fails to
put memory in huge pages. Here is an example of failed madvise():

   /* mount /dev/shm with huge=3Dadvise:
    *     mount -o remount,huge=3Dadvise /dev/shm */
   /* create file /dev/shm/huge */
   #define HUGE_FILE "/dev/shm/huge"

   fd =3D open(HUGE_FILE, O_RDONLY);
   ptr =3D mmap(NULL, FILE_SIZE, PROT_READ, MAP_PRIVATE, fd, 0);
   ret =3D madvise(ptr, FILE_SIZE, MADV_HUGEPAGE);

madvise() will return 0, but this memory region is never put in huge
page (check from /proc/meminfo: ShmemHugePages).

Thanks,
Song=
