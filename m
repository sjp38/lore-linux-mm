Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com [74.125.82.179])
	by kanga.kvack.org (Postfix) with ESMTP id CDA9D6B0037
	for <linux-mm@kvack.org>; Wed, 24 Sep 2014 03:04:23 -0400 (EDT)
Received: by mail-we0-f179.google.com with SMTP id u56so5701758wes.10
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 00:04:23 -0700 (PDT)
Received: from mail-wi0-x22b.google.com (mail-wi0-x22b.google.com [2a00:1450:400c:c05::22b])
        by mx.google.com with ESMTPS id vm3si18325288wjc.3.2014.09.24.00.04.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 24 Sep 2014 00:04:22 -0700 (PDT)
Received: by mail-wi0-f171.google.com with SMTP id ho1so6271406wib.4
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 00:04:22 -0700 (PDT)
Date: Wed, 24 Sep 2014 09:04:18 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 1/5] SCHED: add some "wait..on_bit...timeout()"
 interfaces.
Message-ID: <20140924070418.GA990@gmail.com>
References: <20140924012422.4838.29188.stgit@notabene.brown>
 <20140924012832.4838.59410.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140924012832.4838.59410.stgit@notabene.brown>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.de>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Jeff Layton <jeff.layton@primarydata.com>, Peter Zijlstra <peterz@infradead.org>


* NeilBrown <neilb@suse.de> wrote:

> @@ -859,6 +860,8 @@ int wake_bit_function(wait_queue_t *wait, unsigned mode, int sync, void *key);
>  
>  extern int bit_wait(struct wait_bit_key *);
>  extern int bit_wait_io(struct wait_bit_key *);
> +extern int bit_wait_timeout(struct wait_bit_key *);
> +extern int bit_wait_io_timeout(struct wait_bit_key *);
>  
>  /**
>   * wait_on_bit - wait for a bit to be cleared
> diff --git a/kernel/sched/wait.c b/kernel/sched/wait.c
> index 15cab1a4f84e..380678b3cba4 100644
> --- a/kernel/sched/wait.c
> +++ b/kernel/sched/wait.c
> @@ -343,6 +343,18 @@ int __sched out_of_line_wait_on_bit(void *word, int bit,
>  }
>  EXPORT_SYMBOL(out_of_line_wait_on_bit);
>  
> +int __sched out_of_line_wait_on_bit_timeout(
> +	void *word, int bit, wait_bit_action_f *action,
> +	unsigned mode, unsigned long timeout)
> +{
> +	wait_queue_head_t *wq = bit_waitqueue(word, bit);
> +	DEFINE_WAIT_BIT(wait, word, bit);
> +
> +	wait.key.timeout = jiffies + timeout;
> +	return __wait_on_bit(wq, &wait, action, mode);
> +}
> +EXPORT_SYMBOL(out_of_line_wait_on_bit_timeout);
> +
>  int __sched
>  __wait_on_bit_lock(wait_queue_head_t *wq, struct wait_bit_queue *q,
>  			wait_bit_action_f *action, unsigned mode)
> @@ -520,3 +532,27 @@ __sched int bit_wait_io(struct wait_bit_key *word)
>  	return 0;
>  }
>  EXPORT_SYMBOL(bit_wait_io);
> +
> +__sched int bit_wait_timeout(struct wait_bit_key *word)
> +{
> +	unsigned long now = ACCESS_ONCE(jiffies);
> +	if (signal_pending_state(current->state, current))
> +		return 1;
> +	if (time_after_eq(now, word->timeout))
> +		return -EAGAIN;
> +	schedule_timeout(word->timeout - now);
> +	return 0;
> +}
> +EXPORT_SYMBOL(bit_wait_timeout);
> +
> +__sched int bit_wait_io_timeout(struct wait_bit_key *word)
> +{
> +	unsigned long now = ACCESS_ONCE(jiffies);
> +	if (signal_pending_state(current->state, current))
> +		return 1;
> +	if (time_after_eq(now, word->timeout))
> +		return -EAGAIN;
> +	io_schedule_timeout(word->timeout - now);
> +	return 0;
> +}
> +EXPORT_SYMBOL(bit_wait_io_timeout);

New scheduler APIs should be exported via EXPORT_SYMBOL_GPL().

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
