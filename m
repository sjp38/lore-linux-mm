Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6538C6B0038
	for <linux-mm@kvack.org>; Tue, 12 Sep 2017 20:13:59 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id r20so10265786oie.0
        for <linux-mm@kvack.org>; Tue, 12 Sep 2017 17:13:59 -0700 (PDT)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id a89si7894394oic.126.2017.09.12.17.13.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Sep 2017 17:13:58 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm, hugetlb, soft_offline: save compound page order
 before page migration
Date: Wed, 13 Sep 2017 00:13:09 +0000
Message-ID: <20170913001308.GA13642@hori1.linux.bs1.fc.nec.co.jp>
References: <20170912204306.GA12053@gmail.com>
In-Reply-To: <20170912204306.GA12053@gmail.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <9C528A433BCBDD418B9E6A0E73956283@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexandru Moise <00moses.alexander00@gmail.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "khandual@linux.vnet.ibm.com" <khandual@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mhocko@suse.com" <mhocko@suse.com>, "aarcange@redhat.com" <aarcange@redhat.com>, "minchan@kernel.org" <minchan@kernel.org>, "hillf.zj@alibaba-inc.com" <hillf.zj@alibaba-inc.com>, "shli@fb.com" <shli@fb.com>, "rppt@linux.vnet.ibm.com" <rppt@linux.vnet.ibm.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "rientjes@google.com" <rientjes@google.com>, "riel@redhat.com" <riel@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi Alexandru,

On Tue, Sep 12, 2017 at 10:43:06PM +0200, Alexandru Moise wrote:
> This fixes a bug in madvise() where if you'd try to soft offline a
> hugepage via madvise(), while walking the address range you'd end up,
> using the wrong page offset due to attempting to get the compound
> order of a former but presently not compound page, due to dissolving
> the huge page (since c3114a8).
>=20
> Signed-off-by: Alexandru Moise <00moses.alexander00@gmail.com>

There was a similar discussion in https://marc.info/?l=3Dlinux-kernel&m=3D1=
50354919510631&w=3D2
over thp. As I stated there, if we give multi-page range into the parameter=
s
[start, end), we expect that memory errors are injected to every single pag=
e
within the range.=20

So I start to feel that we should revert the following patch which introduc=
ed
the multi-page stepping.

   commit 20cb6cab52a21b46e3c0dc7bd23f004f810fb421
   Author: Wanpeng Li <liwanp@linux.vnet.ibm.com>
   Date:   Mon Sep 30 13:45:21 2013 -0700
  =20
       mm/hwpoison: fix traversal of hugetlbfs pages to avoid printk flood

In order to suppress the printk flood, we can use ratelimit mechanism, or
just s/pr_info/pr_debug/ might be ok.

Thanks,
Naoya Horiguchi

> ---
>  mm/madvise.c | 12 ++++++++++--
>  1 file changed, 10 insertions(+), 2 deletions(-)
>=20
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 21261ff0466f..25bade36e9ca 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -625,18 +625,26 @@ static int madvise_inject_error(int behavior,
>  {
>  	struct page *page;
>  	struct zone *zone;
> +	unsigned int order;
> =20
>  	if (!capable(CAP_SYS_ADMIN))
>  		return -EPERM;
> =20
> -	for (; start < end; start +=3D PAGE_SIZE <<
> -				compound_order(compound_head(page))) {
> +
> +	for (; start < end; start +=3D PAGE_SIZE << order) {
>  		int ret;
> =20
>  		ret =3D get_user_pages_fast(start, 1, 0, &page);
>  		if (ret !=3D 1)
>  			return ret;
> =20
> +		/*
> +		 * When soft offlining hugepages, after migrating the page
> +		 * we dissolve it, therefore in the second loop "page" will
> +		 * no longer be a compound page, and order will be 0.
> +		 */
> +		order =3D compound_order(compound_head(page));
> +
>  		if (PageHWPoison(page)) {
>  			put_page(page);
>  			continue;
> --=20
> 2.14.1
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
