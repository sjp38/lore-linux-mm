Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 9CD756B0031
	for <linux-mm@kvack.org>; Wed,  4 Sep 2013 20:50:35 -0400 (EDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 5 Sep 2013 10:36:35 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 4642B2BB0052
	for <linux-mm@kvack.org>; Thu,  5 Sep 2013 10:50:25 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r850Y9QX55115880
	for <linux-mm@kvack.org>; Thu, 5 Sep 2013 10:34:10 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r850oNSj009840
	for <linux-mm@kvack.org>; Thu, 5 Sep 2013 10:50:24 +1000
Date: Thu, 5 Sep 2013 08:50:22 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [patch] mm, compaction: periodically schedule when freeing pages
Message-ID: <20130905005022.GA27516@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <alpine.DEB.2.02.1309041625060.29607@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1309041625060.29607@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Sep 04, 2013 at 04:25:59PM -0700, David Rientjes wrote:
>We've been getting warnings about an excessive amount of time spent
>allocating pages for migration during memory compaction without
>scheduling.  isolate_freepages_block() already periodically checks for
>contended locks or the need to schedule, but isolate_freepages() never
>does.
>
>When a zone is massively long and no suitable targets can be found, this
>iteration can be quite expensive without ever doing cond_resched().
>
>Check periodically for the need to reschedule while the compaction free
>scanner iterates.
>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>Signed-off-by: David Rientjes <rientjes@google.com>
>---
> mm/compaction.c | 7 +++++++
> 1 file changed, 7 insertions(+)
>
>diff --git a/mm/compaction.c b/mm/compaction.c
>--- a/mm/compaction.c
>+++ b/mm/compaction.c
>@@ -677,6 +677,13 @@ static void isolate_freepages(struct zone *zone,
> 					pfn -= pageblock_nr_pages) {
> 		unsigned long isolated;
>
>+		/*
>+		 * This can iterate a massively long zone without finding any
>+		 * suitable migration targets, so periodically check if we need
>+		 * to schedule.
>+		 */
>+		cond_resched();
>+
> 		if (!pfn_valid(pfn))
> 			continue;
>
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
