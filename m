Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id E7CDF828DF
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 03:17:34 -0500 (EST)
Received: by mail-ig0-f172.google.com with SMTP id z14so145439962igp.1
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 00:17:34 -0800 (PST)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id n1si3235848igv.86.2016.01.13.00.17.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Jan 2016 00:17:34 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH V2] mm: mempolicy: skip non-migratable VMAs when setting
 MPOL_MF_LAZY
Date: Wed, 13 Jan 2016 08:16:12 +0000
Message-ID: <20160113081611.GA29313@hori1.linux.bs1.fc.nec.co.jp>
References: <1452138758-30031-1-git-send-email-liangchen.linux@gmail.com>
In-Reply-To: <1452138758-30031-1-git-send-email-liangchen.linux@gmail.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <483ADF7CCFA3D747870627E79CC6B656@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Liang Chen <liangchen.linux@gmail.com>
Cc: "riel@redhat.com" <riel@redhat.com>, "mgorman@suse.de" <mgorman@suse.de>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Gavin Guo <gavin.guo@canonical.com>

Hello Liang,

On Thu, Jan 07, 2016 at 11:52:38AM +0800, Liang Chen wrote:
> MPOL_MF_LAZY is not visible from userspace since 'commit a720094ded8c
> ("mm: mempolicy: Hide MPOL_NOOP and MPOL_MF_LAZY from userspace for now")=
'
> , but it should still skip non-migratable VMAs such as VM_IO, VM_PFNMAP,
> and VM_HUGETLB VMAs, and avoid useless overhead of minor faults.
>=20
> Signed-off-by: Liang Chen <liangchen.linux@gmail.com>
> Signed-off-by: Gavin Guo <gavin.guo@canonical.com>
> ---
> Changes since v2:
> - Add more description into the changelog
>=20
> We have been evaluating the enablement of MPOL_MF_LAZY again, and found
> this issue. And we decided to push this patch upstream no matter if we
> finally determine to propose re-enablement of MPOL_MF_LAZY or not. Since
> it can be a potential problem even if MPOL_MF_LAZY is not enabled this
> time.
> ---
>  mm/mempolicy.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>=20
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 87a1779..436ff411 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -610,7 +610,8 @@ static int queue_pages_test_walk(unsigned long start,=
 unsigned long end,
> =20
>  	if (flags & MPOL_MF_LAZY) {
>  		/* Similar to task_numa_work, skip inaccessible VMAs */
> -		if (vma->vm_flags & (VM_READ | VM_EXEC | VM_WRITE))
> +		if (vma_migratable(vma) &&
> +			vma->vm_flags & (VM_READ | VM_EXEC | VM_WRITE))
>  			change_prot_numa(vma, start, endvma);
>  		return 1;
>  	}

task_numa_work() does more vma checks before entering change_prot_numa() li=
ke
vma_policy_mof(), is_vm_hugetlb_page(), and (vma->vm_flags & VM_MIXEDMAP).
So is it better to use the same check set to limit the target vmas to auto-=
numa
enabled ones?

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
