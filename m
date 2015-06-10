Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 8ED096B0032
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 03:52:24 -0400 (EDT)
Received: by wgbgq6 with SMTP id gq6so29170933wgb.3
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 00:52:24 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i18si16170715wjs.183.2015.06.10.00.52.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Jun 2015 00:52:23 -0700 (PDT)
Date: Wed, 10 Jun 2015 09:52:21 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] oom: always panic on OOM when panic_on_oom is configured
Message-ID: <20150610075221.GC4501@dhcp22.suse.cz>
References: <1433159948-9912-1-git-send-email-mhocko@suse.cz>
 <alpine.DEB.2.10.1506041607020.16555@chino.kir.corp.google.com>
 <20150605111302.GB26113@dhcp22.suse.cz>
 <alpine.DEB.2.10.1506081242250.13272@chino.kir.corp.google.com>
 <20150608213218.GB18360@dhcp22.suse.cz>
 <alpine.DEB.2.10.1506081606500.17040@chino.kir.corp.google.com>
 <20150609094356.GB29057@dhcp22.suse.cz>
 <alpine.DEB.2.10.1506091516000.30516@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1506091516000.30516@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 09-06-15 15:28:40, David Rientjes wrote:
> On Tue, 9 Jun 2015, Michal Hocko wrote:
> 
> > > > On Mon 08-06-15 12:51:53, David Rientjes wrote:
> > > > Do you actually have panic_on_oops enabled?
> > > > 
> > > 
> > > CONFIG_PANIC_ON_OOPS_VALUE should be 0, I'm not sure why that's relevant.
> > 
> > No I meant panic_on_oops > 0.
> > 
> 
> CONFIG_PANIC_ON_OOPS_VALUE sets panic_on_oops, so it's 0.

So you are not using this, thanks for making that clear!
 
> > > The functionality I'm referring to is that your patch now panics the 
> > > machine for configs where /proc/sys/vm/panic_on_oom is set and the same 
> > > scenario occurs as described above.  You're introducing userspace breakage 
> > > because you are using panic_on_oom in a way that it hasn't been used in 
> > > the past and isn't described as working in the documentation.
> > 
> > I am sorry, but I do not follow. The knob has been always used to
> > _panic_ the OOM system. Nothing more and nothing less. Now you
> > are arguing about the change being buggy because a task might be
> > killed but that argument doesn't make much sense to me because
> > basically _any_ other allocation which allows OOM to trigger might hit
> > check_panic_on_oom() and panic the system well before your killed task
> > gets a chance to terminate.
> > 
> 
> Not necessarily.  We pin a lot of memory with get_user_pages() and 
> short-circuit it by checking for fatal_signal_pending() specifically for 
> oom conditions.  This was done over six years ago by commit 4779280d1ea4 
> ("mm: make get_user_pages() interruptible").  When such a process is 
> faulting in memory, and it is killed by userspace as a result of an oom 
> condition, it needs to be able to allocate (TIF_MEMDIE set by the oom 
> killer due to SIGKILL), return to __get_user_pages(), abort, handle the 
> signal, and exit.
> 
> I can't possibly make that any more clear.

Are you even reading what I've written? I will ask for the last
time. What exactly prevents other allocation to trigger to oom path and
panic the system before the killed task has a chance to terminate?

> Your patch causes that to instead panic the system if panic_on_oom is set.  
> It's inappropriate and userspace breakage.  The fact that I don't 
> personally use panic_on_oom is completely and utterly irrelevant.
> 
> There is absolutely nothing wrong with a process that has been killed 
> either directly by userspace or as part of a group exit, or a process that 
> is already in the exit path and needs to allocate memory to be able to 
> free its memory, to get access to memory reserves.  That's not an oom 
> condition, that's memory reserves.  Panic_on_oom has nothing to do with 
> this scenario whatsoever.

It very much has and I have presented arguments about that which you
didn't bother to comment on. TIF_MEMDIE is not a magic which will help a
task to exit in all cases. It is a heuristic and it can fail.
panic_on_oops is a hand break when things go wrong and you want to
reduce your unresponsive time (read failover part in the documentation).

> Panic_on_oom is not panic_when_reclaim_fails. 

OOM is when all other reclaim attempts fail. Jeez we are in
out_of_memory how can this be potentially unclear to you? Yes oom killer
path might use heuristics to reduce the impact of the OOM condition but
once we are in this path _we_are_OOM_.

> It's to suppress a kernel 
> oom kill.  That's why it's checked where it is checked and always has 
> been. 

Which makes no sense as well. Because you might have thousands of other
tasks with fatal signal pending on the task list. Why would current be
any different?

> This patch cannot possibly be merged.
> 
> > I would understand your complain if we waited for oom victim(s) before
> > check_panic_on_oom but we have not been doing that.
> > 
> 
> I don't think anybody is changing panic_on_oom after boot, so we wouldn't 
> have any oom victims if the oom killer never did anything.

This has nothing to do with setting panic_on_oom but. Please go and read
what I wrote again and try to think about it before you throw another
unrelated response.

</bunfight> from my side.

Andrew do whatever you like with this patch. I think that arguing about
the patch being broken because it _might_ break an already racy behavior
which nobody can possible rely on is not a reason to nack it. The risk
of not triggering check_panic_on_oom at all is really low so I can live
without the patch.
I am just worried about the level of argumentation here.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
