Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 207346B0253
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 05:18:54 -0400 (EDT)
Received: by pdjr16 with SMTP id r16so2782100pdj.3
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 02:18:53 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id l3si40895794pdp.109.2015.07.29.02.18.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 29 Jul 2015 02:18:53 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] memory_failure: remove redundant check for the
 PG_HWPoison flag of 'hpage'
Date: Wed, 29 Jul 2015 09:17:32 +0000
Message-ID: <20150729091725.GA1256@hori1.linux.bs1.fc.nec.co.jp>
References: <20150729155246.2fed1b96@hp>
In-Reply-To: <20150729155246.2fed1b96@hp>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <2EFB11D90BBD494EB805C635DBD1F4A8@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Xiaoqiang <wangxq10@lzu.edu.cn>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

# CC:ed linux-mm

Hi Xiaoqiang,

On Wed, Jul 29, 2015 at 03:52:46PM +0800, Wang Xiaoqiang wrote:
> Hi,
>=20
> I find a little problem in the memory_failure function in
> mm/memory-failure.c . Please check it.
>=20
> memory_failure: remove redundant check for the PG_HWPoison flag of
> `hpage'.
>=20
> Since we have check the PG_HWPoison flag by `PageHWPoison' before,
> so the later check by `TestSetPageHWPoison' must return true, there
> is no need to check again!

I'm afraid that this TestSetPageHWPoison is not redundant, because this cod=
e
serializes the concurrent memory error events over the same hugetlb page
(, where 'p' indicates the 4kB error page and 'hpage' indicates the head pa=
ge.)

When an error hits a hugetlb page, set_page_hwpoison_huge_page() sets
PageHWPoison flags over all subpages of the hugetlb page in the ascending
order of pfn. So if we don't have this TestSet, memory error handler can
run more than once on concurrent errors when the 1st memory error hits
(for example) the 100th subpage and the 2nd memory error hits (for example)
the 50th subpage.

Thanks,
Naoya Horiguchi

> Signed-off-by: Wang Xiaoqiang <wangxq10@lzu.edu.cn>
> ---
>  mm/memory-failure.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 1cf7f29..7794fd8 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1115,7 +1115,7 @@ int memory_failure(unsigned long pfn, int trapno, i=
nt flags)
>  			lock_page(hpage);
>  			if (PageHWPoison(hpage)) {
>  				if ((hwpoison_filter(p) && TestClearPageHWPoison(p))
> -				    || (p !=3D hpage && TestSetPageHWPoison(hpage))) {
> +				    || p !=3D hpage) {
>  					atomic_long_sub(nr_pages, &num_poisoned_pages);
>  					unlock_page(hpage);
>  					return 0;
> --=20
> 1.7.10.4
>=20
>=20
>=20
> --
> thx!
> Wang Xiaoqiang
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
