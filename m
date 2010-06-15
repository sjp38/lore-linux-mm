Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 9E6DD6B01AD
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 21:17:17 -0400 (EDT)
Message-ID: <4C16D46D.3020302@redhat.com>
Date: Mon, 14 Jun 2010 21:16:29 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 11/12] vmscan: Write out dirty pages in batch
References: <1276514273-27693-1-git-send-email-mel@csn.ul.ie> <1276514273-27693-12-git-send-email-mel@csn.ul.ie> <20100614231144.GG6590@dastard> <20100614162143.04783749.akpm@linux-foundation.org> <20100615003943.GK6590@dastard>
In-Reply-To: <20100615003943.GK6590@dastard>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On 06/14/2010 08:39 PM, Dave Chinner wrote:
> On Mon, Jun 14, 2010 at 04:21:43PM -0700, Andrew Morton wrote:

>> But then, this all really should be done at the block layer so other
>> io-submitting-paths can benefit from it.
>
> That was what we did in the past with really, really deep IO
> scheduler queues. That leads to IO latency and OOM problems because
> we could lock gigabytes of memory away under IO and take minutes to
> clean it.
>
> Besides, there really isn't the right context in the block layer to
> be able to queue and prioritise large amounts of IO without
> significant penalties to some higher layer operation.

Can we kick flushing for the whole inode at once from
vmscan.c?

That way we should:
1) ensure that the page we want is written to disk, and
2) we flush out related pages at the same time, getting
    a decent IO pattern

Chances are that if we want to evict one page from a
file, we'll also want to evict other pages from that
same file.  In fact, chances are a good number of them
will live nearby on the LRU list.

Does this make sense?

Would it be hard to add a "please flush this file"
way to call the filesystem flushing threads?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
