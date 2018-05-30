Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6483D6B0006
	for <linux-mm@kvack.org>; Wed, 30 May 2018 11:54:36 -0400 (EDT)
Received: by mail-yb0-f198.google.com with SMTP id w15-v6so12281478ybi.13
        for <linux-mm@kvack.org>; Wed, 30 May 2018 08:54:36 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y8-v6sor9036221ybj.33.2018.05.30.08.54.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 May 2018 08:54:35 -0700 (PDT)
Date: Wed, 30 May 2018 08:54:32 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 03/13] blk-cgroup: allow controllers to output their own
 stats
Message-ID: <20180530155432.GK1351649@devbig577.frc2.facebook.com>
References: <20180529211724.4531-1-josef@toxicpanda.com>
 <20180529211724.4531-4-josef@toxicpanda.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180529211724.4531-4-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: axboe@kernel.dk, kernel-team@fb.com, linux-block@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Josef Bacik <jbacik@fb.com>

On Tue, May 29, 2018 at 05:17:14PM -0400, Josef Bacik wrote:
...
> +		mutex_lock(&blkcg_pol_mutex);
> +		for (i = 0; i < BLKCG_MAX_POLS; i++) {
> +			struct blkcg_policy *pol = blkcg_policy[i];
> +
> +			if (!blkg->pd[i] || !pol->pd_stat_fn)
> +				continue;
> +
> +			count = pol->pd_stat_fn(blkg->pd[i], buf, size);

Wouldn't it be easier to simply pass in the seq_file?

> +			if (count >= size)
> +				continue;
> +			buf += count;
> +			total += count;
> +			size -= count + 1;
> +		}
> +		mutex_unlock(&blkcg_pol_mutex);
> +		if (total) {
> +			count = snprintf(buf, size, "\n");
> +			if (count >= size)
> +				continue;

scnprintf() might make this less painful.

> +			total += count;
> +			seq_commit(sf, total);
> +		}

Thanks.

-- 
tejun
