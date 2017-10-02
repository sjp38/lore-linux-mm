Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id E7A356B0069
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 16:00:05 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id j64so1525479pfj.22
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 13:00:05 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b3sor20948itg.101.2017.10.02.13.00.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 02 Oct 2017 13:00:04 -0700 (PDT)
Subject: Re: [PATCH RFC] mm: implement write-behind policy for sequential file
 writes
References: <150693809463.587641.5712378065494786263.stgit@buzz>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <eb9447b7-9fca-5883-8f04-1fdc7db31c20@kernel.dk>
Date: Mon, 2 Oct 2017 14:00:01 -0600
MIME-Version: 1.0
In-Reply-To: <150693809463.587641.5712378065494786263.stgit@buzz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On 10/02/2017 03:54 AM, Konstantin Khlebnikov wrote:
> Traditional writeback tries to accumulate as much dirty data as possible.
> This is worth strategy for extremely short-living files and for batching
> writes for saving battery power. But for workloads where disk latency is
> important this policy generates periodic disk load spikes which increases
> latency for concurrent operations.
> 
> Present writeback engine allows to tune only dirty data size or expiration
> time. Such tuning cannot eliminate pikes - this just lowers and multiplies
> them. Other option is switching into sync mode which flushes written data
> right after each write, obviously this have significant performance impact.
> Such tuning is system-wide and affects memory-mapped and randomly written
> files, flusher threads handle them much better.
> 
> This patch implements write-behind policy which tracks sequential writes
> and starts background writeback when have enough dirty pages in a row.

This is a great idea in general. My only concerns would be around cases
where we don't expect the writes to ever make it to media. It's not an
uncommon use case - app dirties some memory in a file, and expects
to truncate/unlink it before it makes it to disk. We don't want to trigger
writeback for those. Arguably that should be app hinted.

> Write-behind tracks current writing position and looks into two windows
> behind it: first represents unwitten pages, Second - async writeback.
> 
> Next write starts background writeback when first window exceed threshold
> and waits for pages falling behind async writeback window. This allows to
> combine small writes into bigger requests and maintain optimal io-depth.
> 
> This affects only writes via syscalls, memory mapped writes are unchanged.
> Also write-behind doesn't affect files with fadvise POSIX_FADV_RANDOM.
> 
> If async window set to 0 then write-behind skips dirty pages for congested
> disk and never wait for writeback. This is used for files with O_NONBLOCK.
> 
> Also for files with fadvise POSIX_FADV_NOREUSE write-behind automatically
> evicts completely written pages from cache. This is perfect for writing
> verbose logs without pushing more important data out of cache.
> 
> As a bonus write-behind makes blkio throttling much more smooth for most
> bulk file operations like copying or downloading which writes sequentially.
> 
> Size of minimal write-behind request is set in:
> /sys/block/$DISK/bdi/min_write_behind_kb
> Default is 256Kb, 0 - disable write-behind for this disk.
> 
> Size of async window set in:
> /sys/block/$DISK/bdi/async_write_behind_kb
> Default is 1024Kb, 0 - disables sync write-behind.

Should we expose these, or just make them a function of the IO limitations
exposed by the device? Something like 2x max request size, or similar.

Finally, do you have any test results?

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
