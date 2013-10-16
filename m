Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id E4A4C6B0035
	for <linux-mm@kvack.org>; Wed, 16 Oct 2013 14:30:22 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id bj1so1473690pad.28
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 11:30:22 -0700 (PDT)
Received: by mail-vc0-f182.google.com with SMTP id im17so599606vcb.13
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 11:30:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CACz4_2c6+EgTLrybF=bFsK_ra-nNgb46PFuXZA4CT1AfKFf=ug@mail.gmail.com>
References: <20131015001242.GF3432@hippobay.mtv.corp.google.com>
 <20131015103744.A0BD3E0090@blue.fi.intel.com> <CACz4_2c6+EgTLrybF=bFsK_ra-nNgb46PFuXZA4CT1AfKFf=ug@mail.gmail.com>
From: Ning Qu <quning@google.com>
Date: Wed, 16 Oct 2013 11:29:58 -0700
Message-ID: <CACz4_2dgTMO0ufZTRZ6VoFENjKBdhht3sDdH8NwGTQwiM+9ZkA@mail.gmail.com>
Subject: Re: [PATCH 05/12] mm, thp, tmpfs: request huge page in shm_fault when needed
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Al Viro <viro@zeniv.linux.org.uk>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Fixed.
Best wishes,
--=20
Ning Qu (=C7=FA=C4=FE) | Software Engineer | quning@google.com | +1-408-418=
-6066


On Tue, Oct 15, 2013 at 11:49 AM, Ning Qu <quning@google.com> wrote:
> Will fix this.
> Best wishes,
> --
> Ning Qu (=C7=FA=C4=FE) | Software Engineer | quning@google.com | +1-408-4=
18-6066
>
>
> On Tue, Oct 15, 2013 at 3:37 AM, Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> wrote:
>> Ning Qu wrote:
>>> Add the function to request huge page in shm_fault when needed.
>>> And it will fall back to regular page if huge page can't be
>>> satisfied or allocated.
>>>
>>> If small page requested but huge page is found, the huge page will
>>> be splitted.
>>>
>>> Signed-off-by: Ning Qu <quning@gmail.com>
>>> ---
>>>  mm/shmem.c | 32 +++++++++++++++++++++++++++++---
>>>  1 file changed, 29 insertions(+), 3 deletions(-)
>>>
>>> diff --git a/mm/shmem.c b/mm/shmem.c
>>> index 68a0e1d..2fc450d 100644
>>> --- a/mm/shmem.c
>>> +++ b/mm/shmem.c
>>> @@ -1472,19 +1472,45 @@ unlock:
>>>  static int shmem_fault(struct vm_area_struct *vma, struct vm_fault *vm=
f)
>>>  {
>>>       struct inode *inode =3D file_inode(vma->vm_file);
>>> +     struct page *page =3D NULL;
>>>       int error;
>>>       int ret =3D VM_FAULT_LOCKED;
>>>       gfp_t gfp =3D mapping_gfp_mask(inode->i_mapping);
>>> -
>>> -     error =3D shmem_getpage(inode, vmf->pgoff, &vmf->page, SGP_CACHE,=
 gfp,
>>> -                             0, &ret);
>>> +     bool must_use_thp =3D vmf->flags & FAULT_FLAG_TRANSHUGE;
>>> +     int flags =3D 0;
>>> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE
>>> +     flags |=3D AOP_FLAG_TRANSHUGE;
>>> +#endif
>>
>> ifdef is not needed: shmem_getpage will ignore AOP_FLAG_TRANSHUGE if
>> CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE is not defined.
>>
>> --
>>  Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
