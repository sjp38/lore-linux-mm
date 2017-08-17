Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id BF1EC6B025F
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 03:48:15 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z91so5625558wrc.4
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 00:48:15 -0700 (PDT)
Received: from mail-wr0-x244.google.com (mail-wr0-x244.google.com. [2a00:1450:400c:c0c::244])
        by mx.google.com with ESMTPS id a11si3326220edk.129.2017.08.17.00.48.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Aug 2017 00:48:14 -0700 (PDT)
Received: by mail-wr0-x244.google.com with SMTP id x43so6914174wrb.1
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 00:48:14 -0700 (PDT)
Date: Thu, 17 Aug 2017 09:48:11 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v8 00/14] lockdep: Implement crossrelease feature
Message-ID: <20170817074811.csim2edowld4xvky@gmail.com>
References: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
 <20170815082020.fvfahxwx2zt4ps4i@gmail.com>
 <20170816001637.GN20323@X58A-UD3R>
 <20170816035842.p33z5st3rr2gwssh@tardis>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170816035842.p33z5st3rr2gwssh@tardis>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boqun Feng <boqun.feng@gmail.com>
Cc: Byungchul Park <byungchul.park@lge.com>, Thomas Gleixner <tglx@linutronix.de>, peterz@infradead.org, walken@google.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com


* Boqun Feng <boqun.feng@gmail.com> wrote:

> --- a/kernel/workqueue.c
> +++ b/kernel/workqueue.c
> @@ -2431,6 +2431,27 @@ struct wq_barrier {
>  	struct task_struct	*task;	/* purely informational */
>  };
>  
> +#ifdef CONFIG_LOCKDEP_COMPLETE
> +# define INIT_WQ_BARRIER_ONSTACK(barr, func, target)				\
> +do {										\
> +	INIT_WORK_ONSTACK(&(barr)->work, func);					\
> +	__set_bit(WORK_STRUCT_PENDING_BIT, work_data_bits(&(barr)->work));	\
> +	lockdep_init_map_crosslock((struct lockdep_map *)&(barr)->done.map,	\
> +				   "(complete)" #barr,				\
> +				   (target)->lockdep_map.key, 1); 		\
> +	__init_completion(&barr->done);						\
> +	barr->task = current;							\
> +} while (0)
> +#else
> +# define INIT_WQ_BARRIER_ONSTACK(barr, func, target)				\
> +do {										\
> +	INIT_WORK_ONSTACK(&(barr)->work, func);					\
> +	__set_bit(WORK_STRUCT_PENDING_BIT, work_data_bits(&(barr)->work));	\
> +	init_completion(&barr->done);						\
> +	barr->task = current;							\
> +} while (0)
> +#endif

Is there any progress with this bug? This false positive warning regression is 
blocking the locking tree.

BTW., I don't think the #ifdef is necessary: lockdep_init_map_crosslock should map 
to nothing when lockdep is disabled, right?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
