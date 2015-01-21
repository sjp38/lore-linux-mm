Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 46C2D6B0032
	for <linux-mm@kvack.org>; Wed, 21 Jan 2015 01:33:31 -0500 (EST)
Received: by mail-ob0-f176.google.com with SMTP id va2so14439091obc.7
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 22:33:31 -0800 (PST)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id rn3si8873517oeb.1.2015.01.20.22.33.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 20 Jan 2015 22:33:29 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm: pagewalk: call pte_hole() for VM_PFNMAP during
 walk_page_range
Date: Wed, 21 Jan 2015 06:30:53 +0000
Message-ID: <20150121063043.GA18835@hori1.linux.bs1.fc.nec.co.jp>
References: <1421820793-28883-1-git-send-email-shashim@codeaurora.org>
In-Reply-To: <1421820793-28883-1-git-send-email-shashim@codeaurora.org>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <66994E9CC2CE2C44A2D781CCB81E89BF@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shiraz Hashim <shashim@codeaurora.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "oleg@redhat.com" <oleg@redhat.com>, "gorcunov@openvz.org" <gorcunov@openvz.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Jan 21, 2015 at 11:43:13AM +0530, Shiraz Hashim wrote:
> walk_page_range silently skips vma having VM_PFNMAP set,
> which leads to undesirable behaviour at client end (who
> called walk_page_range). For example for pagemap_read,
> when no callbacks are called against VM_PFNMAP vma,
> pagemap_read may prepare pagemap data for next virtual
> address range at wrong index.
>=20
> Signed-off-by: Shiraz Hashim <shashim@codeaurora.org>

Thank you!

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
> The fix is revised, based upon the suggestion here at
> http://www.spinics.net/lists/linux-mm/msg83058.html
>=20
>  mm/pagewalk.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
>=20
> diff --git a/mm/pagewalk.c b/mm/pagewalk.c
> index ad83195..b264bda 100644
> --- a/mm/pagewalk.c
> +++ b/mm/pagewalk.c
> @@ -199,7 +199,10 @@ int walk_page_range(unsigned long addr, unsigned lon=
g end,
>  			 */
>  			if ((vma->vm_start <=3D addr) &&
>  			    (vma->vm_flags & VM_PFNMAP)) {
> -				next =3D vma->vm_end;
> +				if (walk->pte_hole)
> +					err =3D walk->pte_hole(addr, next, walk);
> +				if (err)
> +					break;
>  				pgd =3D pgd_offset(walk->mm, next);
>  				continue;
>  			}
> --=20
> Shiraz Hashim
>=20
> QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
> member of the Code Aurora Forum, hosted by The Linux Foundation
>=20
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
