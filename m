Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 097536B0007
	for <linux-mm@kvack.org>; Thu,  3 May 2018 11:13:49 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id l6-v6so12241312wrn.17
        for <linux-mm@kvack.org>; Thu, 03 May 2018 08:13:48 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e6-v6si2279406edl.176.2018.05.03.08.13.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 May 2018 08:13:47 -0700 (PDT)
Date: Thu, 3 May 2018 17:13:43 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: INFO: task hung in wb_shutdown (2)
Message-ID: <20180503151343.2ijvp3mzdqfwbiay@quack2.suse.cz>
References: <94eb2c05b2d83650030568cc8bd9@google.com>
 <e56c1600-8923-dd6b-d065-c2fd2a720404@I-love.SAKURA.ne.jp>
 <43302799-1c50-4cab-b974-9fe1ca584813@I-love.SAKURA.ne.jp>
 <CA+55aFxaa_+uZ=bOVdevcUwG7ncue7O+i06q4Kb=bWACGwCBjQ@mail.gmail.com>
 <bd3e8460-9794-6b57-e7d6-7e18ea34ac0c@kernel.dk>
 <201805020714.FDD52145.OOJtOFVFSMLQFH@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201805020714.FDD52145.OOJtOFVFSMLQFH@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: axboe@kernel.dk, torvalds@linux-foundation.org, jack@suse.cz, tj@kernel.org, syzbot+c0cf869505e03bdf1a24@syzkaller.appspotmail.com, christophe.jaillet@wanadoo.fr, linux-kernel@vger.kernel.org, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, zhangweiping@didichuxing.com, akpm@linux-foundation.org, dvyukov@google.com, linux-block@vger.kernel.org

On Wed 02-05-18 07:14:51, Tetsuo Handa wrote:
> >From 1b90d7f71d60e743c69cdff3ba41edd1f9f86f93 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Wed, 2 May 2018 07:07:55 +0900
> Subject: [PATCH v2] bdi: wake up concurrent wb_shutdown() callers.
> 
> syzbot is reporting hung tasks at wait_on_bit(WB_shutting_down) in
> wb_shutdown() [1]. This seems to be because commit 5318ce7d46866e1d ("bdi:
> Shutdown writeback on all cgwbs in cgwb_bdi_destroy()") forgot to call
> wake_up_bit(WB_shutting_down) after clear_bit(WB_shutting_down).
> 
> Introduce a helper function clear_and_wake_up_bit() and use it, in order
> to avoid similar errors in future.
> 
> [1] https://syzkaller.appspot.com/bug?id=b297474817af98d5796bc544e1bb806fc3da0e5e
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Reported-by: syzbot <syzbot+c0cf869505e03bdf1a24@syzkaller.appspotmail.com>
> Fixes: 5318ce7d46866e1d ("bdi: Shutdown writeback on all cgwbs in cgwb_bdi_destroy()")
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Jens Axboe <axboe@fb.com>
> Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>

Thanks for debugging this and for the fix Tetsuo! The patch looks good to
me. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  include/linux/wait_bit.h | 17 +++++++++++++++++
>  mm/backing-dev.c         |  2 +-
>  2 files changed, 18 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/wait_bit.h b/include/linux/wait_bit.h
> index 9318b21..2b0072f 100644
> --- a/include/linux/wait_bit.h
> +++ b/include/linux/wait_bit.h
> @@ -305,4 +305,21 @@ struct wait_bit_queue_entry {
>  	__ret;								\
>  })
>  
> +/**
> + * clear_and_wake_up_bit - clear a bit and wake up anyone waiting on that bit
> + *
> + * @bit: the bit of the word being waited on
> + * @word: the word being waited on, a kernel virtual address
> + *
> + * You can use this helper if bitflags are manipulated atomically rather than
> + * non-atomically under a lock.
> + */
> +static inline void clear_and_wake_up_bit(int bit, void *word)
> +{
> +	clear_bit_unlock(bit, word);
> +	/* See wake_up_bit() for which memory barrier you need to use. */
> +	smp_mb__after_atomic();
> +	wake_up_bit(word, bit);
> +}
> +
>  #endif /* _LINUX_WAIT_BIT_H */
> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> index 023190c..fa5e6d7 100644
> --- a/mm/backing-dev.c
> +++ b/mm/backing-dev.c
> @@ -383,7 +383,7 @@ static void wb_shutdown(struct bdi_writeback *wb)
>  	 * the barrier provided by test_and_clear_bit() above.
>  	 */
>  	smp_wmb();
> -	clear_bit(WB_shutting_down, &wb->state);
> +	clear_and_wake_up_bit(WB_shutting_down, &wb->state);
>  }
>  
>  static void wb_exit(struct bdi_writeback *wb)
> -- 
> 1.8.3.1
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
