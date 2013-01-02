Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id E46826B006C
	for <linux-mm@kvack.org>; Wed,  2 Jan 2013 05:44:27 -0500 (EST)
Date: Wed, 2 Jan 2013 11:44:21 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH V3 4/8] memcg: add per cgroup dirty pages accounting
Message-ID: <20130102104421.GC22160@dhcp22.suse.cz>
References: <1356455919-14445-1-git-send-email-handai.szj@taobao.com>
 <1356456367-14660-1-git-send-email-handai.szj@taobao.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1356456367-14660-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, gthelen@google.com, fengguang.wu@intel.com, glommer@parallels.com, dchinner@redhat.com, Sha Zhengju <handai.szj@taobao.com>

On Wed 26-12-12 01:26:07, Sha Zhengju wrote:
> From: Sha Zhengju <handai.szj@taobao.com>
> 
> This patch adds memcg routines to count dirty pages, which allows memory controller
> to maintain an accurate view of the amount of its dirty memory and can provide some
> info for users while cgroup's direct reclaim is working.

I guess you meant targeted resp. (hard/soft) limit reclaim here,
right? It is true that this is direct reclaim but it is not clear to me
why the usefulnes should be limitted to the reclaim for users. I would
understand this if the users was in fact in-kernel users.

[...]
> To prevent AB/BA deadlock mentioned by Greg Thelen in previous version
> (https://lkml.org/lkml/2012/7/30/227), we adjust the lock order:
> ->private_lock --> mapping->tree_lock --> memcg->move_lock.
> So we need to make mapping->tree_lock ahead of TestSetPageDirty in __set_page_dirty()
> and __set_page_dirty_nobuffers(). But in order to avoiding useless spinlock contention,
> a prepare PageDirty() checking is added.

But there is another AA deadlock here I believe.
page_remove_rmap
  mem_cgroup_begin_update_page_stat		<<< 1
  set_page_dirty
    __set_page_dirty_buffers
      __set_page_dirty
        mem_cgroup_begin_update_page_stat	<<< 2
	  move_lock_mem_cgroup
	    spin_lock_irqsave(&memcg->move_lock, *flags);

mem_cgroup_begin_update_page_stat is not recursive wrt. locking AFAICS
because we might race with the moving charges:
	CPU0						CPU1					
page_remove_rmap
						mem_cgroup_can_attach
  mem_cgroup_begin_update_page_stat (1)
    rcu_read_lock
						  mem_cgroup_start_move
						    atomic_inc(&memcg_moving)
						    atomic_inc(&memcg->moving_account)
						    synchronize_rcu
    __mem_cgroup_begin_update_page_stat
      mem_cgroup_stolen	<<< TRUE
      move_lock_mem_cgroup
  [...]
        mem_cgroup_begin_update_page_stat (2)
	  __mem_cgroup_begin_update_page_stat
	    mem_cgroup_stolen	  <<< still TRUE
	    move_lock_mem_cgroup  <<< DEADLOCK
  [...]
  mem_cgroup_end_update_page_stat
    rcu_unlock
    						  # wake up from synchronize_rcu
						[...]
						mem_cgroup_move_task
						  mem_cgroup_move_charge
						    walk_page_range
						      mem_cgroup_move_account
						        move_lock_mem_cgroup


Maybe I have missed some other locking which would prevent this from
happening but the locking relations are really complicated in this area
so if mem_cgroup_{begin,end}_update_page_stat might be called
recursively then we need a fat comment which justifies that.

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
