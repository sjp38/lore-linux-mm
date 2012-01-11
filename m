Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 03B806B004D
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 12:09:17 -0500 (EST)
From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 1/2] fs: sysfs: Do dcache-related updates to sysfs dentries under sysfs_mutex
References: <1326276668-19932-1-git-send-email-mgorman@suse.de>
	<1326276668-19932-2-git-send-email-mgorman@suse.de>
Date: Wed, 11 Jan 2012 09:11:27 -0800
In-Reply-To: <1326276668-19932-2-git-send-email-mgorman@suse.de> (Mel Gorman's
	message of "Wed, 11 Jan 2012 10:11:07 +0000")
Message-ID: <m1k44y5fls.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Gilad Ben-Yossef <gilad@benyossef.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Miklos Szeredi <mszeredi@novell.com>, Greg KH <gregkh@suse.de>, Gong Chen <gong.chen@intel.com>

Mel Gorman <mgorman@suse.de> writes:

> While running a CPU hotplug stress test under memory pressure, a
> spinlock lockup was detected due to a dentry lock being recursively
> taken.  When this happens varies considerably and is difficult
> to trigger.
>
> [  482.345588] BUG: spinlock lockup on CPU#2, udevd/4400
> [  482.345590]  lock: ffff8803075be0d0, .magic: dead4ead, .owner: udevd/5689, .owner_cpu: 0
> [  482.345592] Pid: 4400, comm: udevd Not tainted 3.2.0-vanilla #1
> [  482.345592] Call Trace:
> [  482.345595]  [<ffffffff811e4ffd>] spin_dump+0x88/0x8d
> [  482.345597]  [<ffffffff811e5186>] do_raw_spin_lock+0xd6/0xf9
> [  482.345599]  [<ffffffff813454e1>] _raw_spin_lock+0x39/0x3d
> [  482.345601]  [<ffffffff811396b6>] ? shrink_dcache_parent+0x77/0x28c
> [  482.345603]  [<ffffffff811396b6>] shrink_dcache_parent+0x77/0x28c
> [  482.345605]  [<ffffffff811373a9>] ? have_submounts+0x13e/0x1bd
> [  482.345607]  [<ffffffff811858f8>] sysfs_dentry_revalidate+0xaa/0xbe
> [  482.345608]  [<ffffffff8112e6bd>] do_lookup+0x263/0x2fc
> [  482.345610]  [<ffffffff8119c99b>] ? security_inode_permission+0x1e/0x20
> [  482.345612]  [<ffffffff8112f2c9>] link_path_walk+0x1e2/0x763
> [  482.345614]  [<ffffffff8112fcf2>] path_lookupat+0x5c/0x61a
> [  482.345616]  [<ffffffff810f479c>] ? might_fault+0x89/0x8d
> [  482.345618]  [<ffffffff810f4753>] ? might_fault+0x40/0x8d
> [  482.345619]  [<ffffffff811302da>] do_path_lookup+0x2a/0xa8
> [  482.345621]  [<ffffffff811329dd>] user_path_at_empty+0x5d/0x97
> [  482.345623]  [<ffffffff8107441b>] ? trace_hardirqs_off+0xd/0xf
> [  482.345625]  [<ffffffff81345bcf>] ? _raw_spin_unlock_irqrestore+0x44/0x5a
> [  482.345627]  [<ffffffff81132a28>] user_path_at+0x11/0x13
> [  482.345629]  [<ffffffff81128af0>] vfs_fstatat+0x44/0x71
> [  482.345631]  [<ffffffff81128b7b>] vfs_lstat+0x1e/0x20
> [  482.345632]  [<ffffffff81128b9c>] sys_newlstat+0x1f/0x40
> [  482.345634]  [<ffffffff81075944>] ? trace_hardirqs_on_caller+0x12d/0x164
> [  482.345636]  [<ffffffff811e04fe>] ?  trace_hardirqs_on_thunk+0x3a/0x3f
> [  482.345638]  [<ffffffff8107441b>] ? trace_hardirqs_off+0xd/0xf
> [  482.345640]  [<ffffffff8134d002>] system_call_fastpath+0x16/0x1b
> [  482.515004]  [<ffffffff8107441b>] ? trace_hardirqs_off+0xd/0xf
> [  482.520870]  [<ffffffff8134d002>] system_call_fastpath+0x16/0x1b
>
> At this point, CPU hotplug stops and other processes get stuck in a
> similar deadlock waiting for 5689 to unlock. RCU reports stalls but
> it is collateral damage.
>
> The deadlocked processes have sysfs_dentry_revalidate() in
> common. Miklos Szeredi explained at https://lkml.org/lkml/2012/1/9/114
> that the deadlock happens within dcache if two processes call
> shrink_dcache_parent() on the same dentry.
>
> In Miklos's case, the problem is with the bonding driver but during
> CPU online or offline, a number of dentries are being created and
> deleted and this deadlock is also being hit. Looking at sysfs, there
> is a global sysfs_mutex that protects the sysfs directory tree from
> concurrent reclaims. Almost all operations involving directory inodes
> and dentries take place under the sysfs_mutex - linking, unlinking,
> patch searching lookup, renames and readdir. d_invalidate is slightly
> different. It is mostly under the mutex but if the dentry has to be
> removed from the dcache, the mutex is dropped.

The sysfs_mutex protects the sysfs data structures not the vfs.

> Where as Miklos' patch changes dcache, this patch changes sysfs to
> consistently hold the mutex for dentry-related operations. Once
> applied, this particular bug with CPU hotadd/hotremove no longer
> occurs.

After taking a quick skim over the code to reacquaint myself with
it appears that the usage in sysfs is idiomatic.  That is sysfs
uses shrink_dcache_parent without a lock and in a context where
the right race could trigger this deadlock.

And in particular I expect you could trigger the same deadlock in
proc, nfs, and gfs2 with if you can get the timing right.

I don't think adding a work-around for the bug in shrink_dcache_parent
is going to do anything except hide the bug in the VFS, and
unnecessarily increase the sysfs_mutex hold times.

I may be blind but I don't see a reason at this point to rush out an
incomplete work-around for the bug in shrink_dcahce_parent instead of
actually fixing shrink_dcache_parent.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
