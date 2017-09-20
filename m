Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 321646B0253
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 11:19:17 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id u2so4452723itb.7
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 08:19:17 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 64sor885260iol.11.2017.09.20.08.19.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Sep 2017 08:19:08 -0700 (PDT)
Subject: Re: [PATCH 3/6] page-writeback: pass in '0' for nr_pages writeback in
 laptop mode
References: <1505850787-18311-1-git-send-email-axboe@kernel.dk>
 <1505850787-18311-4-git-send-email-axboe@kernel.dk>
 <20170920143505.GD11106@quack2.suse.cz>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <b6aaf770-6543-728a-1f10-1268d3827b8a@kernel.dk>
Date: Wed, 20 Sep 2017 09:19:05 -0600
MIME-Version: 1.0
In-Reply-To: <20170920143505.GD11106@quack2.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org, clm@fb.com

On 09/20/2017 08:35 AM, Jan Kara wrote:
> On Tue 19-09-17 13:53:04, Jens Axboe wrote:
>> Laptop mode really wants to writeback the number of dirty
>> pages and inodes. Instead of calculating this in the caller,
>> just pass in 0 and let wakeup_flusher_threads() handle it.
>>
>> Use the new wakeup_flusher_threads_bdi() instead of rolling
>> our own.
>>
>> Signed-off-by: Jens Axboe <axboe@kernel.dk>
> ...
>> -	rcu_read_lock();
>> -	list_for_each_entry_rcu(wb, &q->backing_dev_info->wb_list, bdi_node)
>> -		if (wb_has_dirty_io(wb))
>> -			wb_start_writeback(wb, nr_pages, true,
>> -					   WB_REASON_LAPTOP_TIMER);
>> -	rcu_read_unlock();
>> +	wakeup_flusher_threads_bdi(q->backing_dev_info, 0,
>> +					WB_REASON_LAPTOP_TIMER);
>>  }
> 
> So this slightly changes the semantics since previously we were doing
> range_cyclic writeback and now we don't. I don't think this matters in
> practice but please mention that in the changelog. With that you can add:

Thanks, I added a note about that in the commit message.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
