Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4CC106B0003
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 16:35:48 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id k21-v6so1693700pfi.12
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 13:35:48 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o61-v6si24667430pld.109.2018.07.13.13.35.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jul 2018 13:35:47 -0700 (PDT)
Date: Fri, 13 Jul 2018 13:35:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v1 1/2] mm: fix race on soft-offlining free huge pages
Message-Id: <20180713133545.658173ca953e7d2a8a4ee6bd@linux-foundation.org>
In-Reply-To: <1531452366-11661-2-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1531452366-11661-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1531452366-11661-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, xishi.qiuxishi@alibaba-inc.com, zy.zhengyi@alibaba-inc.com, linux-kernel@vger.kernel.org

On Fri, 13 Jul 2018 12:26:05 +0900 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> There's a race condition between soft offline and hugetlb_fault which
> causes unexpected process killing and/or hugetlb allocation failure.
> 
> The process killing is caused by the following flow:
> 
>   CPU 0               CPU 1              CPU 2
> 
>   soft offline
>     get_any_page
>     // find the hugetlb is free
>                       mmap a hugetlb file
>                       page fault
>                         ...
>                           hugetlb_fault
>                             hugetlb_no_page
>                               alloc_huge_page
>                               // succeed
>       soft_offline_free_page
>       // set hwpoison flag
>                                          mmap the hugetlb file
>                                          page fault
>                                            ...
>                                              hugetlb_fault
>                                                hugetlb_no_page
>                                                  find_lock_page
>                                                    return VM_FAULT_HWPOISON
>                                            mm_fault_error
>                                              do_sigbus
>                                              // kill the process
> 
> 
> The hugetlb allocation failure comes from the following flow:
> 
>   CPU 0                          CPU 1
> 
>                                  mmap a hugetlb file
>                                  // reserve all free page but don't fault-in
>   soft offline
>     get_any_page
>     // find the hugetlb is free
>       soft_offline_free_page
>       // set hwpoison flag
>         dissolve_free_huge_page
>         // fail because all free hugepages are reserved
>                                  page fault
>                                    ...
>                                      hugetlb_fault
>                                        hugetlb_no_page
>                                          alloc_huge_page
>                                            ...
>                                              dequeue_huge_page_node_exact
>                                              // ignore hwpoisoned hugepage
>                                              // and finally fail due to no-mem
> 
> The root cause of this is that current soft-offline code is written
> based on an assumption that PageHWPoison flag should beset at first to
> avoid accessing the corrupted data.  This makes sense for memory_failure()
> or hard offline, but does not for soft offline because soft offline is
> about corrected (not uncorrected) error and is safe from data lost.
> This patch changes soft offline semantics where it sets PageHWPoison flag
> only after containment of the error page completes successfully.
> 
> ...
>
> --- v4.18-rc4-mmotm-2018-07-10-16-50/mm/memory-failure.c
> +++ v4.18-rc4-mmotm-2018-07-10-16-50_patched/mm/memory-failure.c
> @@ -1598,8 +1598,18 @@ static int soft_offline_huge_page(struct page *page, int flags)
>  		if (ret > 0)
>  			ret = -EIO;
>  	} else {
> -		if (PageHuge(page))
> -			dissolve_free_huge_page(page);
> +		/*
> +		 * We set PG_hwpoison only when the migration source hugepage
> +		 * was successfully dissolved, because otherwise hwpoisoned
> +		 * hugepage remains on free hugepage list, then userspace will
> +		 * find it as SIGBUS by allocation failure. That's not expected
> +		 * in soft-offlining.
> +		 */

This comment is unclear.  What happens if there's a hwpoisoned page on
the freelist?  The allocator just skips it and looks for another page? 
Or does the allocator return the poisoned page, it gets mapped and
userspace gets a SIGBUS when accessing it?  If the latter (or the
former!), why does the comment mention allocation failure?
