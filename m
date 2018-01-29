Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id C279C6B0007
	for <linux-mm@kvack.org>; Mon, 29 Jan 2018 01:31:26 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id b187so4375091oih.22
        for <linux-mm@kvack.org>; Sun, 28 Jan 2018 22:31:26 -0800 (PST)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id e82si2440610oia.252.2018.01.28.22.31.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Jan 2018 22:31:25 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v1] mm: hwpoison: disable memory error handling on 1GB
 hugepage
Date: Mon, 29 Jan 2018 06:30:55 +0000
Message-ID: <20180129063054.GA5205@hori1.linux.bs1.fc.nec.co.jp>
References: <1517207283-15769-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1517207283-15769-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <B954D16354476E45AC8A17F7B807C767@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

My apology, I forgot to CC to the mailing lists.

On Mon, Jan 29, 2018 at 03:28:03PM +0900, Naoya Horiguchi wrote:
> Recently the following BUG was reported:
>=20
>     Injecting memory failure for pfn 0x3c0000 at process virtual address =
0x7fe300000000
>     Memory failure: 0x3c0000: recovery action for huge page: Recovered
>     BUG: unable to handle kernel paging request at ffff8dfcc0003000
>     IP: gup_pgd_range+0x1f0/0xc20
>     PGD 17ae72067 P4D 17ae72067 PUD 0
>     Oops: 0000 [#1] SMP PTI
>     ...
>     CPU: 3 PID: 5467 Comm: hugetlb_1gb Not tainted 4.15.0-rc8-mm1-abc+ #3
>     Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.9.3-1.f=
c25 04/01/2014
>=20
> You can easily reproduce this by calling madvise(MADV_HWPOISON) twice on
> a 1GB hugepage. This happens because get_user_pages_fast() is not aware
> of a migration entry on pud that was created in the 1st madvise() event.
>=20
> I think that conversion to pud-aligned migration entry is working,
> but other MM code walking over page table isn't prepared for it.
> We need some time and effort to make all this work properly, so
> this patch avoids the reported bug by just disabling error handling
> for 1GB hugepage.
>=20
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  include/linux/mm.h  | 1 +
>  mm/memory-failure.c | 7 +++++++
>  2 files changed, 8 insertions(+)
>=20
> diff --git v4.15-rc8-mmotm-2018-01-18-16-31/include/linux/mm.h v4.15-rc8-=
mmotm-2018-01-18-16-31_patched/include/linux/mm.h
> index 63f7ba1..166864e 100644
> --- v4.15-rc8-mmotm-2018-01-18-16-31/include/linux/mm.h
> +++ v4.15-rc8-mmotm-2018-01-18-16-31_patched/include/linux/mm.h
> @@ -2607,6 +2607,7 @@ enum mf_action_page_type {
>  	MF_MSG_POISONED_HUGE,
>  	MF_MSG_HUGE,
>  	MF_MSG_FREE_HUGE,
> +	MF_MSG_GIGANTIC,
>  	MF_MSG_UNMAP_FAILED,
>  	MF_MSG_DIRTY_SWAPCACHE,
>  	MF_MSG_CLEAN_SWAPCACHE,
> diff --git v4.15-rc8-mmotm-2018-01-18-16-31/mm/memory-failure.c v4.15-rc8=
-mmotm-2018-01-18-16-31_patched/mm/memory-failure.c
> index d530ac1..c497588 100644
> --- v4.15-rc8-mmotm-2018-01-18-16-31/mm/memory-failure.c
> +++ v4.15-rc8-mmotm-2018-01-18-16-31_patched/mm/memory-failure.c
> @@ -508,6 +508,7 @@ static const char * const action_page_types[] =3D {
>  	[MF_MSG_POISONED_HUGE]		=3D "huge page already hardware poisoned",
>  	[MF_MSG_HUGE]			=3D "huge page",
>  	[MF_MSG_FREE_HUGE]		=3D "free huge page",
> +	[MF_MSG_GIGANTIC]		=3D "gigantic page",
>  	[MF_MSG_UNMAP_FAILED]		=3D "unmapping failed page",
>  	[MF_MSG_DIRTY_SWAPCACHE]	=3D "dirty swapcache page",
>  	[MF_MSG_CLEAN_SWAPCACHE]	=3D "clean swapcache page",
> @@ -1090,6 +1091,12 @@ static int memory_failure_hugetlb(unsigned long pf=
n, int trapno, int flags)
>  		return 0;
>  	}
> =20
> +	if (hstate_is_gigantic(page_hstate(head))) {
> +		action_result(pfn, MF_MSG_GIGANTIC, MF_IGNORED);
> +		res =3D -EBUSY;
> +		goto out;
> +	}
> +
>  	if (!hwpoison_user_mappings(p, pfn, trapno, flags, &head)) {
>  		action_result(pfn, MF_MSG_UNMAP_FAILED, MF_IGNORED);
>  		res =3D -EBUSY;
> --=20
> 2.7.0
>=20
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
