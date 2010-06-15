Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 437366B022B
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 09:32:55 -0400 (EDT)
Message-ID: <4C1780F2.7010003@redhat.com>
Date: Tue, 15 Jun 2010 09:32:34 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 11/12] vmscan: Write out dirty pages in batch
References: <1276514273-27693-1-git-send-email-mel@csn.ul.ie> <1276514273-27693-12-git-send-email-mel@csn.ul.ie> <20100614231144.GG6590@dastard> <20100614162143.04783749.akpm@linux-foundation.org> <20100615003943.GK6590@dastard> <4C16D46D.3020302@redhat.com> <20100615110102.GD31051@infradead.org>
In-Reply-To: <20100615110102.GD31051@infradead.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On 06/15/2010 07:01 AM, Christoph Hellwig wrote:
> On Mon, Jun 14, 2010 at 09:16:29PM -0400, Rik van Riel wrote:
>>> Besides, there really isn't the right context in the block layer to
>>> be able to queue and prioritise large amounts of IO without
>>> significant penalties to some higher layer operation.
>>
>> Can we kick flushing for the whole inode at once from
>> vmscan.c?
>
> kswapd really should be a last effort tool to clean filesystem pages.
> If it does enough I/O for this to matter significantly we need to
> fix the VM to move more work to the flusher threads instead of trying
> to fix kswapd.
>
>> Would it be hard to add a "please flush this file"
>> way to call the filesystem flushing threads?
>
> We already have that API, in Jens' latest tree that's
> sync_inodes_sb/writeback_inodes_sb.  We could also add a non-waiting
> variant if required, but I think the big problem with kswapd is that
> we want to wait on I/O completion under circumstances.

However, kswapd does not need to wait on I/O completion of
any page in particular - it just wants to wait on I/O
completion of any inactive pages in the zone (or memcg)
where memory is being freed.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
