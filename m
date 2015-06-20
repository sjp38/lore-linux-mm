Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id D60556B009E
	for <linux-mm@kvack.org>; Sat, 20 Jun 2015 15:46:28 -0400 (EDT)
Received: by wicnd19 with SMTP id nd19so44975922wic.1
        for <linux-mm@kvack.org>; Sat, 20 Jun 2015 12:46:28 -0700 (PDT)
Received: from johanna1.rokki.sonera.fi (mta-out1.inet.fi. [62.71.2.230])
        by mx.google.com with ESMTP id ew11si26647619wjd.9.2015.06.20.12.46.26
        for <linux-mm@kvack.org>;
        Sat, 20 Jun 2015 12:46:27 -0700 (PDT)
Date: Sat, 20 Jun 2015 22:46:12 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: Fix MAP_POPULATE and mlock() for DAX
Message-ID: <20150620194612.GA5268@node.dhcp.inet.fi>
References: <1434493710-11138-1-git-send-email-toshi.kani@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1434493710-11138-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, willy@linux.intel.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org

On Tue, Jun 16, 2015 at 04:28:30PM -0600, Toshi Kani wrote:
> DAX has the following issues in a shared or read-only private
> mmap'd file.
>  - mmap(MAP_POPULATE) does not pre-fault
>  - mlock() fails with -ENOMEM
> 
> DAX uses VM_MIXEDMAP for mmap'd files, which do not have struct
> page associated with the ranges.  Both MAP_POPULATE and mlock()
> call __mm_populate(), which in turn calls __get_user_pages().
> Because __get_user_pages() requires a valid page returned from
> follow_page_mask(), MAP_POPULATE and mlock(), i.e. FOLL_POPULATE,
> fail in the first page.
> 
> Change __get_user_pages() to proceed FOLL_POPULATE when the
> translation is set but its page does not exist (-EFAULT), and
> @pages is not requested.  With that, MAP_POPULATE and mlock()
> set translations to the requested range and complete successfully.
> 
> MAP_POPULATE still provides a major performance improvement to
> DAX as it will avoid page faults during initial access to the
> pages.
> 
> mlock() continues to set VM_LOCKED to vma and populate the range.
> Since there is no struct page, the range is pinned without marking
> pages mlocked.
> 
> Note, MAP_POPULATE and mlock() already work for a write-able
> private mmap'd file on DAX since populate_vma_page_range() breaks
> COW, which allocates page caches.

I don't think that's true in all cases.

We would fail to break COW for mlock() if the mapping is populated with
read-only entries by the mlock() time. In this case follow_page_mask()
would fail with -EFAULT and faultin_page() will never executed.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
