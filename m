Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 1699A6B0085
	for <linux-mm@kvack.org>; Mon, 17 Mar 2014 05:53:21 -0400 (EDT)
Received: by mail-wg0-f44.google.com with SMTP id m15so4277899wgh.15
        for <linux-mm@kvack.org>; Mon, 17 Mar 2014 02:53:21 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u1si2480559wje.153.2014.03.17.02.53.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 17 Mar 2014 02:53:20 -0700 (PDT)
Date: Mon, 17 Mar 2014 10:53:17 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] backing_dev: Fix hung task on sync
Message-ID: <20140317095317.GD2210@quack.suse.cz>
References: <1392437537-27392-1-git-send-email-dbasehore@chromium.org>
 <20140218225548.GI31892@mtj.dyndns.org>
 <20140219092731.GA4849@quack.suse.cz>
 <20140219190139.GQ10134@htj.dyndns.org>
 <CAGAzgspTZnUh_qi=FeQ4hS4LRiexPccTyALMg3Gt1K0ZZq_MuQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGAzgspTZnUh_qi=FeQ4hS4LRiexPccTyALMg3Gt1K0ZZq_MuQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "dbasehore ." <dbasehore@chromium.org>
Cc: Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, Alexander Viro <viro@zento.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, Kees Cook <keescook@chromium.org>, linux-fsdevel@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, bleung@chromium.org, sonnyrao@chromium.org, Luigi Semenzato <semenzato@chromium.org>

On Sat 15-03-14 13:22:53, dbasehore . wrote:
> Resurrecting this for further discussion about the root of the problem.
> 
> mod_delayed_work_if_later addresses the problem one way, but the
> problem is still there for mod_delayed_work.
  But flusher works care about only that one way, don't they? We always
want the flushing work to execute at min(timer so far, new time target). So
for that mod_delayed_work_if_later() works just fine.

> I think we could take
> another approach that doesn't modify the API, but still addresses
> (most of) the problem.
> 
> mod_delayed_work currently removes a work item from a workqueue if it
> is on it. Correct me if I'm wrong, but I don't think that this is
> necessarily required for mod_delayed_work to have the current
> behavior. We should be able to set the timer while a delayed_work is
> currently on a workqueue. If the delayed_work is still on the
> workqueue when the timer goes off, everything is fine. If it has left
> the workqueue, we can queue it again.
  But here you are relying on the fact that flusher works always want the
work to be executed immediately (i.e., they will be queued), or after some
fixed time T. So I agree what you suggest will work but changing the API as
Tejun described seems cleaner to me.

								Honza

> On Wed, Feb 19, 2014 at 11:01 AM, Tejun Heo <tj@kernel.org> wrote:
> > Hello, Jan.
> >
> > On Wed, Feb 19, 2014 at 10:27:31AM +0100, Jan Kara wrote:
> >>   You are the workqueue expert so you may know better ;) But the way I
> >> understand it is that queue_delayed_work() does nothing if the timer is
> >> already running. Since we queue flusher work to run either immediately or
> >> after dirty_writeback_interval we are safe to run queue_delayed_work()
> >> whenever we want it to run after dirty_writeback_interval and
> >> mod_delayed_work() whenever we want to run it immediately.
> >
> > Ah, okay, so it's always mod on immediate and queue on delayed.  Yeah,
> > that should work.
> >
> >> But it's subtle and some interface where we could say queue delayed work
> >> after no later than X would be easier to grasp.
> >
> > Yeah, I think it'd be better if we had something like
> > mod_delayed_work_if_later().  Hmm...
> >
> > Thanks.
> >
> > --
> > tejun
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
