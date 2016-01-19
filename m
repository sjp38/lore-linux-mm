Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 9D7906B0009
	for <linux-mm@kvack.org>; Tue, 19 Jan 2016 04:35:40 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id l65so130129432wmf.1
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 01:35:40 -0800 (PST)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id 9si31892800wmi.71.2016.01.19.01.35.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jan 2016 01:35:39 -0800 (PST)
Received: by mail-wm0-x244.google.com with SMTP id 123so14740394wmz.2
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 01:35:39 -0800 (PST)
Date: Tue, 19 Jan 2016 10:35:35 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH V2] sched/numa: Fix use-after-free bug in the
 task_numa_compare
Message-ID: <20160119093535.GA2458@gmail.com>
References: <20160118143345.GQ6357@twins.programming.kicks-ass.net>
 <1453130661-16573-1-git-send-email-gavin.guo@canonical.com>
 <20160118171328.GT6357@twins.programming.kicks-ass.net>
 <CA+eFSM1AUYLeGmmBgEzz8PCFMgsmCuztQpOSy3OiT1_3453ozg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+eFSM1AUYLeGmmBgEzz8PCFMgsmCuztQpOSy3OiT1_3453ozg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Guo <gavin.guo@canonical.com>
Cc: Peter Zijlstra <peterz@infradead.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Jay Vosburgh <jay.vosburgh@canonical.com>, Liang Chen <liang.chen@canonical.com>, mgorman@suse.de, mingo@redhat.com, riel@redhat.com


* Gavin Guo <gavin.guo@canonical.com> wrote:

> Hi Peter,
> 
> On Tue, Jan 19, 2016 at 1:13 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> > On Mon, Jan 18, 2016 at 11:24:21PM +0800, gavin.guo@canonical.com wrote:
> >> From: Gavin Guo <gavin.guo@canonical.com>
> >>
> >> The following message can be observed on the Ubuntu v3.13.0-65 with KASan
> >> backported:
> >
> > <snip>
> >
> >> As commit 1effd9f19324 ("sched/numa: Fix unsafe get_task_struct() in
> >> task_numa_assign()") points out, the rcu_read_lock() cannot protect the
> >> task_struct from being freed in the finish_task_switch(). And the bug
> >> happens in the process of calculation of imp which requires the access of
> >> p->numa_faults being freed in the following path:
> >>
> >> do_exit()
> >>         current->flags |= PF_EXITING;
> >>     release_task()
> >>         ~~delayed_put_task_struct()~~
> >>     schedule()
> >>     ...
> >>     ...
> >> rq->curr = next;
> >>     context_switch()
> >>         finish_task_switch()
> >>             put_task_struct()
> >>                 __put_task_struct()
> >>                   task_numa_free()
> >>
> >> The fix here to get_task_struct() early before end of dst_rq->lock to
> >> protect the calculation process and also put_task_struct() in the
> >> corresponding point if finally the dst_rq->curr somehow cannot be
> >> assigned.
> >>
> >> v1->v2:
> >> - Fix coding style suggested by Peter Zijlstra.
> >>
> >> Signed-off-by: Gavin Guo <gavin.guo@canonical.com>
> >> Signed-off-by: Liang Chen <liangchen.linux@gmail.com>
> >
> > Argh, sorry for not noticing before; this SoB chain is not valid.
> >
> > Gavin wrote (per From) and send me the patch (per actual email headers),
> > so Liang never touched it.
> >
> > Should that be a reviewed-by for him?
> 
> Liang is also the co-author of the original patch, we figured out the code
> by parallel programming, part of the idea was came from him. If SoB is
> not valid, can I change the line to the following?
> 
> Co-authored-by: Liang Chen <liangchen.linux@gmail.com>

So unless you guys shared the same keyboard at the same time, there's at least 
line granular authorship, right?

The main author (the guy who wrote the most code and comments) should be the 
'From' author - additional help can be credited in the changelog. If of one you 
wrote an initial version that the other one used, you can use something like:

 Originally-From: ...

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
