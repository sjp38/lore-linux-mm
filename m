Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2886D6B0007
	for <linux-mm@kvack.org>; Wed, 30 May 2018 12:26:34 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id w8-v6so6744778ywg.22
        for <linux-mm@kvack.org>; Wed, 30 May 2018 09:26:34 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w2-v6sor3393575yba.27.2018.05.30.09.26.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 May 2018 09:26:33 -0700 (PDT)
Date: Wed, 30 May 2018 09:26:29 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 06/13] blkcg: add generic throttling mechanism
Message-ID: <20180530162629.GN1351649@devbig577.frc2.facebook.com>
References: <20180529211724.4531-1-josef@toxicpanda.com>
 <20180529211724.4531-7-josef@toxicpanda.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180529211724.4531-7-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: axboe@kernel.dk, kernel-team@fb.com, linux-block@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Josef Bacik <jbacik@fb.com>

Hello,

On Tue, May 29, 2018 at 05:17:17PM -0400, Josef Bacik wrote:
> +static void blkcg_scale_delay(struct blkcg_gq *blkg, u64 now)
> +{
> +	u64 old = atomic64_read(&blkg->delay_start);
> +
> +	if (old + NSEC_PER_SEC <= now &&

Maybe time_before64()?

> +	    atomic64_cmpxchg(&blkg->delay_start, old, now) == old) {
> +		u64 cur = atomic64_read(&blkg->delay_nsec);
> +		u64 sub = min_t(u64, blkg->last_delay, now - old);
> +		int cur_use = atomic_read(&blkg->use_delay);
> +
> +		if (cur_use < blkg->last_use)
> +			sub = max_t(u64, sub, blkg->last_delay >> 1);
> +
> +		/* This shouldn't happen, but handle it anyway. */
> +		if (unlikely(cur < sub)) {
> +			atomic64_set(&blkg->delay_nsec, 0);
> +			blkg->last_delay = 0;
> +		} else {
> +			atomic64_sub(sub, &blkg->delay_nsec);
> +			blkg->last_delay = cur - sub;
> +		}
> +		blkg->last_use = cur_use;

Can you please add some comments explaining the above?  It's a lot of
logic.

> +static void blkcg_maybe_throttle_blkg(struct blkcg_gq *blkg, bool use_memdelay)
> +{

Maybe add a comment explaining that this is a cold path?

> +	u64 now = ktime_to_ns(ktime_get());
> +	u64 exp;
> +	u64 delay_nsec = 0;
> +	int tok;
> +
> +	while (blkg->parent) {
> +		if (atomic_read(&blkg->use_delay)) {
> +			blkcg_scale_delay(blkg, now);
> +			delay_nsec = max_t(u64, delay_nsec,
> +					   atomic64_read(&blkg->delay_nsec));
> +		}
> +		blkg = blkg->parent;
> +	}

Cuz the above may look too much otherwise.

...
> +void blkcg_maybe_throttle_current(void)
> +{
> +	struct request_queue *q = current->throttle_queue;
> +	struct cgroup_subsys_state *css;
> +	struct blkcg *blkcg;
> +	struct blkcg_gq *blkg;
> +	bool use_memdelay = current->use_memdelay;
> +
> +	if (!q)
> +		return;

The above would be the path taken in most cases, right?

> +
> +	current->throttle_queue = NULL;
> +	current->use_memdelay = false;

So, we only wait once, capped to 1s per blkcg_schedule_throttle()?
It'd be great to document the rationales.

> +	rcu_read_lock();
> +	css = kthread_blkcg();
> +	if (css)
> +		blkcg = css_to_blkcg(css);
> +	else
> +		blkcg = css_to_blkcg(task_css(current, io_cgrp_id));
> +
> +	if (!blkcg)
> +		goto out;
> +	blkg = blkg_lookup(blkcg, q);
> +	if (!blkg)
> +		goto out;
> +	blkg_get(blkg);

I don't think we can do blkg_get() on a blkg which is only protected
by rcu.  We probably need blkg_tryget() here.

> +	rcu_read_unlock();
> +	blk_put_queue(q);
> +
> +	blkcg_maybe_throttle_blkg(blkg, use_memdelay);
> +	blkg_put(blkg);
> +	return;
> +out:
> +	rcu_read_unlock();
> +	blk_put_queue(q);
> +}
> +EXPORT_SYMBOL_GPL(blkcg_maybe_throttle_current);
> +
> +void blkcg_schedule_throttle(struct request_queue *q, bool use_memdelay)
> +{
> +	if (unlikely(current->flags & PF_KTHREAD))
> +		return;
> +
> +	if (!blk_get_queue(q))
> +		return;
> +
> +	if (current->throttle_queue)
> +		blk_put_queue(current->throttle_queue);
> +	current->throttle_queue = q;

Can't we set current->throttle_blkg directly?

> +static inline int blkcg_unuse_delay(struct blkcg_gq *blkg)
> +{
> +	int old = atomic_read(&blkg->use_delay);
> +
> +	if (old == 0)
> +		return 0;
> +
> +	while (old) {
> +		int cur = atomic_cmpxchg(&blkg->use_delay, old, old - 1);

Can we use atomic_dec_return() here?

> +		if (cur == old)
> +			break;
> +		cur = old;
> +	}
> +
> +	if (old == 0)
> +		return 0;
> +	if (old == 1)
> +		atomic_dec(&blkg->blkcg->css.cgroup->congestion_count);
> +	return 1;
> +}
> +
> +static inline void blkcg_clear_delay(struct blkcg_gq *blkg)
> +{
> +	int old = atomic_read(&blkg->use_delay);
> +	if (!old)
> +		return;
> +	if (atomic_cmpxchg(&blkg->use_delay, old, 0) == old)
> +		atomic_dec(&blkg->blkcg->css.cgroup->congestion_count);

atomic_add_unless()?

Thanks.

-- 
tejun
