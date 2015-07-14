Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id F23616B0266
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 11:18:26 -0400 (EDT)
Received: by wgjx7 with SMTP id x7so11452999wgj.2
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 08:18:26 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o8si2424399wjo.49.2015.07.14.08.18.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 14 Jul 2015 08:18:25 -0700 (PDT)
Date: Tue, 14 Jul 2015 17:18:23 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 7/8] memcg: get rid of mm_struct::owner
Message-ID: <20150714151823.GG17660@dhcp22.suse.cz>
References: <1436358472-29137-1-git-send-email-mhocko@kernel.org>
 <1436358472-29137-8-git-send-email-mhocko@kernel.org>
 <20150710140533.GB29540@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150710140533.GB29540@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Greg Thelen <gthelen@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri 10-07-15 16:05:33, Michal Hocko wrote:
> JFYI: I've found some more issues while hamerring this more.

OK so the main issue is quite simple but I have completely missed it when
thinking about the patch before. clone(CLONE_VM) without CLONE_THREAD is
really nasty and it will easily lockup the machine with preempt. disabled
for ever. It goes like this:
taskA (in memcg A)
  taskB = clone(CLONE_VM)
				taskB
				  A -> B	# Both tasks charge to B now
				  exit()	# No tasks in B -> can be
				  		# offlined now
				css_offline()
  mem_cgroup_try_charge
    get_mem_cgroup_from_mm
      rcu_read_lock()
      do {
      } while css_tryget_online(mm->memcg)	# will never succeed
      rcu_read_unlock()

taskA and taskB are basically independent entities wrt. the life
cycle (unlike threads which are bound to the group leader). The
previous code handles this by re-ownering during exit by the monster
mm_update_next_owner.

I can see the following options without reintroducing reintroducing
some form of mm_update_next_owner:

1) Do not allow offlining a cgroup if we have active users in it.  This
would require a callback from the cgroup core to the subsystem called if
there are no active tasks tracked by the cgroup core. Tracking on the memcg
side doesn't sound terribly hard - just mark a mm_struct as an alien and
count the number of aliens during the move in mem_cgroup. mm_drop_memcg
then drops the counter. We could end up with EBUSY cgroup without any
visible tasks which is a bit awkward.

2) update get_mem_cgroup_from_mm and others to fallback to the parent
memcg if the current one is offline. This would be in line with charge
reparenting we used to do. I cannot say I would like this because it
allows for easy runaway to the root memcg if the hierarchy is not
configured cautiously. The code would be also quite tricky because each
direct consumer of mm->memcg would have to be aware of this. This is
awkward.

3) fail mem_cgroup_can_attach if we are trying to migrate a task sharing
mm_struct with a process outside of the tset. If I understand the
tset properly this would require all the sharing tasks to be migrated
together and we would never end up with task_css != &task->mm->css.
__cgroup_procs_write doesn't seem to support multi pid move currently
AFAICS, though. cgroup_migrate_add_src, however, seems to be intended
for this purpose so this should be doable. Without that support we would
basically disallow migrating these tasks - I wouldn't object if you ask
me.

Do you see other options? From the above three options the 3rd one
sounds the most sane to me and the 1st quite easy to implement. Both will
require some cgroup core work though. But maybe we would be good enough
with 3rd option without supporting moving schizophrenic tasks and that
would be reduced to memcg code.

Or we can, of course, stay with the current state but I think it would
be much saner to get rid of the schizophrenia.

What do you think?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
