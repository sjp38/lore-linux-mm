Date: Tue, 9 Dec 2008 12:53:41 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [mm] [PATCH 3/4] Memory cgroup hierarchical reclaim (v4)
Message-Id: <20081209125341.456bf635.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20081209115943.7d6a0ea3.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081116081034.25166.7586.sendpatchset@balbir-laptop>
	<20081116081055.25166.85066.sendpatchset@balbir-laptop>
	<20081125205832.38f8c365.nishimura@mxp.nes.nec.co.jp>
	<492C1345.9090201@linux.vnet.ibm.com>
	<20081126111447.106ec275.nishimura@mxp.nes.nec.co.jp>
	<20081209115943.7d6a0ea3.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

On Tue, 9 Dec 2008 11:59:43 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Wed, 26 Nov 2008 11:14:47 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > On Tue, 25 Nov 2008 20:31:25 +0530, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > Daisuke Nishimura wrote:
> > > > Hi.
> > > > 
> > > > Unfortunately, trying to hold cgroup_mutex at reclaim causes dead lock.
> > > > 
> > > > For example, when attaching a task to some cpuset directory(memory_migrate=on),
> > > > 
> > > >     cgroup_tasks_write (hold cgroup_mutex)
> > > >         attach_task_by_pid
> > > >             cgroup_attach_task
> > > >                 cpuset_attach
> > > >                     cpuset_migrate_mm
> > > >                         :
> > > >                         unmap_and_move
> > > >                             mem_cgroup_prepare_migration
> > > >                                 mem_cgroup_try_charge
> > > >                                     mem_cgroup_hierarchical_reclaim
> > > > 
> > > 
> > > Did lockdep complain about it?
> > > 
> > I haven't understood lockdep so well, but I got logs like this:
> > 
> > ===
> > INFO: task move.sh:17710 blocked for more than 480 seconds.
> > "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> > move.sh       D ffff88010e1c76c0     0 17710  17597
> >  ffff8800bd9edf00 0000000000000046 0000000000000000 0000000000000000
> >  ffff8803afbc0000 ffff8800bd9ee270 0000000e00000000 000000010a54459c
> >  ffffffffffffffff ffffffffffffffff ffffffffffffffff 7fffffffffffffff
> > Call Trace:
> >  [<ffffffff802ae9f0>] mem_cgroup_get_first_node+0x29/0x8a
> >  [<ffffffff804cb357>] mutex_lock_nested+0x180/0x2a2
> >  [<ffffffff802ae9f0>] mem_cgroup_get_first_node+0x29/0x8a
> >  [<ffffffff802ae9f0>] mem_cgroup_get_first_node+0x29/0x8a
> >  [<ffffffff802aed9c>] __mem_cgroup_try_charge+0x27a/0x2de
> >  [<ffffffff802afdfd>] mem_cgroup_prepare_migration+0x6c/0xa5
> >  [<ffffffff802ad97f>] migrate_pages+0x10c/0x4a0
> >  [<ffffffff802ad9c8>] migrate_pages+0x155/0x4a0
> >  [<ffffffff802a14cb>] new_node_page+0x0/0x2f
> >  [<ffffffff802a1adb>] check_range+0x300/0x325
> >  [<ffffffff802a2374>] do_migrate_pages+0x1a5/0x1f1
> >  [<ffffffff8026d272>] cpuset_migrate_mm+0x30/0x93
> >  [<ffffffff8026d29c>] cpuset_migrate_mm+0x5a/0x93
> >  [<ffffffff8026df41>] cpuset_attach+0x93/0xa6
> >  [<ffffffff8026ae1b>] cgroup_attach_task+0x395/0x3e1
> >  [<ffffffff8026af61>] cgroup_tasks_write+0xfa/0x11d
> >  [<ffffffff8026aea0>] cgroup_tasks_write+0x39/0x11d
> >  [<ffffffff8026b5aa>] cgroup_file_write+0xef/0x216
> >  [<ffffffff802b2968>] vfs_write+0xad/0x136
> >  [<ffffffff802b2dfe>] sys_write+0x45/0x6e
> >  [<ffffffff8020bdab>] system_call_fastpath+0x16/0x1b
> > INFO: lockdep is turned off.
> > ===
> > 
> > And other processes trying to hold cgroup_mutex are also stuck.
> > 
> > > 1. We could probably move away from cgroup_mutex to a memory controller specific
> > > mutex.
> > > 2. We could give up cgroup_mutex before migrate_mm, since it seems like we'll
> > > hold the cgroup lock for long and holding it during reclaim will definitely be
> > > visible to users trying to create/delete nodes.
> > > 
> > > I prefer to do (2), I'll look at the code more closely
> > > 
> > I basically agree, but I think we should also consider mpol_rebind_mm.
> > 
> > mpol_rebind_mm, which can be called from cpuset_attach, does down_write(mm->mmap_sem),
> > which means down_write(mm->mmap_sem) can be called under cgroup_mutex.
> > OTOH, page fault path does down_read(mm->mmap_sem) and can call mem_cgroup_try_charge,
> > which means mutex_lock(cgroup_mutex) can be called under down_read(mm->mmap_sem).
> > 
> 
> What's status of this problem ? fixed or not yet ?
> Sorry for failing to track paches.
> 
Not yet.

Those dead locks cannot be fixed as long as reclaim path tries to hold cgroup_mutex.
(current mmotm doesn't hold cgroup_mutex on reclaim path if !use_hierarchy and
I'm testing with !use_hierarchy. It works well basically, but I got another bug
at rmdir today, and digging it now.)

The dead lock I've fixed by memcg-avoid-dead-lock-caused-by-race-between-oom-and-cpuset_attach.patch
is another one(removed cgroup_lock from oom code).


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
