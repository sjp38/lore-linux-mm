Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 329E26B0260
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 05:24:57 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id fe3so36061480pab.1
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 02:24:57 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id ez9si5181705pad.150.2016.03.30.02.24.56
        for <linux-mm@kvack.org>;
        Wed, 30 Mar 2016 02:24:56 -0700 (PDT)
Date: Wed, 30 Mar 2016 10:24:48 +0100
From: Steve Capper <steve.capper@arm.com>
Subject: Re: [PATCH] mm: Exclude HugeTLB pages from THP page_mapped logic
Message-ID: <20160330092448.GA19367@e103986-lin>
References: <1459269581-21190-1-git-send-email-steve.capper@arm.com>
 <20160329165149.GA1102@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160329165149.GA1102@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Steve Capper <steve.capper@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, will.deacon@arm.com, dwoods@mellanox.com, mhocko@suse.com, mingo@kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Mar 29, 2016 at 07:51:49PM +0300, Kirill A. Shutemov wrote:
> On Tue, Mar 29, 2016 at 05:39:41PM +0100, Steve Capper wrote:
> > HugeTLB pages cannot be split, thus use the compound_mapcount to
> > track rmaps.
> > 
> > Currently the page_mapped function will check the compound_mapcount, but
> > will also go through the constituent pages of a THP compound page and
> > query the individual _mapcount's too.
> > 
> > Unfortunately, the page_mapped function does not distinguish between
> > HugeTLB and THP compound pages and assumes that a compound page always
> > needs to have HPAGE_PMD_NR pages querying.
> > 
> > For most cases when dealing with HugeTLB this is just inefficient, but
> > for scenarios where the HugeTLB page size is less than the pmd block
> > size (e.g. when using contiguous bit on ARM) this can lead to crashes.
> > 
> > This patch adjusts the page_mapped function such that we skip the
> > unnecessary THP reference checks for HugeTLB pages.
> > 
> > Fixes: e1534ae95004 ("mm: differentiate page_mapped() from page_mapcount() for compound pages")
> > Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Signed-off-by: Steve Capper <steve.capper@arm.com>
> 
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Thanks!

> 
> > ---
> > 
> > Hi,
> > 
> > This patch is my approach to fixing a problem that unearthed with
> > HugeTLB pages on arm64. We ran with PAGE_SIZE=64KB and placed down 32
> > contiguous ptes to create 2MB HugeTLB pages. (We can provide hints to
> > the MMU that page table entries are contiguous thus larger TLB entries
> > can be used to represent them).
> > 
> > The PMD_SIZE was 512MB thus the old version of page_mapped would read
> > through too many struct pages and lead to BUGs.
> > 
> > Original problem reported here:
> > http://lists.infradead.org/pipermail/linux-arm-kernel/2016-March/414657.html
> > 
> > Having examined the HugeTLB code, I understand that only the
> > compound_mapcount_ptr is used to track rmap presence so going through
> > the individual _mapcounts for HugeTLB pages is superfluous? Or should I
> > instead post a patch that changes hpage_nr_pages to use the compound
> > order?
> 
> I would not touch hpage_nr_page().
> 
> We probably need to introduce compound_nr_pages() or something to replace
> (1 << compound_order(page)) to be used independetely from thp/hugetlb
> pages.

Okay, I will stick with the approach in this patch. With HugeTLB we also
have hstate information to use.

> 
> > Also, for the sake of readability, would it be worth changing the
> > definition of PageTransHuge to refer to only THPs (not both HugeTLB
> > and THP)?
> 
> I don't think so.
> 
> That would have overhead, since we wound need to do function call inside
> PageTransHuge(). HugeTLB() is not inlinable.

Ahh, I hadn't considered that...

> 
> hugetlb deverges from rest of mm pretty early, so thp vs. hugetlb
> confusion is not that ofter. We just don't share enough codepath.

Thanks Kirill, agreed.

Cheers,
-- 
Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
