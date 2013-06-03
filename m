Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 52DAF6B0031
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 17:43:18 -0400 (EDT)
Date: Mon, 3 Jun 2013 17:43:04 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm, memcg: add oom killer delay
Message-ID: <20130603214304.GL15576@cmpxchg.org>
References: <20130530150539.GA18155@dhcp22.suse.cz>
 <alpine.DEB.2.02.1305301338430.20389@chino.kir.corp.google.com>
 <20130531081052.GA32491@dhcp22.suse.cz>
 <alpine.DEB.2.02.1305310316210.27716@chino.kir.corp.google.com>
 <20130531112116.GC32491@dhcp22.suse.cz>
 <alpine.DEB.2.02.1305311224330.3434@chino.kir.corp.google.com>
 <20130601102058.GA19474@dhcp22.suse.cz>
 <alpine.DEB.2.02.1306031102480.7956@chino.kir.corp.google.com>
 <20130603185433.GK15576@cmpxchg.org>
 <alpine.DEB.2.02.1306031159060.7956@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1306031159060.7956@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Mon, Jun 03, 2013 at 12:09:22PM -0700, David Rientjes wrote:
> On Mon, 3 Jun 2013, Johannes Weiner wrote:
> 
> > > It's not necessarily harder if you assign the userspace oom handlers to 
> > > the root of your subtree with access to more memory than the children.  
> > > There is no "inability" to write a proper handler, but when you have 
> > > dozens of individual users implementing their own userspace handlers with 
> > > changing memcg limits over time, then you might find it hard to have 
> > > perfection every time.  If we had perfection, we wouldn't have to worry 
> > > about oom in the first place.  We can't just let these gazillion memcgs 
> > > sit spinning forever because they get stuck, either.  That's why we've 
> > > used this solution for years as a failsafe.  Disabling the oom killer 
> > > entirely, even for a memcg, is ridiculous, and if you don't have a grace 
> > > period then oom handlers themselves just don't work.
> > 
> > It's only ridiculous if your OOM handler is subject to the OOM
> > situation it's trying to handle.
> > 
> 
> You're suggesting the oom handler can't be subject to its own memcg 
> limits, independent of the memcg it is handling?  If we demand that such a 
> handler be attached to the root memcg, that breaks the memory isolation 
> that memcg provides.  We constrain processes to a memcg for the purposes 
> of that isolation, so it cannot use more resources than allotted.

I guess the traditional use case is that you have a job manager that
you trust, that sets up the groups, configures their limits etc. and
would also know more about the jobs than the kernel to act as the OOM
killer as well.  Since it's trusted and not expected to consume any
significant amounts of memory by itself, the memcg code assumes that
it does not run in a cgroup itself, it's just not thought of as being
part of the application class.

I'm not saying it should necessarily stay that way, but it's also not
a completely ridiculous model.

> > What we could do is allow one task in the group to be the dedicated
> > OOM handler.  If we catch this task in the charge path during an OOM
> > situation, we fall back to the kernel OOM handler.
> > 
> 
> I'm not sure it even makes sense to have more than one oom handler per 
> memcg and the synchronization that requires in userspace to get the right 
> result, so I didn't consider dedicating a single oom handler.  That would 
> be an entirely new interface, though, since we may have multiple processes 
> waiting on memory.oom_control that aren't necessarily handlers; they grab 
> a snapshot of memory, do logging, etc.

It will probably be hard to extend the existing oom_control interface.

But we could add a separate one where you put in a pid or 0 (kernel)
instead of a boolean value, which then enables or disables the
userspace OOM handling task for the whole subtree.  If that task
enters the OOM path, the kernel handler is invoked.  If the task dies,
the kernel handler is permanently re-enabled.  Everybody is free to
poll that interface for OOM notifications, not only that one task.

Combined with the "enter waitqueue after unwinding page fault stack"
patch, would this fully cover your usecase?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
