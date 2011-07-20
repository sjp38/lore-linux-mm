Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 42DB56B004A
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 03:00:50 -0400 (EDT)
Date: Wed, 20 Jul 2011 09:00:43 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/2] memcg: change memcg_oom_mutex to spinlock
Message-ID: <20110720070043.GB10857@tiehlicka.suse.cz>
References: <cover.1310732789.git.mhocko@suse.cz>
 <b24894c23d0bb06f849822cb30726b532ea3a4c5.1310732789.git.mhocko@suse.cz>
 <CAKTCnzkiRW3aLwnCYyb9XPfTZWipqcA5Jd7d27rZpecqn3wFuQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKTCnzkiRW3aLwnCYyb9XPfTZWipqcA5Jd7d27rZpecqn3wFuQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Wed 20-07-11 12:04:17, Balbir Singh wrote:
> On Thu, Jul 14, 2011 at 8:59 PM, Michal Hocko <mhocko@suse.cz> wrote:
> > memcg_oom_mutex is used to protect memcg OOM path and eventfd interface
> > for oom_control. None of the critical sections which it protects sleep
> > (eventfd_signal works from atomic context and the rest are simple linked
> > list resp. oom_lock atomic operations).
> > Mutex is also too heavy weight for those code paths because it triggers
> > a lot of scheduling. It also makes makes convoying effects more visible
> > when we have a big number of oom killing because we take the lock
> > mutliple times during mem_cgroup_handle_oom so we have multiple places
> > where many processes can sleep.
> >
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> 
> Quick question: How long do we expect this lock to be taken? 

The lock is taken in 
* mem_cgroup_handle_oom at 2 places
	- to protect mem_cgroup_oom_lock and mem_cgroup_oom_notify
	- to protect mem_cgroup_oom_unlock and memcg_wakeup_oom

mem_cgroup_oom_{un}lock as well as mem_cgroup_oom_notify scale with the
number of groups in the hierarchy.
mem_cgroup_oom_notify scales with the number of all blocked tasks on the
memcg_oom_waitq (which is not mem_cgroup specific) and
memcg_oom_wake_function can go up the hierarchy for all of them in the
worst case.

* mem_cgroup_oom_register_event uses it to protect notifier registration
  (one list_add operation) + notification in case the group is already
  under oom - we can consider both operations to be constant time
* mem_cgroup_oom_unregister_event protects unregistration so it scales
  with the number of notifiers. I guess this is potentially unlimitted
  but I wouldn't be afraid of that as we call just list_del to every
  one.

> What happens under oom?

Could you be more specific? Does the above exaplains?

> Any tests? Numbers?

I was testing with the test mentioned in the other patch and I couldn't
measure any significant difference. That is why I noted that I do not
have any hard numbers to base my argumentation on. It is just that the
mutex doesn't _feel_ right in the code paths we are using it now.
 
> Balbir Singh

Thanks
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
