Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 83B106B0003
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 21:00:01 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id l26-v6so2745988oii.14
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 18:00:01 -0700 (PDT)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id g188-v6si1563184oic.33.2018.07.17.17.59.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 17:59:59 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2 1/2] mm: fix race on soft-offlining free huge pages
Date: Wed, 18 Jul 2018 00:55:29 +0000
Message-ID: <20180718005528.GA12184@hori1.linux.bs1.fc.nec.co.jp>
References: <1531805552-19547-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1531805552-19547-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20180717142743.GJ7193@dhcp22.suse.cz>
In-Reply-To: <20180717142743.GJ7193@dhcp22.suse.cz>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <6FFDF45C1E8AD64E88E9A9492850100B@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "xishi.qiuxishi@alibaba-inc.com" <xishi.qiuxishi@alibaba-inc.com>, "zy.zhengyi@alibaba-inc.com" <zy.zhengyi@alibaba-inc.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, Jul 17, 2018 at 04:27:43PM +0200, Michal Hocko wrote:
> On Tue 17-07-18 14:32:31, Naoya Horiguchi wrote:
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
>=20
> Could you please expand on the worklow here please? The code is really
> hard to grasp. I must be missing something because the thing shouldn't
> be really complicated. Either the page is in the free pool and you just
> remove it from the allocator (with hugetlb asking for a new hugeltb page
> to guaratee reserves) or it is used and you just migrate the content to
> a new page (again with the hugetlb reserves consideration). Why should
> PageHWPoison flag ordering make any relevance?

(Considering soft offlining free hugepage,)
PageHWPoison is set at first before this patch, which is racy with
hugetlb fault code because it's not protected by hugetlb_lock.

Originally this was written in the similar manner as hard-offline, where
the race is accepted and a PageHWPoison flag is set as soon as possible.
But actually that's found not necessary/correct because soft offline is
supposed to be less aggressive and failure is OK.

So this patch is suggesting to make soft-offline less aggressive by
moving SetPageHWPoison into the lock.

>=20
> Do I get it right that the only difference between the hard and soft
> offlining is that hugetlb reserves might break for the former while not
> for the latter

Correct.

> and that the failed migration kills all owners for the
> former while not for latter?

Hard-offline doesn't cause any page migration because the data is already
lost, but yes it can kill the owners.
Soft-offline never kills processes even if it fails (due to migration failr=
ue
or some other reasons.)

I listed below some common points and differences between hard-offline
and soft-offline.

  common points
    - they are both contained by PageHWPoison flag,
    - error is injected via simliar interfaces.

  differences
    - the data on the page is considered lost in hard offline, but is not
      in soft offline,
    - hard offline likely kills the affected processes, but soft offline
      never kills processes,
    - soft offline causes page migration, but hard offline does not,
    - hard offline prioritizes to prevent consumption of broken data with
      accepting some race, and soft offline prioritizes not to impact
      userspace with accepting failure.

Looks to me that there're more differences rather than commont points.

Thanks,
Naoya Horiguchi

> =20
> > Reported-by: Xishi Qiu <xishi.qiuxishi@alibaba-inc.com>
> > Suggested-by: Xishi Qiu <xishi.qiuxishi@alibaba-inc.com>
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > ---
> > changelog v1->v2:
> > - don't use set_hwpoison_free_buddy_page() (not defined yet)
> > - updated comment in soft_offline_huge_page()
> > ---
> >  mm/hugetlb.c        | 11 +++++------
> >  mm/memory-failure.c | 24 ++++++++++++++++++------
> >  mm/migrate.c        |  2 --
> >  3 files changed, 23 insertions(+), 14 deletions(-)
> >=20
> > diff --git v4.18-rc4-mmotm-2018-07-10-16-50/mm/hugetlb.c v4.18-rc4-mmot=
m-2018-07-10-16-50_patched/mm/hugetlb.c
> > index 430be42..937c142 100644
> > --- v4.18-rc4-mmotm-2018-07-10-16-50/mm/hugetlb.c
> > +++ v4.18-rc4-mmotm-2018-07-10-16-50_patched/mm/hugetlb.c
> > @@ -1479,22 +1479,20 @@ static int free_pool_huge_page(struct hstate *h=
, nodemask_t *nodes_allowed,
> >  /*
> >   * Dissolve a given free hugepage into free buddy pages. This function=
 does
> >   * nothing for in-use (including surplus) hugepages. Returns -EBUSY if=
 the
> > - * number of free hugepages would be reduced below the number of reser=
ved
> > - * hugepages.
> > + * dissolution fails because a give page is not a free hugepage, or be=
cause
> > + * free hugepages are fully reserved.
> >   */
> >  int dissolve_free_huge_page(struct page *page)
> >  {
> > -	int rc =3D 0;
> > +	int rc =3D -EBUSY;
> > =20
> >  	spin_lock(&hugetlb_lock);
> >  	if (PageHuge(page) && !page_count(page)) {
> >  		struct page *head =3D compound_head(page);
> >  		struct hstate *h =3D page_hstate(head);
> >  		int nid =3D page_to_nid(head);
> > -		if (h->free_huge_pages - h->resv_huge_pages =3D=3D 0) {
> > -			rc =3D -EBUSY;
> > +		if (h->free_huge_pages - h->resv_huge_pages =3D=3D 0)
> >  			goto out;
> > -		}
> >  		/*
> >  		 * Move PageHWPoison flag from head page to the raw error page,
> >  		 * which makes any subpages rather than the error page reusable.
> > @@ -1508,6 +1506,7 @@ int dissolve_free_huge_page(struct page *page)
> >  		h->free_huge_pages_node[nid]--;
> >  		h->max_huge_pages--;
> >  		update_and_free_page(h, head);
> > +		rc =3D 0;
> >  	}
> >  out:
> >  	spin_unlock(&hugetlb_lock);
> > diff --git v4.18-rc4-mmotm-2018-07-10-16-50/mm/memory-failure.c v4.18-r=
c4-mmotm-2018-07-10-16-50_patched/mm/memory-failure.c
> > index 9d142b9..9b77f85 100644
> > --- v4.18-rc4-mmotm-2018-07-10-16-50/mm/memory-failure.c
> > +++ v4.18-rc4-mmotm-2018-07-10-16-50_patched/mm/memory-failure.c
> > @@ -1598,8 +1598,20 @@ static int soft_offline_huge_page(struct page *p=
age, int flags)
> >  		if (ret > 0)
> >  			ret =3D -EIO;
> >  	} else {
> > -		if (PageHuge(page))
> > -			dissolve_free_huge_page(page);
> > +		/*
> > +		 * We set PG_hwpoison only when the migration source hugepage
> > +		 * was successfully dissolved, because otherwise hwpoisoned
> > +		 * hugepage remains on free hugepage list. The allocator ignores
> > +		 * such a hwpoisoned page so it's never allocated, but it could
> > +		 * kill a process because of no-memory rather than hwpoison.
> > +		 * Soft-offline never impacts the userspace, so this is
> > +		 * undesired.
> > +		 */
> > +		ret =3D dissolve_free_huge_page(page);
> > +		if (!ret) {
> > +			if (!TestSetPageHWPoison(page))
> > +				num_poisoned_pages_inc();
> > +		}
> >  	}
> >  	return ret;
> >  }
> > @@ -1715,13 +1727,13 @@ static int soft_offline_in_use_page(struct page=
 *page, int flags)
> > =20
> >  static void soft_offline_free_page(struct page *page)
> >  {
> > +	int rc =3D 0;
> >  	struct page *head =3D compound_head(page);
> > =20
> > -	if (!TestSetPageHWPoison(head)) {
> > +	if (PageHuge(head))
> > +		rc =3D dissolve_free_huge_page(page);
> > +	if (!rc && !TestSetPageHWPoison(page))
> >  		num_poisoned_pages_inc();
> > -		if (PageHuge(head))
> > -			dissolve_free_huge_page(page);
> > -	}
> >  }
> > =20
> >  /**
> > diff --git v4.18-rc4-mmotm-2018-07-10-16-50/mm/migrate.c v4.18-rc4-mmot=
m-2018-07-10-16-50_patched/mm/migrate.c
> > index 198af42..3ae213b 100644
> > --- v4.18-rc4-mmotm-2018-07-10-16-50/mm/migrate.c
> > +++ v4.18-rc4-mmotm-2018-07-10-16-50_patched/mm/migrate.c
> > @@ -1318,8 +1318,6 @@ static int unmap_and_move_huge_page(new_page_t ge=
t_new_page,
> >  out:
> >  	if (rc !=3D -EAGAIN)
> >  		putback_active_hugepage(hpage);
> > -	if (reason =3D=3D MR_MEMORY_FAILURE && !test_set_page_hwpoison(hpage)=
)
> > -		num_poisoned_pages_inc();
> > =20
> >  	/*
> >  	 * If migration was not successful and there's a freeing callback, us=
e
> > --=20
> > 2.7.0
>=20
> --=20
> Michal Hocko
> SUSE Labs
> =
