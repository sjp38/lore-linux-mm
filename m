Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id 45E5A6B006C
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 13:39:52 -0400 (EDT)
Received: by lbcmq2 with SMTP id mq2so125274lbc.0
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 10:39:51 -0700 (PDT)
Received: from mail-la0-x230.google.com (mail-la0-x230.google.com. [2a00:1450:4010:c03::230])
        by mx.google.com with ESMTPS id i6si3434584lbj.168.2015.03.24.10.39.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Mar 2015 10:39:50 -0700 (PDT)
Received: by lagg8 with SMTP id g8so45435lag.1
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 10:39:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com>
Date: Tue, 24 Mar 2015 20:39:49 +0300
Message-ID: <CALYGNiOSczCjcJPWocXFnBm=mF7zjeA+xd9j=wBS_ZjZL5z0Pw@mail.gmail.com>
Subject: Re: [PATCH 00/16] Sanitize usage of ->flags and ->mapping for tail pages
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Mar 19, 2015 at 8:08 PM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> Currently we take naive approach to page flags on compound -- we set the
> flag on the page without consideration if the flag makes sense for tail
> page or for compound page in general. This patchset try to sort this out
> by defining per-flag policy on what need to be done if page-flag helper
> operate on compound page.
>
> The last patch in patchset also sanitize usege of page->mapping for tail
> pages. We don't define meaning of page->mapping for tail pages. Currently
> it's always NULL, which can be inconsistent with head page and potentially
> lead to problems.
>
> For now I catched one case of illigal usage of page flags or ->mapping:
> sound subsystem allocates pages with __GFP_COMP and maps them with PTEs.
> It leads to setting dirty bit on tail pages and access to tail_page's
> ->mapping. I don't see any bad behaviour caused by this, but worth fixing
> anyway.

Do you mean call of set_page_dirty() from zap_pte_range() ?
I think this should be replaced with vma operation:
vma->vm_ops->set_page_dirty()

>
> This patchset makes more sense if you take my THP refcounting into
> account: we will see more compound pages mapped with PTEs and we need to
> define behaviour of flags on compound pages to avoid bugs.
>
> Kirill A. Shutemov (16):
>   mm: consolidate all page-flags helpers in <linux/page-flags.h>
>   page-flags: trivial cleanup for PageTrans* helpers
>   page-flags: introduce page flags policies wrt compound pages
>   page-flags: define PG_locked behavior on compound pages
>   page-flags: define behavior of FS/IO-related flags on compound pages
>   page-flags: define behavior of LRU-related flags on compound pages
>   page-flags: define behavior SL*B-related flags on compound pages
>   page-flags: define behavior of Xen-related flags on compound pages
>   page-flags: define PG_reserved behavior on compound pages
>   page-flags: define PG_swapbacked behavior on compound pages
>   page-flags: define PG_swapcache behavior on compound pages
>   page-flags: define PG_mlocked behavior on compound pages
>   page-flags: define PG_uncached behavior on compound pages
>   page-flags: define PG_uptodate behavior on compound pages
>   page-flags: look on head page if the flag is encoded in page->mapping
>   mm: sanitize page->mapping for tail pages
>
>  fs/cifs/file.c             |   8 +-
>  include/linux/hugetlb.h    |   7 -
>  include/linux/ksm.h        |  17 ---
>  include/linux/mm.h         | 122 +----------------
>  include/linux/page-flags.h | 317 ++++++++++++++++++++++++++++++++++-----------
>  include/linux/pagemap.h    |  25 ++--
>  include/linux/poison.h     |   4 +
>  mm/filemap.c               |  15 ++-
>  mm/huge_memory.c           |   2 +-
>  mm/ksm.c                   |   2 +-
>  mm/memory-failure.c        |   2 +-
>  mm/memory.c                |   2 +-
>  mm/migrate.c               |   2 +-
>  mm/page_alloc.c            |   7 +
>  mm/shmem.c                 |   4 +-
>  mm/slub.c                  |   2 +
>  mm/swap_state.c            |   4 +-
>  mm/util.c                  |   5 +-
>  mm/vmscan.c                |   4 +-
>  mm/zswap.c                 |   4 +-
>  20 files changed, 294 insertions(+), 261 deletions(-)
>
> --
> 2.1.4
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
