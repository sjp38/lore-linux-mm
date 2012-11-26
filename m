Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 047186B006E
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 15:08:54 -0500 (EST)
Received: by mail-vc0-f169.google.com with SMTP id gb30so6325061vcb.14
        for <linux-mm@kvack.org>; Mon, 26 Nov 2012 12:08:53 -0800 (PST)
Date: Mon, 26 Nov 2012 21:08:48 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -mm] memcg: do not trigger OOM from
 add_to_page_cache_locked
Message-ID: <20121126200848.GC12602@dhcp22.suse.cz>
References: <20121125011047.7477BB5E@pobox.sk>
 <20121125120524.GB10623@dhcp22.suse.cz>
 <20121125135542.GE10623@dhcp22.suse.cz>
 <20121126013855.AF118F5E@pobox.sk>
 <20121126131837.GC17860@dhcp22.suse.cz>
 <20121126174622.GE2799@cmpxchg.org>
 <20121126180444.GA12602@dhcp22.suse.cz>
 <20121126182421.GB2301@cmpxchg.org>
 <20121126190329.GB12602@dhcp22.suse.cz>
 <20121126192941.GC2301@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121126192941.GC2301@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: azurIt <azurit@pobox.sk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Mon 26-11-12 14:29:41, Johannes Weiner wrote:
> On Mon, Nov 26, 2012 at 08:03:29PM +0100, Michal Hocko wrote:
> > On Mon 26-11-12 13:24:21, Johannes Weiner wrote:
> > > On Mon, Nov 26, 2012 at 07:04:44PM +0100, Michal Hocko wrote:
> > > > On Mon 26-11-12 12:46:22, Johannes Weiner wrote:
> > [...]
> > > > > I think global oom already handles this in a much better way: invoke
> > > > > the OOM killer, sleep for a second, then return to userspace to
> > > > > relinquish all kernel resources and locks.  The only reason why we
> > > > > can't simply change from an endless retry loop is because we don't
> > > > > want to return VM_FAULT_OOM and invoke the global OOM killer.
> > > > 
> > > > Exactly.
> > > > 
> > > > > But maybe we can return a new VM_FAULT_OOM_HANDLED for memcg OOM and
> > > > > just restart the pagefault.  Return -ENOMEM to the buffered IO syscall
> > > > > respectively.  This way, the memcg OOM killer is invoked as it should
> > > > > but nobody gets stuck anywhere livelocking with the exiting task.
> > > > 
> > > > Hmm, we would still have a problem with oom disabled (aka user space OOM
> > > > killer), right? All processes but those in mem_cgroup_handle_oom are
> > > > risky to be killed.
> > > 
> > > Could we still let everybody get stuck in there when the OOM killer is
> > > disabled and let userspace take care of it?
> > 
> > I am not sure what exactly you mean by "userspace take care of it" but
> > if those processes are stuck and holding the lock then it is usually
> > hard to find that out. Well if somebody is familiar with internal then
> > it is doable but this makes the interface really unusable for regular
> > usage.
> 
> If oom_kill_disable is set, then all processes get stuck all the way
> down in the charge stack.  Whatever resource they pin, you may
> deadlock on if you try to touch it while handling the problem from
> userspace.

OK, I guess I am getting what you are trying to say. So what you are
suggesting is to just let mem_cgroup_out_of_memory send the signal and
move on without retry (or with few charge retries without further OOM
killing) and fail the charge with your new FAULT_OOM_HANDLED (resp.
something like FAULT_RETRY) error code resp. ENOMEM depending on the
caller.  OOM disabled case would be "you are on your own" because this
has been dangerous anyway. Correct?
I do agree that the current endless retry loop is far from being ideal
and can see some updates but I am quite nervous about any potential
regressions in this area (e.g. too aggressive OOM etc...). I have to
think about it some more.
Anyway if you have some more specific ideas I would be happy to review
patches.

[...]

Thanks
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
