Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 8DB926B006E
	for <linux-mm@kvack.org>; Fri, 28 Feb 2014 18:14:30 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id kp14so1289862pab.19
        for <linux-mm@kvack.org>; Fri, 28 Feb 2014 15:14:30 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id fd10si3589296pad.225.2014.02.28.15.14.29
        for <linux-mm@kvack.org>;
        Fri, 28 Feb 2014 15:14:29 -0800 (PST)
Date: Fri, 28 Feb 2014 15:14:27 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm, hugetlbfs: fix rmapping for anonymous hugepages
 with page_pgoff()
Message-Id: <20140228151427.dd232b07960dcf876112e191@linux-foundation.org>
In-Reply-To: <5310ea8b.c425e00a.2cd9.ffffe097SMTPIN_ADDED_BROKEN@mx.google.com>
References: <1393475977-3381-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1393475977-3381-3-git-send-email-n-horiguchi@ah.jp.nec.com>
	<20140227131957.d81cf9a643f4d3fd6b8d8b16@linux-foundation.org>
	<530fb3ee.03cb0e0a.407a.ffffffbcSMTPIN_ADDED_BROKEN@mx.google.com>
	<5310ea8b.c425e00a.2cd9.ffffe097SMTPIN_ADDED_BROKEN@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: sasha.levin@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@redhat.com

On Fri, 28 Feb 2014 14:59:02 -0500 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> page->index stores pagecache index when the page is mapped into file mapping
> region, and the index is in pagecache size unit, so it depends on the page
> size. Some of users of reverse mapping obviously assumes that page->index
> is in PAGE_CACHE_SHIFT unit, so they don't work for anonymous hugepage.
> 
> For example, consider that we have 3-hugepage vma and try to mbind the 2nd
> hugepage to migrate to another node. Then the vma is split and migrate_page()
> is called for the 2nd hugepage (belonging to the middle vma.)
> In migrate operation, rmap_walk_anon() tries to find the relevant vma to
> which the target hugepage belongs, but here we miscalculate pgoff.
> So anon_vma_interval_tree_foreach() grabs invalid vma, which fires VM_BUG_ON.
> 
> This patch introduces a new API that is usable both for normal page and
> hugepage to get PAGE_SIZE offset from page->index. Users should clearly
> distinguish page_index for pagecache index and page_pgoff for page offset.
> 
> ..
>
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -307,6 +307,22 @@ static inline loff_t page_file_offset(struct page *page)
>  	return ((loff_t)page_file_index(page)) << PAGE_CACHE_SHIFT;
>  }
>  
> +static inline unsigned int page_size_order(struct page *page)
> +{
> +	return unlikely(PageHuge(page)) ?
> +		huge_page_size_order(page) :
> +		(PAGE_CACHE_SHIFT - PAGE_SHIFT);
> +}

Could use some nice documentation, please.  Why it exists, what it
does.  Particularly: what sort of pages it can and can't operate on,
and why.

The presence of PAGE_CACHE_SIZE is unfortunate - it at least implies
that the page is a pagecache page.  I dunno, maybe just use "0"?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
