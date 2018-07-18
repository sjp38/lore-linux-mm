Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 07FD76B0006
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 21:28:48 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id x5-v6so2249355ioa.6
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 18:28:48 -0700 (PDT)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id d197-v6si1606405ioe.204.2018.07.17.18.28.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 18:28:46 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2 1/2] mm: fix race on soft-offlining free huge pages
Date: Wed, 18 Jul 2018 01:28:17 +0000
Message-ID: <20180718012817.GB12184@hori1.linux.bs1.fc.nec.co.jp>
References: <1531805552-19547-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1531805552-19547-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20180717142743.GJ7193@dhcp22.suse.cz>
 <773a2f4e-c420-e973-cadd-4144730d28e8@oracle.com>
In-Reply-To: <773a2f4e-c420-e973-cadd-4144730d28e8@oracle.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <FD920B7331243C4CBAFDBF37FFBCA01A@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Michal Hocko <mhocko@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "xishi.qiuxishi@alibaba-inc.com" <xishi.qiuxishi@alibaba-inc.com>, "zy.zhengyi@alibaba-inc.com" <zy.zhengyi@alibaba-inc.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, Jul 17, 2018 at 01:10:39PM -0700, Mike Kravetz wrote:
> On 07/17/2018 07:27 AM, Michal Hocko wrote:
> > On Tue 17-07-18 14:32:31, Naoya Horiguchi wrote:
> >> There's a race condition between soft offline and hugetlb_fault which
> >> causes unexpected process killing and/or hugetlb allocation failure.
> >>
> >> The process killing is caused by the following flow:
> >>
> >>   CPU 0               CPU 1              CPU 2
> >>
> >>   soft offline
> >>     get_any_page
> >>     // find the hugetlb is free
> >>                       mmap a hugetlb file
> >>                       page fault
> >>                         ...
> >>                           hugetlb_fault
> >>                             hugetlb_no_page
> >>                               alloc_huge_page
> >>                               // succeed
> >>       soft_offline_free_page
> >>       // set hwpoison flag
> >>                                          mmap the hugetlb file
> >>                                          page fault
> >>                                            ...
> >>                                              hugetlb_fault
> >>                                                hugetlb_no_page
> >>                                                  find_lock_page
> >>                                                    return VM_FAULT_HWP=
OISON
> >>                                            mm_fault_error
> >>                                              do_sigbus
> >>                                              // kill the process
> >>
> >>
> >> The hugetlb allocation failure comes from the following flow:
> >>
> >>   CPU 0                          CPU 1
> >>
> >>                                  mmap a hugetlb file
> >>                                  // reserve all free page but don't fa=
ult-in
> >>   soft offline
> >>     get_any_page
> >>     // find the hugetlb is free
> >>       soft_offline_free_page
> >>       // set hwpoison flag
> >>         dissolve_free_huge_page
> >>         // fail because all free hugepages are reserved
> >>                                  page fault
> >>                                    ...
> >>                                      hugetlb_fault
> >>                                        hugetlb_no_page
> >>                                          alloc_huge_page
> >>                                            ...
> >>                                              dequeue_huge_page_node_ex=
act
> >>                                              // ignore hwpoisoned huge=
page
> >>                                              // and finally fail due t=
o no-mem
> >>
> >> The root cause of this is that current soft-offline code is written
> >> based on an assumption that PageHWPoison flag should beset at first to
> >> avoid accessing the corrupted data.  This makes sense for memory_failu=
re()
> >> or hard offline, but does not for soft offline because soft offline is
> >> about corrected (not uncorrected) error and is safe from data lost.
> >> This patch changes soft offline semantics where it sets PageHWPoison f=
lag
> >> only after containment of the error page completes successfully.
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
> My understanding may not be corect, but just looking at the current code
> for soft_offline_free_page helps me understand:
>=20
> static void soft_offline_free_page(struct page *page)
> {
> 	struct page *head =3D compound_head(page);
>=20
> 	if (!TestSetPageHWPoison(head)) {
> 		num_poisoned_pages_inc();
> 		if (PageHuge(head))
> 			dissolve_free_huge_page(page);
> 	}
> }
>=20
> The HWPoison flag is set before even checking to determine if the huge
> page can be dissolved.  So, someone could could attempt to pull the page
> off the free list (if free) or fault/map it (if already associated with
> a file) which leads to the  failures described above.  The patches ensure
> that we only set HWPoison after successfully dissolving the page. At leas=
t
> that is how I understand it.

Thanks for elaborating, this is correct.

>=20
> It seems that soft_offline_free_page can be called for in use pages.
> Certainly, that is the case in the first workflow above.  With the
> suggested changes, I think this is OK for huge pages.  However, it seems
> that setting HWPoison on a in use non-huge page could cause issues?

Just after dissolve_free_huge_page() returns, the target page is just a
free buddy page without PageHWPoison set. If this page is allocated
immediately, that's "migration succeeded, but soft offline failed" case,
so no problem.
Certainly, there also is a race between cheking TestSetPageHWPoison and
page allocation, so this issue is handled in patch 2/2.

> While looking at the code, I noticed this comment in __get_any_page()
>         /*
>          * When the target page is a free hugepage, just remove it
>          * from free hugepage list.
>          */
> Did that apply to some code that was removed?  It does not seem to make
> any sense in that routine.

This comment is completely obsolete, I'll remove this one.

Thanks,
Naoya Horiguchi=
