Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id BC9B96B0038
	for <linux-mm@kvack.org>; Wed, 19 Nov 2014 02:02:14 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id r10so749910pdi.27
        for <linux-mm@kvack.org>; Tue, 18 Nov 2014 23:02:14 -0800 (PST)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id ov7si1311303pbb.81.2014.11.18.23.02.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 18 Nov 2014 23:02:13 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 10/19] thp: PMD splitting without splitting compound page
Date: Wed, 19 Nov 2014 06:57:47 +0000
Message-ID: <20141119065823.GA16887@hori1.linux.bs1.fc.nec.co.jp>
References: <1415198994-15252-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1415198994-15252-11-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1415198994-15252-11-git-send-email-kirill.shutemov@linux.intel.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <A2F1A9975D855846A367C9484925D0C7@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, Nov 05, 2014 at 04:49:45PM +0200, Kirill A. Shutemov wrote:
> Current split_huge_page() combines two operations: splitting PMDs into
> tables of PTEs and splitting underlying compound page. This patch
> changes split_huge_pmd() implementation to split the given PMD without
> splitting other PMDs this page mapped with or underlying compound page.
>=20
> In order to do this we have to get rid of tail page refcounting, which
> uses _mapcount of tail pages. Tail page refcounting is needed to be able
> to split THP page at any point: we always know which of tail pages is
> pinned (i.e. by get_user_pages()) and can distribute page count
> correctly.
>=20
> We can avoid this by allowing split_huge_page() to fail if the compound
> page is pinned. This patch removes all infrastructure for tail page
> refcounting and make split_huge_page() to always return -EBUSY. All
> split_huge_page() users already know how to handle its fail. Proper
> implementation will be added later.
>=20
> Without tail page refcounting, implementation of split_huge_pmd() is
> pretty straight-forward.
>=20
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
...

> diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.=
c
> index 7e70ae968e5f..e4ba17694b6b 100644
> --- a/arch/powerpc/mm/hugetlbpage.c
> +++ b/arch/powerpc/mm/hugetlbpage.c
> @@ -1022,7 +1022,6 @@ int gup_hugepte(pte_t *ptep, unsigned long sz, unsi=
gned long addr,
>  {
>  	unsigned long mask;
>  	unsigned long pte_end;
> -	struct page *head, *page, *tail;
>  	pte_t pte;
>  	int refs;
> =20

This breaks build of powerpc, so you need keep *head and *page as
you do for other architectures.=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
