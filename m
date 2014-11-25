Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 448BD6B0038
	for <linux-mm@kvack.org>; Mon, 24 Nov 2014 22:02:37 -0500 (EST)
Received: by mail-pd0-f177.google.com with SMTP id ft15so10943878pdb.22
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 19:02:37 -0800 (PST)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id kn4si24469839pbc.19.2014.11.24.19.02.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 24 Nov 2014 19:02:35 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 01/19] mm, thp: drop FOLL_SPLIT
Date: Tue, 25 Nov 2014 03:01:16 +0000
Message-ID: <20141125030109.GA21716@hori1.linux.bs1.fc.nec.co.jp>
References: <1415198994-15252-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1415198994-15252-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1415198994-15252-2-git-send-email-kirill.shutemov@linux.intel.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <C01FDC8EF842D54697B74E053094DEBA@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, Nov 05, 2014 at 04:49:36PM +0200, Kirill A. Shutemov wrote:
> FOLL_SPLIT is used only in two places: migration and s390.
>=20
> Let's replace it with explicit split and remove FOLL_SPLIT.
>=20
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
...
> @@ -1246,6 +1246,11 @@ static int do_move_page_to_node_array(struct mm_st=
ruct *mm,
>  		if (!page)
>  			goto set_status;
> =20
> +		if (PageTransHuge(page) && split_huge_page(page)) {
> +			err =3D -EBUSY;
> +			goto set_status;
> +		}
> +

This check makes split_huge_page() be called for hugetlb pages, which
triggers BUG_ON. So could you do this after if (PageHuge) block below?
And I think that we have "Node already in the right place" check afterward,
so I hope that moving down this check also helps us reduce thp splitting.

Thanks,
Naoya Horiguchi

>  		/* Use PageReserved to check for zero page */
>  		if (PageReserved(page))
>  			goto put_and_set;=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
