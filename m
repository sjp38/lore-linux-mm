Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3770B6B0033
	for <linux-mm@kvack.org>; Fri,  6 Oct 2017 04:20:30 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a7so37026027pfj.3
        for <linux-mm@kvack.org>; Fri, 06 Oct 2017 01:20:30 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id b9si755279pls.609.2017.10.06.01.20.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Oct 2017 01:20:29 -0700 (PDT)
Date: Fri, 6 Oct 2017 01:20:20 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v2] block/laptop_mode: Convert timers to use timer_setup()
Message-ID: <20171006082020.GA12192@infradead.org>
References: <20171005231623.GA109154@beast>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171005231623.GA109154@beast>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Jens Axboe <axboe@kernel.dk>, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Nicholas Piggin <npiggin@gmail.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Matthew Wilcox <mawilcox@microsoft.com>, Jeff Layton <jlayton@redhat.com>, linux-block@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>

> -static void blk_rq_timed_out_timer(unsigned long data)
> +static void blk_rq_timed_out_timer(struct timer_list *t)
>  {
> -	struct request_queue *q = (struct request_queue *)data;
> +	struct request_queue *q = from_timer(q, t, timeout);
>  
>  	kblockd_schedule_work(&q->timeout_work);
>  }

This isn't the laptop_mode timer, although the change itself looks fine.

> +	timer_setup(&q->backing_dev_info->laptop_mode_wb_timer,
> +		    laptop_mode_timer_fn, 0);

And I already pointed out to Jens when he did the previous changes
to this one that it has no business being in the block code, it
really should move to mm/page-writeback.c with the rest of the
handling of this timer.  Once that is fixed up your automated script
should pick it up, so we wouldn't need the manual change.

Untested patch for that below:

---
