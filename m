Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1E6A66B0006
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 04:50:39 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id m18-v6so281781eds.0
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 01:50:39 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i43-v6si3628087ede.243.2018.06.22.01.50.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 22 Jun 2018 01:50:38 -0700 (PDT)
Date: Fri, 22 Jun 2018 10:50:35 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [BUG] mm: backing-dev: a possible sleep-in-atomic-context bug in
 cgwb_create()
Message-ID: <20180622085035.2zn2voqgqxcx55f3@quack2.suse.cz>
References: <626acba3-c565-7e05-6c8b-0d100ff645c5@gmail.com>
 <20180621033515.GA12608@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180621033515.GA12608@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Jia-Ju Bai <baijiaju1990@gmail.com>, axboe@kernel.dk, akpm@linux-foundation.or, jack@suse.cz, zhangweiping@didichuxing.com, sergey.senozhatsky@gmail.com, andriy.shevchenko@linux.intel.com, christophe.jaillet@wanadoo.fr, aryabinin@virtuozzo.com, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed 20-06-18 20:35:15, Matthew Wilcox wrote:
> On Thu, Jun 21, 2018 at 11:02:58AM +0800, Jia-Ju Bai wrote:
> > The kernel may sleep with holding a spinlock.
> > The function call path (from bottom to top) in Linux-4.16.7 is:
> > 
> > [FUNC] schedule
> > lib/percpu-refcount.c, 222:
> >         schedule in __percpu_ref_switch_mode
> > lib/percpu-refcount.c, 339:
> >         __percpu_ref_switch_mode in percpu_ref_kill_and_confirm
> > ./include/linux/percpu-refcount.h, 127:
> >         percpu_ref_kill_and_confirm in percpu_ref_kill
> > mm/backing-dev.c, 545:
> >         percpu_ref_kill in cgwb_kill
> > mm/backing-dev.c, 576:
> >         cgwb_kill in cgwb_create
> > mm/backing-dev.c, 573:
> >         _raw_spin_lock_irqsave in cgwb_create
> > 
> > This bug is found by my static analysis tool (DSAC-2) and checked by my
> > code review.
> 
> I disagree with your code review.
> 
>          * If the previous ATOMIC switching hasn't finished yet, wait for
>          * its completion.  If the caller ensures that ATOMIC switching
>          * isn't in progress, this function can be called from any context.
> 
> I believe cgwb_kill is always called under the spinlock, so we will never
> sleep because the percpu ref will never be switching to atomic mode.

You are right that the sleep under spinlock never happens. And the reason
is that percpu_ref_kill() never results in blocking - it does call
percpu_ref_kill_and_confirm() but the 'confirm' argument is NULL and thus
even percpu_ref_kill_and_confirm() never blocks.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
