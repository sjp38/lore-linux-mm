Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id CFE7C6B0390
	for <linux-mm@kvack.org>; Sun, 16 Apr 2017 19:57:38 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 194so78248518pfv.11
        for <linux-mm@kvack.org>; Sun, 16 Apr 2017 16:57:38 -0700 (PDT)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id b24si9269009pfk.341.2017.04.16.16.57.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Apr 2017 16:57:37 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] hugetlbfs: fix offset overflow in huegtlbfs mmap
Date: Sun, 16 Apr 2017 23:43:50 +0000
Message-ID: <20170416234349.GA3395@hori1.linux.bs1.fc.nec.co.jp>
References: <1491951118-30678-1-git-send-email-mike.kravetz@oracle.com>
 <20170414033210.GA12973@hori1.linux.bs1.fc.nec.co.jp>
 <c5c80a74-b4a8-6987-188e-ab63420f5362@oracle.com>
In-Reply-To: <c5c80a74-b4a8-6987-188e-ab63420f5362@oracle.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <7997CABDB2A4C944A9B13908A926003D@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Vegard Nossum <vegard.nossum@gmail.com>, Dmitry Vyukov <dvyukov@google.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Michal Hocko <mhocko@suse.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>

On Sat, Apr 15, 2017 at 03:58:59PM -0700, Mike Kravetz wrote:
> On 04/13/2017 08:32 PM, Naoya Horiguchi wrote:
> > On Tue, Apr 11, 2017 at 03:51:58PM -0700, Mike Kravetz wrote:
> > ...
> >> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> >> index 7163fe0..dde8613 100644
> >> --- a/fs/hugetlbfs/inode.c
> >> +++ b/fs/hugetlbfs/inode.c
> >> @@ -136,17 +136,26 @@ static int hugetlbfs_file_mmap(struct file *file=
, struct vm_area_struct *vma)
> >>  	vma->vm_flags |=3D VM_HUGETLB | VM_DONTEXPAND;
> >>  	vma->vm_ops =3D &hugetlb_vm_ops;
> >> =20
> >> +	/*
> >> +	 * Offset passed to mmap (before page shift) could have been
> >> +	 * negative when represented as a (l)off_t.
> >> +	 */
> >> +	if (((loff_t)vma->vm_pgoff << PAGE_SHIFT) < 0)
> >> +		return -EINVAL;
> >> +
> >>  	if (vma->vm_pgoff & (~huge_page_mask(h) >> PAGE_SHIFT))
> >>  		return -EINVAL;
> >> =20
> >>  	vma_len =3D (loff_t)(vma->vm_end - vma->vm_start);
> >> +	len =3D vma_len + ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
> >> +	/* check for overflow */
> >> +	if (len < vma_len)
> >> +		return -EINVAL;
> >=20
> > Andrew sent this patch to Linus today, so I know it's a little too late=
, but
> > I think that getting len directly from vma like below might be a simple=
r fix.
> >=20
> >   len =3D (loff_t)(vma->vm_end - vma->vm_start + (vma->vm_pgoff << PAGE=
_SHIFT));=20
> >=20
> > This shouldn't overflow because vma->vm_{end|start|pgoff} are unsigned =
long,
> > but if worried you can add VM_BUG_ON_VMA(len < 0, vma).
>=20
> Thanks Naoya,
>=20
> I am pretty sure the checks are necessary.  You are correct in that
> vma->vm_{end|start|pgoff} are unsigned long.  However,  pgoff can be
> a REALLY big value that becomes negative when shifted.
>=20
> Note that pgoff is simply the off_t offset value passed from the user cas=
t
> to unsigned long and shifted right by PAGE_SHIFT.  There is nothing to
> prevent a user from passing a 'signed' negative value.  In the reproducer
> provided, the value passed from user space is 0x8000000000000000ULL.

OK, thank you for explanation. You're right.

- Naoya=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
