Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 20FE56B0031
	for <linux-mm@kvack.org>; Tue, 10 Sep 2013 09:20:38 -0400 (EDT)
Date: Tue, 10 Sep 2013 14:20:32 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch] mm, compaction: periodically schedule when freeing pages
Message-ID: <20130910132032.GO22421@suse.de>
References: <alpine.DEB.2.02.1309041625060.29607@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1309041625060.29607@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Sep 04, 2013 at 04:25:59PM -0700, David Rientjes wrote:
> We've been getting warnings about an excessive amount of time spent
> allocating pages for migration during memory compaction without
> scheduling.  isolate_freepages_block() already periodically checks for
> contended locks or the need to schedule, but isolate_freepages() never
> does.
> 
> When a zone is massively long and no suitable targets can be found, this
> iteration can be quite expensive without ever doing cond_resched().
> 
> Check periodically for the need to reschedule while the compaction free
> scanner iterates.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Ok, fair enough.

Acked-by: Mel Gorman <mgorman@suse.de>

However I'm curious. Do you know why the combined use of
compact_cached_free_pfn and pageblock skip bits is not enough for the scanner
to quickly find a pageblock that is suitable for isolate_freepages_block()?
Is the pageblock skip information getting cleared frequently by kswapd
or something?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
