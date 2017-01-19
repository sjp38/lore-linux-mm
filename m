Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id DAB0A6B02BE
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 13:16:38 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id d134so66752003pfd.0
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 10:16:38 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r11si4209760pgn.300.2017.01.19.10.16.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jan 2017 10:16:38 -0800 (PST)
Date: Thu, 19 Jan 2017 19:16:51 +0100
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] mm/hugetlb.c: fix reservation race when freeing surplus
 pages
Message-ID: <20170119181651.GA30720@kroah.com>
References: <1483991767-6879-1-git-send-email-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1483991767-6879-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Paul Cassella <cassella@cray.com>, Michal Hocko <mhocko@kernel.org>, Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org

On Mon, Jan 09, 2017 at 11:56:07AM -0800, Mike Kravetz wrote:
> The routine return_unused_surplus_pages decrements the global
> reservation count, and frees any unused surplus pages that were
> backing the reservation.  Commit 7848a4bf51b3 ("mm/hugetlb.c:
> add cond_resched_lock() in return_unused_surplus_pages()") added
> a call to cond_resched_lock in the loop freeing the pages.  As
> a result, the hugetlb_lock could be dropped, and someone else
> could use the pages that will be freed in subsequent iterations
> of the loop.  This could result in inconsistent global hugetlb
> page state, application api failures (such as mmap) failures or
> application crashes.
> 
> When dropping the lock in return_unused_surplus_pages, make sure
> that the global reservation count (resv_huge_pages) remains
> sufficiently large to prevent someone else from claiming pages
> about to be freed.
> 
> Fixes: 7848a4bf51b3 ("mm/hugetlb.c: add cond_resched_lock() in return_unused_surplus_pages()")
> Reported-and-analyzed-by: Paul Cassella <cassella@cray.com>
> Suggested-by: Michal Hocko <mhocko@kernel.org>
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> ---
>  mm/hugetlb.c | 37 ++++++++++++++++++++++++++++---------
>  1 file changed, 28 insertions(+), 9 deletions(-)

<formletter>

This is not the correct way to submit patches for inclusion in the
stable kernel tree.  Please read Documentation/stable_kernel_rules.txt
for how to do this properly.

</formletter>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
