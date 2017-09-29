Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id BE8406B0038
	for <linux-mm@kvack.org>; Fri, 29 Sep 2017 19:20:06 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r74so694007wme.5
        for <linux-mm@kvack.org>; Fri, 29 Sep 2017 16:20:06 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d21sor3010026edb.24.2017.09.29.16.20.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 29 Sep 2017 16:20:04 -0700 (PDT)
Subject: Re: [PATCH 7/7] fs-writeback: only allow one inflight and pending
 full flush
From: Jens Axboe <axboe@kernel.dk>
References: <1505921582-26709-1-git-send-email-axboe@kernel.dk>
 <1505921582-26709-8-git-send-email-axboe@kernel.dk>
 <20170921150510.GH8839@infradead.org>
 <728d4141-8d73-97fb-de08-90671c2897da@kernel.dk>
 <3682c4c2-6e8a-e883-9f62-455ea2944496@kernel.dk>
 <20170925093532.GC5741@quack2.suse.cz>
 <214d2bcb-0697-c051-0f36-20cd0d8702b0@kernel.dk>
Message-ID: <028e9761-6188-a531-9b1e-32ad9353de13@kernel.dk>
Date: Sat, 30 Sep 2017 01:20:02 +0200
MIME-Version: 1.0
In-Reply-To: <214d2bcb-0697-c051-0f36-20cd0d8702b0@kernel.dk>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org, clm@fb.com

On 09/28/2017 08:09 PM, Jens Axboe wrote:
> On 09/25/2017 11:35 AM, Jan Kara wrote:
>> On Thu 21-09-17 10:00:25, Jens Axboe wrote:
>>> On 09/21/2017 09:36 AM, Jens Axboe wrote:
>>>>> But more importantly once we are not guaranteed that we only have
>>>>> a single global wb_writeback_work per bdi_writeback we should just
>>>>> embedd that into struct bdi_writeback instead of dynamically
>>>>> allocating it.
>>>>
>>>> We could do this as a followup. But right now the logic is that we
>>>> can have on started (inflight), and still have one new queued.
>>>
>>> Something like the below would fit on top to do that. Gets rid of the
>>> allocation and embeds the work item for global start-all in the
>>> bdi_writeback structure.
>>
>> Hum, so when we consider stuff like embedded work item, I would somewhat
>> prefer to handle this like we do for for_background and for_kupdate style
>> writeback so that we don't have another special case. For these don't queue
>> any item, we just queue writeback work into the workqueue (via
>> wb_wakeup()). When flusher work gets processed wb_do_writeback() checks
>> (after processing all normal writeback requests) whether conditions for
>> these special writeback styles are met and if yes, it creates on-stack work
>> item and processes it (see wb_check_old_data_flush() and
>> wb_check_background_flush()).
>>
>> So in this case we would just set some flag in bdi_writeback when memory
>> reclaim needs help and wb_do_writeback() would check for this flag and
>> create and process writeback-all style writeback work. Granted this does
>> not preserve ordering of requests (basically any specific request gets
>> priority over writeback-whole-world request) but memory gets cleaned in
>> either case so flusher should be doing what is needed.
> 
> How about something like the below? It's on top of the latest series,
> which is in my wb-start-all branch. It handles start_all like the
> background/kupdate style writeback, reusing the WB_start_all bit for
> that.
> 
> On a plane, so untested, but it seems pretty straight forward. It
> changes the logic a little bit, as the WB_start_all bit isn't cleared
> until after we're done with a flush-all request. At this point it's
> truly on inflight at any point in time, not one inflight and one
> potentially queued.

I tested it, with adding a patch that actually enables laptop completion
triggers on blk-mq (not there before, an oversight, will send that out
separately). It works fine for me, verified with tracing that we do
trigger flushes with completions from laptop mode.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
