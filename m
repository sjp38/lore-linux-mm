Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 1E8AA6B0038
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 15:44:50 -0400 (EDT)
Date: Mon, 5 Aug 2013 15:44:44 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 4/9] mm: zone_reclaim: compaction: reset before
 initializing the scan cursors
Message-ID: <20130805194444.GD1845@cmpxchg.org>
References: <1375459596-30061-1-git-send-email-aarcange@redhat.com>
 <1375459596-30061-5-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1375459596-30061-5-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Johannes Weiner <jweiner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hush Bensen <hush.bensen@gmail.com>

On Fri, Aug 02, 2013 at 06:06:31PM +0200, Andrea Arcangeli wrote:
> Correct the location where we reset the scan cursors, otherwise the
> first iteration of compaction (after restarting it) will only do a
> partial scan.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Reviewed-by: Rik van Riel <riel@redhat.com>
> Acked-by: Mel Gorman <mgorman@suse.de>
> Acked-by: Rafael Aquini <aquini@redhat.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Yes, it does not make sense to read the situation from the cache
first, then two lines later invalidate it because it's stale data.

That being said, why are we maintaining the pageblock skip bits in
addition to the scanner offset caches?  Sometimes we only set the
pageblock skip bit and not update the position cache, but the next
invocation will skip over these blocks anyway because of
!isolation_suitable().  And they are invalidated together.  Aren't
they redundant?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
