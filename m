Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id DCBE96B0035
	for <linux-mm@kvack.org>; Wed, 28 May 2014 21:46:08 -0400 (EDT)
Received: by mail-qg0-f47.google.com with SMTP id j107so20210125qga.6
        for <linux-mm@kvack.org>; Wed, 28 May 2014 18:46:08 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id a1si24845467qab.72.2014.05.28.18.46.07
        for <linux-mm@kvack.org>;
        Wed, 28 May 2014 18:46:08 -0700 (PDT)
Message-ID: <53869160.8113e00a.60af.5c69SMTPIN_ADDED_BROKEN@mx.google.com>
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm/memory-failure.c: support dedicated thread to handle SIGBUS(BUS_MCEERR_AO) thread
Date: Wed, 28 May 2014 21:45:41 -0400
In-Reply-To: <CA+8MBbKdKy+sbov-f+1xNnj=syEM5FWR1BV85AgRJ9S+qPbWEg@mail.gmail.com>
References: <eb791998a8ada97b204dddf2719a359149e9ae31.1400607328.git.tony.luck@intel.com> <20140523033438.GC16945@gchen.bj.intel.com> <CA+8MBb+Una+Z5Q-Pn0OoMYaaSx9sPJ3fdriMRMgN=CE1Jdp7Cg@mail.gmail.com> <20140527161613.GC4108@mcs.anl.gov> <5384d07e.4504e00a.2680.ffff8c31SMTPIN_ADDED_BROKEN@mx.google.com> <CA+8MBbKuBo4c2v-Y0TOk-LUJuyJsGG=twqQyAPG5WOa8Aj4GyA@mail.gmail.com> <53852abb.867ce00a.3cef.3c7eSMTPIN_ADDED_BROKEN@mx.google.com> <FDBACF11-D9F6-4DE5-A0D4-800903A243B7@gmail.com> <53862f6c.91148c0a.5fb0.2d0cSMTPIN_ADDED_BROKEN@mx.google.com> <CA+8MBbKdKy+sbov-f+1xNnj=syEM5FWR1BV85AgRJ9S+qPbWEg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tony.luck@gmail.com
Cc: iskra@mcs.anl.gov, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Borislav Petkov <bp@suse.de>, gong.chen@linux.jf.intel.com

On Wed, May 28, 2014 at 03:00:11PM -0700, Tony Luck wrote:
> On Wed, May 28, 2014 at 11:47 AM, Naoya Horiguchi
> <n-horiguchi@ah.jp.nec.com> wrote:
> > Could you take a look?
> 
> It looks good - and should be a workable API for
> application writers to use.
> 
> > @@ -84,6 +84,11 @@ PR_MCE_KILL
> >                 PR_MCE_KILL_EARLY: Early kill
> >                 PR_MCE_KILL_LATE:  Late kill
> >                 PR_MCE_KILL_DEFAULT: Use system global default
> > +       Note that if you want to have a dedicated thread which handles
> > +       the SIGBUS(BUS_MCEERR_AO) on behalf of the process, you should
> > +       call prctl() on the thread. Otherwise, the SIGBUS is sent to
> > +       the main thread.
> 
> Perhaps be more explicit here that the user should call
> prctl(PR_MCE_KILL_EARLY) on the designated thread
> to get this behavior?

OK.

>  The user could also mark more than
> one thread in this way - in which case the kernel will pick
> the first one it sees (is that oldest, or newest?) that is marked.
> Not sure if this would ever be useful unless you want to pass
> responsibility around in an application that is dynamically
> creating and removing threads.

I'm not sure which is better to send signal to first-found marked thread
or to all marked threads. If we have a good reason to do the latter,
I'm ok about it. Any idea?

> 
> > +               if (t->flags & PF_MCE_PROCESS && t->flags & PF_MCE_EARLY)
> 
> This is correct - but made me twitch to add extra brackets:
> 
>                   if ((t->flags & PF_MCE_PROCESS) && (t->flags & PF_MCE_EARLY))

OK, I'll take this.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
