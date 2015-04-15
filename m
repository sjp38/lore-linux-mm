Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 5B7086B0038
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 07:42:37 -0400 (EDT)
Received: by wizk4 with SMTP id k4so151090050wiz.1
        for <linux-mm@kvack.org>; Wed, 15 Apr 2015 04:42:36 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id z9si9529554wiw.87.2015.04.15.04.42.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Apr 2015 04:42:35 -0700 (PDT)
Date: Wed, 15 Apr 2015 13:42:20 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 3/4] mm: Gather more PFNs before sending a TLB to flush
 unmapped pages
Message-ID: <20150415114220.GG17717@twins.programming.kicks-ass.net>
References: <1429094576-5877-1-git-send-email-mgorman@suse.de>
 <1429094576-5877-4-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1429094576-5877-4-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Apr 15, 2015 at 11:42:55AM +0100, Mel Gorman wrote:
> +/*
> + * Use a page to store as many PFNs as possible for batch unmapping. Adjusting
> + * this trades memory usage for number of IPIs sent
> + */
> +#define BATCH_TLBFLUSH_SIZE \
> +	((PAGE_SIZE - sizeof(struct cpumask) - sizeof(unsigned long)) / sizeof(unsigned long))
>  
>  /* Track pages that require TLB flushes */
>  struct unmap_batch {
> +	/* Update BATCH_TLBFLUSH_SIZE when adjusting this structure */
>  	struct cpumask cpumask;
>  	unsigned long nr_pages;
>  	unsigned long pfns[BATCH_TLBFLUSH_SIZE];

The alternative is something like:

struct unmap_batch {
	struct cpumask cpumask;
	unsigned long nr_pages;
	unsigned long pfnsp[0];
};

#define BATCH_TLBFLUSH_SIZE ((PAGE_SIZE - sizeof(struct unmap_batch)) / sizeof(unsigned long))

and unconditionally allocate 1 page. This saves you from having to worry
about the layout of struct unmap_batch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
