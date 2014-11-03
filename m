Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f170.google.com (mail-qc0-f170.google.com [209.85.216.170])
	by kanga.kvack.org (Postfix) with ESMTP id 55E5B6B011A
	for <linux-mm@kvack.org>; Sun,  2 Nov 2014 19:44:33 -0500 (EST)
Received: by mail-qc0-f170.google.com with SMTP id l6so8448904qcy.15
        for <linux-mm@kvack.org>; Sun, 02 Nov 2014 16:44:33 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p12si27623784qaa.132.2014.11.02.16.44.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 02 Nov 2014 16:44:32 -0800 (PST)
Date: Mon, 3 Nov 2014 01:44:23 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: Question/clarification on pmd accessors
Message-ID: <20141103004423.GD12925@redhat.com>
References: <87fve1hfwh.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87fve1hfwh.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: David Miller <davem@davemloft.net>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-arch@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi Aneesh,

On Sun, Nov 02, 2014 at 07:18:46PM +0530, Aneesh Kumar K.V wrote:
> 
> Hi Andrea,
> 
> This came up when I was looking at how best we can implement generic GUP
> that can also handle sparc usecase. Below are the pmd accessors that
> would be nice to get documented. 
> 
> pmd_present():
>         I guess we should return true for both pointer to pte page and
>         huge page pte (THP and explicit hugepages). We will always find
>         THP and explicit hugepage present. If so how is it
>         different from pmd_none() ? (There is an expection of
>         __split_huge_page_map marking the pmd not
>         present. Should pmd_present() return false in that case ?)
> 
> pmd_none():
>         In some arch it is same as !pmd_present(). I am
>         not sure that is correct. Can we explain the difference between
>         !pmd_present and pmd_none ?

Originally pmd_present was different than !pmd_none. So I used
!pmd_none instead of pmd_present in some places to cover for the
pmdp_invalidate and pmd_mknotpresent race window (back when
pmd_present wouldn't return true unless the _PAGE_PRESENT bit was
set). However some place that still used pmd_present and wasn't
converted to a !pmd_none, got confused by the pmd_mknotpresent that
split_huge_page has to go through for the pmdp_invalidate() call
(immediately followed by pmd_populate).

The implementation of pmdp_invalidate with pmd_mknotpresent is
required to prevent TLBs of multiple size simultaneously co-existing
for the same physical page (some CPU need it and it sounds safer
anyway because at least one TLB flush after those two lines would be
needed anyway after the pmdp_establish, and the TLB flush is the only
runtime cost, the pmd_mknotpresent not).

These days they are equivalent, the details of this change is in
commit 027ef6c87853b0a9df53175063028edb4950d476.

The old behavior of pmd_present just happened to be a lowlevel version
that would show the effect of a pmd_mknotpresent, except it wasn't
useful like that, and it just created a tiny race window for some
places.

After the above commit they are equivalent and in fact as the commit
header already hinted, we could actually delete pmd_present and just
use !pmd_none.

The only reason I didn't delete pmd_present is that conceptually it is
different, and it is required in order to later swapout THP natively
in 2M blocks. If THP are swapped out natively pmd_present would be
false and pmd_none would be false, so they wouldn't be equivalent
anymore.

In short pmd_present/pmd_none are conceptually identical to
pte_present/pte_none, except we can't swap THP natively yet so
pmd_present and !pmd_none are practically the same now.

> pmd_trans_huge():
>         pmd value that represent a hugepage built via THP mechanism.
>         Also implies present.

pmd_trans_huge() would return true on a hugetlbfs hugepage too, just
by design pmd_trans_huge can never be run on any hugetlbfs page. The
hugetlbfs page table walking and mangling paths are totally separated
form the core VM paths and they're differentiated by VM_HUGETLB being
set on vm_flags well before any pmd_trans_huge could run.

pmd_trans_huge() is defined as false at build time if
CONFIG_TRANSPARENT_HUGEPAGE=n to optimize away code blocks at build
time in such case.

> pmd_huge():
>         Should cover both the THP and explicit hugepages

Yes, because they work the same, but again the difference here is made
by the fact pmd_huge is hugetlbfs private thing, and by design it's
never run by design on any pmd that could possibly point to a THP
page by differentiating using the VM_HUGETLB flag in vm_flags.

Following the same lines of pmd_trans_huge, pmd_huge is also defined
as 0 at build time if CONFIG_HUGETLB_PAGE=n.

They both are optimized away or not depending on
CONFIG_HUGETLB_PAGE=y/n and CONFIG_TRANSPARENT_HUGEPAGE=y/n at build
time.

> pmd_large():
>         This is confusing. On ppc64 this one also check for
>         _PAGE_PRESENT. I don't recollect how we end up with that.

pmd_large is the one that cannot be optimized away and it is only used
by the arch code (like pageattr) where it must be always available if
needed.

The whole exercise for pmd_huge/pmd_trans_huge is about optimizing
away code blocks at build time depending on config options and they're
doing the same thing (pmd_huge just with a slighter slower variation
with !! to return 0/1 instead of 0/_PAGE_PSE), but they're mutually
exclusive by design through the VM_HUGETLB vm_flags and the totally
separate paths of hugetlbfs vs core VM.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
