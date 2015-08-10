Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id AB55C6B0253
	for <linux-mm@kvack.org>; Mon, 10 Aug 2015 04:51:56 -0400 (EDT)
Received: by pdco4 with SMTP id o4so69268637pdc.3
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 01:51:56 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id zp6si14717698pac.43.2015.08.10.01.51.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 10 Aug 2015 01:51:56 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 1/2] mm/hwpoison: fix fail to split THP w/ refcount held
Date: Mon, 10 Aug 2015 08:50:47 +0000
Message-ID: <20150810085047.GC21282@hori1.linux.bs1.fc.nec.co.jp>
References: <BLU436-SMTP188C7B16D46EEDEB4A9B9F980700@phx.gbl>
 <20150810081019.GA21282@hori1.linux.bs1.fc.nec.co.jp>
 <BLU436-SMTP6090BE1965823BCE9FBC4580700@phx.gbl>
In-Reply-To: <BLU436-SMTP6090BE1965823BCE9FBC4580700@phx.gbl>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <5E9D511B34238A458B93373B16FD5924@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <wanpeng.li@hotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, Aug 10, 2015 at 04:29:18PM +0800, Wanpeng Li wrote:
> Hi Naoya,
>=20
> On 8/10/15 4:10 PM, Naoya Horiguchi wrote:
> >On Mon, Aug 10, 2015 at 02:32:30PM +0800, Wanpeng Li wrote:
> >>THP pages will get a refcount in madvise_hwpoison() w/ MF_COUNT_INCREAS=
ED
> >>flag, however, the refcount is still held when fail to split THP pages.
> >>
> >>Fix it by reducing the refcount of THP pages when fail to split THP.
> >>
> >>Signed-off-by: Wanpeng Li <wanpeng.li@hotmail.com>
> >It seems that the same conditional put_page() would be added to
> >"soft offline: %#lx page already poisoned" branch too, right?
>=20
> PageHWPoison() is just called before the soft_offline_page() in
> madvise_hwpoion(). I think the PageHWPosion()
> check in soft_offline_page() makes more sense for the other
> soft_offline_page() callsites which don't have the
> refcount held.

What I am worried is a race like below:

  CPU0                              CPU1

  madvise_hwpoison
  get_user_pages_fast
  PageHWPoison check (false)
                                    memory_failure
                                    TestSetPageHWPoison
  soft_offline_page
  PageHWPoison check (true)
  return -EBUSY (without put_page)

It's rare and madvise_hwpoison() is testing feature, so this never causes
real problems in production systems, so it's not a big deal.
My suggestion is maybe just for code correctness thing ...

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
