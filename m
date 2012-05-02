Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 636646B004D
	for <linux-mm@kvack.org>; Tue,  1 May 2012 21:10:46 -0400 (EDT)
Date: Wed, 2 May 2012 03:10:31 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [patch 0/5] refault distance-based file cache sizing
Message-ID: <20120502011031.GD22923@redhat.com>
References: <1335861713-4573-1-git-send-email-hannes@cmpxchg.org>
 <20120501120819.0af1e54b.akpm@linux-foundation.org>
 <4FA05354.8000304@redhat.com>
 <20120501142656.c9160d96.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120501142656.c9160d96.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Hi,

On Tue, May 01, 2012 at 02:26:56PM -0700, Andrew Morton wrote:
> Well, think of a stupid workload which creates a large number of very
> large but sparse files (populated with one page in each 64, for
> example).  Get them all in cache, then sit there touching the inodes to
> keep then fresh.  What's the worst case here?

I suspect in that scenario we may drop more inodes than before and so
a ton of their cache with it and actually worsen the LRU effect
instead of improving them.

I don't think it's a reliablity issue, or we would probably be bitten
by it already, especially with a ton of inodes with just one page at a
very large file offset accessed in a loop. This only makes more sticky
a badness we already have. Testing it for sure, wouldn't be a bad idea
though.

At first glance it sounds like a good tradeoff, as normally the
"worsening" effect of when we have too many and large radix trees that
would lead to more inodes to be dropped than before, shouldn't
materialize and we'd just make better use of the memory we already
allocated to make more accurate decisions on the active/inactive
LRU balancing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
