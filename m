Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4AE3C6B0038
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 10:48:49 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id k101so13276777iod.1
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 07:48:49 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f192sor2732182iof.296.2017.09.25.07.48.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Sep 2017 07:48:48 -0700 (PDT)
Subject: Re: [PATCH 7/7] fs-writeback: only allow one inflight and pending
 full flush
References: <1505921582-26709-1-git-send-email-axboe@kernel.dk>
 <1505921582-26709-8-git-send-email-axboe@kernel.dk>
 <20170921150510.GH8839@infradead.org>
 <728d4141-8d73-97fb-de08-90671c2897da@kernel.dk>
 <3682c4c2-6e8a-e883-9f62-455ea2944496@kernel.dk>
 <20170925093532.GC5741@quack2.suse.cz>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <d2c0d136-6d62-d4f2-ebc7-9cdd7ec69343@kernel.dk>
Date: Mon, 25 Sep 2017 08:48:46 -0600
MIME-Version: 1.0
In-Reply-To: <20170925093532.GC5741@quack2.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org, clm@fb.com

On 09/25/2017 03:35 AM, Jan Kara wrote:
> On Thu 21-09-17 10:00:25, Jens Axboe wrote:
>> On 09/21/2017 09:36 AM, Jens Axboe wrote:
>>>> But more importantly once we are not guaranteed that we only have
>>>> a single global wb_writeback_work per bdi_writeback we should just
>>>> embedd that into struct bdi_writeback instead of dynamically
>>>> allocating it.
>>>
>>> We could do this as a followup. But right now the logic is that we
>>> can have on started (inflight), and still have one new queued.
>>
>> Something like the below would fit on top to do that. Gets rid of the
>> allocation and embeds the work item for global start-all in the
>> bdi_writeback structure.
> 
> Hum, so when we consider stuff like embedded work item, I would somewhat
> prefer to handle this like we do for for_background and for_kupdate style
> writeback so that we don't have another special case. For these don't queue
> any item, we just queue writeback work into the workqueue (via
> wb_wakeup()). When flusher work gets processed wb_do_writeback() checks
> (after processing all normal writeback requests) whether conditions for
> these special writeback styles are met and if yes, it creates on-stack work
> item and processes it (see wb_check_old_data_flush() and
> wb_check_background_flush()).

Thanks Jan, I think that's a really good suggestion and kills the
special case completely. I'll rework the patch as a small series
for 4.15.

> So in this case we would just set some flag in bdi_writeback when memory
> reclaim needs help and wb_do_writeback() would check for this flag and
> create and process writeback-all style writeback work. Granted this does
> not preserve ordering of requests (basically any specific request gets
> priority over writeback-whole-world request) but memory gets cleaned in
> either case so flusher should be doing what is needed.

I don't think that matters, and we're already mostly there since we
reject a request if one is pending. And at this point they are all
identical "start all writeback" requests.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
