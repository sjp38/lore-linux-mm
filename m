Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 0DB806B002C
	for <linux-mm@kvack.org>; Tue, 31 Jan 2012 15:40:27 -0500 (EST)
Date: Tue, 31 Jan 2012 12:40:26 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: compaction: Check pfn_valid when entering a new
 MAX_ORDER_NR_PAGES block during isolation for migration
Message-Id: <20120131124026.15c0f495.akpm@linux-foundation.org>
In-Reply-To: <20120131163528.GR4065@suse.de>
References: <20120131163528.GR4065@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Herbert van den Bergh <herbert.van.den.bergh@oracle.com>, Michal Nazarewicz <mina86@mina86.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 31 Jan 2012 16:35:28 +0000
Mel Gorman <mgorman@suse.de> wrote:

> When isolating for migration, migration starts at the start of a zone
> which is not necessarily pageblock aligned. Further, it stops isolating
> when COMPACT_CLUSTER_MAX pages are isolated so migrate_pfn is generally
> not aligned.
> 
> The problem is that pfn_valid is only called on the first PFN being
> checked. Lets say we have a case like this
> 
> H = MAX_ORDER_NR_PAGES boundary
> | = pageblock boundary
> m = cc->migrate_pfn
> f = cc->free_pfn
> o = memory hole
> 
> H------|------H------|----m-Hoooooo|ooooooH-f----|------H
> 
> The migrate_pfn is just below a memory hole and the free scanner is
> beyond the hole. When isolate_migratepages started, it scans from
> migrate_pfn to migrate_pfn+pageblock_nr_pages which is now in a memory
> hole. It checks pfn_valid() on the first PFN but then scans into the
> hole where there are not necessarily valid struct pages.
> 
> This patch ensures that isolate_migratepages calls pfn_valid when
> necessary.
> 
> Reported-and-tested-by: Herbert van den Bergh <herbert.van.den.bergh@oracle.com>
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> Acked-by: Michal Nazarewicz <mina86@mina86.com>

The changelog forgot to describe the user-visible effects of the bug.

> Cc: stable@kernel.org

So he (and others) will be confused.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
