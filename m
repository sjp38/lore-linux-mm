Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 40D766B0036
	for <linux-mm@kvack.org>; Wed, 14 May 2014 23:34:34 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id ld10so478581pab.17
        for <linux-mm@kvack.org>; Wed, 14 May 2014 20:34:33 -0700 (PDT)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id ef1si1967861pbc.128.2014.05.14.20.34.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 14 May 2014 20:34:33 -0700 (PDT)
Received: by mail-pa0-f42.google.com with SMTP id rd3so480532pab.15
        for <linux-mm@kvack.org>; Wed, 14 May 2014 20:34:33 -0700 (PDT)
Message-ID: <1400124866.26173.19.camel@cyc>
Subject: Re: [PATCH] mm/memory-failure.c: fix memory leak by race between
 poison and unpoison
From: cyc <soldier.cyc81@gmail.com>
Date: Thu, 15 May 2014 11:34:26 +0800
In-Reply-To: <1400080891-5145-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1400080891-5145-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

a?? 2014-05-14a,?c?? 11:21 -0400i 1/4 ?Naoya Horiguchia??e??i 1/4 ?
> When a memory error happens on an in-use page or (free and in-use) hugepage,
> the victim page is isolated with its refcount set to one. When you try to
> unpoison it later, unpoison_memory() calls put_page() for it twice in order to
> bring the page back to free page pool (buddy or free hugepage list.)
> However, if another memory error occurs on the page which we are unpoisoning,
> memory_failure() returns without releasing the refcount which was incremented
> in the same call at first, which results in memory leak and unconsistent
> num_poisoned_pages statistics. This patch fixes it.

We assume that a new memory error occurs on the hugepage which we are
unpoisoning. 

          A   unpoisoned  B    poisoned    C          
hugepage: |---------------+++++++++++++++++|

There are two cases, so shown.
  1. the victim page belongs to A-B, the memory_failure will be blocked
by lock_page() until unlock_page() invoked by unpoison_memory().
  2. the victim page belongs to B-C, the memory_failure() will return
very soon at the beginning of this function.

So the new memory error will have no effect what you say so.

thx!
cyc 

> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: <stable@vger.kernel.org>    [2.6.32+]
> ---
>  mm/memory-failure.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git next-20140512.orig/mm/memory-failure.c next-20140512/mm/memory-failure.c
> index 9872af1b1e9d..93a08bd78c78 100644
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


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
