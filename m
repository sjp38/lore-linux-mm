Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 3CBA06B00EE
	for <linux-mm@kvack.org>; Mon, 15 Aug 2011 09:19:23 -0400 (EDT)
Date: Mon, 15 Aug 2011 21:19:15 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 1/2 v2] writeback: Add a 'reason' to wb_writeback_work
Message-ID: <20110815131915.GA13534@localhost>
References: <1313189245-7197-1-git-send-email-curtw@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1313189245-7197-1-git-send-email-curtw@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Curt Wohlgemuth <curtw@google.com>
Cc: Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Michael Rubin <mrubin@google.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi Curt,

This is a very useful patch, thanks!  Nitpicks followed :)

> +       enum wb_stats reason;           /* why was writeback initiated? */

Not about this patch, but some time later, some one may well find the
->for_background, ->for_kupdate fields duplicated with ->reason, and
try to eliminate the struct fields as well as the trace point fields :)

>  /*
> + * why this writeback was initiated
> + */
> +enum wb_stats {
> +       /* The following are counts of pages written for a specific cause */
> +       WB_STAT_BALANCE_DIRTY,
> +       WB_STAT_BG_WRITEOUT,
> +       WB_STAT_TRY_TO_FREE_PAGES,
> +       WB_STAT_SYNC,
> +       WB_STAT_KUPDATE,
> +       WB_STAT_LAPTOP_TIMER,
> +       WB_STAT_FREE_MORE_MEM,
> +       WB_STAT_FS_FREE_SPACE,
> +       WB_STAT_FORKER_THREAD,
> +
> +       WB_STAT_MAX,
> +};

I find it more comfortable to use "reason", "enum wb_reason" and
WB_REASON_* uniformly. Yeah, I read in the next patch that you'll add
other stat fields, however they are different in concept and looks
better be put to another enum. With some index shift, it should yield
the same efficient code, with better code readability.

> +#define show_work_reason(reason)                                       \
> +       __print_symbolic(reason,                                        \
> +               {WB_STAT_BALANCE_DIRTY,         "balance_dirty"},       \
> +               {WB_STAT_BG_WRITEOUT,           "background"},          \
> +               {WB_STAT_TRY_TO_FREE_PAGES,     "try_to_free_pages"},   \
> +               {WB_STAT_SYNC,                  "sync"},                \
> +               {WB_STAT_KUPDATE,               "periodic"},            \
> +               {WB_STAT_LAPTOP_TIMER,          "laptop_timer"},        \
> +               {WB_STAT_FREE_MORE_MEM,         "free_more_memory"},    \
> +               {WB_STAT_FS_FREE_SPACE,         "FS_free_space"}        \
> +       )

Some symbolic names disagree with the names used in the next patch..

> -                 "kupdate=%d range_cyclic=%d background=%d",
> +                 "kupdate=%d range_cyclic=%d background=%d reason=%s",

Here is the obvious duplicates. I'm not sure if there are serious
scripts relying on the kupdate/background fields (none from me), and
if we are going to carry this redundancy in future..

>  TRACE_EVENT(writeback_queue_io,
>         TP_PROTO(struct bdi_writeback *wb,
> -                unsigned long *older_than_this,
> +                struct wb_writeback_work *work,
>                  int moved),
> -       TP_ARGS(wb, older_than_this, moved),
> +       TP_ARGS(wb, work, moved),
>         TP_STRUCT__entry(
>                 __array(char,           name, 32)
>                 __field(unsigned long,  older)
>                 __field(long,           age)
>                 __field(int,            moved)
> +               __field(int,            reason)
>         ),
>         TP_fast_assign(
>                 strncpy(__entry->name, dev_name(wb->bdi->dev), 32);
> -               __entry->older  = older_than_this ?  *older_than_this : 0;
> -               __entry->age    = older_than_this ?
> -                                 (jiffies - *older_than_this) * 1000 / HZ : -1;
> +               __entry->older  = work->older_than_this ?
> +                                               *work->older_than_this : 0;
> +               __entry->age    = work->older_than_this ?
> +                         (jiffies - *work->older_than_this) * 1000 / HZ : -1;

The older_than_this change seems big enough for a standalone patch.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
