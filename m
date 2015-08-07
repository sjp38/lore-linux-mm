Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id 932306B0254
	for <linux-mm@kvack.org>; Fri,  7 Aug 2015 03:50:16 -0400 (EDT)
Received: by qgj62 with SMTP id 62so44527578qgj.2
        for <linux-mm@kvack.org>; Fri, 07 Aug 2015 00:50:16 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id z81si16479431qkz.128.2015.08.07.00.50.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 07 Aug 2015 00:50:15 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm/hwpoison: fix page refcount of unkown non LRU page
Date: Fri, 7 Aug 2015 07:46:13 +0000
Message-ID: <20150807074612.GA8014@hori1.linux.bs1.fc.nec.co.jp>
References: <BLU436-SMTP128848C012F916D3DFC86B80740@phx.gbl>
In-Reply-To: <BLU436-SMTP128848C012F916D3DFC86B80740@phx.gbl>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <705AE040ABD8B04C9959EE9CE33FFDD6@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <wanpeng.li@hotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Tony Luck <tony.luck@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Aug 06, 2015 at 04:09:37PM +0800, Wanpeng Li wrote:
> After try to drain pages from pagevec/pageset, we try to get reference
> count of the page again, however, the reference count of the page is=20
> not reduced if the page is still not on LRU list. This patch fix it by=20
> adding the put_page() to drop the page reference which is from=20
> __get_any_page().
>=20
> Signed-off-by: Wanpeng Li <wanpeng.li@hotmail.com>=20

This fix is correct. Thanks you for catching this, Wanpeng!

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

BTW, I think this patch is worth sending to stable tree. It seems that
the latest change around this code is given by the following commit:

  commit af8fae7c08862bb85c5cf445bf9b36314b82111f
  Author: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
  Date:   Fri Feb 22 16:34:03 2013 -0800
 =20
      mm/memory-failure.c: clean up soft_offline_page()

. I think that this bug existed before this commit, but this patch is
cleanly applicable only after this patch, so I think tagging
"Cc: stable@vger.kernel.org # 3.9+" is good.

Thanks,
Naoya Horiguchi

> ---
>  mm/memory-failure.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
>=20
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index c53543d..23163d0 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1535,6 +1535,8 @@ static int get_any_page(struct page *page, unsigned=
 long pfn, int flags)
>  		 */
>  		ret =3D __get_any_page(page, pfn, 0);
>  		if (!PageLRU(page)) {
> +			/* Drop page reference which is from __get_any_page() */
> +			put_page(page);
>  			pr_info("soft_offline: %#lx: unknown non LRU page type %lx\n",
>  				pfn, page->flags);
>  			return -EIO;
> --=20
> 1.7.1
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
