Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 3EF9F6B01E5
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 06:28:29 -0400 (EDT)
Date: Tue, 15 Jun 2010 14:28:22 +0400
From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH 11/12] vmscan: Write out dirty pages in batch
Message-ID: <20100615102822.GA4010@ioremap.net>
References: <1276514273-27693-1-git-send-email-mel@csn.ul.ie> <1276514273-27693-12-git-send-email-mel@csn.ul.ie> <20100614231144.GG6590@dastard> <20100614162143.04783749.akpm@linux-foundation.org> <20100615003943.GK6590@dastard> <20100614183957.ad0cdb58.akpm@linux-foundation.org> <20100615032034.GR6590@dastard> <20100614211515.dd9880dc.akpm@linux-foundation.org> <20100615063643.GS6590@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100615063643.GS6590@dastard>
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 15, 2010 at 04:36:43PM +1000, Dave Chinner (david@fromorbit.com) wrote:
> > Nope.  Large-number-of-small-files is a pretty common case.  If the fs
> > doesn't handle that well (ie: by placing them nearby on disk), it's
> > borked.
> 
> Filesystems already handle this case just fine as we see it from
> writeback all the time. Untarring a kernel is a good example of
> this...
> 
> I suggested sorting all the IO to be issued into per-mapping page
> groups because:
> 	a) makes IO issued from reclaim look almost exactly the same
> 	   to the filesytem as if writeback is pushing out the IO.
> 	b) it looks to be a trivial addition to the new code.
> 
> To me that's a no-brainer.

That doesn't coverup large-number-of-small-files pattern, since
untarring subsequently means creating something new, which FS can
optimize. Much more interesting case is when we have dirtied large
number of small files in kind-of random order and submitted them
down to disk.

Per-mapping sorting will not do anything good in this case, even if
files were previously created in a good facion being placed closely and
so on, and only block layer will find a correlation between adjacent
blocks in different files. But with existing queue management it has
quite a small opportunity, and that's what I think Andrew is arguing
about.

-- 
	Evgeniy Polyakov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
