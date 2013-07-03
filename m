Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 0B2E96B0033
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 14:42:48 -0400 (EDT)
Date: Wed, 3 Jul 2013 20:42:13 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 12/13] mm: numa: Scan pages with elevated page_mapcount
Message-ID: <20130703184213.GE18898@dyad.programming.kicks-ass.net>
References: <1372861300-9973-1-git-send-email-mgorman@suse.de>
 <1372861300-9973-13-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1372861300-9973-13-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jul 03, 2013 at 03:21:39PM +0100, Mel Gorman wrote:
> @@ -1587,10 +1588,11 @@ int migrate_misplaced_page(struct page *page, int node)
>  	LIST_HEAD(migratepages);
>  
>  	/*
> +	 * Don't migrate file pages that are mapped in multiple processes
> +	 * with execute permissions as they are probably shared libraries.
>  	 */
> +	if (page_mapcount(page) != 1 && page_is_file_cache(page) &&
> +	    (vma->vm_flags & VM_EXEC))
>  		goto out;

So we will migrate DSOs that are mapped but once. That's fair enough I suppose.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
