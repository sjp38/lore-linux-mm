Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id DCACB6B007E
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 22:25:43 -0400 (EDT)
Received: by mail-pf0-f173.google.com with SMTP id e128so36187957pfe.3
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 19:25:43 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id h7si10505049pat.9.2016.03.30.19.25.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 30 Mar 2016 19:25:43 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [RFC PATCH 1/2] mm/hugetlbfs: Attempt PUD_SIZE mapping
 alignment if PMD sharing enabled
Date: Thu, 31 Mar 2016 02:18:51 +0000
Message-ID: <20160331021850.GA4079@hori1.linux.bs1.fc.nec.co.jp>
References: <1459213970-17957-1-git-send-email-mike.kravetz@oracle.com>
 <1459213970-17957-2-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1459213970-17957-2-git-send-email-mike.kravetz@oracle.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <CB4D9524F302A3448DE2061321C84918@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, Hugh Dickins <hughd@google.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Steve Capper <steve.capper@linaro.org>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Mar 28, 2016 at 06:12:49PM -0700, Mike Kravetz wrote:
> When creating a hugetlb mapping, attempt PUD_SIZE alignment if the
> following conditions are met:
> - Address passed to mmap or shmat is NULL
> - The mapping is flaged as shared
> - The mapping is at least PUD_SIZE in length
> If a PUD_SIZE aligned mapping can not be created, then fall back to a
> huge page size mapping.

It would be kinder if the patch description includes why this change.
Simply "to facilitate pmd sharing" is helpful for someone who read
"git log".

>=20
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> ---
>  fs/hugetlbfs/inode.c | 29 +++++++++++++++++++++++++++--
>  1 file changed, 27 insertions(+), 2 deletions(-)
>=20
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index 540ddc9..22b2e38 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -175,6 +175,17 @@ hugetlb_get_unmapped_area(struct file *file, unsigne=
d long addr,
>  	struct vm_area_struct *vma;
>  	struct hstate *h =3D hstate_file(file);
>  	struct vm_unmapped_area_info info;
> +	bool pud_size_align =3D false;
> +	unsigned long ret_addr;
> +
> +	/*
> +	 * If PMD sharing is enabled, align to PUD_SIZE to facilitate
> +	 * sharing.  Only attempt alignment if no address was passed in,
> +	 * flags indicate sharing and size is big enough.
> +	 */
> +	if (IS_ENABLED(CONFIG_ARCH_WANT_HUGE_PMD_SHARE) &&
> +	    !addr && flags & MAP_SHARED && len >=3D PUD_SIZE)
> +		pud_size_align =3D true;

This code will have duplicates in the next patch, so how about checking
this in a separate check routine?

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
