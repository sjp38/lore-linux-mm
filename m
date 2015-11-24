Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id ACA916B0038
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 00:04:39 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so9059806pac.3
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 21:04:39 -0800 (PST)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id c4si24408389pfd.43.2015.11.23.21.04.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 23 Nov 2015 21:04:38 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v1] mm: hugetlb: fix hugepage memory leak caused by
 wrong reserve count
Date: Tue, 24 Nov 2015 05:03:34 +0000
Message-ID: <20151124050323.GA31053@hori1.linux.bs1.fc.nec.co.jp>
References: <1448004017-23679-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <050201d12369$167a0a10$436e1e30$@alibaba-inc.com>
 <20151120142638.c505927a43dc1ede32570db0@linux-foundation.org>
In-Reply-To: <20151120142638.c505927a43dc1ede32570db0@linux-foundation.org>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <64C2FB06565D2B4183A1583A513BAEF6@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>, 'David Rientjes' <rientjes@google.com>, 'Dave Hansen' <dave.hansen@intel.com>, 'Mel Gorman' <mgorman@suse.de>, 'Joonsoo Kim' <iamjoonsoo.kim@lge.com>, 'Mike Kravetz' <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, 'Naoya Horiguchi' <nao.horiguchi@gmail.com>

On Fri, Nov 20, 2015 at 02:26:38PM -0800, Andrew Morton wrote:
> On Fri, 20 Nov 2015 15:57:21 +0800 "Hillf Danton" <hillf.zj@alibaba-inc.c=
om> wrote:
>=20
> > >=20
> > > When dequeue_huge_page_vma() in alloc_huge_page() fails, we fall back=
 to
> > > alloc_buddy_huge_page() to directly create a hugepage from the buddy =
allocator.
> > > In that case, however, if alloc_buddy_huge_page() succeeds we don't d=
ecrement
> > > h->resv_huge_pages, which means that successful hugetlb_fault() retur=
ns without
> > > releasing the reserve count. As a result, subsequent hugetlb_fault() =
might fail
> > > despite that there are still free hugepages.
> > >=20
> > > This patch simply adds decrementing code on that code path.
> > >=20
> > > I reproduced this problem when testing v4.3 kernel in the following s=
ituation:
> > > - the test machine/VM is a NUMA system,
> > > - hugepage overcommiting is enabled,
> > > - most of hugepages are allocated and there's only one free hugepage
> > >   which is on node 0 (for example),
> > > - another program, which calls set_mempolicy(MPOL_BIND) to bind itsel=
f to
> > >   node 1, tries to allocate a hugepage,
> > > - the allocation should fail but the reserve count is still hold.
> > >=20
> > > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > > Cc: <stable@vger.kernel.org> [3.16+]
> > > ---
> > > - the reason why I set stable target to "3.16+" is that this patch ca=
n be
> > >   applied easily/automatically on these versions. But this bug seems =
to be
> > >   old one, so if you are interested in backporting to older kernels,
> > >   please let me know.
> > > ---
> > >  mm/hugetlb.c |    5 ++++-
> > >  1 files changed, 4 insertions(+), 1 deletions(-)
> > >=20
> > > diff --git v4.3/mm/hugetlb.c v4.3_patched/mm/hugetlb.c
> > > index 9cc7734..77c518c 100644
> > > --- v4.3/mm/hugetlb.c
> > > +++ v4.3_patched/mm/hugetlb.c
> > > @@ -1790,7 +1790,10 @@ struct page *alloc_huge_page(struct vm_area_st=
ruct *vma,
> > >  		page =3D alloc_buddy_huge_page(h, NUMA_NO_NODE);
> > >  		if (!page)
> > >  			goto out_uncharge_cgroup;
> > > -
> > > +		if (!avoid_reserve && vma_has_reserves(vma, gbl_chg)) {
> > > +			SetPagePrivate(page);
> > > +			h->resv_huge_pages--;
> > > +		}
> >=20
> > I am wondering if this patch was prepared against the next tree.
>=20
> It's against 4.3.

Hi Hillf, Andrew,

That's right, this was against 4.3, and I agree with the adjustment
for next as done below.

> Here's the version I have, against current -linus:
>=20
> --- a/mm/hugetlb.c~mm-hugetlb-fix-hugepage-memory-leak-caused-by-wrong-re=
serve-count
> +++ a/mm/hugetlb.c
> @@ -1886,7 +1886,10 @@ struct page *alloc_huge_page(struct vm_a
>  		page =3D __alloc_buddy_huge_page_with_mpol(h, vma, addr);
>  		if (!page)
>  			goto out_uncharge_cgroup;
> -
> +		if (!avoid_reserve && vma_has_reserves(vma, gbl_chg)) {
> +			SetPagePrivate(page);
> +			h->resv_huge_pages--;
> +		}
>  		spin_lock(&hugetlb_lock);
>  		list_move(&page->lru, &h->hugepage_activelist);
>  		/* Fall through */
>=20
> It needs a careful re-review and, preferably, retest please.

I retested and made sure that the fix works on next-20151123.

Thanks,
Naoya Horiguchi

> Probably when Greg comes to merge this he'll hit problems and we'll
> need to provide him with the against-4.3 patch.
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
