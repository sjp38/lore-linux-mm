Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 74DCD6B0007
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 23:35:29 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id g5-v6so646211pgv.12
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 20:35:29 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p10-v6si3730556plk.295.2018.06.20.20.35.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Jun 2018 20:35:28 -0700 (PDT)
Date: Wed, 20 Jun 2018 20:35:15 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [BUG] mm: backing-dev: a possible sleep-in-atomic-context bug in
 cgwb_create()
Message-ID: <20180621033515.GA12608@bombadil.infradead.org>
References: <626acba3-c565-7e05-6c8b-0d100ff645c5@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <626acba3-c565-7e05-6c8b-0d100ff645c5@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia-Ju Bai <baijiaju1990@gmail.com>
Cc: axboe@kernel.dk, akpm@linux-foundation.or, jack@suse.cz, zhangweiping@didichuxing.com, sergey.senozhatsky@gmail.com, andriy.shevchenko@linux.intel.com, christophe.jaillet@wanadoo.fr, aryabinin@virtuozzo.com, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Jun 21, 2018 at 11:02:58AM +0800, Jia-Ju Bai wrote:
> The kernel may sleep with holding a spinlock.
> The function call path (from bottom to top) in Linux-4.16.7 is:
> 
> [FUNC] schedule
> lib/percpu-refcount.c, 222:
>         schedule in __percpu_ref_switch_mode
> lib/percpu-refcount.c, 339:
>         __percpu_ref_switch_mode in percpu_ref_kill_and_confirm
> ./include/linux/percpu-refcount.h, 127:
>         percpu_ref_kill_and_confirm in percpu_ref_kill
> mm/backing-dev.c, 545:
>         percpu_ref_kill in cgwb_kill
> mm/backing-dev.c, 576:
>         cgwb_kill in cgwb_create
> mm/backing-dev.c, 573:
>         _raw_spin_lock_irqsave in cgwb_create
> 
> This bug is found by my static analysis tool (DSAC-2) and checked by my
> code review.

I disagree with your code review.

         * If the previous ATOMIC switching hasn't finished yet, wait for
         * its completion.  If the caller ensures that ATOMIC switching
         * isn't in progress, this function can be called from any context.

I believe cgwb_kill is always called under the spinlock, so we will never
sleep because the percpu ref will never be switching to atomic mode.

This is complex and subtle, so I could be wrong.
