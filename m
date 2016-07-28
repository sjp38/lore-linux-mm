Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4BAD66B025F
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 02:43:40 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id w128so37471650pfd.3
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 23:43:40 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id k8si10827493pab.100.2016.07.27.23.43.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Jul 2016 23:43:39 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH V2] mm/hugetlb: Avoid soft lockup in set_max_huge_pages()
Date: Thu, 28 Jul 2016 06:41:28 +0000
Message-ID: <20160728064128.GA11208@hori1.linux.bs1.fc.nec.co.jp>
References: <1469674442-14848-1-git-send-email-hejianet@gmail.com>
In-Reply-To: <1469674442-14848-1-git-send-email-hejianet@gmail.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <9696EB4DFFE25245A048AC55D9B00807@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia He <hejianet@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>, Paul Gortmaker <paul.gortmaker@windriver.com>

On Thu, Jul 28, 2016 at 10:54:02AM +0800, Jia He wrote:
> In powerpc servers with large memory(32TB), we watched several soft
> lockups for hugepage under stress tests.
> The call trace are as follows:
> 1.
> get_page_from_freelist+0x2d8/0xd50 =20
> __alloc_pages_nodemask+0x180/0xc20 =20
> alloc_fresh_huge_page+0xb0/0x190   =20
> set_max_huge_pages+0x164/0x3b0     =20
>=20
> 2.
> prep_new_huge_page+0x5c/0x100            =20
> alloc_fresh_huge_page+0xc8/0x190         =20
> set_max_huge_pages+0x164/0x3b0
>=20
> This patch is to fix such soft lockups. It is safe to call cond_resched()=
=20
> there because it is out of spin_lock/unlock section.
>=20
> Signed-off-by: Jia He <hejianet@gmail.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Mike Kravetz <mike.kravetz@oracle.com>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Paul Gortmaker <paul.gortmaker@windriver.com>

Looks good to me.

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Thanks,
Naoya Horiguchi

>=20
> ---
> Changes in V2: move cond_resched to a common calling site in set_max_huge=
_pages
>=20
>  mm/hugetlb.c | 4 ++++
>  1 file changed, 4 insertions(+)
>=20
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index abc1c5f..9284280 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2216,6 +2216,10 @@ static unsigned long set_max_huge_pages(struct hst=
ate *h, unsigned long count,
>  		 * and reducing the surplus.
>  		 */
>  		spin_unlock(&hugetlb_lock);
> +
> +		/* yield cpu to avoid soft lockup */
> +		cond_resched();
> +
>  		if (hstate_is_gigantic(h))
>  			ret =3D alloc_fresh_gigantic_page(h, nodes_allowed);
>  		else
> --=20
> 2.5.0
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
