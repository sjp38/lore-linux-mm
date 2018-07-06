Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 401E16B0271
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 04:19:07 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id f9-v6so5583341pfn.22
        for <linux-mm@kvack.org>; Fri, 06 Jul 2018 01:19:07 -0700 (PDT)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id a10-v6si7827441pli.122.2018.07.06.01.19.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jul 2018 01:19:06 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [RFC] a question about reuse hwpoison page in
 soft_offline_page()
Date: Fri, 6 Jul 2018 08:18:47 +0000
Message-ID: <20180706081847.GA5144@hori1.linux.bs1.fc.nec.co.jp>
References: <99235479-716d-4c40-8f61-8e44c242abf8.xishi.qiuxishi@alibaba-inc.com>
In-Reply-To: <99235479-716d-4c40-8f61-8e44c242abf8.xishi.qiuxishi@alibaba-inc.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <419F96D9D966E6498748381491C4F00A@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?iso-2022-jp?B?GyRCamQ1KUBQGyhCKBskQjUpQFAbKEIp?= <xishi.qiuxishi@alibaba-inc.com>
Cc: linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, "zy.zhengyi" <zy.zhengyi@alibaba-inc.com>

On Fri, Jul 06, 2018 at 11:37:41AM +0800, =1B$Bjd5)@P=1B(B(=1B$B5)@P=1B(B) =
wrote:
> This patch add05cec
> (mm: soft-offline: don't free target page in successful page migration) r=
emoves
> set_migratetype_isolate() and unset_migratetype_isolate() in soft_offline=
_page
> ().
>=20
> And this patch 243abd5b
> (mm: hugetlb: prevent reuse of hwpoisoned free hugepages) changes
> if (!is_migrate_isolate_page(page)) to if (!PageHWPoison(page)), so it co=
uld
> prevent someone
> reuse the free hugetlb again after set the hwpoison flag
> in soft_offline_free_page()
>=20
> My question is that if someone reuse the free hugetlb again before=20
> soft_offline_free_page() and
> after get_any_page(), then it uses the hopoison page, and this may trigge=
r mce
> kill later, right?

Hi Xishi,

Thank you for pointing out the issue. That's nice catch.

I think that the race condition itself could happen, but it doesn't lead
to MCE kill because PageHWPoison is not visible to HW which triggers MCE.
PageHWPoison flag is just a flag in struct page to report the memory error
from kernel to userspace. So even if a CPU is accessing to the page whose
struct page has PageHWPoison set, that doesn't cause a MCE unless the page
is physically broken.
The type of memory error that soft offline tries to handle is corrected
one which is not a failure yet although it's starting to wear.
So such PageHWPoison page can be reused, but that's not critical because
the page is freed at some point afterword and error containment completes.

However, I noticed that there's a small pain in free hugetlb case.
We call dissolve_free_huge_page() in soft_offline_free_page() which moves
the PageHWPoison flag from the head page to the raw error page.
If the reported race happens, dissolve_free_huge_page() just return without
doing any dissolve work because "if (PageHuge(page) && !page_count(page))"
block is skipped.
The hugepage is allocated and used as usual, but the contaiment doesn't
complete as expected in the normal page, because free_huge_pages() doesn't
call dissolve_free_huge_page() for hwpoison hugepage. This is not critical
because such error hugepage just reside in free hugepage list. But this
might looks like a kind of memory leak. And even worse when hugepage pool
is shrinked and the hwpoison hugepage is freed, the PageHWPoison flag is
still on the head page which is unlikely to be an actual error page.

So I think we need improvement here, how about the fix like below?

  (not tested yet, sorry)

  diff --git a/mm/memory-failure.c b/mm/memory-failure.c
  --- a/mm/memory-failure.c
  +++ b/mm/memory-failure.c
  @@ -1883,6 +1883,11 @@ static void soft_offline_free_page(struct page *pa=
ge)
          struct page *head =3D compound_head(page);
 =20
          if (!TestSetPageHWPoison(head)) {
  +               if (page_count(head)) {
  +                       ClearPageHWPoison(head);
  +                       return;
  +               }
  +
                  num_poisoned_pages_inc();
                  if (PageHuge(head))
                          dissolve_free_huge_page(page);

Thanks,
Naoya Horiguchi=
