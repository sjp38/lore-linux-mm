Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 2ECB96B0038
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 03:30:27 -0500 (EST)
Received: by wmww144 with SMTP id w144so93974509wmw.0
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 00:30:26 -0800 (PST)
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com. [74.125.82.47])
        by mx.google.com with ESMTPS id c73si17717365wmh.51.2015.11.23.00.30.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Nov 2015 00:30:26 -0800 (PST)
Received: by wmww144 with SMTP id w144so93974008wmw.0
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 00:30:25 -0800 (PST)
Date: Mon, 23 Nov 2015 09:30:24 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: linux-4.4-rc1: TIF_MEMDIE without SIGKILL pending?
Message-ID: <20151123083024.GA21436@dhcp22.suse.cz>
References: <201511222113.FCF57847.OOMJVQtFFSOFLH@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201511222113.FCF57847.OOMJVQtFFSOFLH@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, oleg@redhat.com, linux-mm@kvack.org

On Sun 22-11-15 21:13:22, Tetsuo Handa wrote:
> I was updating kmallocwd in preparation for testing "[RFC 0/3] OOM detection
> rework v2" patchset. I noticed an unexpected result with linux.git as of
> 3ad5d7e06a96 .
> 
> The problem is that an OOM victim arrives at do_exit() with TIF_MEMDIE flag
> set but without pending SIGKILL. Is this correct behavior?

Have a look at out_of_memory where we do:
        /*
         * If current has a pending SIGKILL or is exiting, then automatically
         * select it.  The goal is to allow it to allocate so that it may
         * quickly exit and free its memory.
         *
         * But don't select if current has already released its mm and cleared
         * TIF_MEMDIE flag at exit_mm(), otherwise an OOM livelock may occur.
         */
        if (current->mm &&
            (fatal_signal_pending(current) || task_will_free_mem(current))) {
                mark_oom_victim(current);
                return true;
        }

So if the current was exiting already we are not killing it, we just give it
access to memory reserves to expedite the exit. We do the same thing for the
memcg case.

Why would that be an issue in the first place?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
