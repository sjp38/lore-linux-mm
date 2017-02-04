Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id BCF066B0033
	for <linux-mm@kvack.org>; Sat,  4 Feb 2017 05:33:58 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id c85so9755078wmi.6
        for <linux-mm@kvack.org>; Sat, 04 Feb 2017 02:33:58 -0800 (PST)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id t10si1177031wmb.160.2017.02.04.02.33.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 04 Feb 2017 02:33:57 -0800 (PST)
Received: by mail-wm0-x242.google.com with SMTP id v77so10205838wmv.0
        for <linux-mm@kvack.org>; Sat, 04 Feb 2017 02:33:56 -0800 (PST)
Date: Sat, 4 Feb 2017 13:33:53 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv3 03/12] mm: fix handling PTE-mapped THPs in
 page_referenced()
Message-ID: <20170204103353.GA8013@node.shutemov.name>
References: <20170129173858.45174-1-kirill.shutemov@linux.intel.com>
 <20170129173858.45174-4-kirill.shutemov@linux.intel.com>
 <20170202152655.GB22823@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170202152655.GB22823@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Feb 02, 2017 at 04:26:56PM +0100, Michal Hocko wrote:
> On Sun 29-01-17 20:38:49, Kirill A. Shutemov wrote:
> > For PTE-mapped THP page_check_address_transhuge() is not adequate: it
> > cannot find all relevant PTEs, only the first one. It means we can miss
> > some references of the page and it can result in suboptimal decisions by
> > vmscan.
> > 
> > Let's switch it to page_vma_mapped_walk().
> > 
> > I don't think it's subject for stable@: it's not fatal. The only side
> > effect is that THP can be swapped out when it shouldn't.
> 
> Please be more specific about the situation when this happens and how a
> user can recognize this is going on. In other words when should I
> consider backporting this series.

The first you need huge PMD to get split with split_huge_pmd(). It can
happen due to munmap(), mprotect(), mremap(), etc. After split_huge_pmd()
we have THP mapped with bunch of PTEs instead of single PMD.

The bug is that the kernel only sees pte_young() on the PTEs that maps the
first 4k, but not the rest. So if your access pattern touches the THP, but
not the first 4k, the page can be reclaimed unfairly and possibly
re-faulted from swap soon after.

I don't think it's visible to user, except as unneeded swap-out/swap-in in
on rare occasion.

> Also the interface is quite awkward imho. Why cannot we provide a
> callback into page_vma_mapped_walk and call it for each pte/pmd that
> matters to the given page? Wouldn't that be much easier than the loop
> around page_vma_mapped_walk iterator?

I don't agree that interface with call back would be easier. You would
also need to pass down additional context with packing/unpacking it on
both ends. I don't think it makes interface less awkward.

But it's matter of taste.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
