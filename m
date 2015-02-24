Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 1F8ED6B0032
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 15:23:58 -0500 (EST)
Received: by mail-ig0-f170.google.com with SMTP id l13so31345265iga.1
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 12:23:57 -0800 (PST)
Received: from mail-ig0-x235.google.com (mail-ig0-x235.google.com. [2607:f8b0:4001:c05::235])
        by mx.google.com with ESMTPS id k140si12823226iok.7.2015.02.24.12.23.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Feb 2015 12:23:57 -0800 (PST)
Received: by mail-ig0-f181.google.com with SMTP id hn18so234769igb.2
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 12:23:57 -0800 (PST)
Date: Tue, 24 Feb 2015 12:23:55 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm, oom: do not fail __GFP_NOFAIL allocation if oom
 killer is disbaled
In-Reply-To: <20150224191127.GA14718@phnom.home.cmpxchg.org>
Message-ID: <alpine.DEB.2.10.1502241220500.3855@chino.kir.corp.google.com>
References: <1424801964-1602-1-git-send-email-mhocko@suse.cz> <20150224191127.GA14718@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, "\\\"Rafael J. Wysocki\\\"" <rjw@rjwysocki.net>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, 24 Feb 2015, Johannes Weiner wrote:

> On Tue, Feb 24, 2015 at 07:19:24PM +0100, Michal Hocko wrote:
> > Tetsuo Handa has pointed out that __GFP_NOFAIL allocations might fail
> > after OOM killer is disabled if the allocation is performed by a
> > kernel thread. This behavior was introduced from the very beginning by
> > 7f33d49a2ed5 (mm, PM/Freezer: Disable OOM killer when tasks are frozen).
> > This means that the basic contract for the allocation request is broken
> > and the context requesting such an allocation might blow up unexpectedly.
> > 
> > There are basically two ways forward.
> > 1) move oom_killer_disable after kernel threads are frozen. This has a
> >    risk that the OOM victim wouldn't be able to finish because it would
> >    depend on an already frozen kernel thread. This would be really
> >    tricky to debug.
> > 2) do not fail GFP_NOFAIL allocation no matter what and risk a potential
> >    Freezable kernel threads will loop and fail the suspend. Incidental
> >    allocations after kernel threads are frozen will at least dump a
> >    warning - if we are lucky and the serial console is still active of
> >    course...
> > 
> > This patch implements the later option because it is safer. We would see
> > warnings rather than allocation failures for the kernel threads which
> > would blow up otherwise and have a higher chances to identify
> > __GFP_NOFAIL users from deeper pm code.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> > ---
> > 
> > We haven't seen any bug reports 
> > 
> >  mm/oom_kill.c | 8 ++++++++
> >  1 file changed, 8 insertions(+)
> > 
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index 642f38cb175a..ea8b443cd871 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -772,6 +772,10 @@ out:
> >  		schedule_timeout_killable(1);
> >  }
> >  
> > +static DEFINE_RATELIMIT_STATE(oom_disabled_rs,
> > +		DEFAULT_RATELIMIT_INTERVAL,
> > +		DEFAULT_RATELIMIT_BURST);
> > +
> >  /**
> >   * out_of_memory -  tries to invoke OOM killer.
> >   * @zonelist: zonelist pointer
> > @@ -792,6 +796,10 @@ bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
> >  	if (!oom_killer_disabled) {
> >  		__out_of_memory(zonelist, gfp_mask, order, nodemask, force_kill);
> >  		ret = true;
> > +	} else if (gfp_mask & __GFP_NOFAIL) {
> > +		if (__ratelimit(&oom_disabled_rs))
> > +			WARN(1, "Unable to make forward progress for __GFP_NOFAIL because OOM killer is disbaled\n");
> > +		ret = true;
> 
> I'm fine with keeping the allocation looping, but is that message
> helpful?  It seems completely useless to the user encountering it.  Is
> it going to help kernel developers when we get a bug report with it?
> 
> WARN_ON_ONCE()?
> 

Yeah, I'm not sure that the warning is helpful (and it needs 
s/disbaled/disabled/ if it is to be kept).  I also think this check should 
be moved out of out_of_memory() since gfp/retry logic should be in the 
page allocator itself and not in the oom killer: just make 
__alloc_pages_may_oom() also set *did_some_progress = 1 for __GFP_NOFAIL.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
