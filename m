Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 049166B005A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 20:55:37 -0400 (EDT)
Message-ID: <4FEBAB92.4090206@kernel.org>
Date: Thu, 28 Jun 2012 09:55:46 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: excessive CPU utilization by isolate_freepages?
References: <4FEB8237.6030402@sandia.gov> <4FEB9E73.5040709@kernel.org> <4FEBA520.4030205@redhat.com>
In-Reply-To: <4FEBA520.4030205@redhat.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Jim Schutt <jaschut@sandia.gov>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "ceph-devel@vger.kernel.org" <ceph-devel@vger.kernel.org>

On 06/28/2012 09:28 AM, Rik van Riel wrote:

> On 06/27/2012 07:59 PM, Minchan Kim wrote:
> 
>> I doubt compaction try to migrate continuously although we have no
>> free memory.
>> Could you apply this patch and retest?
>>
>> https://lkml.org/lkml/2012/6/21/30
> 
> Another possibility is that compaction is succeeding every time,
> but since we always start scanning all the way at the beginning
> and end of each zone, we waste a lot of CPU time rescanning the
> same pages (that we just filled up with moved pages) to see if
> any are free.


It does make sense.

> 
> In short, due to the way compaction behaves right now,
> compaction + isolate_freepages are essentially quadratic.
> 
> What we need to do is remember where we left off after a
> successful compaction, so we can continue the search there
> at the next invocation.
> 


Good idea.
It could enhance parallel compaction, too.
Of course, if we can't meet the goal, we need loop around from start/end of zone.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
