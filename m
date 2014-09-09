Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 984746B00AA
	for <linux-mm@kvack.org>; Tue,  9 Sep 2014 16:39:39 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id w10so4809825pde.41
        for <linux-mm@kvack.org>; Tue, 09 Sep 2014 13:39:39 -0700 (PDT)
Received: from mail-pd0-x229.google.com (mail-pd0-x229.google.com [2607:f8b0:400e:c02::229])
        by mx.google.com with ESMTPS id fk1si25122547pab.33.2014.09.09.13.39.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 09 Sep 2014 13:39:38 -0700 (PDT)
Received: by mail-pd0-f169.google.com with SMTP id fp1so4227632pdb.14
        for <linux-mm@kvack.org>; Tue, 09 Sep 2014 13:39:38 -0700 (PDT)
Date: Tue, 9 Sep 2014 13:37:55 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v4 2/2] ksm: provide support to use deferrable timers
 for scanner thread
In-Reply-To: <540F141B.9060603@codeaurora.org>
Message-ID: <alpine.LSU.2.11.1409091315240.8432@eggly.anvils>
References: <1408536628-29379-1-git-send-email-cpandya@codeaurora.org> <1408536628-29379-2-git-send-email-cpandya@codeaurora.org> <alpine.LSU.2.11.1408272258050.10518@eggly.anvils> <20140903095815.GK4783@worktop.ger.corp.intel.com>
 <alpine.LSU.2.11.1409080023100.1610@eggly.anvils> <20140908093949.GZ6758@twins.programming.kicks-ass.net> <540F141B.9060603@codeaurora.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chintan Pandya <cpandya@codeaurora.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Hugh Dickins <hughd@google.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-arm-msm@vger.kernel.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, John Stultz <john.stultz@linaro.org>, Ingo Molnar <mingo@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>

On Tue, 9 Sep 2014, Chintan Pandya wrote:
> Hello All,
> 
> Before its too late to discuss this basic question, allow me to share my view
> on the deferrable timer approach.
> 
> I believe KSM at this point is tunable with predictable outcomes. When it
> will get triggered, how many pages it will scan etc. This aggression control
> is with user who can implement any complex logic based on its own flashy
> parameters. Along the same line, I was seeing this deferrable timer knob.
> 
> Here I was hoping the same level of predictability with this knob. Kernel
> still won't do smart work and user is free to play smart/complex with the
> knob. I believe that there are many use-cases where a single strategy of "to
> make KSM perform better while saving power at the same time" may not work.
> So,

Understood.  Whereas seasoned developers grow increasingly sick and
sceptical of such knobs, preferring to make an effort to get things
working well without them.  Both attitudes are valid.

> 
> > On Mon, Sep 08, 2014 at 01:25:36AM -0700, Hugh Dickins wrote:
> > > Well, yes, but... how do we know when there is no more work to do?
> > 
> > Yeah, I figured that out _after_ I send that email..
> > 
> > > Thomas has given reason why KSM might simply fail to do its job if we
> > > rely on the deferrable timer.
> 
> With deferrable timer, KSM thread will be scheduled on the 'active' CPU at
> that very same time. Yes, I understood from Thomas's clarification that if
> that very CPU goes IDLE, KSM task will get deferred even if at the timeout,
> we have some CPUs running. I think, this situation can be avoided potentially
> very small timeout value (?). But in totality, this is where KSM will be idle
> for sure, may be that is unwanted.

I don't get how a very small timeout value would solve that.  But I am
all for a KSM which works well even with timeout value 0: responsive,
but not power hungry.

> 
> > > 
> > > Chintan, even if the scheduler guys turn out to hate it, please would
> > > you give the patch below a try, to see how well it works in your
> > > environment, whether it seems to go better or worse than your own patch.
> > > 
> > > If it works well enough for you, maybe we can come up with ideas to
> > > make it more palatable.  I do think your issue is an important one
> > > to fix, one way or another.
> 
> It is taking a little more time for me to grasp your change :)

Grasping the intent should be easy: I thought that was in the title,
"ksm: avoid periodic wakeup while mergeable mms are quiet": just go
to sleep until at least one of the MMF_VM_MERGEABLE tasks gets run.

Checking the details, whether I'm accomplishing that intent, yes,
that needs more understanding of ksm.c, which your deferrable timer
approach did not need to get involved with at all (to its credit).

> So, after Peter's comment, do you want me to try this out

Certainly yes, please do.  I'm not saying that's a patch which will
ever go into the kernel itself, but we do want to know whether it does
the job for you or not, whether it's a worthwhile attempt in the right
direction.  Does it save as much as your patch?  Does it save more?

> or you are looking forward for even better idea ?

I'd love a better idea: assuming mine works, is there some other way
of accomplishing it, which does not pollute sched/core.c, but does
not drag in mm_struct cachelines for a frequent flags check?

> BTW, if deferrable timer patch gets any green signal,
> I will publish new patch with your comments on v4.

It seems to be a red light at present: but lights do change ;)

> 
> > > 
> > > Thanks,
> > > Hugh
> > > 
> > > [PATCH] ksm: avoid periodic wakeup while mergeable mms are quiet
> > > 
> > > Description yet to be written!
> > > 
> > > Reported-by: Chintan Pandya<cpandya@codeaurora.org>
> > > Not-Signed-off-by: Hugh Dickins<hughd@google.com>
> 
> 
> >>> So looking at Hughs test results I'm quite sure that the deferrable
> >>> timer is just another tunable bandaid with dubious value and the
> >>> potential of predictable bug/regresssion reports.
> 
> Here I am naive in understanding the obvious disadvantages of 'one more
> knob'. And hence was inclined towards deferrable timer knob. Thomas, could
> you explain what kind of bug/regression you foresee with such approach ?
> 
> -- 
> Chintan Pandya
> 
> QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
> member of the Code Aurora Forum, hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
