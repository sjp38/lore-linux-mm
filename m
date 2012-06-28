Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id B63D76B005A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 20:28:45 -0400 (EDT)
Message-ID: <4FEBA520.4030205@redhat.com>
Date: Wed, 27 Jun 2012 20:28:16 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: excessive CPU utilization by isolate_freepages?
References: <4FEB8237.6030402@sandia.gov> <4FEB9E73.5040709@kernel.org>
In-Reply-To: <4FEB9E73.5040709@kernel.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Jim Schutt <jaschut@sandia.gov>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "ceph-devel@vger.kernel.org" <ceph-devel@vger.kernel.org>

On 06/27/2012 07:59 PM, Minchan Kim wrote:

> I doubt compaction try to migrate continuously although we have no free memory.
> Could you apply this patch and retest?
>
> https://lkml.org/lkml/2012/6/21/30

Another possibility is that compaction is succeeding every time,
but since we always start scanning all the way at the beginning
and end of each zone, we waste a lot of CPU time rescanning the
same pages (that we just filled up with moved pages) to see if
any are free.

In short, due to the way compaction behaves right now,
compaction + isolate_freepages are essentially quadratic.

What we need to do is remember where we left off after a
successful compaction, so we can continue the search there
at the next invocation.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
