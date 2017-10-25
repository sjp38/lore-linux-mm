Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 65BAD6B0069
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 02:35:16 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id v127so9106379wma.3
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 23:35:16 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r13sor943995wrc.10.2017.10.24.23.35.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Oct 2017 23:35:15 -0700 (PDT)
Date: Wed, 25 Oct 2017 08:35:12 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v4 6/7] workqueue: Remove unnecessary acquisitions wrt
 workqueue flush
Message-ID: <20171025063512.qvdwo4q7hakeiwqf@gmail.com>
References: <1508908272-15757-1-git-send-email-byungchul.park@lge.com>
 <1508908272-15757-7-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1508908272-15757-7-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: peterz@infradead.org, axboe@kernel.dk, johan@kernel.org, tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tj@kernel.org, johannes.berg@intel.com, oleg@redhat.com, amir73il@gmail.com, david@fromorbit.com, darrick.wong@oracle.com, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, hch@infradead.org, idryomov@gmail.com, kernel-team@lge.com


* Byungchul Park <byungchul.park@lge.com> wrote:

> The workqueue added manual acquisitions to catch deadlock cases.
> Now crossrelease was introduced, some of those are redundant, since
> wait_for_completion() already includes the acquisition for itself.
> Removed it.
> 
> Signed-off-by: Byungchul Park <byungchul.park@lge.com>
> ---
>  include/linux/workqueue.h |  4 ++--
>  kernel/workqueue.c        | 19 +++----------------
>  2 files changed, 5 insertions(+), 18 deletions(-)
> 
> diff --git a/include/linux/workqueue.h b/include/linux/workqueue.h
> index f3c47a0..1455b5e 100644
> --- a/include/linux/workqueue.h
> +++ b/include/linux/workqueue.h
> @@ -218,7 +218,7 @@ static inline void destroy_delayed_work_on_stack(struct delayed_work *work) { }
>  									\
>  		__init_work((_work), _onstack);				\
>  		(_work)->data = (atomic_long_t) WORK_DATA_INIT();	\
> -		lockdep_init_map(&(_work)->lockdep_map, #_work, &__key, 0); \
> +		lockdep_init_map(&(_work)->lockdep_map, "(complete)"#_work, &__key, 0); \

This has a similar naming problem as the block bits: should be "wq_completion" or 
such.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
