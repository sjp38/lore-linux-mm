Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id AFA326B0260
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 04:46:15 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id f9so4205715otd.4
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 01:46:15 -0800 (PST)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id v187si11138195oif.296.2017.01.18.01.46.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jan 2017 01:46:14 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [RFC] HWPOISON: soft offlining for non-lru movable page
Date: Wed, 18 Jan 2017 09:45:31 +0000
Message-ID: <20170118094530.GA29579@hori1.linux.bs1.fc.nec.co.jp>
References: <1484712054-7997-1-git-send-email-xieyisheng1@huawei.com>
In-Reply-To: <1484712054-7997-1-git-send-email-xieyisheng1@huawei.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <44BE79BA9E6D6841B82AFFE2B547127A@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <xieyisheng1@huawei.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mhocko@suse.com" <mhocko@suse.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "minchan@kernel.org" <minchan@kernel.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "guohanjun@huawei.com" <guohanjun@huawei.com>, "qiuxishi@huawei.com" <qiuxishi@huawei.com>

On Wed, Jan 18, 2017 at 12:00:54PM +0800, Yisheng Xie wrote:
> This patch is to extends soft offlining framework to support
> non-lru page, which already support migration after
> commit bda807d44454 ("mm: migrate: support non-lru movable page
> migration")
>=20
> When memory corrected errors occur on a non-lru movable page,
> we can choose to stop using it by migrating data onto another
> page and disable the original (maybe half-broken) one.
>=20
> Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>

It looks OK in my quick glance. I'll do some testing more tomorrow.

Thanks,
Naoya Horiguchi

> ---
>  mm/memory-failure.c | 55 +++++++++++++++++++++++++++++++++++++++++++++++=
++++--
>  1 file changed, 53 insertions(+), 2 deletions(-)
>=20
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index f283c7e..10043a4 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1527,7 +1527,8 @@ static int get_any_page(struct page *page, unsigned=
 long pfn, int flags)
>  {
>  	int ret =3D __get_any_page(page, pfn, flags);
> =20
> -	if (ret =3D=3D 1 && !PageHuge(page) && !PageLRU(page)) {
> +	if (ret =3D=3D 1 && !PageHuge(page) &&
> +	    !PageLRU(page) && !__PageMovable(page)) {
>  		/*
>  		 * Try to free it.
>  		 */
> @@ -1549,6 +1550,54 @@ static int get_any_page(struct page *page, unsigne=
d long pfn, int flags)
>  	return ret;
>  }
> =20
> +static int soft_offline_movable_page(struct page *page, int flags)
> +{
> +	int ret;
> +	unsigned long pfn =3D page_to_pfn(page);
> +	LIST_HEAD(pagelist);
> +
> +	/*
> +	 * This double-check of PageHWPoison is to avoid the race with
> +	 * memory_failure(). See also comment in __soft_offline_page().
> +	 */
> +	lock_page(page);
> +	if (PageHWPoison(page)) {
> +		unlock_page(page);
> +		put_hwpoison_page(page);
> +		pr_info("soft offline: %#lx movable page already poisoned\n",
> +			pfn);
> +		return -EBUSY;
> +	}
> +	unlock_page(page);
> +
> +	ret =3D isolate_movable_page(page, ISOLATE_UNEVICTABLE);
> +	/*
> +	 * get_any_page() and isolate_movable_page() takes a refcount each,
> +	 * so need to drop one here.
> +	 */
> +	put_hwpoison_page(page);
> +	if (!ret) {
> +		pr_info("soft offline: %#lx movable page failed to isolate\n",
> +			pfn);
> +		return -EBUSY;
> +	}
> +
> +	list_add(&page->lru, &pagelist);
> +	ret =3D migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
> +			    MIGRATE_SYNC, MR_MEMORY_FAILURE);
> +	if (ret) {
> +		if (!list_empty(&pagelist))
> +			putback_movable_pages(&pagelist);
> +
> +		pr_info("soft offline: %#lx: migration failed %d, type %lx\n",
> +			pfn, ret, page->flags);
> +		if (ret > 0)
> +			ret =3D -EIO;
> +	}
> +
> +	return ret;
> +}
> +
>  static int soft_offline_huge_page(struct page *page, int flags)
>  {
>  	int ret;
> @@ -1705,8 +1754,10 @@ static int soft_offline_in_use_page(struct page *p=
age, int flags)
> =20
>  	if (PageHuge(page))
>  		ret =3D soft_offline_huge_page(page, flags);
> -	else
> +	else if (PageLRU(page))
>  		ret =3D __soft_offline_page(page, flags);
> +	else
> +		ret =3D soft_offline_movable_page(page, flags);
> =20
>  	return ret;
>  }
> --=20
> 1.7.12.4
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
