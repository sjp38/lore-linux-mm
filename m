Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id DE2F26B0005
	for <linux-mm@kvack.org>; Mon,  4 Jul 2016 14:25:57 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id t2so221862841qkh.1
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 11:25:57 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s48si2841354qta.19.2016.07.04.11.25.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jul 2016 11:25:57 -0700 (PDT)
Date: Mon, 4 Jul 2016 20:25:50 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 3/8] mm,oom: Use list of mm_struct used by OOM victims.
Message-ID: <20160704182549.GB8396@redhat.com>
References: <201607031135.AAH95347.MVOHQtFJFLOOFS@I-love.SAKURA.ne.jp>
 <201607031138.AHB35971.FLVQOtJFOMFHSO@I-love.SAKURA.ne.jp>
 <20160704103931.GA3882@redhat.com>
 <201607042150.CIB00512.FSOtMHLOOVFFQJ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201607042150.CIB00512.FSOtMHLOOVFFQJ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com, mhocko@suse.com, mhocko@kernel.org

On 07/04, Tetsuo Handa wrote:
>
> Oleg Nesterov wrote:
> > >
> > > --- a/kernel/fork.c
> > > +++ b/kernel/fork.c
> > > @@ -722,6 +722,7 @@ static inline void __mmput(struct mm_struct *mm)
> > >  	}
> > >  	if (mm->binfmt)
> > >  		module_put(mm->binfmt->module);
> > > +	exit_oom_mm(mm);
> >
> > Is it strictly necessary? At first glance not. Sooner or later oom_reaper() should
> > find this mm_struct and do exit_oom_mm(). And given that mm->mm_users is already 0
> > the "extra" __oom_reap_vmas() doesn't really hurt.
> >
> > It would be nice to remove exit_oom_mm() from __mmput(); it takes the global spinlock
> > for the very unlikely case, and if we can avoid it here then perhaps we can remove
> > ->oom_mm from mm_struct.
>
> I changed not to take global spinlock from __mmput() unless that mm was used by
> TIF_MEMDIE threads.

This new version doesn't apply on top of 2/8, I can't really understand it...

> But I don't think I can remove oom_mm from mm_struct

I think we can try later. oom_init() can create a small mem-pool or we can even
use GFP_ATOMIC for the start to (try to) alloc

	struct oom_mm {
		struct mm_struct *mm;	// mm to reap
		struct list_head list;	// node in the oom_mm_list
		...
	};

lets discuss this later, but to do this we need to remove exit_oom_mm() from exit_mm().
Although we can probably add another MMF_flag, but I think it would be nice to avoid
exit_oom_mm anyway, if it is possible.

And in any case personally I really hate oom_mm->comm/pid ;) but I think we
can remove it later either way.

> Thus, I think I need to remember task_struct which got TIF_MEMDIE.

Well, this is unfortunate imho. This in fact turns "reap mm" back into "reap task".

> I'd like to wait for Michal to come back...

Yes. imho this series doesn't look bad, but lets wait for Michal.

> +void exit_oom_mm(struct mm_struct *mm)
> +{
> +	/* Nothing to do unless mark_oom_victim() was called with this mm. */
> +	if (!mm->oom_mm.victim)
> +		return;
> +#ifdef CONFIG_MMU
> +	/*
> +	 * OOM reaper will eventually call __exit_oom_mm().
> +	 * Allow oom_has_pending_mm() to ignore this mm.
> +	 */
> +	set_bit(MMF_OOM_REAPED, &mm->flags);

If the caller is exit_mm(), then mm->mm_users == 0 and oom_has_pending_mm()
can check it is zero instead?

So,

> +#else
> +	__exit_oom_mm(mm);
> +#endif

it seems that only CONFIG_MMU=n needs this... Apart from oom_has_pending_mm()
why do we bother to add the victim's mm to oom_mm_list?

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
