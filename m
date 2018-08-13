Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id ACCB66B0006
	for <linux-mm@kvack.org>; Mon, 13 Aug 2018 06:58:27 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id x2-v6so7094737pgp.4
        for <linux-mm@kvack.org>; Mon, 13 Aug 2018 03:58:27 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 73-v6sor3907148pgc.52.2018.08.13.03.58.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 13 Aug 2018 03:58:26 -0700 (PDT)
Date: Mon, 13 Aug 2018 13:58:21 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: migration: fix migration of huge PMD shared pages
Message-ID: <20180813105821.j4tg6iyrdxgwyr3y@kshutemo-mobl1>
References: <20180813034108.27269-1-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180813034108.27269-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, =?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Sun, Aug 12, 2018 at 08:41:08PM -0700, Mike Kravetz wrote:
> The page migration code employs try_to_unmap() to try and unmap the
> source page.  This is accomplished by using rmap_walk to find all
> vmas where the page is mapped.  This search stops when page mapcount
> is zero.  For shared PMD huge pages, the page map count is always 1
> not matter the number of mappings.  Shared mappings are tracked via
> the reference count of the PMD page.  Therefore, try_to_unmap stops
> prematurely and does not completely unmap all mappings of the source
> page.
> 
> This problem can result is data corruption as writes to the original
> source page can happen after contents of the page are copied to the
> target page.  Hence, data is lost.
> 
> This problem was originally seen as DB corruption of shared global
> areas after a huge page was soft offlined.  DB developers noticed
> they could reproduce the issue by (hotplug) offlining memory used
> to back huge pages.  A simple testcase can reproduce the problem by
> creating a shared PMD mapping (note that this must be at least
> PUD_SIZE in size and PUD_SIZE aligned (1GB on x86)), and using
> migrate_pages() to migrate process pages between nodes.
> 
> To fix, have the try_to_unmap_one routine check for huge PMD sharing
> by calling huge_pmd_unshare for hugetlbfs huge pages.  If it is a
> shared mapping it will be 'unshared' which removes the page table
> entry and drops reference on PMD page.  After this, flush caches and
> TLB.
> 
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> ---
> I am not %100 sure on the required flushing, so suggestions would be
> appreciated.  This also should go to stable.  It has been around for
> a long time so still looking for an appropriate 'fixes:'.

I believe we need flushing. And huge_pmd_unshare() usage in
__unmap_hugepage_range() looks suspicious: I don't see how we flush TLB in
that case.

-- 
 Kirill A. Shutemov
