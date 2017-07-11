Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id EF9376B04E8
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 12:13:12 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id r4so35002399ith.7
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 09:13:12 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id j9si332553ioe.158.2017.07.11.09.13.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jul 2017 09:13:11 -0700 (PDT)
Date: Tue, 11 Jul 2017 18:12:32 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v7 06/16] lockdep: Detect and handle hist_lock ring
 buffer overwrite
Message-ID: <20170711161232.GB28975@worktop>
References: <1495616389-29772-1-git-send-email-byungchul.park@lge.com>
 <1495616389-29772-7-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1495616389-29772-7-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com


ARGH!!! please, if there are known holes in patches, put a comment in.

I now had to independently discover this problem during review of the
last patch.

On Wed, May 24, 2017 at 05:59:39PM +0900, Byungchul Park wrote:
> The ring buffer can be overwritten by hardirq/softirq/work contexts.
> That cases must be considered on rollback or commit. For example,
> 
>           |<------ hist_lock ring buffer size ----->|
>           ppppppppppppiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii
> wrapped > iiiiiiiiiiiiiiiiiiiiiii....................
> 
>           where 'p' represents an acquisition in process context,
>           'i' represents an acquisition in irq context.
> 
> On irq exit, crossrelease tries to rollback idx to original position,
> but it should not because the entry already has been invalid by
> overwriting 'i'. Avoid rollback or commit for entries overwritten.
> 
> Signed-off-by: Byungchul Park <byungchul.park@lge.com>
> ---
>  include/linux/lockdep.h  | 20 +++++++++++
>  include/linux/sched.h    |  4 +++
>  kernel/locking/lockdep.c | 92 +++++++++++++++++++++++++++++++++++++++++-------
>  3 files changed, 104 insertions(+), 12 deletions(-)
> 
> diff --git a/include/linux/lockdep.h b/include/linux/lockdep.h
> index d531097..a03f79d 100644
> --- a/include/linux/lockdep.h
> +++ b/include/linux/lockdep.h
> @@ -284,6 +284,26 @@ struct held_lock {
>   */
>  struct hist_lock {
>  	/*
> +	 * Id for each entry in the ring buffer. This is used to
> +	 * decide whether the ring buffer was overwritten or not.
> +	 *
> +	 * For example,
> +	 *
> +	 *           |<----------- hist_lock ring buffer size ------->|
> +	 *           pppppppppppppppppppppiiiiiiiiiiiiiiiiiiiiiiiiiiiii
> +	 * wrapped > iiiiiiiiiiiiiiiiiiiiiiiiiii.......................
> +	 *
> +	 *           where 'p' represents an acquisition in process
> +	 *           context, 'i' represents an acquisition in irq
> +	 *           context.
> +	 *
> +	 * In this example, the ring buffer was overwritten by
> +	 * acquisitions in irq context, that should be detected on
> +	 * rollback or commit.
> +	 */
> +	unsigned int hist_id;
> +
> +	/*
>  	 * Seperate stack_trace data. This will be used at commit step.
>  	 */
>  	struct stack_trace	trace;
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index 5f6d6f4..9e1437c 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1756,6 +1756,10 @@ struct task_struct {
>  	unsigned int xhlock_idx_soft; /* For restoring at softirq exit */
>  	unsigned int xhlock_idx_hard; /* For restoring at hardirq exit */
>  	unsigned int xhlock_idx_work; /* For restoring at work exit */
> +	unsigned int hist_id;
> +	unsigned int hist_id_soft; /* For overwrite check at softirq exit */
> +	unsigned int hist_id_hard; /* For overwrite check at hardirq exit */
> +	unsigned int hist_id_work; /* For overwrite check at work exit */
>  #endif
>  #ifdef CONFIG_UBSAN
>  	unsigned int in_ubsan;


Right, like I wrote in the comment; I don't think you need quite this
much.

The problem only happens if you rewind more than MAX_XHLOCKS_NR;
although I realize it can be an accumulative rewind, which makes it
slightly more tricky.

We can either make the rewind more expensive and make xhlock_valid()
false for each rewound entry; or we can keep the max_idx and account
from there. If we rewind >= MAX_XHLOCKS_NR from the max_idx we need to
invalidate the entire state, which we can do by invaliding
xhlock_valid() or by re-introduction of the hist_gen_id. When we
invalidate the entire state, we can also clear the max_idx.

Given that rewinding _that_ far should be fairly rare (do we have
numbers?) simply iterating the entire thing and setting
xhlock->hlock.instance = NULL, should work I think.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
