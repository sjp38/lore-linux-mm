Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 2B80F6B0035
	for <linux-mm@kvack.org>; Wed, 25 Jun 2014 19:35:31 -0400 (EDT)
Received: by mail-ig0-f173.google.com with SMTP id uq10so68208igb.6
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 16:35:31 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id b5si8271734icx.38.2014.06.25.16.35.30
        for <linux-mm@kvack.org>;
        Wed, 25 Jun 2014 16:35:30 -0700 (PDT)
Date: Wed, 25 Jun 2014 16:35:28 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 5/6] mm: page_alloc: Reduce cost of dirty zone balancing
Message-Id: <20140625163528.11368b86ef7d0a38cf9d1255@linux-foundation.org>
In-Reply-To: <1403683129-10814-6-git-send-email-mgorman@suse.de>
References: <1403683129-10814-1-git-send-email-mgorman@suse.de>
	<1403683129-10814-6-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Jens Axboe <axboe@kernel.dk>, Jeff Moyer <jmoyer@redhat.com>, Dave Chinner <david@fromorbit.com>

On Wed, 25 Jun 2014 08:58:48 +0100 Mel Gorman <mgorman@suse.de> wrote:

> @@ -325,7 +321,14 @@ static unsigned long zone_dirty_limit(struct zone *zone)
>   */
>  bool zone_dirty_ok(struct zone *zone)
>  {
> -	unsigned long limit = zone_dirty_limit(zone);
> +	unsigned long limit = zone->dirty_limit_cached;
> +	struct task_struct *tsk = current;
> +
> +	if (tsk->flags & PF_LESS_THROTTLE || rt_task(tsk)) {
> +		limit = zone_dirty_limit(zone);
> +		zone->dirty_limit_cached = limit;
> +		limit += limit / 4;
> +	}

Could we get a comment in here explaining what we're doing and why
PF_LESS_THROTTLE and rt_task control whether we do it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
