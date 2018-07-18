Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id A2E6B6B0003
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 21:49:23 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id t65-v6so2254361iof.23
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 18:49:23 -0700 (PDT)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id k4-v6si1613125iog.129.2018.07.17.18.49.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 18:49:22 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2 1/2] mm: fix race on soft-offlining free huge pages
Date: Wed, 18 Jul 2018 01:41:06 +0000
Message-ID: <20180718014106.GC12184@hori1.linux.bs1.fc.nec.co.jp>
References: <1531805552-19547-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1531805552-19547-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20180717142743.GJ7193@dhcp22.suse.cz>
 <20180718005528.GA12184@hori1.linux.bs1.fc.nec.co.jp>
In-Reply-To: <20180718005528.GA12184@hori1.linux.bs1.fc.nec.co.jp>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <17B3499424B95046AD437A3299570E4B@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "xishi.qiuxishi@alibaba-inc.com" <xishi.qiuxishi@alibaba-inc.com>, "zy.zhengyi@alibaba-inc.com" <zy.zhengyi@alibaba-inc.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Jul 18, 2018 at 12:55:29AM +0000, Horiguchi Naoya(=1B$BKY8}=1B(B =
=1B$BD>Li=1B(B) wrote:
> On Tue, Jul 17, 2018 at 04:27:43PM +0200, Michal Hocko wrote:
> > On Tue 17-07-18 14:32:31, Naoya Horiguchi wrote:
> > > There's a race condition between soft offline and hugetlb_fault which
> > > causes unexpected process killing and/or hugetlb allocation failure.
> > >=20
> > > The process killing is caused by the following flow:
> > >=20
> > >   CPU 0               CPU 1              CPU 2
> > >=20
> > >   soft offline
> > >     get_any_page
> > >     // find the hugetlb is free
> > >                       mmap a hugetlb file
> > >                       page fault
> > >                         ...
> > >                           hugetlb_fault
> > >                             hugetlb_no_page
> > >                               alloc_huge_page
> > >                               // succeed
> > >       soft_offline_free_page
> > >       // set hwpoison flag
> > >                                          mmap the hugetlb file
> > >                                          page fault
> > >                                            ...
> > >                                              hugetlb_fault
> > >                                                hugetlb_no_page
> > >                                                  find_lock_page
> > >                                                    return VM_FAULT_HW=
POISON
> > >                                            mm_fault_error
> > >                                              do_sigbus
> > >                                              // kill the process
> > >=20
> > >=20
> > > The hugetlb allocation failure comes from the following flow:
> > >=20
> > >   CPU 0                          CPU 1
> > >=20
> > >                                  mmap a hugetlb file
> > >                                  // reserve all free page but don't f=
ault-in
> > >   soft offline
> > >     get_any_page
> > >     // find the hugetlb is free
> > >       soft_offline_free_page
> > >       // set hwpoison flag
> > >         dissolve_free_huge_page
> > >         // fail because all free hugepages are reserved
> > >                                  page fault
> > >                                    ...
> > >                                      hugetlb_fault
> > >                                        hugetlb_no_page
> > >                                          alloc_huge_page
> > >                                            ...
> > >                                              dequeue_huge_page_node_e=
xact
> > >                                              // ignore hwpoisoned hug=
epage
> > >                                              // and finally fail due =
to no-mem
> > >=20
> > > The root cause of this is that current soft-offline code is written
> > > based on an assumption that PageHWPoison flag should beset at first t=
o
> > > avoid accessing the corrupted data.  This makes sense for memory_fail=
ure()
> > > or hard offline, but does not for soft offline because soft offline i=
s
> > > about corrected (not uncorrected) error and is safe from data lost.
> > > This patch changes soft offline semantics where it sets PageHWPoison =
flag
> > > only after containment of the error page completes successfully.
> >=20
> > Could you please expand on the worklow here please? The code is really
> > hard to grasp. I must be missing something because the thing shouldn't
> > be really complicated. Either the page is in the free pool and you just
> > remove it from the allocator (with hugetlb asking for a new hugeltb pag=
e
> > to guaratee reserves) or it is used and you just migrate the content to
> > a new page (again with the hugetlb reserves consideration). Why should
> > PageHWPoison flag ordering make any relevance?
>=20
> (Considering soft offlining free hugepage,)
> PageHWPoison is set at first before this patch, which is racy with
> hugetlb fault code because it's not protected by hugetlb_lock.
>=20
> Originally this was written in the similar manner as hard-offline, where
> the race is accepted and a PageHWPoison flag is set as soon as possible.
> But actually that's found not necessary/correct because soft offline is
> supposed to be less aggressive and failure is OK.
>=20
> So this patch is suggesting to make soft-offline less aggressive


> by moving SetPageHWPoison into the lock.

My apology, this part of reasoning was incorrect.  What patch 1/2 actually
does is transforming the issue into the normal page's similar race issue
which is solved by patch 2/2.  After patch 1/2, soft offline never sets
PageHWPoison on hugepage.

Thanks,
Naoya Horiguchi

>=20
> >=20
> > Do I get it right that the only difference between the hard and soft
> > offlining is that hugetlb reserves might break for the former while not
> > for the latter
>=20
> Correct.
>=20
> > and that the failed migration kills all owners for the
> > former while not for latter?
>=20
> Hard-offline doesn't cause any page migration because the data is already
> lost, but yes it can kill the owners.
> Soft-offline never kills processes even if it fails (due to migration fai=
lrue
> or some other reasons.)
>=20
> I listed below some common points and differences between hard-offline
> and soft-offline.
>=20
>   common points
>     - they are both contained by PageHWPoison flag,
>     - error is injected via simliar interfaces.
>=20
>   differences
>     - the data on the page is considered lost in hard offline, but is not
>       in soft offline,
>     - hard offline likely kills the affected processes, but soft offline
>       never kills processes,
>     - soft offline causes page migration, but hard offline does not,
>     - hard offline prioritizes to prevent consumption of broken data with
>       accepting some race, and soft offline prioritizes not to impact
>       userspace with accepting failure.
>=20
> Looks to me that there're more differences rather than commont points.=
