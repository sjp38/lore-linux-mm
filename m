Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 8C4C36B005A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 21:13:32 -0400 (EDT)
Message-ID: <4FEBAF9D.2000008@redhat.com>
Date: Wed, 27 Jun 2012 21:13:01 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: excessive CPU utilization by isolate_freepages?
References: <4FEB8237.6030402@sandia.gov> <4FEB9E73.5040709@kernel.org> <4FEBA520.4030205@redhat.com> <alpine.DEB.2.00.1206271745170.9552@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1206271745170.9552@chino.kir.corp.google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Minchan Kim <minchan@kernel.org>, Jim Schutt <jaschut@sandia.gov>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "ceph-devel@vger.kernel.org" <ceph-devel@vger.kernel.org>

On 06/27/2012 08:52 PM, David Rientjes wrote:
> On Wed, 27 Jun 2012, Rik van Riel wrote:

>> Another possibility is that compaction is succeeding every time,
>> but since we always start scanning all the way at the beginning
>> and end of each zone, we waste a lot of CPU time rescanning the
>> same pages (that we just filled up with moved pages) to see if
>> any are free.
>>
>> In short, due to the way compaction behaves right now,
>> compaction + isolate_freepages are essentially quadratic.
>>
>> What we need to do is remember where we left off after a
>> successful compaction, so we can continue the search there
>> at the next invocation.
>>
>
> So when the free and migration scanners meet and compact_finished() ==
> COMPACT_CONTINUE, loop around to the start of the zone and continue until
> you reach the pfn that it was started at?  Seems appropriate.

Exactly.

It would entail changes to struct compact_control, where
we have to remember whether we started at the top of the
zone or not (for a full compaction, ie order==-1 we might).

For a compaction of order >0, we would remember the last
pfn where isolate_freepages isolated a page, and start
isolating below that.

If we fail to isolate pages when cc->free_pfn and cc->migrate_pfn
meet, we may want to restart from the top for a second round.
If they meet again after the second round, we have really failed,
and compaction will be deferred.

As long as compaction succeeds, we will slowly move through the
zone, with each invocation of compaction scanning a little more.

For cc->migrate_pfn it is probably fine to start from the
beginning of the zone each time.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
