Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id CBF8D828E1
	for <linux-mm@kvack.org>; Tue,  5 Jul 2016 16:52:40 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id i44so487157273qte.3
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 13:52:40 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n80si52611qke.73.2016.07.05.13.52.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jul 2016 13:52:39 -0700 (PDT)
Date: Tue, 5 Jul 2016 22:52:31 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 3/8] mm,oom: Use list of mm_struct used by OOM victims.
Message-ID: <20160705205231.GA25340@redhat.com>
References: <201607031135.AAH95347.MVOHQtFJFLOOFS@I-love.SAKURA.ne.jp>
 <201607031138.AHB35971.FLVQOtJFOMFHSO@I-love.SAKURA.ne.jp>
 <20160704103931.GA3882@redhat.com>
 <201607042150.CIB00512.FSOtMHLOOVFFQJ@I-love.SAKURA.ne.jp>
 <20160704182549.GB8396@redhat.com>
 <201607051943.GHB86443.SOOFFFHJVLMQOt@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201607051943.GHB86443.SOOFFFHJVLMQOt@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com, mhocko@suse.com, mhocko@kernel.org

Tetsuo,

I am already sleeping and had a lot of beer ;) but let me try to (partly) reply anyway.

On 07/05, Tetsuo Handa wrote:
>
> Oleg Nesterov wrote:
> >
> > This new version doesn't apply on top of 2/8, I can't really understand it...
>
> This new version is not for on top of 2/8, but squashed of all [1-8]/8 patches.

Ah, OK, I'll try to take a look tomorrow.

> > > +void exit_oom_mm(struct mm_struct *mm)
> > > +{
> > > +	/* Nothing to do unless mark_oom_victim() was called with this mm. */
> > > +	if (!mm->oom_mm.victim)
> > > +		return;
> > > +#ifdef CONFIG_MMU
> > > +	/*
> > > +	 * OOM reaper will eventually call __exit_oom_mm().
> > > +	 * Allow oom_has_pending_mm() to ignore this mm.
> > > +	 */
> > > +	set_bit(MMF_OOM_REAPED, &mm->flags);
> >
> > If the caller is exit_mm(), then mm->mm_users == 0 and oom_has_pending_mm()
> > can check it is zero instead?
>
> I don't think so. Setting MMF_OOM_REAPED indicates that memory used by that
> mm is already reclaimed by the OOM reaper or by __mmput().

Sure, this is clear,

> mm->mm_users == 0
> alone does not mean memory used by that mm is already reclaimed.
  ^^^^^

Of course! I meant that oom_has_pending_mm() can check _both_ mm_users and
MMF_OOM_REAPED and then we do not need to set MMF_OOM_REAPED in exit_mm() path.

No?

> Making exit_oom_mm() a no-op for CONFIG_MMU=y would be OK,

Yes. Not only because this can simplify other changes. I do believe that the less
"oom" hooks we have the better, even if this needs some complications in oom_kill.c.

For example, this series removes the extra try_to_freeze_tasks() from freeze_processes()
(which is in fact the "oom" hook) and personally I do like this fact.

And. Of course I am not sure this is possible, but to me it would be very nice
to kill oom_reaper_list altogether if CONFIG_MMU=n.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
