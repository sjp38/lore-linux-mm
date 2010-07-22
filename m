Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 43B896B02A3
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 19:49:53 -0400 (EDT)
Date: Thu, 22 Jul 2010 16:49:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC]mm: batch activate_page() to reduce lock contention
Message-Id: <20100722164921.4918399f.akpm@linux-foundation.org>
In-Reply-To: <1279610324.17101.9.camel@sli10-desk.sh.intel.com>
References: <1279610324.17101.9.camel@sli10-desk.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, "Wu, Fengguang" <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, 20 Jul 2010 15:18:44 +0800
Shaohua Li <shaohua.li@intel.com> wrote:

> +void activate_page(struct page *page)
> +{
> +	struct pagevec *pvec = &get_cpu_var(activate_page_pvecs);
> +
> +	page_cache_get(page);
> +	if (!pagevec_add(pvec, page))
> +		activate_page_drain_cpu(smp_processor_id());
> +	put_cpu_var(activate_page_pvecs);
>  }

uhm, could I please draw attention to the most valuable
Documentation/SubmitChecklist?  In particular,

12: Has been tested with CONFIG_PREEMPT, CONFIG_DEBUG_PREEMPT,
    CONFIG_DEBUG_SLAB, CONFIG_DEBUG_PAGEALLOC, CONFIG_DEBUG_MUTEXES,
    CONFIG_DEBUG_SPINLOCK, CONFIG_DEBUG_SPINLOCK_SLEEP all simultaneously
    enabled.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
