Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 3F0FC6B004D
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 05:12:27 -0500 (EST)
Date: Thu, 5 Jan 2012 10:12:22 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v2] mm/compaction : fix the wrong return value for
 isolate_migratepages()
Message-ID: <20120105101222.GD28031@suse.de>
References: <1325322585-16216-1-git-send-email-b32955@freescale.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1325322585-16216-1-git-send-email-b32955@freescale.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huang Shijie <b32955@freescale.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, shijie8@gmail.com

On Sat, Dec 31, 2011 at 05:09:45PM +0800, Huang Shijie wrote:
> When we do not get any migrate page, we should return ISOLATE_NONE.
> 

Why?

Returning ISOLATE_SUCCESS means that we fall through. This means busy
work in migrate_pages(), updating list accounting and the list. It's
wasteful but is it functionally incorrect? What problem did you observe?

If this is simply a performance issue then minimally COMPACTBLOCKS
still needs to be updated, we still want to see the tracepoint etc. To
preserve that, I would suggest as an alternative to leave it returning
ISOLATE_SUCCESS but move


               err = migrate_pages(&cc->migratepages, compaction_alloc,
                                (unsigned long)cc, false,
                                cc->sync ? MIGRATE_SYNC_LIGHT : MIGRATE_ASYNC);
                update_nr_listpages(cc);

inside a if (nr_migrate) check to avoid some overhead.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
