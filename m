Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id F14F76B0038
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 00:40:49 -0500 (EST)
Received: by pacej9 with SMTP id ej9so10144262pac.2
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 21:40:49 -0800 (PST)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id w6si489323pbs.64.2015.11.23.21.33.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 23 Nov 2015 21:33:25 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v1] mm: hugetlb: fix hugepage memory leak caused by
 wrong reserve count
Date: Tue, 24 Nov 2015 05:32:59 +0000
Message-ID: <20151124053258.GA27211@hori1.linux.bs1.fc.nec.co.jp>
References: <1448004017-23679-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <050201d12369$167a0a10$436e1e30$@alibaba-inc.com>
 <564F9702.5070007@oracle.com>
In-Reply-To: <564F9702.5070007@oracle.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <1296A6AF322D374DB7FC2E7FECA19BFB@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'David Rientjes' <rientjes@google.com>, 'Dave Hansen' <dave.hansen@intel.com>, 'Mel Gorman' <mgorman@suse.de>, 'Joonsoo Kim' <iamjoonsoo.kim@lge.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, 'Naoya Horiguchi' <nao.horiguchi@gmail.com>

On Fri, Nov 20, 2015 at 01:56:18PM -0800, Mike Kravetz wrote:
> On 11/19/2015 11:57 PM, Hillf Danton wrote:
> >>
> >> When dequeue_huge_page_vma() in alloc_huge_page() fails, we fall back =
to
> >> alloc_buddy_huge_page() to directly create a hugepage from the buddy a=
llocator.
> >> In that case, however, if alloc_buddy_huge_page() succeeds we don't de=
crement
> >> h->resv_huge_pages, which means that successful hugetlb_fault() return=
s without
> >> releasing the reserve count. As a result, subsequent hugetlb_fault() m=
ight fail
> >> despite that there are still free hugepages.
> >>
> >> This patch simply adds decrementing code on that code path.
>=20
> In general, I agree with the patch.  If we allocate a huge page via the
> buddy allocator and that page will be used to satisfy a reservation, then
> we need to decrement the reservation count.
>=20
> As Hillf mentions, this code is not exactly the same in linux-next.
> Specifically, there is the new call to take the memory policy of the
> vma into account when calling the buddy allocator.  I do not think,
> this impacts your proposed change but you may want to test with that
> in place.
>=20
> >>
> >> I reproduced this problem when testing v4.3 kernel in the following si=
tuation:
> >> - the test machine/VM is a NUMA system,
> >> - hugepage overcommiting is enabled,
> >> - most of hugepages are allocated and there's only one free hugepage
> >>   which is on node 0 (for example),
> >> - another program, which calls set_mempolicy(MPOL_BIND) to bind itself=
 to
> >>   node 1, tries to allocate a hugepage,
>=20
> I am curious about this scenario.  When this second program attempts to
> allocate the page, I assume it creates a reservation first.  Is this
> reservation before or after setting mempolicy?  If the mempolicy was set
> first, I would have expected the reservation to allocate a page on
> node 1 to satisfy the reservation.

My testing called set_mempolicy() at first then called mmap(), but things
didn't change if I reordered them, because currently hugetlb reservation is
not NUMA-aware.

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
