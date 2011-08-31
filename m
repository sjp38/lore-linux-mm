Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 533D96B016C
	for <linux-mm@kvack.org>; Wed, 31 Aug 2011 10:42:02 -0400 (EDT)
Received: by yib2 with SMTP id 2so717642yib.14
        for <linux-mm@kvack.org>; Wed, 31 Aug 2011 07:42:00 -0700 (PDT)
Date: Wed, 31 Aug 2011 23:41:50 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 2/3] compaction: compact unevictable page
Message-ID: <20110831144150.GA1860@barrios-desktop>
References: <cover.1321112552.git.minchan.kim@gmail.com>
 <8ef02605a7a76b176167d90a285033afa8513326.1321112552.git.minchan.kim@gmail.com>
 <20110831111954.GB17512@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110831111954.GB17512@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

On Wed, Aug 31, 2011 at 01:19:54PM +0200, Johannes Weiner wrote:
> On Sun, Nov 13, 2011 at 01:37:42AM +0900, Minchan Kim wrote:
> > Now compaction doesn't handle mlocked page as it uses __isolate_lru_page
> > which doesn't consider unevicatable page. It has been used by just lumpy so
> > it was pointless that it isolates unevictable page. But the situation is
> > changed. Compaction could handle unevictable page and it can help getting
> > big contiguos pages in fragment memory by many pinned page with mlock.
> 
> This may result in applications unexpectedly faulting and waiting on
> mlocked pages under migration.  I wonder how realtime people feel
> about that?

I didn't consider it but it's very important point.
The migrate_page can call pageout on dirty page so RT process could wait on the
mlocked page during very long time.
I can mitigate it with isolating mlocked page in case of !sync but still we can't
guarantee the time because we can't know how many vmas point the page so that try_to_unmap
could spend lots of time.

We can think it's a trade off between high order allocation VS RT latency.
Now I am biasing toward RT latency as considering mlock man page.

Any thoughts?

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
