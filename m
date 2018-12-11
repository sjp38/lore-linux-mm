Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 223CF8E0095
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 09:32:44 -0500 (EST)
Received: by mail-io1-f69.google.com with SMTP id y25so1029611ioc.9
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 06:32:44 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id x7si7643873iof.117.2018.12.11.06.32.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 06:32:42 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH 2/2] swap: Deal with PTE mapped THP when unuse PTE
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20181211084609.19553-2-ying.huang@intel.com>
Date: Tue, 11 Dec 2018 07:32:07 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <77D903B4-E63F-4633-8D5B-C39EFC067FB8@oracle.com>
References: <20181211084609.19553-1-ying.huang@intel.com>
 <20181211084609.19553-2-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huang Ying <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vineeth Remanan Pillai <vpillai@digitalocean.com>, Kelley Nielsen <kelleynnn@gmail.com>, Rik van Riel <riel@surriel.com>, Matthew Wilcox <willy@infradead.org>, Hugh Dickins <hughd@google.com>



> ---
> mm/swapfile.c | 4 +---
> 1 file changed, 1 insertion(+), 3 deletions(-)
>=20
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 7464d0a92869..9e6da494781f 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -1921,10 +1921,8 @@ static int unuse_pte_range(struct =
vm_area_struct *vma, pmd_t *pmd,
> 			goto out;
> 		}
>=20
> -		if (PageSwapCache(page) && (swap_count(*swap_map) =3D=3D =
0))
> -			delete_from_swap_cache(compound_head(page));
> +		try_to_free_swap(page);
>=20
> -		SetPageDirty(page);
> 		unlock_page(page);
> 		put_page(page);
>=20
> --=20
> 2.18.1
>=20

Since try_to_free_swap() can return 0 under certain error conditions, =
you should check
check for a return status of 1 before calling unlock_page() and =
put_page().

Reviewed-by: William Kucharski <william.kucharski@oracle.com>=
