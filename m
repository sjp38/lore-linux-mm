Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 9E29F6B0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2013 07:23:31 -0400 (EDT)
Date: Wed, 10 Jul 2013 13:23:27 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] mm, memcg: add oom killer delay
Message-ID: <20130710112327.GF4437@dhcp22.suse.cz>
References: <20130605093937.GK15997@dhcp22.suse.cz>
 <alpine.DEB.2.02.1306051657001.29626@chino.kir.corp.google.com>
 <20130610142321.GE5138@dhcp22.suse.cz>
 <alpine.DEB.2.02.1306111321360.32688@chino.kir.corp.google.com>
 <20130612202348.GA17282@dhcp22.suse.cz>
 <alpine.DEB.2.02.1306121408490.24902@chino.kir.corp.google.com>
 <20130613151602.GG23070@dhcp22.suse.cz>
 <alpine.DEB.2.02.1306131508300.8686@chino.kir.corp.google.com>
 <51BA6A2A.3060107@jp.fujitsu.com>
 <alpine.DEB.2.02.1306140254590.8780@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1306140254590.8780@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Fri 14-06-13 03:12:52, David Rientjes wrote:
> On Fri, 14 Jun 2013, Kamezawa Hiroyuki wrote:
> 
> > Reading your discussion, I think I understand your requirements.
> > The problem is that I can't think you took into all options into
> > accounts and found the best way is this new oom_delay. IOW, I can't
> > convice oom-delay is the best way to handle your issue.
> > 
> 
> Ok, let's talk about it.
> 
> > Your requeirement is
> >  - Allowing userland oom-handler within local memcg.
> > 
> 
> Another requirement:
> 
>  - Allow userland oom handler for global oom conditions.
> 
> Hopefully that's hooked into memcg because the functionality is already 
> there, we can simply duplicate all of the oom functionality that we'll be 
> adding for the root memcg.

I understand this and that's why I mentioned enabling oom_control for
root memcg at LSF. I liked the idea at the time but the more I think
about it the more I am scared about all the consequences. Maybe my fear
is not justified as in-kernel (scripting or module registering its own
handler) would be fragile in a similar ways. I would like to see this
being discussed before we go enable memcg way.

I _do_ agree that we really _want_ a way to provide a customer oom
handler.

> > Considering straightforward, the answer should be
> >  - Allowing oom-handler daemon out of memcg's control by its limit.
> >    (For example, a flag/capability for a task can archive this.)
> >    Or attaching some *fixed* resource to the task rather than cgroup.
> > 
> >    Allow to set task->secret_saving=20M.
> > 
> 
> Exactly!

I thought your users are untrusted so you cannot give them any
additional reserves. Or is this only about the root cgroup?

> First of all, thanks very much for taking an interest in our usecase and 
> discussing it with us.
> 
> I didn't propose what I referred to earlier in the thread as "memcg 
> reserves" because I thought it was going to be a more difficult battle.  
> The fact that you brought it up first actually makes me think it's less 
> insane :)

reserves for oom handler doesn't sound like a bad idea but it assumes
that the handler is trusted.

> We do indeed want memcg reserves and I have patches to add it if you'd 
> like to see that first.  It ensures that this userspace oom handler can 
> actually do some work in determining which process to kill.  The reserve 
> is a fraction of true memory reserves (the space below the per-zone min 
> watermarks) which is dependent on min_free_kbytes.  This does indeed 
> become more difficult with true and complete kmem charging.  That "work" 
> could be opening the tasks file (which allocates the pidlist within the 
> kernel),

I am not familiar with details why it has to allocate memory but I guess
we need to read tasks file without any in-kernel allocations.

> checking /proc/pid/status for rss,

This doesn't require in kernel allocation AFAICS.

> checking for how long a process has been running, checking for tid,
> sending a signal to drop caches, etc.
> 
> We'd also like to do this for global oom conditions, which makes it even 
> more interesting.  I was thinking of using a fraction of memory reserves 
> as the oom killer currently does (that memory below the min watermark) for 
> these purposes.
> 
> Memory charging is simply bypassed for these oom handlers (we only grant 
> access to those waiting on the memory.oom_control eventfd) up to 
> memory.limit_in_bytes + (min_free_kbytes / 4), for example.  I don't think 
> this is entirely insane because these oom handlers should lead to future 
> memory freeing, just like TIF_MEMDIE processes.
> 
> > Going back to your patch, what's confusing is your approach.
> > Why the problem caused by the amount of memory should be solved by
> > some dealy, i.e. the amount of time ?
> > 
> > This exchanging sounds confusing to me.
> > 
> 
> Even with all of the above (which is not actually that invasive of a 
> patch), I still think we need memory.oom_delay_millisecs. 

I am still not convinced. I have already mentioned that this can be
handled from userspace.
A simple watchdog which sits on oom_control eventfd which triggers
timer (and reschedule it on a new event while there is one scheduled
already) which reads oom_control to check under_oom before it enables
in-kernel oom handling again doesn't need any memory allocation so there
is nothing to prevent it from resurrecting the system. So I really do
not see a reason for a new knob.

> I probably made a mistake in describing what that is addressing if it
> seems like it's trying to address any of the above.
> 
> If a userspace oom handler fails to respond even with access to those 
> "memcg reserves", the kernel needs to kill within that memcg.  Do we do 
> that above a set time period (this patch) or when the reserves are 
> completely exhausted?  That's debatable, but if we are to allow it for 
> global oom conditions as well then my opinion was to make it as safe as 
> possible; today, we can't disable the global oom killer from userspace and 
> I don't think we should ever allow it to be disabled.  I think we should 
> allow userspace a reasonable amount of time to respond and then kill if it 
> is exceeded.

I don't know. I like the way how we can say we are under control here
and take all the consequences. The scheme you are proposing. You have
some time and you better handle the situation under that time or we will
take over sounds weird to me. We have traditionally allowed users to
shoot their heads expecting they know what they are doing. Why we should
differ here?

> For the global oom case, we want to have a priority-based memcg selection.
> Select the lowest priority top-level memcg and kill within it.  

Yes that makes sense as zillions of other heuristics. E.g. kill whole
groups as they might loose any point if one of their process is killed.

> If it has an oom notifier, send it a signal to kill something.  If
> it fails to react, kill something after memory.oom_delay_millisecs
> has elapsed.  If there isn't a userspace oom notifier, kill something
> within that lowest priority memcg.
> 
> The bottomline with my approach is that I don't believe there is ever a 
> reason for an oom memcg to remain oom indefinitely.  That's why I hate 
> memory.oom_control == 1 and I think for the global notification it would 
> be deemed a nonstarter since you couldn't even login to the machine.
> 
> > I'm not against what you finally want to do, but I don't like the fix.
> > 
> 
> I'm thrilled to hear that, and I hope we can work to make userspace oom 
> handling more effective.
> 
> What do you think about that above?

I think the idea about reserves is worth considering. This, however,
requires a stronger trust model for oom handlers. Maybe we can grant
reserves only to processes with some capability, dunno.

I also think that we should explore/discuss other options for custom oom
handling than hooking into memcg oom_control. I do see why oom_control
is a good fit for you (and I thought about it as well - it is really
ironic that I thought you would hate the idea when I mentioned that at
LSF) but once we allow that we will have to live with that for ever
which might turn out to be problem so better not hurry there.

Finally, I still do not like the "you have this amount of time and
handle that or we will take over" approach so I cannot support you with
your delay knob. If one wants to play with fire he has to take all the
consequences and unless you really convince me that this is not doable I
will stick with this.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
