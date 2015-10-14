Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f173.google.com (mail-io0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id EBC2A6B0255
	for <linux-mm@kvack.org>; Wed, 14 Oct 2015 12:30:22 -0400 (EDT)
Received: by iofl186 with SMTP id l186so61335982iof.2
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 09:30:22 -0700 (PDT)
Received: from mail-io0-x22e.google.com (mail-io0-x22e.google.com. [2607:f8b0:4001:c06::22e])
        by mx.google.com with ESMTPS id b69si7908114iob.208.2015.10.14.09.30.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Oct 2015 09:30:22 -0700 (PDT)
Received: by iofl186 with SMTP id l186so61335616iof.2
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 09:30:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20151013214952.GB23106@mtj.duckdns.org>
References: <20151013214952.GB23106@mtj.duckdns.org>
Date: Wed, 14 Oct 2015 09:30:21 -0700
Message-ID: <CA+55aFzV61qsWOObLUPpL-2iU1=8EopEgfse+kRGuUi9kevoOA@mail.gmail.com>
Subject: Re: [GIT PULL] workqueue fixes for v4.3-rc5
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.cz>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>, Shaohua Li <shli@fb.com>, linux-mm <linux-mm@kvack.org>

On Tue, Oct 13, 2015 at 2:49 PM, Tejun Heo <tj@kernel.org> wrote:
>
> Single patch to fix delayed work being queued on the wrong CPU.  This
> has been broken forever (v2.6.31+) but obviously doesn't trigger in
> most configurations.

So why is this a bugfix? If cpu == WORK_CPU_UNBOUND, then things
_shouldn't_ care which cpu it gets run on.

I don't think the patch is bad per se, because we obviously have other
places where we just do that "WORK_CPU_UNBOUND means current cpu", and
it's documented to "prefer" the current CPU, but at the same time I
get the very strong feeling that anything that *requires* it to mean
the current CPU is just buggy crap.

So the whole "wrong CPU" argument seems bogus. It's not a workqueue
bug, it's a caller bug.

Because I'd argue that any user that *requires* a particular CPU
should specify that. This "fix" doesn't seem to be a fix at all.

So to me, the bug seems to be that vmstat_update() is just bogus, and
uses percpu data but doesn't speicy that it needs to run on the
current cpu.

Look at vmstat_shepherd() that does this *right* and starts the whole thing:

                        schedule_delayed_work_on(cpu,
                                &per_cpu(vmstat_work, cpu), 0);

and then look at vmstat_update() that gets it wrong:

                schedule_delayed_work(this_cpu_ptr(&vmstat_work),
                        round_jiffies_relative(sysctl_stat_interval));

Notice the difference?

So I feel that this is *obviously* a vmstat bug, and that working
around it by adding ah-hoc crap to the workqueues is completely the
wrong thing to do. So I'm not going to pull this, because it seems to
be hiding the real problem rather than really "fixing" anything.

(That said, it's not obvious to me why we don't just specify the cpu
in the work structure itself, and just get rid of the "use different
functions to schedule the work" model. I think it's somewhat fragile
how you can end up using the same work in different "CPU boundedness"
models like this).

Added the mm/vmstat.c suspects to the cc. Particularly Christoph
Lameter - this goes back to commit 7cc36bbddde5 ("vmstat: on-demand
vmstat workers V8").

Comments?

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
