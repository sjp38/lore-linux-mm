Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B329B6B01AD
	for <linux-mm@kvack.org>; Sun, 27 Jun 2010 07:34:33 -0400 (EDT)
Date: Sun, 27 Jun 2010 13:34:23 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] vmscan: recalculate lru_pages on each priority
Message-ID: <20100627113422.GA14504@cmpxchg.org>
References: <20100625181221.805A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100625181221.805A.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jun 25, 2010 at 06:13:20PM +0900, KOSAKI Motohiro wrote:
> shrink_zones() need relatively long time. and lru_pages can be
> changed dramatically while shrink_zones().
> then, lru_pages need recalculate on each priority.

In the direct reclaim path, we bail out of that loop after
SWAP_CLUSTER_MAX reclaimed pages, so in this case, decreasing priority
levels actually mean we do _not_ make any progress and the total
number of lru pages should not change (much).  The possible distortion
in shrink_slab() is small.

However, for the suspend-to-disk case the reclaim target can be a lot
higher and we inevitably end up at higher priorities even though we
make progress, but fail to increase pressure on the shrinkers as well
without your patch.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
