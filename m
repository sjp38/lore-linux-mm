Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3E71E6B0038
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 14:06:04 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 22so5155858wrb.7
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 11:06:04 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id t26si760940edc.328.2017.10.03.11.06.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Oct 2017 11:06:02 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 3C23199170
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 18:06:02 +0000 (UTC)
Date: Tue, 3 Oct 2017 19:04:27 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm/mempolicy: fix NUMA_INTERLEAVE_HIT counter
Message-ID: <20171003180427.lhdeb6yyhfjfve3d@techsingularity.net>
References: <20171003164720.22130-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20171003164720.22130-1-aryabinin@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Kemi Wang <kemi.wang@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Oct 03, 2017 at 07:47:20PM +0300, Andrey Ryabinin wrote:
> Commit 3a321d2a3dde separated NUMA counters from zone counters, but
> the NUMA_INTERLEAVE_HIT call site wasn't updated to use the new interface.
> So alloc_page_interleave() actually increments NR_ZONE_INACTIVE_FILE
> instead of NUMA_INTERLEAVE_HIT.
> 
> Fix this by using __inc_numa_state() interface to increment
> NUMA_INTERLEAVE_HIT.
> 
> Fixes: 3a321d2a3dde ("mm: change the call sites of numa statistics items")
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> ---
>  mm/mempolicy.c | 9 +++++++--
>  1 file changed, 7 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 006ba625c0b8..3a18f0a091c4 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1920,8 +1920,13 @@ static struct page *alloc_page_interleave(gfp_t gfp, unsigned order,
>  	struct page *page;
>  
>  	page = __alloc_pages(gfp, order, nid);
> -	if (page && page_to_nid(page) == nid)
> -		inc_zone_page_state(page, NUMA_INTERLEAVE_HIT);
> +	if (page && page_to_nid(page) == nid) {
> +		unsigned long flags;
> +
> +		local_irq_save(flags);
> +		__inc_numa_state(page_zone(page), NUMA_INTERLEAVE_HIT);
> +		local_irq_restore(flags);
> +	}
>  	return page;
>  }

alloc_page_interleave is only called from !irq contexts and the requirements
for __inc_numa_state should only require interrupt disabling if that
particular counter can be updated from interrupt context. Disabling
preemption should be sufficient for NUMA_INTERLEAVE_HIT and would be cheaper.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
