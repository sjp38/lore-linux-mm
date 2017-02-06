Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5D0176B0033
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 01:17:14 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id s36so73885198otd.3
        for <linux-mm@kvack.org>; Sun, 05 Feb 2017 22:17:14 -0800 (PST)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id x66si13798937oia.49.2017.02.05.22.17.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 05 Feb 2017 22:17:13 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v3 01/14] mm: thp: make __split_huge_pmd_locked visible.
Date: Mon, 6 Feb 2017 06:12:33 +0000
Message-ID: <20170206061232.GB1659@hori1.linux.bs1.fc.nec.co.jp>
References: <20170205161252.85004-1-zi.yan@sent.com>
 <20170205161252.85004-2-zi.yan@sent.com>
In-Reply-To: <20170205161252.85004-2-zi.yan@sent.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <8C0CFCE161D53349A854029A7AC4E8C4@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@sent.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "minchan@kernel.org" <minchan@kernel.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "khandual@linux.vnet.ibm.com" <khandual@linux.vnet.ibm.com>, "zi.yan@cs.rutgers.edu" <zi.yan@cs.rutgers.edu>, Zi Yan <ziy@nvidia.com>

On Sun, Feb 05, 2017 at 11:12:39AM -0500, Zi Yan wrote:
> From: Zi Yan <ziy@nvidia.com>
>=20
> It allows splitting huge pmd while you are holding the pmd lock.
> It is prepared for future zap_pmd_range() use.
>=20
> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
> ---
>  include/linux/huge_mm.h |  2 ++
>  mm/huge_memory.c        | 22 ++++++++++++----------
>  2 files changed, 14 insertions(+), 10 deletions(-)
>=20
...
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 03e4566fc226..cd66532ef667 100644
...
> @@ -2036,10 +2039,9 @@ void __split_huge_pmd(struct vm_area_struct *vma, =
pmd_t *pmd,
>  			clear_page_mlock(page);
>  	} else if (!pmd_devmap(*pmd))
>  		goto out;
> -	__split_huge_pmd_locked(vma, pmd, haddr, freeze);
> +	__split_huge_pmd_locked(vma, pmd, address, freeze);

Could you explain what is intended on this change?
If some caller (f.e. wp_huge_pmd?) could call __split_huge_pmd() with
address not aligned with pmd border, __split_huge_pmd_locked() results in
triggering VM_BUG_ON(haddr & ~HPAGE_PMD_MASK).

Thanks,
Naoya Horiguchi

>  out:
>  	spin_unlock(ptl);
> -	mmu_notifier_invalidate_range_end(mm, haddr, haddr + HPAGE_PMD_SIZE);
>  }
> =20
>  void split_huge_pmd_address(struct vm_area_struct *vma, unsigned long ad=
dress,
> --=20
> 2.11.0
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
