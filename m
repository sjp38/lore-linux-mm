Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id ED76B6B0253
	for <linux-mm@kvack.org>; Sun, 20 Sep 2015 10:58:58 -0400 (EDT)
Received: by qgez77 with SMTP id z77so72904566qge.1
        for <linux-mm@kvack.org>; Sun, 20 Sep 2015 07:58:58 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g36si17349762qkh.100.2015.09.20.07.58.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Sep 2015 07:58:58 -0700 (PDT)
Date: Sun, 20 Sep 2015 16:55:57 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: can't oom-kill zap the victim's memory?
Message-ID: <20150920145557.GA10200@redhat.com>
References: <1442512783-14719-1-git-send-email-kwalker@redhat.com> <20150919150316.GB31952@redhat.com> <201509202350.DDG21892.FFStOLHOQOFMVJ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201509202350.DDG21892.FFStOLHOQOFMVJ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: kwalker@redhat.com, cl@linux.com, torvalds@linux-foundation.org, mhocko@kernel.org, akpm@linux-foundation.org, rientjes@google.com, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, skozina@redhat.com

On 09/20, Tetsuo Handa wrote:
>
> Oleg Nesterov wrote:
> > On 09/17, Kyle Walker wrote:
> > >
> > > Currently, the oom killer will attempt to kill a process that is in
> > > TASK_UNINTERRUPTIBLE state. For tasks in this state for an exceptional
> > > period of time, such as processes writing to a frozen filesystem during
> > > a lengthy backup operation, this can result in a deadlock condition as
> > > related processes memory access will stall within the page fault
> > > handler.
> >
> > And there are other potential reasons for deadlock.
> >
> > Stupid idea. Can't we help the memory hog to free its memory? This is
> > orthogonal to other improvements we can do.
>
> So, we are trying to release memory without waiting for arriving at
> exit_mm() from do_exit(), right? If it works, it will be a simple and
> small change that will be easy to backport.
>
> The idea is that since fatal_signal_pending() tasks no longer return to
> user space, we can release memory allocated for use by user space, right?

Yes.

> Then, I think that this approach can be applied to not only OOM-kill case
> but also regular kill(pid, SIGKILL) case (i.e. kick from signal_wake_up(1)
> or somewhere?).

I don't think so... but we might want to do this if (say) we are not going
to kill someone else because fatal_signal_pending(current).

> A dedicated kernel thread (not limited to OOM-kill purpose)
> scans for fatal_signal_pending() tasks and release that task's memory.

Perhaps a dedicated kernel thread makes sense (see other emails),
but I don't think it should scan the killed threads. oom-kill should
kict it.

Anyway, let me repeat there are a lot of details we might want to
discuss. But the initial changes should be simple as possible, imo.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
