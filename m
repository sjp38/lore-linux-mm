Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 1F1476B0083
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 01:53:32 -0400 (EDT)
Date: Tue, 9 Jun 2009 22:54:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/4] Reintroduce zone_reclaim_interval for when
 zone_reclaim() scans and fails to avoid CPU spinning at 100% on NUMA
Message-Id: <20090609225425.b0820ce5.akpm@linux-foundation.org>
In-Reply-To: <1244566904-31470-5-git-send-email-mel@csn.ul.ie>
References: <1244566904-31470-1-git-send-email-mel@csn.ul.ie>
	<1244566904-31470-5-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, yanmin.zhang@intel.com, Wu Fengguang <fengguang.wu@intel.com>, linuxram@us.ibm.com, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue,  9 Jun 2009 18:01:44 +0100 Mel Gorman <mel@csn.ul.ie> wrote:

> On NUMA machines, the administrator can configure zone_reclaim_mode that is a
> more targetted form of direct reclaim. On machines with large NUMA distances,
> zone_reclaim_mode defaults to 1 meaning that clean unmapped pages will be
> reclaimed if the zone watermarks are not being met. The problem is that
> zone_reclaim() may get into a situation where it scans excessively without
> making progress.
> 
> One such situation occured where a large tmpfs mount occupied a
> large percentage of memory overall. The pages did not get reclaimed by
> zone_reclaim(), but the lists are uselessly scanned frequencly making the
> CPU spin at 100%. The observation in the field was that malloc() stalled
> for a long time (minutes in some cases) when this situation occurs. This
> situation should be resolved now and there are counters in place that
> detect when the scan-avoidance heuristics break but the heuristics might
> still not be bullet proof. If they fail again, the kernel should respond
> in some fashion other than scanning uselessly chewing up CPU time.
> 
> This patch reintroduces zone_reclaim_interval which was removed by commit
> 34aa1330f9b3c5783d269851d467326525207422 [zoned vm counters: zone_reclaim:
> remove /proc/sys/vm/zone_reclaim_interval. In the event the scan-avoidance
> heuristics fail, the event is counted and zone_reclaim_interval avoids
> excessive scanning.

More distressed fretting!

Pages can be allocated and freed and reclaimed at rates anywhere
between zero per second to one million per second or more.  So what
sense does it make to pace MM activity by wall-time??

A better clock for pacing MM activity is page-allocation-attempts, or
pages-scanned, etc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
