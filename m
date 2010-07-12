Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C526B6B02A3
	for <linux-mm@kvack.org>; Mon, 12 Jul 2010 18:16:19 -0400 (EDT)
Date: Mon, 12 Jul 2010 15:15:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 5/6] writeback: fix queue_io() ordering
Message-Id: <20100712151518.d4cdfebc.akpm@linux-foundation.org>
In-Reply-To: <20100711021749.163345723@intel.com>
References: <20100711020656.340075560@intel.com>
	<20100711021749.163345723@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Martin Bligh <mbligh@google.com>, Michael Rubin <mrubin@google.com>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sun, 11 Jul 2010 10:07:01 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> This was not a bug, since b_io is empty for kupdate writeback.
> The next patch will do requeue_io() for non-kupdate writeback,
> so let's fix it.
> 
> CC: Dave Chinner <david@fromorbit.com>
> Cc: Martin Bligh <mbligh@google.com>
> Cc: Michael Rubin <mrubin@google.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Signed-off-by: Fengguang Wu <wfg@mail.ustc.edu.cn>

I assumed you didn't mean to sign this twice so I removed this signoff.

> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  fs/fs-writeback.c |    7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
> 
> --- linux-next.orig/fs/fs-writeback.c	2010-07-11 09:13:31.000000000 +0800
> +++ linux-next/fs/fs-writeback.c	2010-07-11 09:13:32.000000000 +0800
> @@ -252,11 +252,14 @@ static void move_expired_inodes(struct l
>  }
>  
>  /*
> - * Queue all expired dirty inodes for io, eldest first.
> + * Queue all expired dirty inodes for io, eldest first:
> + * (newly dirtied) => b_dirty inodes
> + *                 => b_more_io inodes
> + *                 => remaining inodes in b_io => (dequeue for sync)
>   */
>  static void queue_io(struct bdi_writeback *wb, unsigned long *older_than_this)
>  {
> -	list_splice_init(&wb->b_more_io, wb->b_io.prev);
> +	list_splice_init(&wb->b_more_io, &wb->b_io);
>  	move_expired_inodes(&wb->b_dirty, &wb->b_io, older_than_this);
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
