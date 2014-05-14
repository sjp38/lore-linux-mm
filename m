Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 1E9CA6B0036
	for <linux-mm@kvack.org>; Wed, 14 May 2014 18:10:40 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id lj1so163050pab.28
        for <linux-mm@kvack.org>; Wed, 14 May 2014 15:10:39 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id bw8si3218507pad.133.2014.05.14.15.10.38
        for <linux-mm@kvack.org>;
        Wed, 14 May 2014 15:10:39 -0700 (PDT)
Date: Wed, 14 May 2014 15:10:37 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/memory-failure.c: fix memory leak by race between
 poison and unpoison
Message-Id: <20140514151037.37592c3bb31f51fdad8c5a42@linux-foundation.org>
In-Reply-To: <1400080891-5145-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1400080891-5145-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 14 May 2014 11:21:31 -0400 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> When a memory error happens on an in-use page or (free and in-use) hugepage,
> the victim page is isolated with its refcount set to one. When you try to
> unpoison it later, unpoison_memory() calls put_page() for it twice in order to
> bring the page back to free page pool (buddy or free hugepage list.)
> However, if another memory error occurs on the page which we are unpoisoning,
> memory_failure() returns without releasing the refcount which was incremented
> in the same call at first, which results in memory leak and unconsistent
> num_poisoned_pages statistics. This patch fixes it.
> 
> ...
>
> --- next-20140512.orig/mm/memory-failure.c
> +++ next-20140512/mm/memory-failure.c
> @@ -1153,6 +1153,8 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
>  	 */
>  	if (!PageHWPoison(p)) {
>  		printk(KERN_ERR "MCE %#lx: just unpoisoned\n", pfn);
> +		atomic_long_sub(nr_pages, &num_poisoned_pages);
> +		put_page(hpage);
>  		res = 0;
>  		goto out;
>  	}

Looking at the surrounding code...

	/*
	 * Lock the page and wait for writeback to finish.
	 * It's very difficult to mess with pages currently under IO
	 * and in many cases impossible, so we just avoid it here.
	 */
	lock_page(hpage);


lock_page() doesn't wait for writeback to finish -
wait_on_page_writeback() does that.  Either the code or the comment
could do with fixing.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
