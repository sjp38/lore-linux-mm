Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 41C1C6B0253
	for <linux-mm@kvack.org>; Mon, 10 Aug 2015 04:59:27 -0400 (EDT)
Received: by pacgr6 with SMTP id gr6so22677621pac.2
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 01:59:27 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id gc5si32006332pbd.186.2015.08.10.01.59.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 10 Aug 2015 01:59:26 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 2/2] mm/hwpoison: fix refcount of THP head page in
 no-injection case
Date: Mon, 10 Aug 2015 08:58:38 +0000
Message-ID: <20150810085837.GA28025@hori1.linux.bs1.fc.nec.co.jp>
References: <1439188351-24292-1-git-send-email-wanpeng.li@hotmail.com>
 <BLU436-SMTP1881EF02196F4DFB4A0882B80700@phx.gbl>
 <20150810083529.GB21282@hori1.linux.bs1.fc.nec.co.jp>
 <BLU436-SMTP3886BA6C827CC74CCF19EB80700@phx.gbl>
In-Reply-To: <BLU436-SMTP3886BA6C827CC74CCF19EB80700@phx.gbl>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <78BFF436DADF6D419A22B400E83FBB24@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <wanpeng.li@hotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, Aug 10, 2015 at 04:54:39PM +0800, Wanpeng Li wrote:
> On 8/10/15 4:35 PM, Naoya Horiguchi wrote:
> >On Mon, Aug 10, 2015 at 02:32:31PM +0800, Wanpeng Li wrote:
> >>Hwpoison injection takes a refcount of target page and another refcount
> >>of head page of THP if the target page is the tail page of a THP. Howev=
er,
> >>current code doesn't release the refcount of head page if the THP is no=
t
> >>supported to be injected wrt hwpoison filter.
> >>
> >>Fix it by reducing the refcount of head page if the target page is the =
tail
> >>page of a THP and it is not supported to be injected.
> >>
> >>Signed-off-by: Wanpeng Li <wanpeng.li@hotmail.com>
> >>---
> >>  mm/hwpoison-inject.c |    2 ++
> >>  1 files changed, 2 insertions(+), 0 deletions(-)
> >>
> >>diff --git a/mm/hwpoison-inject.c b/mm/hwpoison-inject.c
> >>index 5015679..c343a45 100644
> >>--- a/mm/hwpoison-inject.c
> >>+++ b/mm/hwpoison-inject.c
> >>@@ -56,6 +56,8 @@ inject:
> >>  	return memory_failure(pfn, 18, MF_COUNT_INCREASED);
> >>  put_out:
> >>  	put_page(p);
> >>+	if (p !=3D hpage)
> >>+		put_page(hpage);
> >Yes, we need this when we inject to a thp tail page and "goto put_out" i=
s
> >called. But it seems that this code can be called also when injecting er=
ror
> >to a hugetlb tail page and hwpoison_filter() returns non-zero, which is =
not
> >expected. Unfortunately simply doing like below
> >
> >+	if (!PageHuge(p) && p !=3D hpage)
> >+		put_page(hpage);
> >
> >doesn't work, because exisiting put_page(p) can release refcount of huge=
tlb
> >tail page, while get_hwpoison_page() takes refcount of hugetlb head page=
.
> >
> >So I feel that we need put_hwpoison_page() to properly release the refco=
unt
> >taken by memory error handlers.
>=20
> Good point. I think I will continue to do it and will post it out soon. :=
)

Great, thank you :)

Naoya=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
