Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 99D136B0032
	for <linux-mm@kvack.org>; Tue, 23 Dec 2014 09:57:28 -0500 (EST)
Received: by mail-wg0-f53.google.com with SMTP id l18so9194085wgh.40
        for <linux-mm@kvack.org>; Tue, 23 Dec 2014 06:57:28 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hj1si25421377wib.65.2014.12.23.06.57.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 23 Dec 2014 06:57:27 -0800 (PST)
Date: Tue, 23 Dec 2014 15:57:24 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC PATCH] oom: Don't count on mm-less current process.
Message-ID: <20141223145724.GG28549@dhcp22.suse.cz>
References: <20141223122401.GC28549@dhcp22.suse.cz>
 <201412232200.BCI48944.LJFSFVOFHMOtQO@I-love.SAKURA.ne.jp>
 <20141223130909.GE28549@dhcp22.suse.cz>
 <201412232220.IIJ57305.OMOOSVFtFFHQLJ@I-love.SAKURA.ne.jp>
 <20141223134309.GF28549@dhcp22.suse.cz>
 <201412232311.IJH26045.LMSHFVOFJQFtOO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201412232311.IJH26045.LMSHFVOFJQFtOO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com

On Tue 23-12-14 23:11:01, Tetsuo Handa wrote:
[...]
>   (1) P2 is sleeping at sleep(10).
>   (2) P1 triggers the OOM killer and P2 is chosen.
>   (3) The OOM killer sets TIF_MEMDIE on P2.
>   (4) P2 wakes up as sleep(10) expired.
>   (5) P2 calls read().
>   (6) P2 triggers page fault inside read().
>   (7) P2 allocates from memory reserves for handling page fault.
>   (8) The OOM killer sends SIGKILL to P2.
>   (9) P2 receives SIGKILL after all memory reserves were
>       allocated for handling page fault.
>   (10) P2 starts steps for die, but memory reserves may be
>        already empty.

How is that any different from any other task which allocates with
TIF_MEMDIE already set and fatal_signal_pending without checking for
the later?
 
> My worry:
> 
>   More the delay between (3) and (8) becomes longer (e.g. 30 seconds
>   for an overdone case), more likely to cause memory reserves being
>   consumed before (9). If (3) and (8) are reversed, P2 will notice
>   fatal_signal_pending() and bail out before allocating a lot of
>   memory from memory reserves.

And my suspicion is that this has never been a real problem and I really
do not like to fiddle with the code for non-existing problems. If
you are sure that the reverse order is correct and doesn't cause any
other issues then you are free to send a separate patch with a proper
justification. The patch I've posted fixes a different problem and
putting more stuff in it is just not right! I really hate how you
conflate different issues all the time, TBH.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
