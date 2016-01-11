Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 3DE6F828EB
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 17:35:50 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id yy13so235408163pab.3
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 14:35:50 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id x83si10749954pfi.25.2016.01.11.14.35.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jan 2016 14:35:49 -0800 (PST)
Date: Mon, 11 Jan 2016 14:35:48 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/hugetlbfs: Unmap pages if page fault raced with hole
 punch
Message-Id: <20160111143548.f6dc084529530b05b03b8f0c@linux-foundation.org>
In-Reply-To: <1452119824-32715-1-git-send-email-mike.kravetz@oracle.com>
References: <1452119824-32715-1-git-send-email-mike.kravetz@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Davidlohr Bueso <dave@stgolabs.net>, Dave Hansen <dave.hansen@linux.intel.com>

On Wed,  6 Jan 2016 14:37:04 -0800 Mike Kravetz <mike.kravetz@oracle.com> wrote:

> Page faults can race with fallocate hole punch.  If a page fault happens
> between the unmap and remove operations, the page is not removed and
> remains within the hole.  This is not the desired behavior.  The race
> is difficult to detect in user level code as even in the non-race
> case, a page within the hole could be faulted back in before fallocate
> returns.  If userfaultfd is expanded to support hugetlbfs in the future,
> this race will be easier to observe.
> 
> If this race is detected and a page is mapped, the remove operation
> (remove_inode_hugepages) will unmap the page before removing.  The unmap
> within remove_inode_hugepages occurs with the hugetlb_fault_mutex held
> so that no other faults will be processed until the page is removed.
> 
> The (unmodified) routine hugetlb_vmdelete_list was moved ahead of
> remove_inode_hugepages to satisfy the new reference.
> 
> ...
>
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
>
> ...
>
> @@ -395,37 +431,43 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
>  							mapping, next, 0);
>  			mutex_lock(&hugetlb_fault_mutex_table[hash]);
>  
> -			lock_page(page);
> -			if (likely(!page_mapped(page))) {

hm, what are the locking requirements for page_mapped()?

> -				bool rsv_on_error = !PagePrivate(page);
> -				/*
> -				 * We must free the huge page and remove
> -				 * from page cache (remove_huge_page) BEFORE
> -				 * removing the region/reserve map
> -				 * (hugetlb_unreserve_pages).  In rare out
> -				 * of memory conditions, removal of the
> -				 * region/reserve map could fail.  Before
> -				 * free'ing the page, note PagePrivate which
> -				 * is used in case of error.
> -				 */
> -				remove_huge_page(page);

And remove_huge_page().

> -				freed++;
> -				if (!truncate_op) {
> -					if (unlikely(hugetlb_unreserve_pages(
> -							inode, next,
> -							next + 1, 1)))
> -						hugetlb_fix_reserve_counts(
> -							inode, rsv_on_error);
> -				}
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
