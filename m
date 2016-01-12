Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
	by kanga.kvack.org (Postfix) with ESMTP id 07D624403D9
	for <linux-mm@kvack.org>; Tue, 12 Jan 2016 07:16:47 -0500 (EST)
Received: by mail-lb0-f169.google.com with SMTP id bc4so270479167lbc.2
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 04:16:46 -0800 (PST)
Received: from v094114.home.net.pl (v094114.home.net.pl. [79.96.170.134])
        by mx.google.com with SMTP id pl9si15965520lbb.30.2016.01.12.04.16.38
        for <linux-mm@kvack.org>;
        Tue, 12 Jan 2016 04:16:39 -0800 (PST)
From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Subject: Re: What is oom_killer_disable() for?
Date: Tue, 12 Jan 2016 13:17:12 +0100
Message-ID: <3233132.pKCmWfMDDM@vostro.rjw.lan>
In-Reply-To: <20160111144924.GF27317@dhcp22.suse.cz>
References: <1452337485-8273-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp> <201601100202.DHE57897.OVLJOMHFOtFFSQ@I-love.SAKURA.ne.jp> <20160111144924.GF27317@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: hannes@cmpxchg.org, rientjes@google.com, linux-mm@kvack.org, Linux PM list <linux-pm@vger.kernel.org>

On Monday, January 11, 2016 03:49:24 PM Michal Hocko wrote:
> [CCing Rafael]
> 
> On Sun 10-01-16 02:02:32, Tetsuo Handa wrote:
> > I wonder what oom_killer_disable() wants to do.
> > 
> > (1) We need to save a consistent memory snapshot image when suspending,
> >     is this correct?
> 
> Yes
> 
> > (2) To obtain a consistent memory snapshot image, we need to freeze all
> >     but current thread in order to avoid modifying on-memory data while
> >     saving to disk, is this correct?
> 
> Yes, the system has to enter a quiescent state where no further user
> space activity can interfere with the PM suspend.

The system has to be quiescent during the image creation only.

After the image has been created, it may do whatever it likes so long as
the contents of persistent storage is consistent with the information
related to it included in the image.

> > (3) Then, what is the purpose of disabling the OOM killer? Why do we
> >     need to disable the OOM killer? Is it because the OOM killer thaws
> >     already frozen threads?
> 
> Yes. We have to be able to thaw frozen tasks if they are chosen as an
> OOM victim otherwise you could hide processes into the fridge and lockup
> the system. oom_killer_disable is then needed for pm freezer because the
> OOM killer might be invoked even after all the userspace is considered
> in the quiescent state. We cannot wake any task anymore during the later
> pm freezer processing AFAIU. oom_killer_disable then acts as a hard
> barrier after which we know that even OOM killer won't wake any user
> space tasks.

So the reason(s) why user space tasks are frozen is not specific to hibernation.

The main reason is to take user space out of the way so that device drivers
don't need to worry about possible interactions with user space while the
devices are being suspended and resumed.  IOW, this allows user space to
see a consistent state of the system before and after suspend/resume without
being exposed to itermediate, possibly inconsistent, states.

> > (4) Then, why do we wait for TIF_MEMDIE threads to terminate? We can
> >     freeze thawed threads again without waiting for TIF_MEMDIE threads,
> >     can't we? Is it because we need free memory for saving to disk?
> 
> It is preferable to finish the OOM killer handling before entering the
> quiescent state. As only TIF_MEMDIE tasks are thawed we do not wait for
> all killed task. If this alone doesn't help to resolve the OOM condition
> then we will likely fail later in the process when a memory allocation
> is required and ENOMEM terminate the whole process.
> 
> > (5) Then, why waiting for only TIF_MEMDIE threads is sufficient? There
> >     is no TIF_MEMDIE threads does not guarantee that we have free memory,
> >     for there might be !TIF_MEMDIE threads which are still sharing memory
> >     used by TIF_MEMDIE threads.
> 
> see above. We are trying to be as good as possible but not perfect. The
> only hard requirement is that an unexpected OOM victim won't interfere
> with a code which doesn't expect userspace to run.

Right.

In particular, it must not result in an access to a suspended device.

> > (6) Since oom_killer_disable() already disabled the OOM killer,
> >     !TIF_MEMDIE threads which are sharing memory used by TIF_MEMDIE
> >     threads cannot get TIF_MEMDIE by calling out_of_memory().
> 
> They shouldn't be running at all because the whole userspace has been
> frozen. Only TIF_MEMDIE tasks are running at the time we are disabling
> the oom killer and we are waiting for them. Please go and read through
> c32b3cbe0d06 ("oom, PM: make OOM detection in the freezer path raceless")
> 
> >     Also, since out_of_memory() returns false after oom_killer_disable()
> >     disabled the OOM killer, allocation requests by these !TIF_MEMDIE
> >     threads start failing. Why do we need to give up with accepting
> >     undesirable errors (e.g. failure of syscalls which modify an object's
> >     attribute)?
> 
> Userspace shouldn't see unexpected errors due to OOM being disabled
> because it is not runable at that time.
> 
> >     Why don't we abort suspend operation by marking that
> >     re-enabling of the OOM killer might caused modification of on-memory
> >     data (like patch shown below)? We can make final decision after memory
> >     image snapshot is saved to disk, can't we?
> 
> I am not sure I am following you here but how do you detect that the
> userspace has corrupted your image or accesses an already (half)
> suspended device or something similar?

Right.

As I said above, the (main) reason for user space freezing is not specific
to hibernation and it is only indirectly related to the creation of the memory
snapshot.

> I am not saying disabling the OOM killer is the greatest solution. It
> took quite some time to make it work reliably. But I fail to see how can
> we guarantee no userspace interference when an OOM victim might be woken
> by any allocation deep inside the PM code path. I believe we simply
> need a point of no userspace activity to proceed with further PM steps
> reasonably.

Agreed.

Thanks,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
