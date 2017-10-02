Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9BFE26B0253
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 17:50:34 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id s80so263022lfg.0
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 14:50:34 -0700 (PDT)
Received: from forwardcorp1j.cmail.yandex.net (forwardcorp1j.cmail.yandex.net. [5.255.227.106])
        by mx.google.com with ESMTPS id g1si6019439ljb.478.2017.10.02.14.50.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Oct 2017 14:50:33 -0700 (PDT)
Subject: Re: [PATCH RFC] mm: implement write-behind policy for sequential file
 writes
References: <150693809463.587641.5712378065494786263.stgit@buzz>
 <eb9447b7-9fca-5883-8f04-1fdc7db31c20@kernel.dk>
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <3f67ed30-4a2e-09d2-3663-8be423dbbdac@yandex-team.ru>
Date: Tue, 3 Oct 2017 00:50:31 +0300
MIME-Version: 1.0
In-Reply-To: <eb9447b7-9fca-5883-8f04-1fdc7db31c20@kernel.dk>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On 02.10.2017 23:00, Jens Axboe wrote:
> On 10/02/2017 03:54 AM, Konstantin Khlebnikov wrote:
>> Traditional writeback tries to accumulate as much dirty data as possible.
>> This is worth strategy for extremely short-living files and for batching
>> writes for saving battery power. But for workloads where disk latency is
>> important this policy generates periodic disk load spikes which increases
>> latency for concurrent operations.
>>
>> Present writeback engine allows to tune only dirty data size or expiration
>> time. Such tuning cannot eliminate pikes - this just lowers and multiplies
>> them. Other option is switching into sync mode which flushes written data
>> right after each write, obviously this have significant performance impact.
>> Such tuning is system-wide and affects memory-mapped and randomly written
>> files, flusher threads handle them much better.
>>
>> This patch implements write-behind policy which tracks sequential writes
>> and starts background writeback when have enough dirty pages in a row.
> 
> This is a great idea in general. My only concerns would be around cases
> where we don't expect the writes to ever make it to media. It's not an
> uncommon use case - app dirties some memory in a file, and expects
> to truncate/unlink it before it makes it to disk. We don't want to trigger
> writeback for those. Arguably that should be app hinted.

Yes, this is case where serious degradation might happens.

Threshold 256k saves small files from writing.
Big temporary files anyway have good chances to be pushed
into disk by memory pressure or flusher thread.

> 
>> Write-behind tracks current writing position and looks into two windows
>> behind it: first represents unwitten pages, Second - async writeback.
>>
>> Next write starts background writeback when first window exceed threshold
>> and waits for pages falling behind async writeback window. This allows to
>> combine small writes into bigger requests and maintain optimal io-depth.
>>
>> This affects only writes via syscalls, memory mapped writes are unchanged.
>> Also write-behind doesn't affect files with fadvise POSIX_FADV_RANDOM.
>>
>> If async window set to 0 then write-behind skips dirty pages for congested
>> disk and never wait for writeback. This is used for files with O_NONBLOCK.
>>
>> Also for files with fadvise POSIX_FADV_NOREUSE write-behind automatically
>> evicts completely written pages from cache. This is perfect for writing
>> verbose logs without pushing more important data out of cache.
>>
>> As a bonus write-behind makes blkio throttling much more smooth for most
>> bulk file operations like copying or downloading which writes sequentially.
>>
>> Size of minimal write-behind request is set in:
>> /sys/block/$DISK/bdi/min_write_behind_kb
>> Default is 256Kb, 0 - disable write-behind for this disk.
>>
>> Size of async window set in:
>> /sys/block/$DISK/bdi/async_write_behind_kb
>> Default is 1024Kb, 0 - disables sync write-behind.
> 
> Should we expose these, or just make them a function of the IO limitations
> exposed by the device? Something like 2x max request size, or similar.

Window depend on IO latency expectations for parallel workload and
concurrency at all levels.
Also it seems that RAIDs needs special treatment.
For now I think this is minimal possible interface.

> 
> Finally, do you have any test results?
> 

Nothing particular yet.

For example:
$ fio  --name=test --rw=write --filesize=1G --ioengine=sync --blocksize=4k --end_fsync=1

with patch ends earlier
9.0s -> 8.2s for HDD
5.4s -> 4.7s for SSD
because write starts earlier. both uses old sq/cfq.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
