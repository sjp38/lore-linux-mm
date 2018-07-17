Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 93F666B0003
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 20:28:34 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id b8-v6so44809675oib.4
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 17:28:34 -0700 (PDT)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id x7-v6si19383732oix.414.2018.07.16.17.28.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 17:28:33 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v1 1/2] mm: fix race on soft-offlining free huge pages
Date: Tue, 17 Jul 2018 00:25:19 +0000
Message-ID: <20180717002518.GA4673@hori1.linux.bs1.fc.nec.co.jp>
References: <1531452366-11661-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1531452366-11661-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20180713133545.658173ca953e7d2a8a4ee6bd@linux-foundation.org>
In-Reply-To: <20180713133545.658173ca953e7d2a8a4ee6bd@linux-foundation.org>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <F871C069B6AEFB418A4EB07B3710BAA6@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>, "xishi.qiuxishi@alibaba-inc.com" <xishi.qiuxishi@alibaba-inc.com>, "zy.zhengyi@alibaba-inc.com" <zy.zhengyi@alibaba-inc.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, Jul 13, 2018 at 01:35:45PM -0700, Andrew Morton wrote:
> On Fri, 13 Jul 2018 12:26:05 +0900 Naoya Horiguchi <n-horiguchi@ah.jp.nec=
.com> wrote:
>=20
> > There's a race condition between soft offline and hugetlb_fault which
> > causes unexpected process killing and/or hugetlb allocation failure.
> >=20
> > The process killing is caused by the following flow:
> >=20
> >   CPU 0               CPU 1              CPU 2
> >=20
> >   soft offline
> >     get_any_page
> >     // find the hugetlb is free
> >                       mmap a hugetlb file
> >                       page fault
> >                         ...
> >                           hugetlb_fault
> >                             hugetlb_no_page
> >                               alloc_huge_page
> >                               // succeed
> >       soft_offline_free_page
> >       // set hwpoison flag
> >                                          mmap the hugetlb file
> >                                          page fault
> >                                            ...
> >                                              hugetlb_fault
> >                                                hugetlb_no_page
> >                                                  find_lock_page
> >                                                    return VM_FAULT_HWPO=
ISON
> >                                            mm_fault_error
> >                                              do_sigbus
> >                                              // kill the process
> >=20
> >=20
> > The hugetlb allocation failure comes from the following flow:
> >=20
> >   CPU 0                          CPU 1
> >=20
> >                                  mmap a hugetlb file
> >                                  // reserve all free page but don't fau=
lt-in
> >   soft offline
> >     get_any_page
> >     // find the hugetlb is free
> >       soft_offline_free_page
> >       // set hwpoison flag
> >         dissolve_free_huge_page
> >         // fail because all free hugepages are reserved
> >                                  page fault
> >                                    ...
> >                                      hugetlb_fault
> >                                        hugetlb_no_page
> >                                          alloc_huge_page
> >                                            ...
> >                                              dequeue_huge_page_node_exa=
ct
> >                                              // ignore hwpoisoned hugep=
age
> >                                              // and finally fail due to=
 no-mem
> >=20
> > The root cause of this is that current soft-offline code is written
> > based on an assumption that PageHWPoison flag should beset at first to
> > avoid accessing the corrupted data.  This makes sense for memory_failur=
e()
> > or hard offline, but does not for soft offline because soft offline is
> > about corrected (not uncorrected) error and is safe from data lost.
> > This patch changes soft offline semantics where it sets PageHWPoison fl=
ag
> > only after containment of the error page completes successfully.
> >=20
> > ...
> >
> > --- v4.18-rc4-mmotm-2018-07-10-16-50/mm/memory-failure.c
> > +++ v4.18-rc4-mmotm-2018-07-10-16-50_patched/mm/memory-failure.c
> > @@ -1598,8 +1598,18 @@ static int soft_offline_huge_page(struct page *p=
age, int flags)
> >  		if (ret > 0)
> >  			ret =3D -EIO;
> >  	} else {
> > -		if (PageHuge(page))
> > -			dissolve_free_huge_page(page);
> > +		/*
> > +		 * We set PG_hwpoison only when the migration source hugepage
> > +		 * was successfully dissolved, because otherwise hwpoisoned
> > +		 * hugepage remains on free hugepage list, then userspace will
> > +		 * find it as SIGBUS by allocation failure. That's not expected
> > +		 * in soft-offlining.
> > +		 */
>=20
> This comment is unclear.  What happens if there's a hwpoisoned page on
> the freelist?  The allocator just skips it and looks for another page?=20

Yes, this is what the allocator does.

> Or does the allocator return the poisoned page, it gets mapped and
> userspace gets a SIGBUS when accessing it?  If the latter (or the
> former!), why does the comment mention allocation failure?

The mention to allocation failure was unclear, I'd like to replace
with below, is it clearer?

+		/*
+		 * We set PG_hwpoison only when the migration source hugepage
+		 * was successfully dissolved, because otherwise hwpoisoned
+		 * hugepage remains on free hugepage list. The allocator ignores
+		 * such a hwpoisoned page so it's never allocated, but it could
+		 * kill a process because of no-memory rather than hwpoison.
+		 * Soft-offline never impacts the userspace, so this is undesired.
+		 */

Thanks,
Naoya Horiguchi=
