Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f176.google.com (mail-vc0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id 2BA286B0036
	for <linux-mm@kvack.org>; Fri, 23 May 2014 12:48:43 -0400 (EDT)
Received: by mail-vc0-f176.google.com with SMTP id id10so3138647vcb.7
        for <linux-mm@kvack.org>; Fri, 23 May 2014 09:48:42 -0700 (PDT)
Received: from mail-ve0-x22e.google.com (mail-ve0-x22e.google.com [2607:f8b0:400c:c01::22e])
        by mx.google.com with ESMTPS id 6si1975810vdo.17.2014.05.23.09.48.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 23 May 2014 09:48:42 -0700 (PDT)
Received: by mail-ve0-f174.google.com with SMTP id jw12so6627648veb.33
        for <linux-mm@kvack.org>; Fri, 23 May 2014 09:48:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140523033438.GC16945@gchen.bj.intel.com>
References: <cover.1400607328.git.tony.luck@intel.com>
	<eb791998a8ada97b204dddf2719a359149e9ae31.1400607328.git.tony.luck@intel.com>
	<20140523033438.GC16945@gchen.bj.intel.com>
Date: Fri, 23 May 2014 09:48:42 -0700
Message-ID: <CA+8MBb+Una+Z5Q-Pn0OoMYaaSx9sPJ3fdriMRMgN=CE1Jdp7Cg@mail.gmail.com>
Subject: Re: [PATCH 1/2] memory-failure: Send right signal code to correct thread
From: Tony Luck <tony.luck@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Borislav Petkov <bp@suse.de>, Chen Gong <gong.chen@linux.jf.intel.com>, iskra@mcs.anl.gov

Added Kamil (hope I got the right one - the spinics.net archive obfuscates
the e-mail addresses).

>> -     if ((flags & MF_ACTION_REQUIRED) && t == current) {
>> +     if ((flags & MF_ACTION_REQUIRED) && t->mm == current->mm) {
>>               si.si_code = BUS_MCEERR_AR;
>> -             ret = force_sig_info(SIGBUS, &si, t);
>> +             ret = force_sig_info(SIGBUS, &si, current);
>>       } else {
>>               /*
>>                * Don't use force here, it's convenient if the signal
>> --
>> 1.8.4.1
> Very interesting. I remembered there was a thread about AO error. Here is
> the link: http://www.spinics.net/lists/linux-mm/msg66653.html.
> According to this link, I have two concerns:
>
> 1) how to handle the similar scenario like it in this link. I mean once
> the main thread doesn't handle AR error but a thread does this, if SIGBUS
> can't be handled at once.
> 2) why that patch isn't merged. From that thread, Naoya should mean
> "acknowledge" :-).

That's an interesting thread ... and looks like it helps out in a case
where there are only AO signals.

But the "AR" case complicates things. Kamil points out at the start
of the thread:
> Also, do I understand it correctly that "action required" faults *must* be
> handled by the thread that triggered the error?  I guess it makes sense for
> it to be that way, even if it circumvents the "dedicated handling thread"
> idea...
this is absolutely true ... in the BUS_MCEERR_AR case the current
thread is executing an instruction that is attempting to consume poison
data ... and we cannot let that instruction retire, so we have to signal that
thread - if it can fix the problem by mapping a new page to the location
that was lost, and refilling it with the right data - the handler can return
to resume - otherwise it can longjmp() somewhere or exit.

This means that the idea of having a multi-threaded application where
just one thread has a SIGBUS handler and we gently steer the
BUS_MCEERR_AO signals to that thread to be handled is flawed.
Every thread needs to have a SIGBUS handler - so that we can handle
the "AR" case. [Digression: what does happen to a process with a thread
with no SIGBUS handler if we in fact send it a SIGBUS? Does just that
thread die (default action for SIGBUS)? Or does the whole process get
killed?  If just one thread is terminated ... then perhaps someone could
write a recovery aware application that worked like this - though it sounds
like that would be working blindfold with one hand tied behind your back.
How would the remaining threads know why their buddy just died? The
siginfo_t describing the problem isn't available]

If we want steerable AO signals to a dedicated thread - we'd have to
use different signals for AO & AR. So every thread can have an AR
handler, but just one have the AO handler.  Or something more exotic
with prctl to designate the preferred target for AO signals?

Or just live with the fact that every thread needs a handler for AR ...
and have the application internally pass AO activity from the
thread that originally got the SIGBUS to some worker thread.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
