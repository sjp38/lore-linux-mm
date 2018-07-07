Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 539656B0006
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 20:05:42 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id e93-v6so3412885plb.5
        for <linux-mm@kvack.org>; Fri, 06 Jul 2018 17:05:42 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d31-v6sor3134936pla.48.2018.07.06.17.05.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 06 Jul 2018 17:05:41 -0700 (PDT)
Date: Fri, 6 Jul 2018 17:05:39 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v3] mm, oom: fix unnecessary killing of additional
 processes
In-Reply-To: <20180705164621.0a4fe6ab3af27a1d387eecc9@linux-foundation.org>
Message-ID: <alpine.DEB.2.21.1807061652430.71359@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1806211434420.51095@chino.kir.corp.google.com> <20180705164621.0a4fe6ab3af27a1d387eecc9@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, Michal Hocko <mhocko@suse.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 5 Jul 2018, Andrew Morton wrote:

> > +#ifdef CONFIG_DEBUG_FS
> > +static int oom_free_timeout_ms_read(void *data, u64 *val)
> > +{
> > +	*val = oom_free_timeout_ms;
> > +	return 0;
> > +}
> > +
> > +static int oom_free_timeout_ms_write(void *data, u64 val)
> > +{
> > +	if (val > 60 * 1000)
> > +		return -EINVAL;
> > +
> > +	oom_free_timeout_ms = val;
> > +	return 0;
> > +}
> > +DEFINE_SIMPLE_ATTRIBUTE(oom_free_timeout_ms_fops, oom_free_timeout_ms_read,
> > +			oom_free_timeout_ms_write, "%llu\n");
> > +#endif /* CONFIG_DEBUG_FS */
> 
> One of the several things I dislike about debugfs is that nobody
> bothers documenting it anywhere.  But this should really be documented.
> I'm not sure where, but the documentation will find itself alongside a
> bunch of procfs things which prompts the question "why it *this* one in
> debugfs"?
> 

The only reason I have placed it in debugfs, or making it tunable at all, 
is to appease others.  I know the non-default value we need to use to stop 
millions of processes being oom killed unnecessarily.  Michal suggested a 
tunable to disable the oom reaper entirely, which is not what we want, so 
I found this to be the best alternative.

I'd like to say that it is purposefully undocumented since it's not a 
sysctl and nobody can suggest that it is becoming a permanent API that we 
must maintain for backwards compatibility.  Having it be configurable is 
kind of ridiculous, but such is the nature of trying to get patches merged 
these days to prevent millions of processes being oom killed 
unnecessarily.

Blockable mmu notifiers and mlocked memory is not the extent of the 
problem, if a process has a lot of virtual memory we must wait until 
free_pgtables() completes in exit_mmap() to prevent unnecessary oom 
killing.  For implementations such as tcmalloc, which does not release 
virtual memory, this is important because, well, it releases this only at 
exit_mmap().  Of course we cannot do that with only the protection of 
mm->mmap_sem for read.

This is a patch that we'll always need if we continue with the current 
implementation of the oom reaper.  I wouldn't suggest it as a configurable 
value, but, owell.

I'll document the tunable and purposefully repeat myself that this is 
addresses millions of processes being oom killed unnecessarily so the 
rather important motivation of the change is clear to anyone who reads 
this thread now or in the future.  Nobody can guess an appropriate value 
until they have been hit by the issue themselves and need to deal with the 
loss of work from important processes being oom killed when some best 
effort logging cron job uses too much memory.  Or, of course, pissed off 
users who have their jobs killed off and you find yourself in the rather 
unfortunate situation of explaining why the Linux kernel in 2018 needs to 
immediately SIGKILL processes because of an arbitrary nack related to a 
timestamp.

Thanks.
