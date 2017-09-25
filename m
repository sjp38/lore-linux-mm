Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 80DA06B0038
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 05:35:36 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id r83so12656385pfj.5
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 02:35:36 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f69si3673324pfj.623.2017.09.25.02.35.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Sep 2017 02:35:35 -0700 (PDT)
Date: Mon, 25 Sep 2017 11:35:32 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 7/7] fs-writeback: only allow one inflight and pending
 full flush
Message-ID: <20170925093532.GC5741@quack2.suse.cz>
References: <1505921582-26709-1-git-send-email-axboe@kernel.dk>
 <1505921582-26709-8-git-send-email-axboe@kernel.dk>
 <20170921150510.GH8839@infradead.org>
 <728d4141-8d73-97fb-de08-90671c2897da@kernel.dk>
 <3682c4c2-6e8a-e883-9f62-455ea2944496@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3682c4c2-6e8a-e883-9f62-455ea2944496@kernel.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org, clm@fb.com, jack@suse.cz

On Thu 21-09-17 10:00:25, Jens Axboe wrote:
> On 09/21/2017 09:36 AM, Jens Axboe wrote:
> >> But more importantly once we are not guaranteed that we only have
> >> a single global wb_writeback_work per bdi_writeback we should just
> >> embedd that into struct bdi_writeback instead of dynamically
> >> allocating it.
> >
> > We could do this as a followup. But right now the logic is that we
> > can have on started (inflight), and still have one new queued.
> 
> Something like the below would fit on top to do that. Gets rid of the
> allocation and embeds the work item for global start-all in the
> bdi_writeback structure.

Hum, so when we consider stuff like embedded work item, I would somewhat
prefer to handle this like we do for for_background and for_kupdate style
writeback so that we don't have another special case. For these don't queue
any item, we just queue writeback work into the workqueue (via
wb_wakeup()). When flusher work gets processed wb_do_writeback() checks
(after processing all normal writeback requests) whether conditions for
these special writeback styles are met and if yes, it creates on-stack work
item and processes it (see wb_check_old_data_flush() and
wb_check_background_flush()).

So in this case we would just set some flag in bdi_writeback when memory
reclaim needs help and wb_do_writeback() would check for this flag and
create and process writeback-all style writeback work. Granted this does
not preserve ordering of requests (basically any specific request gets
priority over writeback-whole-world request) but memory gets cleaned in
either case so flusher should be doing what is needed.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
