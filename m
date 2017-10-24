Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id DF2E26B0033
	for <linux-mm@kvack.org>; Mon, 23 Oct 2017 20:46:22 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id b189so20042481oia.10
        for <linux-mm@kvack.org>; Mon, 23 Oct 2017 17:46:22 -0700 (PDT)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id y28si2702514oty.487.2017.10.23.17.46.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Oct 2017 17:46:21 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 1/1] mm:hugetlbfs: Fix hwpoison reserve accounting
Date: Tue, 24 Oct 2017 00:46:05 +0000
Message-ID: <20171024004605.GA19663@hori1.linux.bs1.fc.nec.co.jp>
References: <20171019230007.17043-1-mike.kravetz@oracle.com>
 <20171019230007.17043-2-mike.kravetz@oracle.com>
 <20171020023019.GA9318@hori1.linux.bs1.fc.nec.co.jp>
 <5016e528-8ea9-7597-3420-086ae57f3d9d@oracle.com>
 <20171023073258.GA5115@hori1.linux.bs1.fc.nec.co.jp>
 <26945734-ac7e-f71e-dbfa-0b0f0fdaff32@oracle.com>
In-Reply-To: <26945734-ac7e-f71e-dbfa-0b0f0fdaff32@oracle.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <5660F1F4E820CC4B8F5D48232D4ACF16@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>

On Mon, Oct 23, 2017 at 11:20:02AM -0700, Mike Kravetz wrote:
> On 10/23/2017 12:32 AM, Naoya Horiguchi wrote:
> > On Fri, Oct 20, 2017 at 10:49:46AM -0700, Mike Kravetz wrote:
> >> On 10/19/2017 07:30 PM, Naoya Horiguchi wrote:
> >>> On Thu, Oct 19, 2017 at 04:00:07PM -0700, Mike Kravetz wrote:
> >>>
> >>> Thank you for addressing this. The patch itself looks good to me, but
> >>> the reported issue (negative reserve count) doesn't reproduce in my t=
rial
> >>> with v4.14-rc5, so could you share the exact procedure for this issue=
?
> >>
> >> Sure, but first one question on your test scenario below.
> >>
> >>>
> >>> When error handler runs over a huge page, the reserve count is increm=
ented
> >>> so I'm not sure why the reserve count goes negative.
> >>
> >> I'm not sure I follow.  What specific code is incrementing the reserve
> >> count?
> >=20
> > The call path is like below:
> >=20
> >   hugetlbfs_error_remove_page
> >     hugetlb_fix_reserve_counts
> >       hugepage_subpool_get_pages(spool, 1)
> >         hugetlb_acct_memory(h, 1);
> >           gather_surplus_pages
> >             h->resv_huge_pages +=3D delta;
> >=20
>=20
> Ah OK.  This is a result of call to hugetlb_fix_reserve_counts which
> I believe is incorrect in most instances, and is unlikely to happen=20
> with my patch.
>=20
> >>
> >> Remove the file (rm /var/opt/oracle/hugepool/foo)
> >> -------------------------------------------------
> >> HugePages_Total:       1
> >> HugePages_Free:        0
> >> HugePages_Rsvd:    18446744073709551615
> >> HugePages_Surp:        0
> >> Hugepagesize:       2048 kB
> >>
> >> I am still confused about how your test maintains a reserve count afte=
r
> >> poisoning.  It may be a good idea for you to test my patch with your
> >> test scenario as I can not recreate here.
> >=20
> > Interestingly, I found that this reproduces if all hugetlb pages are
> > reserved when poisoning.
> > Your testing meets the condition, and mine doesn't.
> >=20
> > In gather_surplus_pages() we determine whether we extend hugetlb pool
> > with surplus pages like below:
> >=20
> >     needed =3D (h->resv_huge_pages + delta) - h->free_huge_pages;
> >     if (needed <=3D 0) {
> >             h->resv_huge_pages +=3D delta;
> >             return 0;
> >     }
> >     ...
> >=20
> > needed is 1 if h->resv_huge_pages =3D=3D h->free_huge_pages, and then
> > the reserve count gets inconsistent.
> > I confirmed that your patch fixes the issue, so I'm OK with it.
>=20
> Thanks.  That now makes sense to me.
>=20
> hugetlb_fix_reserve_counts (which results in gather_surplus_pages being
> called), is only designed to be called in the extremely rare cases when
> we have free'ed a huge page but are unable to free the reservation entry.
>=20
> Just curious, when the hugetlb_fix_reserve_counts call was added to
> hugetlbfs_error_remove_page, was the intention to preserve the original
> reservation?=20

No, the intention was to remove the reservation of the error hugepage
which was unmapped and isolated from normal hugepage's lifecycle.
The error hugepage is not freed back to hugepage pool, but it should be
handled in the same manner as freeing from the perspective of reserve count=
.

When I was writing commit 78bb920344b8, I experienced some reserve count
mismatch, and wrongly borrowed the code from truncation code.

> I remember thinking hard about that for the hole punch
> case and came to the conclusion that it was easier and less error prone
> to remove the reservation as well.  That will also happen in the error
> case with the patch I provided.

Yes, hole punching seems sililar to poisoning except that the final destina=
tion
of the target page differs. So we can make the same conclusion here.

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
