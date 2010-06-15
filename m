Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id ADD416B01E4
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 06:19:16 -0400 (EDT)
Date: Tue, 15 Jun 2010 11:18:58 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 11/12] vmscan: Write out dirty pages in batch
Message-ID: <20100615101857.GB26788@csn.ul.ie>
References: <1276514273-27693-1-git-send-email-mel@csn.ul.ie> <1276514273-27693-12-git-send-email-mel@csn.ul.ie> <4C169B81.8010707@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4C169B81.8010707@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 14, 2010 at 05:13:37PM -0400, Rik van Riel wrote:
> On 06/14/2010 07:17 AM, Mel Gorman wrote:
>> Page reclaim cleans individual pages using a_ops->writepage() because from
>> the VM perspective, it is known that pages in a particular zone must be freed
>> soon, it considers the target page to be the oldest and it does not want
>> to wait while background flushers cleans other pages. From a filesystem
>> perspective this is extremely inefficient as it generates a very seeky
>> IO pattern leading to the perverse situation where it can take longer to
>> clean all dirty pages than it would have otherwise.
>
> Reclaiming clean pages should be fast enough that this should
> make little, if any, difference.
>

Indeed, this was a bit weak. The original point of the patch was to write
contiguous pages belonging to the same inode when they were encountered in
that batch which made a bit more sense but didn't work out at first
pass.

>> This patch queues all dirty pages at once to maximise the chances that
>> the write requests get merged efficiently. It also makes the next patch
>> that avoids writeout from direct reclaim more straight-forward.
>
> However, this is a convincing argument :)
>

Thanks.

>> Signed-off-by: Mel Gorman<mel@csn.ul.ie>
>
> Reviewed-by: Rik van Riel <riel@redhat.com>
>

Thanks again :)

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
