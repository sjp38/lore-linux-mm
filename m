Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id C22726B0034
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 14:03:21 -0400 (EDT)
Received: by mail-ee0-f44.google.com with SMTP id c13so399093eek.17
        for <linux-mm@kvack.org>; Mon, 03 Jun 2013 11:03:20 -0700 (PDT)
Date: Mon, 3 Jun 2013 20:03:16 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] mm, memcg: add oom killer delay
Message-ID: <20130603180316.GA23659@dhcp22.suse.cz>
References: <alpine.DEB.2.02.1305291817280.520@chino.kir.corp.google.com>
 <20130530150539.GA18155@dhcp22.suse.cz>
 <alpine.DEB.2.02.1305301338430.20389@chino.kir.corp.google.com>
 <20130531081052.GA32491@dhcp22.suse.cz>
 <alpine.DEB.2.02.1305310316210.27716@chino.kir.corp.google.com>
 <20130531112116.GC32491@dhcp22.suse.cz>
 <alpine.DEB.2.02.1305311224330.3434@chino.kir.corp.google.com>
 <20130601061151.GC15576@cmpxchg.org>
 <20130603153432.GC18588@dhcp22.suse.cz>
 <20130603164839.GG15576@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130603164839.GG15576@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Mon 03-06-13 12:48:39, Johannes Weiner wrote:
> On Mon, Jun 03, 2013 at 05:34:32PM +0200, Michal Hocko wrote:
> > On Sat 01-06-13 02:11:51, Johannes Weiner wrote:
> > [...]
> > > From: Johannes Weiner <hannes@cmpxchg.org>
> > > Subject: [PATCH] memcg: more robust oom handling
> > > 
> > > The memcg OOM handling is incredibly fragile because once a memcg goes
> > > OOM, one task (kernel or userspace) is responsible for resolving the
> > > situation.  Every other task that gets caught trying to charge memory
> > > gets stuck in a waitqueue while potentially holding various filesystem
> > > and mm locks on which the OOM handling task may now deadlock.
> > > 
> > > Do two things to charge attempts under OOM:
> > > 
> > > 1. Do not trap system calls (buffered IO and friends), just return
> > >    -ENOMEM.  Userspace should be able to handle this... right?
> > > 
> > > 2. Do not trap page faults directly in the charging context.  Instead,
> > >    remember the OOMing memcg in the task struct and fully unwind the
> > >    page fault stack first.  Then synchronize the memcg OOM from
> > >    pagefault_out_of_memory()
> > 
> > I think this should work and I really like it! Nice work Johannes, I
> > never dared to go that deep and my opposite approach was also much more
> > fragile.
> > 
> > I am just afraid about all the other archs that do not support (from
> > quick grep it looks like: blackfin, c6x, h8300, metag, mn10300,
> > openrisc, score and tile). What would be an alternative for them?
> > #ifdefs for the old code (something like ARCH_HAS_FAULT_OOM_RETRY)? This
> > would be acceptable for me.
> 
> blackfin is NOMMU but I guess the others should be converted to the
> proper OOM protocol anyway and not just kill the faulting task.  I can
> update them in the next version of the patch (series).

OK, if you are willing to convert them all then even better.

> > > Not-quite-signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > > ---
> > >  arch/x86/mm/fault.c        |   2 +
> > >  include/linux/memcontrol.h |   6 +++
> > >  include/linux/sched.h      |   6 +++
> > >  mm/memcontrol.c            | 104 +++++++++++++++++++++++++--------------------
> > >  mm/oom_kill.c              |   7 ++-
> > >  5 files changed, 78 insertions(+), 47 deletions(-)
> > > 
> > [...]
> > > diff --git a/include/linux/sched.h b/include/linux/sched.h
> > > index e692a02..cf60aef 100644
> > > --- a/include/linux/sched.h
> > > +++ b/include/linux/sched.h
> > > @@ -1282,6 +1282,8 @@ struct task_struct {
> > >  				 * execve */
> > >  	unsigned in_iowait:1;
> > >  
> > > +	unsigned in_userfault:1;
> > > +
> > 
> > [This is more a nit pick but before I forget while I am reading through
> > the rest of the patch.]
> > 
> > OK there is a lot of room around those bit fields but as this is only
> > for memcg and you are enlarging the structure by the pointer then you
> > can reuse bottom bit of memcg pointer.
> 
> I just didn't want to put anything in the arch code that looks too
> memcgish, even though it's the only user right now.  But granted, it
> will also probably remain the only user for a while.

OK, no objection. I would just use a more generic name. Something like
memcg_oom_can_block.

[...`]
> > >  	if (locked)
> > >  		mem_cgroup_oom_notify(memcg);
> > >  	spin_unlock(&memcg_oom_lock);
> > >  
> > >  	if (need_to_kill) {
> > > -		finish_wait(&memcg_oom_waitq, &owait.wait);
> > >  		mem_cgroup_out_of_memory(memcg, mask, order);
> > > -	} else {
> > > -		schedule();
> > > -		finish_wait(&memcg_oom_waitq, &owait.wait);
> > > +		memcg_oom_recover(memcg);
> > 
> > Why do we need to call memcg_oom_recover here? We do not know that any
> > charges have been released. Say mem_cgroup_out_of_memory selected a task
> > which migrated to our group (without its charges) so we would kill the
> > poor guy and free no memory from this group.
> > Now you wake up oom waiters to refault but they will end up in the same
> > situation. I think it should be sufficient to wait for memcg_oom_recover
> > until the memory is uncharged (which we do already).
> 
> It's a leftover from how it was before (see the memcg_wakeup_oom
> below), but you are right, we can get rid of it.

right, I have missed that. Then it would deserve a note in the
changelog. Something like
"
memcg_wakeup_oom should be removed because there is no guarantee that
mem_cgroup_out_of_memory was able to free any memory. It could have
killed a task which doesn't have any charges from the group. Waiters
should be woken up by memcg_oom_recover during uncharge or a limit
change.
"
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
