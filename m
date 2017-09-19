Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id F38A46B0033
	for <linux-mm@kvack.org>; Tue, 19 Sep 2017 16:39:38 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 188so1239810pgb.3
        for <linux-mm@kvack.org>; Tue, 19 Sep 2017 13:39:38 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l6sor1254197pgc.7.2017.09.19.13.39.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Sep 2017 13:39:35 -0700 (PDT)
Subject: Re: [PATCH 6/6] fs-writeback: only allow one inflight and pending
 !nr_pages flush
References: <1505850787-18311-1-git-send-email-axboe@kernel.dk>
 <1505850787-18311-7-git-send-email-axboe@kernel.dk>
 <20170919201840.GF11873@cmpxchg.org>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <036d35fc-e88d-b000-3db3-e5b736fa1e88@kernel.dk>
Date: Tue, 19 Sep 2017 14:39:32 -0600
MIME-Version: 1.0
In-Reply-To: <20170919201840.GF11873@cmpxchg.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, clm@fb.com, jack@suse.cz

On 09/19/2017 02:18 PM, Johannes Weiner wrote:
> On Tue, Sep 19, 2017 at 01:53:07PM -0600, Jens Axboe wrote:
>> A few callers pass in nr_pages == 0 when they wakeup the flusher
>> threads, which means that the flusher should just flush everything
>> that was currently dirty. If we are tight on memory, we can get
>> tons of these queued from kswapd/vmscan. This causes (at least)
>> two problems:
>>
>> 1) We consume a ton of memory just allocating writeback work items.
>> 2) We spend so much time processing these work items, that we
>>    introduce a softlockup in writeback processing.
>>
>> Fix this by adding a 'zero_pages' bit to the writeback structure,
>> and set that when someone queues a nr_pages==0 flusher thread
>> wakeup. The bit is cleared when we start writeback on that work
>> item. If the bit is already set when we attempt to queue !nr_pages
>> writeback, then we simply ignore it.
>>
>> This provides us one of full flush in flight, with one pending as
>> well, and makes for more efficient handling of this type of
>> writeback.
>>
>> Signed-off-by: Jens Axboe <axboe@kernel.dk>
> 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> Just a nitpick:
> 
>> @@ -948,15 +949,25 @@ static void wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
>>  			       bool range_cyclic, enum wb_reason reason)
>>  {
>>  	struct wb_writeback_work *work;
>> +	bool zero_pages = false;
>>  
>>  	if (!wb_has_dirty_io(wb))
>>  		return;
>>  
>>  	/*
>> -	 * If someone asked for zero pages, we write out the WORLD
>> +	 * If someone asked for zero pages, we write out the WORLD.
>> +	 * Places like vmscan and laptop mode want to queue a wakeup to
>> +	 * the flusher threads to clean out everything. To avoid potentially
>> +	 * having tons of these pending, ensure that we only allow one of
>> +	 * them pending and inflight at the time
>>  	 */
>> -	if (!nr_pages)
>> +	if (!nr_pages) {
>> +		if (test_bit(WB_zero_pages, &wb->state))
>> +			return;
>> +		set_bit(WB_zero_pages, &wb->state);
>>  		nr_pages = get_nr_dirty_pages();
> 
> We could rely on the work->older_than_this and pass LONG_MAX here
> instead to write out the world as it was at the time wb commences.
> 
> get_nr_dirty_pages() is somewhat clearer on intent, but on the other
> hand it returns global state and is used here in a split-bdi context,
> and we can end up in sum requesting the system-wide dirty pages
> several times over. It'll work fine, relying on work->older_than_this
> to contain it also, it just seems a little ugly and subtle.

Not disagreeing with that at all. I just carried the !nr_pages forward
as the way to do this. I think any further cleanup or work should just
be based on this patchset, I'd definitely welcome a change in that
direction.

Thanks for your reviews!

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
