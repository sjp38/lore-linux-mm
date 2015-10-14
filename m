Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f181.google.com (mail-yk0-f181.google.com [209.85.160.181])
	by kanga.kvack.org (Postfix) with ESMTP id EF68182F64
	for <linux-mm@kvack.org>; Wed, 14 Oct 2015 12:57:32 -0400 (EDT)
Received: by ykaz22 with SMTP id z22so27525621yka.2
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 09:57:32 -0700 (PDT)
Received: from mail-yk0-x22d.google.com (mail-yk0-x22d.google.com. [2607:f8b0:4002:c07::22d])
        by mx.google.com with ESMTPS id w2si4083299ywe.274.2015.10.14.09.57.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Oct 2015 09:57:31 -0700 (PDT)
Received: by ykoo7 with SMTP id o7so53281556yko.0
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 09:57:31 -0700 (PDT)
Date: Wed, 14 Oct 2015 12:57:29 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [GIT PULL] workqueue fixes for v4.3-rc5
Message-ID: <20151014165729.GA12799@mtj.duckdns.org>
References: <20151013214952.GB23106@mtj.duckdns.org>
 <CA+55aFzV61qsWOObLUPpL-2iU1=8EopEgfse+kRGuUi9kevoOA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzV61qsWOObLUPpL-2iU1=8EopEgfse+kRGuUi9kevoOA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.cz>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>, Shaohua Li <shli@fb.com>, linux-mm <linux-mm@kvack.org>

Hello, Linus.

On Wed, Oct 14, 2015 at 09:30:21AM -0700, Linus Torvalds wrote:
> On Tue, Oct 13, 2015 at 2:49 PM, Tejun Heo <tj@kernel.org> wrote:
> >
> > Single patch to fix delayed work being queued on the wrong CPU.  This
> > has been broken forever (v2.6.31+) but obviously doesn't trigger in
> > most configurations.
> 
> So why is this a bugfix? If cpu == WORK_CPU_UNBOUND, then things
> _shouldn't_ care which cpu it gets run on.

That enum is a bit of misnomer in this case.  It's more like
WORK_CPU_LOCAL.

> I don't think the patch is bad per se, because we obviously have other
> places where we just do that "WORK_CPU_UNBOUND means current cpu", and
> it's documented to "prefer" the current CPU, but at the same time I
> get the very strong feeling that anything that *requires* it to mean
> the current CPU is just buggy crap.
> 
> So the whole "wrong CPU" argument seems bogus. It's not a workqueue
> bug, it's a caller bug.
>
> Because I'd argue that any user that *requires* a particular CPU
> should specify that. This "fix" doesn't seem to be a fix at all.
> 
> So to me, the bug seems to be that vmstat_update() is just bogus, and
> uses percpu data but doesn't speicy that it needs to run on the
> current cpu.

For both delayed and !delayed work items on per-cpu workqueues,
queueing without specifying a specific CPU always meant queueing on
the local CPU.  It just happened to start that way and has never
changed.  It'd be great to make users which want a specific CPU to
always queue with the CPU specified; however, making that change would
need quite a bit of auditing and debug features (like always forcing a
different CPU) given that breakages can be a lot more subtler than
outright crash as in vmstat_update().  I've been thinking about doing
that for quite a while now but haven't had the chance yet.

...
> So I feel that this is *obviously* a vmstat bug, and that working
> around it by adding ah-hoc crap to the workqueues is completely the
> wrong thing to do. So I'm not going to pull this, because it seems to
> be hiding the real problem rather than really "fixing" anything.

I wish this were an ad-hoc thing but this has been the guaranteed
behavior all along.  Switching the specific call-site to
queue_work_on() would still be a good idea tho.

> (That said, it's not obvious to me why we don't just specify the cpu
> in the work structure itself, and just get rid of the "use different
> functions to schedule the work" model. I think it's somewhat fragile
> how you can end up using the same work in different "CPU boundedness"
> models like this).

Hmmm... you mean associating a delayed work item with the target
pool_workqueue on queueing and sharing the queueing paths for both
delayed and !delayed work items?  Yeah, we can do that although it'd
involve somewhat invasive changes to queueing and canceling paths and
making more code paths handle both work_struct and delayed_work.  The
code is the way it is mostly for historical reasons.  I'm not sure the
cleanup (I can't think of scenarios where the observed behaviors would
be different / better) would justify the churn.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
