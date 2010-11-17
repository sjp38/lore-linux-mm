Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 0A7B56B012B
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 09:40:23 -0500 (EST)
Date: Wed, 17 Nov 2010 22:39:03 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 03/13] writeback: per-task rate limit on
 balance_dirty_pages()
Message-ID: <20101117143903.GA11664@localhost>
References: <20101117042720.033773013@intel.com>
 <20101117042849.650810571@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101117042849.650810571@intel.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> +	if (pause == 0 && nr_dirty < background_thresh)
> +		current->nr_dirtied_pause = ratelimit_pages(bdi);
> +	else if (pause == 1)
> +		current->nr_dirtied_pause += current->nr_dirtied_pause >> 5;

Sorry here is a bug fix for the above line, it's also pushed to the
git tree.

Thanks,
Fengguang
---
Subject: writeback: fix increasement of nr_dirtied_pause
Date: Wed Nov 17 22:31:26 CST 2010

Fix a bug that

	current->nr_dirtied_pause += current->nr_dirtied_pause >> 5;

does not effectively increase nr_dirtied_pause when it's <= 32.
Thus nr_dirtied_pause may never grow up..

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-next.orig/mm/page-writeback.c	2010-11-17 22:31:09.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-11-17 22:31:23.000000000 +0800
@@ -662,7 +662,7 @@ pause:
 	if (pause == 0 && nr_dirty < background_thresh)
 		current->nr_dirtied_pause = ratelimit_pages(bdi);
 	else if (pause == 1)
-		current->nr_dirtied_pause += current->nr_dirtied_pause >> 5;
+		current->nr_dirtied_pause += current->nr_dirtied_pause / 32 + 1;
 	else if (pause >= HZ/10)
 		/*
 		 * when repeated, writing 1 page per 100ms on slow devices,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
