Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 478E76B005C
	for <linux-mm@kvack.org>; Tue, 10 Jan 2012 11:44:12 -0500 (EST)
Date: Tue, 10 Jan 2012 16:44:07 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: vmscan: fix setting reclaim mode
Message-ID: <20120110164407.GD4118@suse.de>
References: <CAJd=RBAqzawZ=jEFt7TrZgU0gaejMkfiBxzH7Y19qqNnsZrJGw@mail.gmail.com>
 <20120110094452.GC4118@suse.de>
 <CAJd=RBA7vj83SFQFMS5WaRCfz2ndGJXepBqi5tK0LPjnBYYgfg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAJd=RBA7vj83SFQFMS5WaRCfz2ndGJXepBqi5tK0LPjnBYYgfg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jan 10, 2012 at 11:58:03PM +0800, Hillf Danton wrote:
> From: Hillf Danton <dhillf@gmail.com>
> [PATCH] mm: vmscan: fix setting reclaim mode
> 
> The comment says, initially assume we are entering either lumpy reclaim or
> reclaim/compaction, and depending on the reclaim order, we will either set the
> sync mode or just reclaim order-0 pages later.
> 
> On other hand, order-0 reclaim, instead of sync reclaim, is expected when
> under memory pressure, but the check for memory pressure is incorrect,
> leading to sync reclaim at low reclaim priorities.
> 
> And the result is sync reclaim is set for high priorities.
> 

RECLAIM_MODE_SYNC is only set for RECLAIM_MODE_LUMPYRECLAIM. Even when
using RECLAIM_MODE_LUMPYRECLAIM, it should only be set when reclaim
is under memory pressure and failing to reclaim the necessry pages
(priority < DEF_PRIORITY - 2). Once in symc reclaim, reclaim will call
wait_on_page_writeback() on dirty pages which potentially leads to
significant stalls (one of the reasons why RECLAIM_MODE_LUMPYRECLAIM
sucks and why compaction is preferred). Your patch means sync reclaim
is used even when priority == DEF_PRIORITY. This is unexpected.

Your changelog really needs to explain what the problem is that you
have encountered and why this patch fixes it. It's not like some of
your other patches which were minor performance optimisations that
were self-evident.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
