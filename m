Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 566076B0003
	for <linux-mm@kvack.org>; Tue, 14 Aug 2018 04:48:43 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id o16-v6so8344946pgv.21
        for <linux-mm@kvack.org>; Tue, 14 Aug 2018 01:48:43 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id r64-v6si22445924pfd.37.2018.08.14.01.48.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Aug 2018 01:48:41 -0700 (PDT)
Date: Tue, 14 Aug 2018 11:48:37 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH] mm: migration: fix migration of huge PMD shared pages
Message-ID: <20180814084837.nl7dkea7aov2pzao@black.fi.intel.com>
References: <20180813034108.27269-1-mike.kravetz@oracle.com>
 <20180813105821.j4tg6iyrdxgwyr3y@kshutemo-mobl1>
 <d4cf0f85-e010-36f2-3fae-f7983e4f6505@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d4cf0f85-e010-36f2-3fae-f7983e4f6505@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Aug 13, 2018 at 11:21:41PM +0000, Mike Kravetz wrote:
> On 08/13/2018 03:58 AM, Kirill A. Shutemov wrote:
> > On Sun, Aug 12, 2018 at 08:41:08PM -0700, Mike Kravetz wrote:
> >> The page migration code employs try_to_unmap() to try and unmap the
> >> source page.  This is accomplished by using rmap_walk to find all
> >> vmas where the page is mapped.  This search stops when page mapcount
> >> is zero.  For shared PMD huge pages, the page map count is always 1
> >> not matter the number of mappings.  Shared mappings are tracked via
> >> the reference count of the PMD page.  Therefore, try_to_unmap stops
> >> prematurely and does not completely unmap all mappings of the source
> >> page.
> >>
> >> This problem can result is data corruption as writes to the original
> >> source page can happen after contents of the page are copied to the
> >> target page.  Hence, data is lost.
> >>
> >> This problem was originally seen as DB corruption of shared global
> >> areas after a huge page was soft offlined.  DB developers noticed
> >> they could reproduce the issue by (hotplug) offlining memory used
> >> to back huge pages.  A simple testcase can reproduce the problem by
> >> creating a shared PMD mapping (note that this must be at least
> >> PUD_SIZE in size and PUD_SIZE aligned (1GB on x86)), and using
> >> migrate_pages() to migrate process pages between nodes.
> >>
> >> To fix, have the try_to_unmap_one routine check for huge PMD sharing
> >> by calling huge_pmd_unshare for hugetlbfs huge pages.  If it is a
> >> shared mapping it will be 'unshared' which removes the page table
> >> entry and drops reference on PMD page.  After this, flush caches and
> >> TLB.
> >>
> >> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> >> ---
> >> I am not %100 sure on the required flushing, so suggestions would be
> >> appreciated.  This also should go to stable.  It has been around for
> >> a long time so still looking for an appropriate 'fixes:'.
> > 
> > I believe we need flushing. And huge_pmd_unshare() usage in
> > __unmap_hugepage_range() looks suspicious: I don't see how we flush TLB in
> > that case.
> 
> Thanks Kirill,
> 
> __unmap_hugepage_range() has two callers:
> 1) unmap_hugepage_range, which wraps the call with tlb_gather_mmu and
>    tlb_finish_mmu on the range.  IIUC, this should cause an appropriate
>    TLB flush.
> 2) __unmap_hugepage_range_final via unmap_single_vma.  unmap_single_vma
>   has three callers:
>   - unmap_vmas which assumes the caller will flush the whole range after
>     return.
>   - zap_page_range wraps the call with tlb_gather_mmu/tlb_finish_mmu
>   - zap_page_range_single wraps the call with tlb_gather_mmu/tlb_finish_mmu
> 
> So, it appears we are covered.  But, I could be missing something.

My problem here is that the mapping that moved by huge_pmd_unshare() in
not accounted into mmu_gather and can be missed on tlb_finish_mmu().

-- 
 Kirill A. Shutemov
