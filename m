Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id 41A8C6B0038
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 06:06:12 -0500 (EST)
Received: by oies6 with SMTP id s6so120683910oie.1
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 03:06:11 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id l65si7115758oia.45.2015.11.23.03.06.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 23 Nov 2015 03:06:10 -0800 (PST)
Subject: Re: linux-4.4-rc1: TIF_MEMDIE without SIGKILL pending?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201511222113.FCF57847.OOMJVQtFFSOFLH@I-love.SAKURA.ne.jp>
	<20151123083024.GA21436@dhcp22.suse.cz>
In-Reply-To: <20151123083024.GA21436@dhcp22.suse.cz>
Message-Id: <201511232006.EDD81713.JMSFOOtQFOHLFV@I-love.SAKURA.ne.jp>
Date: Mon, 23 Nov 2015 20:06:02 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, oleg@redhat.com, linux-mm@kvack.org

Michal Hocko wrote:
> On Sun 22-11-15 21:13:22, Tetsuo Handa wrote:
> > I was updating kmallocwd in preparation for testing "[RFC 0/3] OOM detection
> > rework v2" patchset. I noticed an unexpected result with linux.git as of
> > 3ad5d7e06a96 .
> > 
> > The problem is that an OOM victim arrives at do_exit() with TIF_MEMDIE flag
> > set but without pending SIGKILL. Is this correct behavior?
> 
> Have a look at out_of_memory where we do:
>         /*
>          * If current has a pending SIGKILL or is exiting, then automatically
>          * select it.  The goal is to allow it to allocate so that it may
>          * quickly exit and free its memory.
>          *
>          * But don't select if current has already released its mm and cleared
>          * TIF_MEMDIE flag at exit_mm(), otherwise an OOM livelock may occur.
>          */
>         if (current->mm &&
>             (fatal_signal_pending(current) || task_will_free_mem(current))) {
>                 mark_oom_victim(current);
>                 return true;
>         }
> 
> So if the current was exiting already we are not killing it, we just give it
> access to memory reserves to expedite the exit. We do the same thing for the
> memcg case.

The result is the same even if I do

-	BUG_ON(test_thread_flag(TIF_MEMDIE) && !fatal_signal_pending(current));
+	BUG_ON(test_thread_flag(TIF_MEMDIE) && !fatal_signal_pending(current) && !task_will_free_mem(current));

. I think that task_will_free_mem() is always false because this BUG_ON()
is located before "exit_signals(tsk);  /* sets PF_EXITING */" line.

> 
> Why would that be an issue in the first place?

The real problem I care is TIF_MEMDIE livelock.

  MemAlloc: oom-tester4(11040) uninterruptible dying victim
  MemAlloc: oom-tester4(11045) gfp=0x242014a order=0 delay=10000 dying

I'm not talking about TIF_MEMDIE livelock in this thread. I'm just worrying
that below output (which is caused by an OOM victim arriving at do_exit()
with TIF_MEMDIE flag set but without pending SIGKILL) is a foretaste of
unnoticed problem.

  MemAlloc: oom-tester4(11520) uninterruptible victim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
