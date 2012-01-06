Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id E62716B004D
	for <linux-mm@kvack.org>; Fri,  6 Jan 2012 08:42:28 -0500 (EST)
Date: Fri, 6 Jan 2012 05:28:47 -0800
From: Greg KH <gregkh@suse.de>
Subject: Re: [PATCH v5 7/8] mm: Only IPI CPUs to drain local pages if they
 exist
Message-ID: <20120106132847.GA9279@suse.de>
References: <1325499859-2262-1-git-send-email-gilad@benyossef.com>
 <1325499859-2262-8-git-send-email-gilad@benyossef.com>
 <4F033EC9.4050909@gmail.com>
 <20120105142017.GA27881@csn.ul.ie>
 <20120105144011.GU11810@n2100.arm.linux.org.uk>
 <20120105161739.GD27881@csn.ul.ie>
 <20120105163529.GA11810@n2100.arm.linux.org.uk>
 <20120105183504.GF2393@linux.vnet.ibm.com>
 <20120105222116.GF27881@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120105222116.GF27881@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Gilad Ben-Yossef <gilad@benyossef.com>, linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>

On Thu, Jan 05, 2012 at 10:21:16PM +0000, Mel Gorman wrote:
> (Adding Greg to cc to see if he recalls seeing issues with sysfs dentry
> suffering from recursive locking recently)
> 
> On Thu, Jan 05, 2012 at 10:35:04AM -0800, Paul E. McKenney wrote:
> > On Thu, Jan 05, 2012 at 04:35:29PM +0000, Russell King - ARM Linux wrote:
> > > On Thu, Jan 05, 2012 at 04:17:39PM +0000, Mel Gorman wrote:
> > > > Link please?
> > > 
> > > Forwarded, as its still in my mailbox.
> > > 
> > > > I'm including a patch below under development that is
> > > > intended to only cope with the page allocator case under heavy memory
> > > > pressure. Currently it does not pass testing because eventually RCU
> > > > gets stalled with the following trace
> > > > 
> > > > [ 1817.176001]  [<ffffffff810214d7>] arch_trigger_all_cpu_backtrace+0x87/0xa0
> > > > [ 1817.176001]  [<ffffffff810c4779>] __rcu_pending+0x149/0x260
> > > > [ 1817.176001]  [<ffffffff810c48ef>] rcu_check_callbacks+0x5f/0x110
> > > > [ 1817.176001]  [<ffffffff81068d7f>] update_process_times+0x3f/0x80
> > > > [ 1817.176001]  [<ffffffff8108c4eb>] tick_sched_timer+0x5b/0xc0
> > > > [ 1817.176001]  [<ffffffff8107f28e>] __run_hrtimer+0xbe/0x1a0
> > > > [ 1817.176001]  [<ffffffff8107f581>] hrtimer_interrupt+0xc1/0x1e0
> > > > [ 1817.176001]  [<ffffffff81020ef3>] smp_apic_timer_interrupt+0x63/0xa0
> > > > [ 1817.176001]  [<ffffffff81449073>] apic_timer_interrupt+0x13/0x20
> > > > [ 1817.176001]  [<ffffffff8116c135>] vfsmount_lock_local_lock+0x25/0x30
> > > > [ 1817.176001]  [<ffffffff8115c855>] path_init+0x2d5/0x370
> > > > [ 1817.176001]  [<ffffffff8115eecd>] path_lookupat+0x2d/0x620
> > > > [ 1817.176001]  [<ffffffff8115f4ef>] do_path_lookup+0x2f/0xd0
> > > > [ 1817.176001]  [<ffffffff811602af>] user_path_at_empty+0x9f/0xd0
> > > > [ 1817.176001]  [<ffffffff81154e7b>] vfs_fstatat+0x4b/0x90
> > > > [ 1817.176001]  [<ffffffff81154f4f>] sys_newlstat+0x1f/0x50
> > > > [ 1817.176001]  [<ffffffff81448692>] system_call_fastpath+0x16/0x1b
> > > > 
> > > > It might be a separate bug, don't know for sure.
> > 
> 
> I rebased the patch on top of 3.2 and tested again with a bunch of
> debugging options set (PROVE_RCU, PROVE_LOCKING etc). Same results. CPU
> hotplug is a lot more reliable and less likely to hang but eventually
> gets into trouble.
> 
> Taking a closer look though, I don't think this is an RCU problem. It's
> just the messenger.
> 
> > Do you get multiple RCU CPU stall-warning messages? 
> 
> Yes, one roughly every 50000 jiffies or so (HZ=250).
> 
> [  878.315029] INFO: rcu_sched detected stall on CPU 3 (t=16250 jiffies)
> [  878.315032] INFO: rcu_sched detected stall on CPU 6 (t=16250 jiffies)
> [ 1072.878669] INFO: rcu_sched detected stall on CPU 3 (t=65030 jiffies)
> [ 1072.878672] INFO: rcu_sched detected stall on CPU 6 (t=65030 jiffies)
> [ 1267.442308] INFO: rcu_sched detected stall on CPU 3 (t=113810 jiffies)
> [ 1267.442312] INFO: rcu_sched detected stall on CPU 6 (t=113810 jiffies)
> [ 1462.005948] INFO: rcu_sched detected stall on CPU 3 (t=162590 jiffies)
> [ 1462.005952] INFO: rcu_sched detected stall on CPU 6 (t=162590 jiffies)
> [ 1656.569588] INFO: rcu_sched detected stall on CPU 3 (t=211370 jiffies)
> [ 1656.569592] INFO: rcu_sched detected stall on CPU 6 (t=211370 jiffies)
> [ 1851.133229] INFO: rcu_sched detected stall on CPU 6 (t=260150 jiffies)
> [ 1851.133233] INFO: rcu_sched detected stall on CPU 3 (t=260150 jiffies)
> [ 2045.696868] INFO: rcu_sched detected stall on CPU 3 (t=308930 jiffies)
> [ 2045.696872] INFO: rcu_sched detected stall on CPU 6 (t=308930 jiffies)
> [ 2240.260508] INFO: rcu_sched detected stall on CPU 6 (t=357710 jiffies)
> [ 2240.260511] INFO: rcu_sched detected stall on CPU 3 (t=357710 jiffies)
> 
> > If so, it can
> > be helpful to look at how the stack frame changes over time.  These
> > stalls are normally caused by a loop in the kernel with preemption
> > disabled, though other scenarios can also cause them.
> > 
> 
> The stacks are not changing much over time and start with this;
> 
> [  878.315029] INFO: rcu_sched detected stall on CPU 3 (t=16250 jiffies)
> [  878.315032] INFO: rcu_sched detected stall on CPU 6 (t=16250 jiffies)
> [  878.315036] Pid: 4422, comm: udevd Not tainted 3.2.0-guardipi-v1r6 #2
> [  878.315037] Call Trace:
> [  878.315038]  <IRQ>  [<ffffffff810a8b20>] __rcu_pending+0x8e/0x36c
> [  878.315052]  [<ffffffff81071b9a>] ? tick_nohz_handler+0xdc/0xdc
> [  878.315054]  [<ffffffff810a8f04>] rcu_check_callbacks+0x106/0x172
> [  878.315056]  [<ffffffff810528e0>] update_process_times+0x3f/0x76
> [  878.315058]  [<ffffffff81071c0a>] tick_sched_timer+0x70/0x9a
> [  878.315060]  [<ffffffff8106654e>] __run_hrtimer+0xc7/0x157
> [  878.315062]  [<ffffffff810667ec>] hrtimer_interrupt+0xba/0x18a
> [  878.315065]  [<ffffffff8134fbad>] smp_apic_timer_interrupt+0x86/0x99
> [  878.315067]  [<ffffffff8134dbf3>] apic_timer_interrupt+0x73/0x80
> [  878.315068]  <EOI>  [<ffffffff81345f34>] ? retint_restore_args+0x13/0x13
> [  878.315072]  [<ffffffff81139591>] ? __shrink_dcache_sb+0x7d/0x19f
> [  878.315075]  [<ffffffff81008c6e>] ? native_read_tsc+0x1/0x16
> [  878.315077]  [<ffffffff811df434>] ? delay_tsc+0x3a/0x82
> [  878.315079]  [<ffffffff811df4a1>] __delay+0xf/0x11
> [  878.315081]  [<ffffffff811e51e5>] do_raw_spin_lock+0xb5/0xf9
> [  878.315083]  [<ffffffff81345561>] _raw_spin_lock+0x39/0x3d
> [  878.315085]  [<ffffffff8113972a>] ? shrink_dcache_parent+0x77/0x28c
> [  878.315087]  [<ffffffff8113972a>] shrink_dcache_parent+0x77/0x28c
> [  878.315089]  [<ffffffff8113741d>] ? have_submounts+0x13e/0x1bd
> [  878.315092]  [<ffffffff81185970>] sysfs_dentry_revalidate+0xaa/0xbe
> [  878.315093]  [<ffffffff8112e731>] do_lookup+0x263/0x2fc
> [  878.315096]  [<ffffffff8119ca13>] ? security_inode_permission+0x1e/0x20
> [  878.315098]  [<ffffffff8112f33d>] link_path_walk+0x1e2/0x763
> [  878.315099]  [<ffffffff8112fd66>] path_lookupat+0x5c/0x61a
> [  878.315102]  [<ffffffff810f4810>] ? might_fault+0x89/0x8d
> [  878.315104]  [<ffffffff810f47c7>] ? might_fault+0x40/0x8d
> [  878.315105]  [<ffffffff8113034e>] do_path_lookup+0x2a/0xa8
> [  878.315107]  [<ffffffff81132a51>] user_path_at_empty+0x5d/0x97
> [  878.315109]  [<ffffffff8107447f>] ? trace_hardirqs_off+0xd/0xf
> [  878.315111]  [<ffffffff81345c4f>] ? _raw_spin_unlock_irqrestore+0x44/0x5a
> [  878.315112]  [<ffffffff81132a9c>] user_path_at+0x11/0x13
> [  878.315115]  [<ffffffff81128b64>] vfs_fstatat+0x44/0x71
> [  878.315117]  [<ffffffff81128bef>] vfs_lstat+0x1e/0x20
> [  878.315118]  [<ffffffff81128c10>] sys_newlstat+0x1f/0x40
> [  878.315120]  [<ffffffff810759a8>] ? trace_hardirqs_on_caller+0x12d/0x164
> [  878.315122]  [<ffffffff811e057e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
> [  878.315124]  [<ffffffff8107447f>] ? trace_hardirqs_off+0xd/0xf
> [  878.315126]  [<ffffffff8134d082>] system_call_fastpath+0x16/0x1b
> [  878.557790] Pid: 5704, comm: udevd Not tainted 3.2.0-guardipi-v1r6 #2
> [  878.564226] Call Trace:
> [  878.566677]  <IRQ>  [<ffffffff810a8b20>] __rcu_pending+0x8e/0x36c
> [  878.572783]  [<ffffffff81071b9a>] ? tick_nohz_handler+0xdc/0xdc
> [  878.578702]  [<ffffffff810a8f04>] rcu_check_callbacks+0x106/0x172
> [  878.584794]  [<ffffffff810528e0>] update_process_times+0x3f/0x76
> [  878.590798]  [<ffffffff81071c0a>] tick_sched_timer+0x70/0x9a
> [  878.596459]  [<ffffffff8106654e>] __run_hrtimer+0xc7/0x157
> [  878.601944]  [<ffffffff810667ec>] hrtimer_interrupt+0xba/0x18a
> [  878.607778]  [<ffffffff8134fbad>] smp_apic_timer_interrupt+0x86/0x99
> [  878.614129]  [<ffffffff8134dbf3>] apic_timer_interrupt+0x73/0x80
> [  878.620134]  <EOI>  [<ffffffff81051e66>] ? run_timer_softirq+0x49/0x32a
> [  878.626759]  [<ffffffff81139591>] ? __shrink_dcache_sb+0x7d/0x19f
> [  878.632851]  [<ffffffff811df402>] ? delay_tsc+0x8/0x82
> [  878.637988]  [<ffffffff811df4a1>] __delay+0xf/0x11
> [  878.642778]  [<ffffffff811e51e5>] do_raw_spin_lock+0xb5/0xf9
> [  878.648437]  [<ffffffff81345561>] _raw_spin_lock+0x39/0x3d
> [  878.653920]  [<ffffffff8113972a>] ? shrink_dcache_parent+0x77/0x28c
> [  878.660186]  [<ffffffff8113972a>] shrink_dcache_parent+0x77/0x28c
> [  878.666277]  [<ffffffff8113741d>] ? have_submounts+0x13e/0x1bd
> [  878.672107]  [<ffffffff81185970>] sysfs_dentry_revalidate+0xaa/0xbe
> [  878.678372]  [<ffffffff8112e731>] do_lookup+0x263/0x2fc
> [  878.683596]  [<ffffffff8119ca13>] ? security_inode_permission+0x1e/0x20
> [  878.690207]  [<ffffffff8112f33d>] link_path_walk+0x1e2/0x763
> [  878.695866]  [<ffffffff8112fd66>] path_lookupat+0x5c/0x61a
> [  878.701350]  [<ffffffff810f4810>] ? might_fault+0x89/0x8d
> [  878.706747]  [<ffffffff810f47c7>] ? might_fault+0x40/0x8d
> [  878.712145]  [<ffffffff8113034e>] do_path_lookup+0x2a/0xa8
> [  878.717630]  [<ffffffff81132a51>] user_path_at_empty+0x5d/0x97
> [  878.723463]  [<ffffffff8107447f>] ? trace_hardirqs_off+0xd/0xf
> [  878.729295]  [<ffffffff81345c4f>] ? _raw_spin_unlock_irqrestore+0x44/0x5a
> [  878.736080]  [<ffffffff81132a9c>] user_path_at+0x11/0x13
> [  878.741391]  [<ffffffff81128b64>] vfs_fstatat+0x44/0x71
> [  878.746616]  [<ffffffff81128bef>] vfs_lstat+0x1e/0x20
> [  878.751668]  [<ffffffff81128c10>] sys_newlstat+0x1f/0x40
> [  878.756981]  [<ffffffff810759a8>] ? trace_hardirqs_on_caller+0x12d/0x164
> [  878.763678]  [<ffffffff811e057e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
> [  878.770116]  [<ffffffff8107447f>] ? trace_hardirqs_off+0xd/0xf
> [  878.775949]  [<ffffffff8134d082>] system_call_fastpath+0x16/0x1b
> [  908.769486] BUG: spinlock lockup on CPU#6, udevd/4422
> [  908.774547]  lock: ffff8803b4c701c8, .magic: dead4ead, .owner: udevd/5709, .owner_cpu: 4
> 
> Seeing that the owner was CPU 4, I found earlier in the log
> 
> [  815.244051] BUG: spinlock lockup on CPU#4, udevd/5709
> [  815.249103]  lock: ffff8803b4c701c8, .magic: dead4ead, .owner: udevd/5709, .owner_cpu: 4
> [  815.258430] Pid: 5709, comm: udevd Not tainted 3.2.0-guardipi-v1r6 #2
> [  815.264866] Call Trace:
> [  815.267329]  [<ffffffff811e507d>] spin_dump+0x88/0x8d
> [  815.272388]  [<ffffffff811e5206>] do_raw_spin_lock+0xd6/0xf9
> [  815.278062]  [<ffffffff81345561>] ? _raw_spin_lock+0x39/0x3d
> [  815.283720]  [<ffffffff8113972a>] ? shrink_dcache_parent+0x77/0x28c
> [  815.289986]  [<ffffffff8113972a>] ? shrink_dcache_parent+0x77/0x28c
> [  815.296249]  [<ffffffff8113741d>] ? have_submounts+0x13e/0x1bd
> [  815.302080]  [<ffffffff81185970>] ? sysfs_dentry_revalidate+0xaa/0xbe
> [  815.308515]  [<ffffffff8112e731>] ? do_lookup+0x263/0x2fc
> [  815.313915]  [<ffffffff8119ca13>] ? security_inode_permission+0x1e/0x20
> [  815.320524]  [<ffffffff8112f33d>] ? link_path_walk+0x1e2/0x763
> [  815.326357]  [<ffffffff8112fd66>] ? path_lookupat+0x5c/0x61a
> [  815.332014]  [<ffffffff810f4810>] ? might_fault+0x89/0x8d
> [  815.337410]  [<ffffffff810f47c7>] ? might_fault+0x40/0x8d
> [  815.342807]  [<ffffffff8113034e>] ? do_path_lookup+0x2a/0xa8
> [  815.348465]  [<ffffffff81132a51>] ? user_path_at_empty+0x5d/0x97
> [  815.354474]  [<ffffffff8107447f>] ? trace_hardirqs_off+0xd/0xf
> [  815.360303]  [<ffffffff81345c4f>] ? _raw_spin_unlock_irqrestore+0x44/0x5a
> [  815.367085]  [<ffffffff81132a9c>] ? user_path_at+0x11/0x13
> [  815.372569]  [<ffffffff81128b64>] ? vfs_fstatat+0x44/0x71
> [  815.377965]  [<ffffffff81128bef>] ? vfs_lstat+0x1e/0x20
> [  815.383192]  [<ffffffff81128c10>] ? sys_newlstat+0x1f/0x40
> [  815.388676]  [<ffffffff810759a8>] ? trace_hardirqs_on_caller+0x12d/0x164
> [  815.395373]  [<ffffffff811e057e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
> [  815.401811]  [<ffffffff8107447f>] ? trace_hardirqs_off+0xd/0xf
> [  815.407642]  [<ffffffff8134d082>] ? system_call_fastpath+0x16/0x1b
> 
> The trace is not particularly useful but it looks like it
> recursively locked even though the message doesn't say that.  If the
> shrink_dcache_parent() entry is accurate, that corresponds to this
> 
> static int select_parent(struct dentry * parent)
> {
>         struct dentry *this_parent;
>         struct list_head *next;
>         unsigned seq;
>         int found = 0;
>         int locked = 0;
> 
>         seq = read_seqbegin(&rename_lock);
> again: 
>         this_parent = parent;
>         spin_lock(&this_parent->d_lock); <----- HERE
> 
> I'm not overly clear on how VFS locking is meant to work but it almost
> looks as if the last reference to an inode is being dropped during a
> sysfs path lookup. Is that meant to happen?
> 
> Judging by sysfs_dentry_revalidate() - possibly not. It looks like
> we must have reached out_bad: and called shrink_dcache_parent() on a
> dentry that was already locked by the running process. Not sure how
> this could have happened - Greg, does this look familiar?

I don't know.  I'm working with some others who are trying to trace down
a sysfs lockup bug when files go away and are created very quickly and
userspace tries to stat them, but I'm not quite sure this is the same
issue or not.

Are these sysfs files being removed that you are having problems with?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
