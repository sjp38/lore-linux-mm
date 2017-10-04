Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1884B6B025F
	for <linux-mm@kvack.org>; Wed,  4 Oct 2017 17:42:51 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id s185so2225963oif.3
        for <linux-mm@kvack.org>; Wed, 04 Oct 2017 14:42:51 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id i11si6729170oih.357.2017.10.04.14.42.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 04 Oct 2017 14:42:49 -0700 (PDT)
Subject: Re: [PATCH 1/2] Revert "vmalloc: back off when the current task is killed"
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20171003225504.GA966@cmpxchg.org>
	<20171004185813.GA2136@cmpxchg.org>
	<20171004185906.GB2136@cmpxchg.org>
	<ab688e7c-75c1-e942-ef44-44615d9fb394@I-love.SAKURA.ne.jp>
	<20171004210027.GA2973@cmpxchg.org>
In-Reply-To: <20171004210027.GA2973@cmpxchg.org>
Message-Id: <201710050642.JJI34818.QFSHJOMOtFOLFV@I-love.SAKURA.ne.jp>
Date: Thu, 5 Oct 2017 06:42:38 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: akpm@linux-foundation.org, alan@llwyncelyn.cymru, hch@lst.de, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Johannes Weiner wrote:
> On Thu, Oct 05, 2017 at 05:49:43AM +0900, Tetsuo Handa wrote:
> > On 2017/10/05 3:59, Johannes Weiner wrote:
> > > But the justification to make that vmalloc() call fail like this isn't
> > > convincing, either. The patch mentions an OOM victim exhausting the
> > > memory reserves and thus deadlocking the machine. But the OOM killer
> > > is only one, improbable source of fatal signals. It doesn't make sense
> > > to fail allocations preemptively with plenty of memory in most cases.
> > 
> > By the time the current thread reaches do_exit(), fatal_signal_pending(current)
> > should become false. As far as I can guess, the source of fatal signal will be
> > tty_signal_session_leader(tty, exit_session) which is called just before
> > tty_ldisc_hangup(tty, cons_filp != NULL) rather than the OOM killer. I don't
> > know whether it is possible to make fatal_signal_pending(current) true inside
> > do_exit() though...
> 
> It's definitely not the OOM killer, the memory situation looks fine
> when this happens. I didn't look closer where the signal comes from.
> 

Then, we could check tsk_is_oom_victim() instead of fatal_signal_pending().

> That said, we trigger this issue fairly easily. We tested the revert
> over night on a couple thousand machines, and it fixed the issue
> (whereas the control group still saw the crashes).
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
