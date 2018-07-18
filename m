Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id 35A1F6B000C
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 18:00:26 -0400 (EDT)
Received: by mail-yb0-f197.google.com with SMTP id p4-v6so3215766ybk.6
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 15:00:26 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e131-v6sor1329782ybh.13.2018.07.18.15.00.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Jul 2018 15:00:24 -0700 (PDT)
Date: Wed, 18 Jul 2018 18:03:10 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 08/10] psi: pressure stall information for CPU, memory,
 and IO
Message-ID: <20180718220310.GD2838@cmpxchg.org>
References: <20180712172942.10094-1-hannes@cmpxchg.org>
 <20180712172942.10094-9-hannes@cmpxchg.org>
 <20180717142157.GF2494@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180717142157.GF2494@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, Jul 17, 2018 at 04:21:57PM +0200, Peter Zijlstra wrote:
> On Thu, Jul 12, 2018 at 01:29:40PM -0400, Johannes Weiner wrote:
> > diff --git a/include/linux/sched/stat.h b/include/linux/sched/stat.h
> > index 04f1321d14c4..ac39435d1521 100644
> > --- a/include/linux/sched/stat.h
> > +++ b/include/linux/sched/stat.h
> > @@ -28,10 +28,14 @@ static inline int sched_info_on(void)
> >  	return 1;
> >  #elif defined(CONFIG_TASK_DELAY_ACCT)
> >  	extern int delayacct_on;
> > +	if (delayacct_on)
> > +		return 1;
> > +#elif defined(CONFIG_PSI)
> > +	extern int psi_disabled;
> > +	if (!psi_disabled)
> > +		return 1;
> >  #endif
> > +	return 0;
> >  }
> 
> Doesn't that want to be something like:
> 
> static inline bool sched_info_on(void)
> {
> #ifdef CONFIG_SCHEDSTAT
> 	return true;
> #else /* !SCHEDSTAT */
> #ifdef CONFIG_TASK_DELAY_ACCT
> 	extern int delayacct_on;
> 	if (delayacct_on)
> 		return true;
> #endif /* DELAYACCT */
> #ifdef CONFIG_PSI
> 	extern int psi_disabled;
> 	if (!psi_disabled)
> 		return true;
> #endif
> 	return false;
> #endif /* !SCHEDSTATE */
> }
> 
> Such that if you build a TASK_DELAY_ACCT && PSI kernel, and boot with
> nodelayacct, you still get sched_info_on().

You're right, that was a brainfart on my end. But as you point out in
the other email, the SCHED_INFO dependency is artificial, so I'll
rework this entire part.
