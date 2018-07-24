Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 052366B0003
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 16:53:53 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id r20-v6so2619783pgv.20
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 13:53:52 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id a10-v6si11256861pff.304.2018.07.24.13.53.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jul 2018 13:53:51 -0700 (PDT)
Date: Tue, 24 Jul 2018 13:53:50 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] RFC: clear 1G pages with streaming stores on x86
Message-Id: <20180724135350.91a90f4f8742ec59c42721c3@linux-foundation.org>
In-Reply-To: <20180724204639.26934-1-cannonmatthews@google.com>
References: <20180724204639.26934-1-cannonmatthews@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cannon Matthews <cannonmatthews@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andres Lagar-Cavilla <andreslc@google.com>, Salman Qazi <sqazi@google.com>, Paul Turner <pjt@google.com>, David Matlack <dmatlack@google.com>, Peter Feiner <pfeiner@google.com>, Alain Trinh <nullptr@google.com>

On Tue, 24 Jul 2018 13:46:39 -0700 Cannon Matthews <cannonmatthews@google.com> wrote:

> Reimplement clear_gigantic_page() to clear gigabytes pages using the
> non-temporal streaming store instructions that bypass the cache
> (movnti), since an entire 1GiB region will not fit in the cache anyway.
> 
> ...
> 
> Tested:
> 	Time to `mlock()` a 512GiB region on broadwell CPU
> 				AVG time (s)	% imp.	ms/page
> 	clear_page_erms		133.584		-	261
> 	clear_page_nt		34.154		74.43%	67

A gigantic improvement!

> --- a/arch/x86/include/asm/page_64.h
> +++ b/arch/x86/include/asm/page_64.h
> @@ -56,6 +56,9 @@ static inline void clear_page(void *page)
> 
>  void copy_page(void *to, void *from);
> 
> +#define __HAVE_ARCH_CLEAR_GIGANTIC_PAGE
> +void __clear_page_nt(void *page, u64 page_size);

Nit: the modern way is

#ifndef __clear_page_nt
void __clear_page_nt(void *page, u64 page_size);
#define __clear_page_nt __clear_page_nt
#endif

Not sure why, really.  I guess it avoids adding two symbols and 
having to remember and maintain the relationship between them.

> --- /dev/null
> +++ b/arch/x86/lib/clear_gigantic_page.c
> @@ -0,0 +1,30 @@
> +#include <asm/page.h>
> +
> +#include <linux/kernel.h>
> +#include <linux/mm.h>
> +#include <linux/sched.h>
> +
> +#if defined(CONFIG_TRANSPARENT_HUGEPAGE) || defined(CONFIG_HUGETLBFS)
> +#define PAGES_BETWEEN_RESCHED 64
> +void clear_gigantic_page(struct page *page,
> +				unsigned long addr,
> +				unsigned int pages_per_huge_page)
> +{
> +	int i;
> +	void *dest = page_to_virt(page);
> +	int resched_count = 0;
> +
> +	BUG_ON(pages_per_huge_page % PAGES_BETWEEN_RESCHED != 0);
> +	BUG_ON(!dest);
> +
> +	might_sleep();

cond_resched() already does might_sleep() - it doesn't seem needed here.

> +	for (i = 0; i < pages_per_huge_page; i += PAGES_BETWEEN_RESCHED) {
> +		__clear_page_nt(dest + (i * PAGE_SIZE),
> +				PAGES_BETWEEN_RESCHED * PAGE_SIZE);
> +		resched_count += cond_resched();
> +	}
> +	/* __clear_page_nt requrires and `sfence` barrier. */
> +	wmb();
> +	pr_debug("clear_gigantic_page: rescheduled %d times\n", resched_count);
> +}
> +#endif
