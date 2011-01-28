Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id DD8F98D0039
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 14:46:09 -0500 (EST)
Date: Fri, 28 Jan 2011 20:45:42 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: too big min_free_kbytes
Message-ID: <20110128194542.GV16981@random.random>
References: <20110127213106.GA25933@csn.ul.ie>
 <4D41FD2F.3050006@redhat.com>
 <20110128103539.GA14669@csn.ul.ie>
 <20110128162831.GH16981@random.random>
 <20110128164624.GA23905@csn.ul.ie>
 <4D42F9E3.2010605@redhat.com>
 <20110128174644.GM16981@random.random>
 <4D430506.2070502@redhat.com>
 <20110128182407.GO16981@random.random>
 <4D431A47.90408@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4D431A47.90408@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "Chen, Tim C" <tim.c.chen@intel.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 28, 2011 at 02:34:31PM -0500, Rik van Riel wrote:
> It will block at high+gap only when one zone has really
> easily reclaimable memory, and another zone has difficult
> to free memory.

The other zone doesn't need to be difficult to free up. All ram in
immediately freeable clean cache is the most common case there is. And
it's more than enough to trigger the scenario in prev email.

> That creates a free memory differential between the
> easy to free and difficult to free memory zones.

There's no difficult to free zone in this scenario.

> If memory in all zones is equally easy to free, kswapd
> will go to sleep once the high watermark is reached in
> every zone.

Yes, at that point the high wmark is reached for all zones. Then cp or
any file read allocates another high-low amount of clean cache, and
kswapd will be waken again. Then when it goes to sleep the over4g tiny
zone will be at "high" again but the below zones will be at
high+(high_over4gwmark-low_over4gwmark), in about 5 seconds the over4g
zone will be at "high" and the other two zones will be at
"high+gap". All when there's zero memory pressure in the below zones,
and there's just some clean cache shrinking required to allocate the
new cache from the over4g zone. Then the below zones lru stops
rotating regardless of the size of the gap (0 or 600M makes no
difference).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
