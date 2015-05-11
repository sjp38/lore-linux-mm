Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id 0F5896B0038
	for <linux-mm@kvack.org>; Mon, 11 May 2015 19:55:30 -0400 (EDT)
Received: by oiko83 with SMTP id o83so117831203oik.1
        for <linux-mm@kvack.org>; Mon, 11 May 2015 16:55:29 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id l6si3256786oif.135.2015.05.11.16.55.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 11 May 2015 16:55:29 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: mm: memory-hotplug: enable memory hotplug to handle hugepage
Date: Mon, 11 May 2015 23:54:44 +0000
Message-ID: <20150511235443.GA8513@hori1.linux.bs1.fc.nec.co.jp>
References: <20150511111748.GA20660@mwanda>
In-Reply-To: <20150511111748.GA20660@mwanda>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <81DA28103FBCCF45BE8B9A549816B929@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Mon, May 11, 2015 at 02:17:48PM +0300, Dan Carpenter wrote:
> Hello Naoya Horiguchi,
>=20
> The patch c8721bbbdd36: "mm: memory-hotplug: enable memory hotplug to
> handle hugepage" from Sep 11, 2013, leads to the following static
> checker warning:
>=20
> 	mm/hugetlb.c:1203 dissolve_free_huge_pages()
> 	warn: potential right shift more than type allows '9,18,64'
>=20
> mm/hugetlb.c
>   1189  void dissolve_free_huge_pages(unsigned long start_pfn, unsigned l=
ong end_pfn)
>   1190  {
>   1191          unsigned int order =3D 8 * sizeof(void *);
>                                      ^^^^^^^^^^^^^^^^^^
> Let's say order is 64.

Hi Dan, thank you for reporting.

order is supposed to be capped by running each hstates and finding the
minimum hugepage order as done in below code, and I intended that this
initialization gives potential maximum. I guess that keeping this to 64
doesn't solve the above warning, so we use 8 * sizeof(void *) - 1 or 63 ?
I don't test on 32-bit system, so not sure that this code can be used
by 32-bit system, but considering such case, keeping sizeof(void *)
seems better.

>=20
>   1192          unsigned long pfn;
>   1193          struct hstate *h;
>   1194 =20
>   1195          if (!hugepages_supported())
>   1196                  return;
>   1197 =20
>   1198          /* Set scan step to minimum hugepage size */
>   1199          for_each_hstate(h)
>   1200                  if (order > huge_page_order(h))
>   1201                          order =3D huge_page_order(h);
>   1202          VM_BUG_ON(!IS_ALIGNED(start_pfn, 1 << order));
>   1203          for (pfn =3D start_pfn; pfn < end_pfn; pfn +=3D 1 << orde=
r)
>                                                             ^^^^^^^^^^
> 1 << 64 is undefined but let's say it's zero because that's normal for
> GCC.  This is an endless loop.

That never happens if hstates is properly initialized, but we had better
avoid the potential risk.

How about the following patch?

Thanks,
Naoya Horiguchi
---
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Date: Tue, 12 May 2015 08:17:10 +0900
Subject: [PATCH] mm/hugetlb: decrement initial value of order in
 dissolve_free_huge_pages

Currently the initial value of order in dissolve_free_huge_page is 64 or 32=
,
which leads to the following warning in static checker:

  mm/hugetlb.c:1203 dissolve_free_huge_pages()
  warn: potential right shift more than type allows '9,18,64'

This is a potential risk of infinite loop, because 1 << order (=3D=3D 0) is=
 used
in for-loop like this:

  for (pfn =3D start_pfn; pfn < end_pfn; pfn +=3D 1 << order)
      ...

So this patch simply avoids the risk by decrementing the initial value.

Fixes: c8721bbbdd36 ("mm: memory-hotplug: enable memory hotplug to handle h=
ugepage")
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/hugetlb.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index c41b2a0ee273..74abfb44e4d0 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1086,7 +1086,8 @@ static void dissolve_free_huge_page(struct page *page=
)
  */
 void dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_p=
fn)
 {
-	unsigned int order =3D 8 * sizeof(void *);
+	/* Initialized to "high enough" value which is capped later */
+	unsigned int order =3D 8 * sizeof(void *) - 1;
 	unsigned long pfn;
 	struct hstate *h;
=20
--=20
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
