Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4AC756B0005
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 04:10:14 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id m197-v6so6455153oig.18
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 01:10:14 -0700 (PDT)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id j66-v6si3569040oif.40.2018.07.19.01.10.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jul 2018 01:10:13 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2 1/2] mm: fix race on soft-offlining free huge pages
Date: Thu, 19 Jul 2018 08:08:05 +0000
Message-ID: <20180719080804.GA32756@hori1.linux.bs1.fc.nec.co.jp>
References: <1531805552-19547-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1531805552-19547-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20180717142743.GJ7193@dhcp22.suse.cz>
 <20180718005528.GA12184@hori1.linux.bs1.fc.nec.co.jp>
 <20180718085032.GS7193@dhcp22.suse.cz>
 <20180719061945.GB22154@hori1.linux.bs1.fc.nec.co.jp>
 <20180719071516.GK7193@dhcp22.suse.cz>
In-Reply-To: <20180719071516.GK7193@dhcp22.suse.cz>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <05B4D8597F8D454BABD4853CF7549D4D@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "xishi.qiuxishi@alibaba-inc.com" <xishi.qiuxishi@alibaba-inc.com>, "zy.zhengyi@alibaba-inc.com" <zy.zhengyi@alibaba-inc.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, Jul 19, 2018 at 09:15:16AM +0200, Michal Hocko wrote:
> On Thu 19-07-18 06:19:45, Naoya Horiguchi wrote:
> > On Wed, Jul 18, 2018 at 10:50:32AM +0200, Michal Hocko wrote:
> > > On Wed 18-07-18 00:55:29, Naoya Horiguchi wrote:
> > > > On Tue, Jul 17, 2018 at 04:27:43PM +0200, Michal Hocko wrote:
> > > > > On Tue 17-07-18 14:32:31, Naoya Horiguchi wrote:
> > > > > > There's a race condition between soft offline and hugetlb_fault=
 which
> > > > > > causes unexpected process killing and/or hugetlb allocation fai=
lure.
> > > > > >
> > > > > > The process killing is caused by the following flow:
> > > > > >
> > > > > >   CPU 0               CPU 1              CPU 2
> > > > > >
> > > > > >   soft offline
> > > > > >     get_any_page
> > > > > >     // find the hugetlb is free
> > > > > >                       mmap a hugetlb file
> > > > > >                       page fault
> > > > > >                         ...
> > > > > >                           hugetlb_fault
> > > > > >                             hugetlb_no_page
> > > > > >                               alloc_huge_page
> > > > > >                               // succeed
> > > > > >       soft_offline_free_page
> > > > > >       // set hwpoison flag
> > > > > >                                          mmap the hugetlb file
> > > > > >                                          page fault
> > > > > >                                            ...
> > > > > >                                              hugetlb_fault
> > > > > >                                                hugetlb_no_page
> > > > > >                                                  find_lock_page
> > > > > >                                                    return VM_FA=
ULT_HWPOISON
> > > > > >                                            mm_fault_error
> > > > > >                                              do_sigbus
> > > > > >                                              // kill the proces=
s
> > > > > >
> > > > > >
> > > > > > The hugetlb allocation failure comes from the following flow:
> > > > > >
> > > > > >   CPU 0                          CPU 1
> > > > > >
> > > > > >                                  mmap a hugetlb file
> > > > > >                                  // reserve all free page but d=
on't fault-in
> > > > > >   soft offline
> > > > > >     get_any_page
> > > > > >     // find the hugetlb is free
> > > > > >       soft_offline_free_page
> > > > > >       // set hwpoison flag
> > > > > >         dissolve_free_huge_page
> > > > > >         // fail because all free hugepages are reserved
> > > > > >                                  page fault
> > > > > >                                    ...
> > > > > >                                      hugetlb_fault
> > > > > >                                        hugetlb_no_page
> > > > > >                                          alloc_huge_page
> > > > > >                                            ...
> > > > > >                                              dequeue_huge_page_=
node_exact
> > > > > >                                              // ignore hwpoison=
ed hugepage
> > > > > >                                              // and finally fai=
l due to no-mem
> > > > > >
> > > > > > The root cause of this is that current soft-offline code is wri=
tten
> > > > > > based on an assumption that PageHWPoison flag should beset at f=
irst to
> > > > > > avoid accessing the corrupted data.  This makes sense for memor=
y_failure()
> > > > > > or hard offline, but does not for soft offline because soft off=
line is
> > > > > > about corrected (not uncorrected) error and is safe from data l=
ost.
> > > > > > This patch changes soft offline semantics where it sets PageHWP=
oison flag
> > > > > > only after containment of the error page completes successfully=
.
> > > > >
> > > > > Could you please expand on the worklow here please? The code is r=
eally
> > > > > hard to grasp. I must be missing something because the thing shou=
ldn't
> > > > > be really complicated. Either the page is in the free pool and yo=
u just
> > > > > remove it from the allocator (with hugetlb asking for a new hugel=
tb page
> > > > > to guaratee reserves) or it is used and you just migrate the cont=
ent to
> > > > > a new page (again with the hugetlb reserves consideration). Why s=
hould
> > > > > PageHWPoison flag ordering make any relevance?
> > > >
> > > > (Considering soft offlining free hugepage,)
> > > > PageHWPoison is set at first before this patch, which is racy with
> > > > hugetlb fault code because it's not protected by hugetlb_lock.
> > > >
> > > > Originally this was written in the similar manner as hard-offline, =
where
> > > > the race is accepted and a PageHWPoison flag is set as soon as poss=
ible.
> > > > But actually that's found not necessary/correct because soft offlin=
e is
> > > > supposed to be less aggressive and failure is OK.
> > >
> > > OK
> > >
> > > > So this patch is suggesting to make soft-offline less aggressive by
> > > > moving SetPageHWPoison into the lock.
> > >
> > > I guess I still do not understand why we should even care about the
> > > ordering of the HWPoison flag setting. Why cannot we simply have the
> > > following code flow? Or maybe we are doing that already I just do not
> > > follow the code
> > >
> > > 	soft_offline
> > > 	  check page_count
> > > 	    - free - normal page - remove from the allocator
> > > 	           - hugetlb - allocate a new hugetlb page && remove from th=
e pool
> > > 	    - used - migrate to a new page && never release the old one
> > >
> > > Why do we even need HWPoison flag here? Everything can be completely
> > > transparent to the application. It shouldn't fail from what I
> > > understood.
> >=20
> > PageHWPoison flag is used to the 'remove from the allocator' part
> > which is like below:
> >=20
> >   static inline
> >   struct page *rmqueue(
> >           ...
> >           do {
> >                   page =3D NULL;
> >                   if (alloc_flags & ALLOC_HARDER) {
> >                           page =3D __rmqueue_smallest(zone, order, MIGR=
ATE_HIGHATOMIC);
> >                           if (page)
> >                                   trace_mm_page_alloc_zone_locked(page,=
 order, migratetype);
> >                   }
> >                   if (!page)
> >                           page =3D __rmqueue(zone, order, migratetype);
> >           } while (page && check_new_pages(page, order));
> >=20
> > check_new_pages() returns true if the page taken from free list has
> > a hwpoison page so that the allocator iterates another round to get
> > another page.
> >=20
> > There's no function that can be called from outside allocator to remove
> > a page in allocator.  So actual page removal is done at allocation time=
,
> > not at error handling time. That's the reason why we need PageHWPoison.
>=20
> hwpoison is an internal mm functionality so why cannot we simply add a
> function that would do that?

That's one possible solution.

I know about another downside in current implementation.
If a hwpoison page is found during high order page allocation,
all 2^order pages (not only hwpoison page) are removed from
buddy because of the above quoted code. And these leaked pages
are never returned to freelist even with unpoison_memory().
If we have a page removal function which properly splits high order
free pages into lower order pages, this problem is avoided.

OTOH PageHWPoison still has a role to report error to userspace.
Without it unpoison_memory() doesn't work.

Thanks,
Naoya Horiguchi

> I find the PageHWPoison usage here doing
> more complications than real good. Or am I missing something?=
