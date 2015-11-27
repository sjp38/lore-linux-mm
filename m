Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f176.google.com (mail-io0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id 7396D6B0038
	for <linux-mm@kvack.org>; Fri, 27 Nov 2015 00:29:59 -0500 (EST)
Received: by ioir85 with SMTP id r85so104801386ioi.1
        for <linux-mm@kvack.org>; Thu, 26 Nov 2015 21:29:59 -0800 (PST)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id k8si32622733ioi.12.2015.11.26.21.29.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 Nov 2015 21:29:58 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v3] mm/mmap.c: remove incorrect MAP_FIXED flag
 comparison from mmap_region
Date: Fri, 27 Nov 2015 05:27:39 +0000
Message-ID: <20151127052738.GA25042@hori1.linux.bs1.fc.nec.co.jp>
References: <20151123081946.GA21050@dhcp22.suse.cz>
 <1448300202-5004-1-git-send-email-kwapulinski.piotr@gmail.com>
In-Reply-To: <1448300202-5004-1-git-send-email-kwapulinski.piotr@gmail.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <E96CA5159710A94A92C988D2F9FFFDB6@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
Cc: "mhocko@suse.com" <mhocko@suse.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "oleg@redhat.com" <oleg@redhat.com>, "cmetcalf@ezchip.com" <cmetcalf@ezchip.com>, "mszeredi@suse.cz" <mszeredi@suse.cz>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "dave@stgolabs.net" <dave@stgolabs.net>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "aarcange@redhat.com" <aarcange@redhat.com>, "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>, "jack@suse.cz" <jack@suse.cz>, "xiexiuqi@huawei.com" <xiexiuqi@huawei.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "Vineet.Gupta1@synopsys.com" <Vineet.Gupta1@synopsys.com>, "riel@redhat.com" <riel@redhat.com>, "gang.chen.5i5j@gmail.com" <gang.chen.5i5j@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Nov 23, 2015 at 06:36:42PM +0100, Piotr Kwapulinski wrote:
> The following flag comparison in mmap_region makes no sense:
>=20
> if (!(vm_flags & MAP_FIXED))
>     return -ENOMEM;
>=20
> The condition is always false and thus the above "return -ENOMEM" is neve=
r
> executed. The vm_flags must not be compared with MAP_FIXED flag.
> The vm_flags may only be compared with VM_* flags.
> MAP_FIXED has the same value as VM_MAYREAD.
> Hitting the rlimit is a slow path and find_vma_intersection should realiz=
e
> that there is no overlapping VMA for !MAP_FIXED case pretty quickly.
>=20
> Remove the code that makes no sense.
>=20
> Signed-off-by: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>

Looks good to me. Thank you.

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
>  mm/mmap.c | 3 ---
>  1 file changed, 3 deletions(-)
>=20
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 2ce04a6..42a8259 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1551,9 +1551,6 @@ unsigned long mmap_region(struct file *file, unsign=
ed long addr,
>  		 * MAP_FIXED may remove pages of mappings that intersects with
>  		 * requested mapping. Account for the pages it would unmap.
>  		 */
> -		if (!(vm_flags & MAP_FIXED))
> -			return -ENOMEM;
> -
>  		nr_pages =3D count_vma_pages_range(mm, addr, addr + len);
> =20
>  		if (!may_expand_vm(mm, (len >> PAGE_SHIFT) - nr_pages))
> --=20
> 2.6.2
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
