Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f178.google.com (mail-qc0-f178.google.com [209.85.216.178])
	by kanga.kvack.org (Postfix) with ESMTP id BDDFD6B00AB
	for <linux-mm@kvack.org>; Tue, 27 May 2014 12:16:16 -0400 (EDT)
Received: by mail-qc0-f178.google.com with SMTP id l6so14445253qcy.9
        for <linux-mm@kvack.org>; Tue, 27 May 2014 09:16:16 -0700 (PDT)
Received: from mailrelay.anl.gov (mailrelay.anl.gov. [130.202.101.22])
        by mx.google.com with ESMTPS id r64si17612130qga.37.2014.05.27.09.16.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 27 May 2014 09:16:15 -0700 (PDT)
Received: from mailgateway.anl.gov (mailgateway.anl.gov [130.202.101.28])
	(using TLSv1 with cipher RC4-SHA (128/128 bits))
	(No client certificate requested)
	by mailrelay.anl.gov (Postfix) with ESMTP id CD6D57CC1E7
	for <linux-mm@kvack.org>; Tue, 27 May 2014 11:16:13 -0500 (CDT)
Date: Tue, 27 May 2014 11:16:13 -0500
From: Kamil Iskra <iskra@mcs.anl.gov>
Subject: Re: [PATCH 1/2] memory-failure: Send right signal code to correct
 thread
Message-ID: <20140527161613.GC4108@mcs.anl.gov>
References: <cover.1400607328.git.tony.luck@intel.com>
 <eb791998a8ada97b204dddf2719a359149e9ae31.1400607328.git.tony.luck@intel.com>
 <20140523033438.GC16945@gchen.bj.intel.com>
 <CA+8MBb+Una+Z5Q-Pn0OoMYaaSx9sPJ3fdriMRMgN=CE1Jdp7Cg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <CA+8MBb+Una+Z5Q-Pn0OoMYaaSx9sPJ3fdriMRMgN=CE1Jdp7Cg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@gmail.com>
Cc: Tony Luck <tony.luck@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Borislav Petkov <bp@suse.de>, Chen Gong <gong.chen@linux.jf.intel.com>

On Fri, May 23, 2014 at 09:48:42 -0700, Tony Luck wrote:

Tony,

> Added Kamil (hope I got the right one - the spinics.net archive obfuscates
> the e-mail addresses).

Yes, you got the right address :-).

> >> -     if ((flags & MF_ACTION_REQUIRED) && t == current) {
> >> +     if ((flags & MF_ACTION_REQUIRED) && t->mm == current->mm) {
> >>               si.si_code = BUS_MCEERR_AR;
> >> -             ret = force_sig_info(SIGBUS, &si, t);
> >> +             ret = force_sig_info(SIGBUS, &si, current);
> >>       } else {
> >>               /*
> >>                * Don't use force here, it's convenient if the signal
> >> --
> >> 1.8.4.1
> > Very interesting. I remembered there was a thread about AO error. Here is
> > the link: http://www.spinics.net/lists/linux-mm/msg66653.html.
> > According to this link, I have two concerns:
> >
> > 1) how to handle the similar scenario like it in this link. I mean once
> > the main thread doesn't handle AR error but a thread does this, if SIGBUS
> > can't be handled at once.
> > 2) why that patch isn't merged. From that thread, Naoya should mean
> > "acknowledge" :-).
> That's an interesting thread ... and looks like it helps out in a case
> where there are only AO signals.

Unfortunately, I got distracted by other pressing work at the time and
didn't follow up on my patch/didn't follow the correct kernel workflow on
patch submission procedures.  I haven't checked any developments in that
area so I don't even know if my patch is still applicable -- do you think
it makes sense for me to revisit the issue at this time, or will the patch
that you are working on make my old patch redundant?

> But the "AR" case complicates things. Kamil points out at the start
> of the thread:
> > Also, do I understand it correctly that "action required" faults *must* be
> > handled by the thread that triggered the error?  I guess it makes sense for
> > it to be that way, even if it circumvents the "dedicated handling thread"
> > idea...
> this is absolutely true ... in the BUS_MCEERR_AR case the current
> thread is executing an instruction that is attempting to consume poison
> data ... and we cannot let that instruction retire, so we have to signal that
> thread - if it can fix the problem by mapping a new page to the location
> that was lost, and refilling it with the right data - the handler can return
> to resume - otherwise it can longjmp() somewhere or exit.

Exactly.

> This means that the idea of having a multi-threaded application where
> just one thread has a SIGBUS handler and we gently steer the
> BUS_MCEERR_AO signals to that thread to be handled is flawed.
> Every thread needs to have a SIGBUS handler - so that we can handle
> the "AR" case. [Digression: what does happen to a process with a thread
> with no SIGBUS handler if we in fact send it a SIGBUS? Does just that
> thread die (default action for SIGBUS)? Or does the whole process get
> killed?  If just one thread is terminated ... then perhaps someone could
> write a recovery aware application that worked like this - though it sounds
> like that would be working blindfold with one hand tied behind your back.
> How would the remaining threads know why their buddy just died? The
> siginfo_t describing the problem isn't available]

I believe I experimented with this and the whole process would get killed.

> If we want steerable AO signals to a dedicated thread - we'd have to
> use different signals for AO & AR. So every thread can have an AR
> handler, but just one have the AO handler.  Or something more exotic
> with prctl to designate the preferred target for AO signals?
> 
> Or just live with the fact that every thread needs a handler for AR ...
> and have the application internally pass AO activity from the
> thread that originally got the SIGBUS to some worker thread.

Yes, you make a very valid point that my patch was not complete... but
then, neither was what was there before it.  So my patch was only an
incremental improvement, enough to play with when artificially injecting
fault events, but not enough to *really* solve the problem.  If you have a
complete solution in mind instead, that would be great.

Kamil

-- 
Kamil Iskra, PhD
Argonne National Laboratory, Mathematics and Computer Science Division
9700 South Cass Avenue, Building 240, Argonne, IL 60439, USA
phone: +1-630-252-7197  fax: +1-630-252-5986

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
