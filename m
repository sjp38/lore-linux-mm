Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id BB5E76B004D
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 21:42:20 -0400 (EDT)
Date: Tue, 9 Jun 2009 09:58:22 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 1/3] Reintroduce zone_reclaim_interval for when
	zone_reclaim() scans and fails to avoid CPU spinning at 100% on NUMA
Message-ID: <20090609015822.GA6740@localhost>
References: <1244466090-10711-1-git-send-email-mel@csn.ul.ie> <1244466090-10711-2-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1244466090-10711-2-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, "Zhang, Yanmin" <yanmin.zhang@intel.com>, "linuxram@us.ibm.com" <linuxram@us.ibm.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 08, 2009 at 09:01:28PM +0800, Mel Gorman wrote:
> On NUMA machines, the administrator can configure zone_reclaim_mode that is a
> more targetted form of direct reclaim. On machines with large NUMA distances,
> zone_reclaim_mode defaults to 1 meaning that clean unmapped pages will be
> reclaimed if the zone watermarks are not being met. The problem is that
> zone_reclaim() can be in a situation where it scans excessively without
> making progress.
> 
> One such situation is where a large tmpfs mount is occupying a large
> percentage of memory overall. The pages do not get cleaned or reclaimed by
> zone_reclaim(), but the lists are uselessly scanned frequencly making the
> CPU spin at 100%. The scanning occurs because zone_reclaim() cannot tell
> in advance the scan is pointless because the counters do not distinguish
> between pagecache pages backed by disk and by RAM.  The observation in
> the field is that malloc() stalls for a long time (minutes in some cases)
> when this situation occurs.
> 
> Accounting for ram-backed file pages was considered but not implemented on
> the grounds it would be introducing new branches and expensive checks into
> the page cache add/remove patches and increase the number of statistics
> needed in the zone. As zone_reclaim() failing is currently considered a
> corner case, this seemed like overkill. Note, if there are a large number
> of reports about CPU spinning at 100% on NUMA that is fixed by disabling
> zone_reclaim, then this assumption is false and zone_reclaim() scanning
> and failing is not a corner case but a common occurance
> 
> This patch reintroduces zone_reclaim_interval which was removed by commit
> 34aa1330f9b3c5783d269851d467326525207422 [zoned vm counters: zone_reclaim:
> remove /proc/sys/vm/zone_reclaim_interval] because the zone counters were
> considered sufficient to determine in advance if the scan would succeed.
> As unsuccessful scans can still occur, zone_reclaim_interval is still
> required.

Can we avoid the user visible parameter zone_reclaim_interval?

That means to introduce some heuristics for it. Since the whole point
is to avoid 100% CPU usage, we can take down the time used for this
failed zone reclaim (T) and forbid zone reclaim until (NOW + 100*T).

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
