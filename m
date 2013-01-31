Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 134AE6B0011
	for <linux-mm@kvack.org>; Thu, 31 Jan 2013 14:34:18 -0500 (EST)
Date: Thu, 31 Jan 2013 11:34:16 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] HWPOISON: fix wrong num_poisoned_pages in handling
 memory error on thp
Message-Id: <20130131113416.963b5f07.akpm@linux-foundation.org>
In-Reply-To: <1359645958-9127-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1359645958-9127-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>, Tony Luck <tony.luck@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 31 Jan 2013 10:25:58 -0500
Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> num_poisoned_pages counts up the number of pages isolated by memory errors.
> But for thp, only one subpage is isolated because memory error handler
> splits it, so it's wrong to add (1 << compound_trans_order).
> 
> ...
>
> --- mmotm-2013-01-23-17-04.orig/mm/memory-failure.c
> +++ mmotm-2013-01-23-17-04/mm/memory-failure.c
> @@ -1039,7 +1039,14 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
>  		return 0;
>  	}
>  
> -	nr_pages = 1 << compound_trans_order(hpage);
> +	/*
> +	 * If a thp is hit by a memory failure, it's supposed to be split.
> +	 * So we should add only one to num_poisoned_pages for that case.
> +	 */
> +	if (PageHuge(p))

/*
 * PageHuge() only returns true for hugetlbfs pages, but not for normal or
 * transparent huge pages.  See the PageTransHuge() documentation for more
 * details.
 */
int PageHuge(struct page *page)
{


> +		nr_pages = 1 << compound_trans_order(hpage);
> +	else /* normal page or thp */
> +		nr_pages = 1;
>  	atomic_long_add(nr_pages, &num_poisoned_pages);
>  
>  	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
