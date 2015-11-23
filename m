Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 92D826B0038
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 06:33:55 -0500 (EST)
Received: by wmww144 with SMTP id w144so100394033wmw.0
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 03:33:55 -0800 (PST)
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com. [74.125.82.52])
        by mx.google.com with ESMTPS id 128si18654821wmy.0.2015.11.23.03.33.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Nov 2015 03:33:54 -0800 (PST)
Received: by wmvv187 with SMTP id v187so156086452wmv.1
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 03:33:54 -0800 (PST)
Date: Mon, 23 Nov 2015 12:33:52 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: linux-4.4-rc1: TIF_MEMDIE without SIGKILL pending?
Message-ID: <20151123113352.GH21050@dhcp22.suse.cz>
References: <201511222113.FCF57847.OOMJVQtFFSOFLH@I-love.SAKURA.ne.jp>
 <20151123083024.GA21436@dhcp22.suse.cz>
 <201511232006.EDD81713.JMSFOOtQFOHLFV@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201511232006.EDD81713.JMSFOOtQFOHLFV@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, oleg@redhat.com, linux-mm@kvack.org

On Mon 23-11-15 20:06:02, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Sun 22-11-15 21:13:22, Tetsuo Handa wrote:
> > > I was updating kmallocwd in preparation for testing "[RFC 0/3] OOM detection
> > > rework v2" patchset. I noticed an unexpected result with linux.git as of
> > > 3ad5d7e06a96 .
> > > 
> > > The problem is that an OOM victim arrives at do_exit() with TIF_MEMDIE flag
> > > set but without pending SIGKILL. Is this correct behavior?
> > 
> > Have a look at out_of_memory where we do:
> >         /*
> >          * If current has a pending SIGKILL or is exiting, then automatically
> >          * select it.  The goal is to allow it to allocate so that it may
> >          * quickly exit and free its memory.
> >          *
> >          * But don't select if current has already released its mm and cleared
> >          * TIF_MEMDIE flag at exit_mm(), otherwise an OOM livelock may occur.
> >          */
> >         if (current->mm &&
> >             (fatal_signal_pending(current) || task_will_free_mem(current))) {
> >                 mark_oom_victim(current);
> >                 return true;
> >         }
> > 
> > So if the current was exiting already we are not killing it, we just give it
> > access to memory reserves to expedite the exit. We do the same thing for the
> > memcg case.
> 
> The result is the same even if I do
> 
> -	BUG_ON(test_thread_flag(TIF_MEMDIE) && !fatal_signal_pending(current));
> +	BUG_ON(test_thread_flag(TIF_MEMDIE) && !fatal_signal_pending(current) && !task_will_free_mem(current));
> 
> . I think that task_will_free_mem() is always false because this BUG_ON()
> is located before "exit_signals(tsk);  /* sets PF_EXITING */" line.

I haven't checked where exactly you added the BUG_ON, I was merely
comenting on the possibility that TIF_MEMDIE is set without sending
SIGKILL.

Now that I am looking at your BUG_ON more closely I am wondering whether
it makes sense at all. The fatal signal has been dequeued in get_signal
before we call into do_group_exit AFAICS.

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
