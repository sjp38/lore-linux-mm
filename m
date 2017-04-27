Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id BF37F6B033C
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 01:55:29 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id q66so17954678pfi.16
        for <linux-mm@kvack.org>; Wed, 26 Apr 2017 22:55:29 -0700 (PDT)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id z33si1589848plb.36.2017.04.26.22.55.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Apr 2017 22:55:28 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: Freeing HugeTLB page into buddy allocator
Date: Thu, 27 Apr 2017 05:54:58 +0000
Message-ID: <20170427055457.GA19344@hori1.linux.bs1.fc.nec.co.jp>
References: <4f609205-fb69-4af5-3235-3abf05aa822a@linux.vnet.ibm.com>
In-Reply-To: <4f609205-fb69-4af5-3235-3abf05aa822a@linux.vnet.ibm.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <185102A7C1CDE845923101F43FED5971@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: "wujianguo@huawei.com" <wujianguo@huawei.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Apr 25, 2017 at 02:27:27PM +0530, Anshuman Khandual wrote:
> Hello Jianguo,
>=20
> In the commit a49ecbcd7b0d5a1cda, it talks about HugeTLB page being
> freed into buddy allocator instead of hugepage_freelists. But if
> I look the code closely for the function unmap_and_move_huge_page()
> it only calls putback_active_hugepage() which puts the page into the
> huge page active list to free up the source HugeTLB page after any
> successful migration. I might be missing something here, so can you
> please point me where we release the HugeTLB page into buddy allocator
> directly during migration ?

Hi Anshuman,

As stated in the patch description, source hugetlb page is freed after
successful migration if overcommit is configured.

The call chain is like below:

  soft_offline_huge_page
    migrate_pages
      unmap_and_move_huge_page
        putback_active_hugepage(hpage)
          put_page // refcount is down to 0
            __put_page
              __put_compound_page
                free_huge_page
                  if (h->surplus_huge_pages_node[nid])
                    update_and_free_page
                      __free_pages

So the inline comment

+		/* overcommit hugetlb page will be freed to buddy */

might be confusing because at this point the overcommit hugetlb page was
already freed to buddy.

I hope this will help you.

Thanks,
Naoya Horiguchi

>=20
>=20
> commit a49ecbcd7b0d5a1cda7d60e03df402dd0ef76ac8
> Author: Jianguo Wu <wujianguo@huawei.com>
> Date:   Wed Dec 18 17:08:54 2013 -0800
>=20
>     mm/memory-failure.c: recheck PageHuge() after hugetlb page migrate su=
ccessfully
>    =20
>     After a successful hugetlb page migration by soft offline, the source
>     page will either be freed into hugepage_freelists or buddy(over-commi=
t
>     page).  If page is in buddy, page_hstate(page) will be NULL.  It will
>     hit a NULL pointer dereference in dequeue_hwpoisoned_huge_page().
>    =20
>       BUG: unable to handle kernel NULL pointer dereference at 0000000000=
000058
>       IP: [<ffffffff81163761>] dequeue_hwpoisoned_huge_page+0x131/0x1d0
>       PGD c23762067 PUD c24be2067 PMD 0
>       Oops: 0000 [#1] SMP
>    =20
>     So check PageHuge(page) after call migrate_pages() successfully.
>    =20
>     Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
>     Tested-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>     Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>     Cc: <stable@vger.kernel.org>
>     Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>     Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
>=20
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index b7c1716..db08af9 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1505,10 +1505,16 @@ static int soft_offline_huge_page(struct page *pa=
ge, int flags)
>  		if (ret > 0)
>  			ret =3D -EIO;
>  	} else {
> -		set_page_hwpoison_huge_page(hpage);
> -		dequeue_hwpoisoned_huge_page(hpage);
> -		atomic_long_add(1 << compound_order(hpage),
> -				&num_poisoned_pages);
> +		/* overcommit hugetlb page will be freed to buddy */
> +		if (PageHuge(page)) {
> +			set_page_hwpoison_huge_page(hpage);
> +			dequeue_hwpoisoned_huge_page(hpage);
> +			atomic_long_add(1 << compound_order(hpage),
> +					&num_poisoned_pages);
> +		} else {
> +			SetPageHWPoison(page);
> +			atomic_long_inc(&num_poisoned_pages);
> +		}
>  	}
>  	return ret;
>  }
>=20
> Regards
> Anshuman
>=20
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
