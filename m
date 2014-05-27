Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id AAAB36B0036
	for <linux-mm@kvack.org>; Tue, 27 May 2014 13:50:56 -0400 (EDT)
Received: by mail-qg0-f43.google.com with SMTP id 63so14485084qgz.16
        for <linux-mm@kvack.org>; Tue, 27 May 2014 10:50:56 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id t52si18042629qge.7.2014.05.27.10.50.55
        for <linux-mm@kvack.org>;
        Tue, 27 May 2014 10:50:56 -0700 (PDT)
Message-ID: <5384d080.37658c0a.2455.3ff0SMTPIN_ADDED_BROKEN@mx.google.com>
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 1/2] memory-failure: Send right signal code to correct thread
Date: Tue, 27 May 2014 13:50:27 -0400
In-Reply-To: <20140527161613.GC4108@mcs.anl.gov>
References: <cover.1400607328.git.tony.luck@intel.com> <eb791998a8ada97b204dddf2719a359149e9ae31.1400607328.git.tony.luck@intel.com> <20140523033438.GC16945@gchen.bj.intel.com> <CA+8MBb+Una+Z5Q-Pn0OoMYaaSx9sPJ3fdriMRMgN=CE1Jdp7Cg@mail.gmail.com> <20140527161613.GC4108@mcs.anl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: iskra@mcs.anl.gov
Cc: tony.luck@gmail.com, Tony Luck <tony.luck@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Borislav Petkov <bp@suse.de>, gong.chen@linux.jf.intel.com

On Tue, May 27, 2014 at 11:16:13AM -0500, Kamil Iskra wrote:
> On Fri, May 23, 2014 at 09:48:42 -0700, Tony Luck wrote:
> 
> Tony,
> 
> > Added Kamil (hope I got the right one - the spinics.net archive obfuscates
> > the e-mail addresses).
> 
> Yes, you got the right address :-).
> 
> > >> -     if ((flags & MF_ACTION_REQUIRED) && t == current) {
> > >> +     if ((flags & MF_ACTION_REQUIRED) && t->mm == current->mm) {
> > >>               si.si_code = BUS_MCEERR_AR;
> > >> -             ret = force_sig_info(SIGBUS, &si, t);
> > >> +             ret = force_sig_info(SIGBUS, &si, current);
> > >>       } else {
> > >>               /*
> > >>                * Don't use force here, it's convenient if the signal
> > >> --
> > >> 1.8.4.1
> > > Very interesting. I remembered there was a thread about AO error. Here is
> > > the link: http://www.spinics.net/lists/linux-mm/msg66653.html.
> > > According to this link, I have two concerns:
> > >
> > > 1) how to handle the similar scenario like it in this link. I mean once
> > > the main thread doesn't handle AR error but a thread does this, if SIGBUS
> > > can't be handled at once.
> > > 2) why that patch isn't merged. From that thread, Naoya should mean
> > > "acknowledge" :-).
> > That's an interesting thread ... and looks like it helps out in a case
> > where there are only AO signals.
> 
> Unfortunately, I got distracted by other pressing work at the time and
> didn't follow up on my patch/didn't follow the correct kernel workflow on
> patch submission procedures.  I haven't checked any developments in that
> area so I don't even know if my patch is still applicable -- do you think
> it makes sense for me to revisit the issue at this time, or will the patch
> that you are working on make my old patch redundant?
> 
> > But the "AR" case complicates things. Kamil points out at the start
> > of the thread:
> > > Also, do I understand it correctly that "action required" faults *must* be
> > > handled by the thread that triggered the error?  I guess it makes sense for
> > > it to be that way, even if it circumvents the "dedicated handling thread"
> > > idea...
> > this is absolutely true ... in the BUS_MCEERR_AR case the current
> > thread is executing an instruction that is attempting to consume poison
> > data ... and we cannot let that instruction retire, so we have to signal that
> > thread - if it can fix the problem by mapping a new page to the location
> > that was lost, and refilling it with the right data - the handler can return
> > to resume - otherwise it can longjmp() somewhere or exit.
> 
> Exactly.
> 
> > This means that the idea of having a multi-threaded application where
> > just one thread has a SIGBUS handler and we gently steer the
> > BUS_MCEERR_AO signals to that thread to be handled is flawed.
> > Every thread needs to have a SIGBUS handler - so that we can handle
> > the "AR" case. [Digression: what does happen to a process with a thread
> > with no SIGBUS handler if we in fact send it a SIGBUS? Does just that
> > thread die (default action for SIGBUS)? Or does the whole process get
> > killed?  If just one thread is terminated ... then perhaps someone could
> > write a recovery aware application that worked like this - though it sounds
> > like that would be working blindfold with one hand tied behind your back.
> > How would the remaining threads know why their buddy just died? The
> > siginfo_t describing the problem isn't available]
> 
> I believe I experimented with this and the whole process would get killed.
> 
> > If we want steerable AO signals to a dedicated thread - we'd have to
> > use different signals for AO & AR.

I think that user process can distinguish which signal it got via
(struct sigaction)->si_code, so we don't need different signals.
If it's right, the followings solves Kamil's problem?
 - apply Kamil's patch
 - make sure that every thread in a recovery aware application should have
   a SIGBUS handler, inside which
   * code for SIGBUS(BUS_MCEERR_AR) is enabled for every thread
   * code for SIGBUS(BUS_MCEERR_AO) is enabled only for a dedicated thread

One concern is that with Kamil's patch, some existing user who expects
that only the main thread of "early kill" process receives SIGBUS(BUS_MCEERR_AO)
could be surprised by this change, because other threads become to get SIGBUS
and if those threads are not prepared for it, they're just killed (IOW, behavior
of these threads could change.)
Good example is qemu, is it safe from Kamil's change?

Thanks,
Naoya Horiguchi

> So every thread can have an AR
> > handler, but just one have the AO handler.  Or something more exotic
> > with prctl to designate the preferred target for AO signals?
> > 
> > Or just live with the fact that every thread needs a handler for AR ...
> > and have the application internally pass AO activity from the
> > thread that originally got the SIGBUS to some worker thread.
> 
> Yes, you make a very valid point that my patch was not complete... but
> then, neither was what was there before it.  So my patch was only an
> incremental improvement, enough to play with when artificially injecting
> fault events, but not enough to *really* solve the problem.  If you have a
> complete solution in mind instead, that would be great.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
