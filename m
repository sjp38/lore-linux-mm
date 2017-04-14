Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C4A546B0038
	for <linux-mm@kvack.org>; Fri, 14 Apr 2017 00:29:59 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id o123so44388911pga.16
        for <linux-mm@kvack.org>; Thu, 13 Apr 2017 21:29:59 -0700 (PDT)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id 189si629492pfg.334.2017.04.13.21.29.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Apr 2017 21:29:58 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] hugetlbfs: fix offset overflow in huegtlbfs mmap
Date: Fri, 14 Apr 2017 03:32:15 +0000
Message-ID: <20170414033210.GA12973@hori1.linux.bs1.fc.nec.co.jp>
References: <1491951118-30678-1-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1491951118-30678-1-git-send-email-mike.kravetz@oracle.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <B8E38353945FF245A2327F0A43B7767B@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Vegard Nossum <vegard.nossum@gmail.com>, Dmitry Vyukov <dvyukov@google.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Michal Hocko <mhocko@suse.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Apr 11, 2017 at 03:51:58PM -0700, Mike Kravetz wrote:
...
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index 7163fe0..dde8613 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -136,17 +136,26 @@ static int hugetlbfs_file_mmap(struct file *file, s=
truct vm_area_struct *vma)
>  	vma->vm_flags |=3D VM_HUGETLB | VM_DONTEXPAND;
>  	vma->vm_ops =3D &hugetlb_vm_ops;
> =20
> +	/*
> +	 * Offset passed to mmap (before page shift) could have been
> +	 * negative when represented as a (l)off_t.
> +	 */
> +	if (((loff_t)vma->vm_pgoff << PAGE_SHIFT) < 0)
> +		return -EINVAL;
> +
>  	if (vma->vm_pgoff & (~huge_page_mask(h) >> PAGE_SHIFT))
>  		return -EINVAL;
> =20
>  	vma_len =3D (loff_t)(vma->vm_end - vma->vm_start);
> +	len =3D vma_len + ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
> +	/* check for overflow */
> +	if (len < vma_len)
> +		return -EINVAL;

Andrew sent this patch to Linus today, so I know it's a little too late, bu=
t
I think that getting len directly from vma like below might be a simpler fi=
x.

  len =3D (loff_t)(vma->vm_end - vma->vm_start + (vma->vm_pgoff << PAGE_SHI=
FT));=20

This shouldn't overflow because vma->vm_{end|start|pgoff} are unsigned long=
,
but if worried you can add VM_BUG_ON_VMA(len < 0, vma).

Thanks,
Naoya Horiguchi

> =20
>  	inode_lock(inode);
>  	file_accessed(file);
> =20
>  	ret =3D -ENOMEM;
> -	len =3D vma_len + ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
> -
>  	if (hugetlb_reserve_pages(inode,
>  				vma->vm_pgoff >> huge_page_order(h),
>  				len >> huge_page_shift(h), vma,
> @@ -155,7 +164,7 @@ static int hugetlbfs_file_mmap(struct file *file, str=
uct vm_area_struct *vma)
> =20
>  	ret =3D 0;
>  	if (vma->vm_flags & VM_WRITE && inode->i_size < len)
> -		inode->i_size =3D len;
> +		i_size_write(inode, len);
>  out:
>  	inode_unlock(inode);
> =20
> --=20
> 2.7.4
>=20
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
