Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5DE8C6B0038
	for <linux-mm@kvack.org>; Sun, 22 Jan 2017 23:44:29 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id s36so95067812otd.3
        for <linux-mm@kvack.org>; Sun, 22 Jan 2017 20:44:29 -0800 (PST)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id u7si5528773otb.200.2017.01.22.20.44.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Jan 2017 20:44:28 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [RFC v2] HWPOISON: soft offlining for non-lru movable page
Date: Mon, 23 Jan 2017 04:39:26 +0000
Message-ID: <20170123043926.GB5610@hori1.linux.bs1.fc.nec.co.jp>
References: <1484837943-21745-1-git-send-email-ysxie@foxmail.com>
In-Reply-To: <1484837943-21745-1-git-send-email-ysxie@foxmail.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <533B334538B834448F4F1044562949F2@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "ysxie@foxmail.com" <ysxie@foxmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mhocko@suse.com" <mhocko@suse.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "minchan@kernel.org" <minchan@kernel.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "guohanjun@huawei.com" <guohanjun@huawei.com>, "qiuxishi@huawei.com" <qiuxishi@huawei.com>

On Thu, Jan 19, 2017 at 10:59:03PM +0800, ysxie@foxmail.com wrote:
> From: Yisheng Xie <xieyisheng1@huawei.com>
>=20
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
> Suggested-by: Michal Hocko <mhocko@kernel.org>

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
> v2:
>  delete function soft_offline_movable_page() and hanle non-lru movable
>  page in __soft_offline_page() as Michal Hocko suggested.
>=20
> Any comment is more than welcome.
>=20
>  mm/memory-failure.c | 27 +++++++++++++++------------
>  1 file changed, 15 insertions(+), 12 deletions(-)
>=20
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index f283c7e..74be9e1 100644
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
> @@ -1609,7 +1610,7 @@ static int soft_offline_huge_page(struct page *page=
, int flags)
> =20
>  static int __soft_offline_page(struct page *page, int flags)
>  {
> -	int ret;
> +	int ret =3D -1;
>  	unsigned long pfn =3D page_to_pfn(page);
> =20
>  	/*
> @@ -1619,7 +1620,8 @@ static int __soft_offline_page(struct page *page, i=
nt flags)
>  	 * so there's no race between soft_offline_page() and memory_failure().
>  	 */
>  	lock_page(page);
> -	wait_on_page_writeback(page);
> +	if (PageLRU(page))
> +		wait_on_page_writeback(page);
>  	if (PageHWPoison(page)) {
>  		unlock_page(page);
>  		put_hwpoison_page(page);
> @@ -1630,7 +1632,8 @@ static int __soft_offline_page(struct page *page, i=
nt flags)
>  	 * Try to invalidate first. This should work for
>  	 * non dirty unmapped page cache pages.
>  	 */
> -	ret =3D invalidate_inode_page(page);
> +	if (PageLRU(page))
> +		ret =3D invalidate_inode_page(page);
>  	unlock_page(page);
>  	/*
>  	 * RED-PEN would be better to keep it isolated here, but we
> @@ -1649,7 +1652,10 @@ static int __soft_offline_page(struct page *page, =
int flags)
>  	 * Try to migrate to a new page instead. migrate.c
>  	 * handles a large number of cases for us.
>  	 */
> -	ret =3D isolate_lru_page(page);
> +	if (PageLRU(page))
> +		ret =3D isolate_lru_page(page);
> +	else
> +		ret =3D !isolate_movable_page(page, ISOLATE_UNEVICTABLE);
>  	/*
>  	 * Drop page reference which is came from get_any_page()
>  	 * successful isolate_lru_page() already took another one.
> @@ -1657,18 +1663,15 @@ static int __soft_offline_page(struct page *page,=
 int flags)
>  	put_hwpoison_page(page);
>  	if (!ret) {
>  		LIST_HEAD(pagelist);
> -		inc_node_page_state(page, NR_ISOLATED_ANON +
> +		if (PageLRU(page))
> +			inc_node_page_state(page, NR_ISOLATED_ANON +
>  					page_is_file_cache(page));
>  		list_add(&page->lru, &pagelist);
>  		ret =3D migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
>  					MIGRATE_SYNC, MR_MEMORY_FAILURE);
>  		if (ret) {
> -			if (!list_empty(&pagelist)) {
> -				list_del(&page->lru);
> -				dec_node_page_state(page, NR_ISOLATED_ANON +
> -						page_is_file_cache(page));
> -				putback_lru_page(page);
> -			}
> +			if (!list_empty(&pagelist))
> +				putback_movable_pages(&pagelist);
> =20
>  			pr_info("soft offline: %#lx: migration failed %d, type %lx\n",
>  				pfn, ret, page->flags);
> --=20
> 1.9.1
>=20
>=20
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
