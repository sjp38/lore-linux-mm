Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f173.google.com (mail-qk0-f173.google.com [209.85.220.173])
	by kanga.kvack.org (Postfix) with ESMTP id D119B6B0255
	for <linux-mm@kvack.org>; Mon, 10 Aug 2015 05:21:58 -0400 (EDT)
Received: by qkbm65 with SMTP id m65so56004025qkb.2
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 02:21:58 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id h184si5985712qhc.21.2015.08.10.02.21.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 10 Aug 2015 02:21:58 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 2/2] mm/hwpoison: fix refcount of THP head page in
 no-injection case
Date: Mon, 10 Aug 2015 09:20:20 +0000
Message-ID: <20150810092020.GB28025@hori1.linux.bs1.fc.nec.co.jp>
References: <1439188351-24292-1-git-send-email-wanpeng.li@hotmail.com>
 <BLU436-SMTP1881EF02196F4DFB4A0882B80700@phx.gbl>
 <20150810083529.GB21282@hori1.linux.bs1.fc.nec.co.jp>
 <BLU436-SMTP3886BA6C827CC74CCF19EB80700@phx.gbl>
 <BLU436-SMTP2382AA11A7E96E3F330B50F80700@phx.gbl>
In-Reply-To: <BLU436-SMTP2382AA11A7E96E3F330B50F80700@phx.gbl>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <5A7E6C0848CAAB46B5D541334679DB88@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <wanpeng.li@hotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, Aug 10, 2015 at 05:06:25PM +0800, Wanpeng Li wrote:
...
> >>>diff --git a/mm/hwpoison-inject.c b/mm/hwpoison-inject.c
> >>>index 5015679..c343a45 100644
> >>>--- a/mm/hwpoison-inject.c
> >>>+++ b/mm/hwpoison-inject.c
> >>>@@ -56,6 +56,8 @@ inject:
> >>>      return memory_failure(pfn, 18, MF_COUNT_INCREASED);
> >>>  put_out:
> >>>      put_page(p);
> >>>+    if (p !=3D hpage)
> >>>+        put_page(hpage);
> >>Yes, we need this when we inject to a thp tail page and "goto put_out"
> >>is
> >>called. But it seems that this code can be called also when injecting
> >>error
> >>to a hugetlb tail page and hwpoison_filter() returns non-zero, which is
> >>not
> >>expected. Unfortunately simply doing like below
> >>
> >>+    if (!PageHuge(p) && p !=3D hpage)
> >>+        put_page(hpage);
> >>
> >>doesn't work, because exisiting put_page(p) can release refcount of
> >>hugetlb
> >>tail page, while get_hwpoison_page() takes refcount of hugetlb head
> >>page.
> >>
> >>So I feel that we need put_hwpoison_page() to properly release the
> >>refcount
> >>taken by memory error handlers.
> >
> >Good point. I think I will continue to do it and will post it out soon. =
:)
>=20
> How about something like this:
>=20
> +void put_hwpoison_page(struct page *page)
> +{
> +       struct page *head =3D compound_head(page);
> +
> +       if (PageHuge(head))
> +               goto put_out;
> +
> +       if (PageTransHuge(head))
> +               if (page !=3D head)
> +                       put_page(head);
> +
> +put_out:
> +       put_page(page);
> +       return;
> +}
> +

Looks good.

> Any comments are welcome, I can update the patch by myself. :)

Most of callsites of put_page() in memory_failure(), soft_offline_page(),
and unpoison_page() can be replaced with put_hwpoison_page().

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
