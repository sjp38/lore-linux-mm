Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id A66686B004D
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 14:29:53 -0500 (EST)
Date: Mon, 26 Nov 2012 14:29:41 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -mm] memcg: do not trigger OOM from
 add_to_page_cache_locked
Message-ID: <20121126192941.GC2301@cmpxchg.org>
References: <20121123100438.GF24698@dhcp22.suse.cz>
 <20121125011047.7477BB5E@pobox.sk>
 <20121125120524.GB10623@dhcp22.suse.cz>
 <20121125135542.GE10623@dhcp22.suse.cz>
 <20121126013855.AF118F5E@pobox.sk>
 <20121126131837.GC17860@dhcp22.suse.cz>
 <20121126174622.GE2799@cmpxchg.org>
 <20121126180444.GA12602@dhcp22.suse.cz>
 <20121126182421.GB2301@cmpxchg.org>
 <20121126190329.GB12602@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121126190329.GB12602@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: azurIt <azurit@pobox.sk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Mon, Nov 26, 2012 at 08:03:29PM +0100, Michal Hocko wrote:
> On Mon 26-11-12 13:24:21, Johannes Weiner wrote:
> > On Mon, Nov 26, 2012 at 07:04:44PM +0100, Michal Hocko wrote:
> > > On Mon 26-11-12 12:46:22, Johannes Weiner wrote:
> [...]
> > > > I think global oom already handles this in a much better way: invoke
> > > > the OOM killer, sleep for a second, then return to userspace to
> > > > relinquish all kernel resources and locks.  The only reason why we
> > > > can't simply change from an endless retry loop is because we don't
> > > > want to return VM_FAULT_OOM and invoke the global OOM killer.
> > > 
> > > Exactly.
> > > 
> > > > But maybe we can return a new VM_FAULT_OOM_HANDLED for memcg OOM and
> > > > just restart the pagefault.  Return -ENOMEM to the buffered IO syscall
> > > > respectively.  This way, the memcg OOM killer is invoked as it should
> > > > but nobody gets stuck anywhere livelocking with the exiting task.
> > > 
> > > Hmm, we would still have a problem with oom disabled (aka user space OOM
> > > killer), right? All processes but those in mem_cgroup_handle_oom are
> > > risky to be killed.
> > 
> > Could we still let everybody get stuck in there when the OOM killer is
> > disabled and let userspace take care of it?
> 
> I am not sure what exactly you mean by "userspace take care of it" but
> if those processes are stuck and holding the lock then it is usually
> hard to find that out. Well if somebody is familiar with internal then
> it is doable but this makes the interface really unusable for regular
> usage.

If oom_kill_disable is set, then all processes get stuck all the way
down in the charge stack.  Whatever resource they pin, you may
deadlock on if you try to touch it while handling the problem from
userspace.  I don't see how this is a new problem...?  Or do you mean
something else?

> > > Other POV might be, why we should trigger an OOM killer from those paths
> > > in the first place. Write or read (or even readahead) are all calls that
> > > should rather fail than cause an OOM killer in my opinion.
> > 
> > Readahead is arguable, but we kill globally for read() and write() and
> > I think we should do the same for memcg.
> 
> Fair point but the global case is little bit easier than memcg in this
> case because nobody can hook on OOM killer and provide a userspace
> implementation for it which is one of the cooler feature of memcg...
> I am all open to any suggestions but we should somehow fix this (and
> backport it to stable trees as this is there for quite some time. The
> current report shows that the problem is not that hard to trigger).

As per above, the userspace OOM handling is risky as hell anyway.
What happens when an anonymous fault waits in memcg userspace OOM
while holding the mmap_sem, and a writer lines up behind it?  Your
userspace OOM handler had better not look at any of the /proc files of
the stuck task that require the mmap_sem.

At the same token, it probably shouldn't touch the same files a memcg
task is stuck trying to read/write.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
