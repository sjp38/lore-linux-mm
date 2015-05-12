Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 510916B0038
	for <linux-mm@kvack.org>; Tue, 12 May 2015 05:21:22 -0400 (EDT)
Received: by pdbqd1 with SMTP id qd1so1890340pdb.2
        for <linux-mm@kvack.org>; Tue, 12 May 2015 02:21:22 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id bv5si21690756pdb.125.2015.05.12.02.21.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 12 May 2015 02:21:21 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH] mm/hugetlb: initialize order with UINT_MAX in
 dissolve_free_huge_pages()
Date: Tue, 12 May 2015 09:20:35 +0000
Message-ID: <20150512092034.GF3068@hori1.linux.bs1.fc.nec.co.jp>
References: <20150511111748.GA20660@mwanda>
 <20150511235443.GA8513@hori1.linux.bs1.fc.nec.co.jp>
 <20150512084339.GN16501@mwanda>
 <20150512090454.GD3068@hori1.linux.bs1.fc.nec.co.jp>
 <20150512091349.GO16501@mwanda>
 <20150512091640.GE3068@hori1.linux.bs1.fc.nec.co.jp>
In-Reply-To: <20150512091640.GE3068@hori1.linux.bs1.fc.nec.co.jp>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <E5CAA6C325FD96449FA0FB4F6189A7FD@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

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

So this patch simply avoids the risk by initializing with UINT_MAX.

Fixes: c8721bbbdd36 ("mm: memory-hotplug: enable memory hotplug to handle h=
ugepage")
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/hugetlb.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 271e4432734c..804437505a84 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1188,7 +1188,7 @@ static void dissolve_free_huge_page(struct page *page=
)
  */
 void dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_p=
fn)
 {
-	unsigned int order =3D 8 * sizeof(void *);
+	unsigned int order =3D UINT_MAX;
 	unsigned long pfn;
 	struct hstate *h;
=20
@@ -1200,6 +1200,7 @@ void dissolve_free_huge_pages(unsigned long start_pfn=
, unsigned long end_pfn)
 		if (order > huge_page_order(h))
 			order =3D huge_page_order(h);
 	VM_BUG_ON(!IS_ALIGNED(start_pfn, 1 << order));
+	VM_BUG_ON(order =3D=3D UINT_MAX);
 	for (pfn =3D start_pfn; pfn < end_pfn; pfn +=3D 1 << order)
 		dissolve_free_huge_page(pfn_to_page(pfn));
 }
--=20
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
