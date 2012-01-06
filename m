Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id A99426B004F
	for <linux-mm@kvack.org>; Fri,  6 Jan 2012 09:09:13 -0500 (EST)
Date: Fri, 6 Jan 2012 14:09:09 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH v5 7/8] mm: Only IPI CPUs to drain local pages if they
 exist
Message-ID: <20120106140909.GI27881@csn.ul.ie>
References: <1325499859-2262-1-git-send-email-gilad@benyossef.com>
 <1325499859-2262-8-git-send-email-gilad@benyossef.com>
 <4F033EC9.4050909@gmail.com>
 <20120105142017.GA27881@csn.ul.ie>
 <20120105144011.GU11810@n2100.arm.linux.org.uk>
 <20120105161739.GD27881@csn.ul.ie>
 <20120105163529.GA11810@n2100.arm.linux.org.uk>
 <20120105183504.GF2393@linux.vnet.ibm.com>
 <20120105222116.GF27881@csn.ul.ie>
 <20120106132847.GA9279@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120106132847.GA9279@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@suse.de>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Gilad Ben-Yossef <gilad@benyossef.com>, linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>

On Fri, Jan 06, 2012 at 05:28:47AM -0800, Greg KH wrote:
> > <SNIP>
> > 
> > I'm not overly clear on how VFS locking is meant to work but it almost
> > looks as if the last reference to an inode is being dropped during a
> > sysfs path lookup. Is that meant to happen?
> > 
> > Judging by sysfs_dentry_revalidate() - possibly not. It looks like
> > we must have reached out_bad: and called shrink_dcache_parent() on a
> > dentry that was already locked by the running process. Not sure how
> > this could have happened - Greg, does this look familiar?
> 
> I don't know.  I'm working with some others who are trying to trace down
> a sysfs lockup bug when files go away and are created very quickly and
> userspace tries to stat them, but I'm not quite sure this is the same
> issue or not.
> 

It seems similar.

> Are these sysfs files being removed that you are having problems with?
> 

Yes, considering that cpu hot-remove is happening around the same time
which results in sysfs files and directories being removed. I'm
currently testing the following patch in conjunction with a page
allocator fix. It's still running after 5 hours which is good but will
take some time to complete.

This patch is part of a short series I planned to post on Monday if
tests complete successfully. The changelog has an ample amount of
guesswork in there.

---8<---
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] fs: sysfs: Do dcache-related updates to sysfs dentries under sysfs_mutex

While running a CPU hotplug stress test under memory pressure, a
spinlock lockup was detected due to what looks like sysfs recursively
taking a lock on a dentry. When this happens varies considerably
and is difficult to trigger.

[  482.345588] BUG: spinlock lockup on CPU#2, udevd/4400
[  482.345590]  lock: ffff8803075be0d0, .magic: dead4ead, .owner: udevd/5689, .owner_cpu: 0
[  482.345592] Pid: 4400, comm: udevd Not tainted 3.2.0-vanilla #1
[  482.345592] Call Trace:
[  482.345595]  [<ffffffff811e4ffd>] spin_dump+0x88/0x8d
[  482.345597]  [<ffffffff811e5186>] do_raw_spin_lock+0xd6/0xf9
[  482.345599]  [<ffffffff813454e1>] _raw_spin_lock+0x39/0x3d
[  482.345601]  [<ffffffff811396b6>] ? shrink_dcache_parent+0x77/0x28c
[  482.345603]  [<ffffffff811396b6>] shrink_dcache_parent+0x77/0x28c
[  482.345605]  [<ffffffff811373a9>] ? have_submounts+0x13e/0x1bd
[  482.345607]  [<ffffffff811858f8>] sysfs_dentry_revalidate+0xaa/0xbe
[  482.345608]  [<ffffffff8112e6bd>] do_lookup+0x263/0x2fc
[  482.345610]  [<ffffffff8119c99b>] ? security_inode_permission+0x1e/0x20
[  482.345612]  [<ffffffff8112f2c9>] link_path_walk+0x1e2/0x763
[  482.345614]  [<ffffffff8112fcf2>] path_lookupat+0x5c/0x61a
[  482.345616]  [<ffffffff810f479c>] ? might_fault+0x89/0x8d
[  482.345618]  [<ffffffff810f4753>] ? might_fault+0x40/0x8d
[  482.345619]  [<ffffffff811302da>] do_path_lookup+0x2a/0xa8
[  482.345621]  [<ffffffff811329dd>] user_path_at_empty+0x5d/0x97
[  482.345623]  [<ffffffff8107441b>] ? trace_hardirqs_off+0xd/0xf
[  482.345625]  [<ffffffff81345bcf>] ? _raw_spin_unlock_irqrestore+0x44/0x5a
[  482.345627]  [<ffffffff81132a28>] user_path_at+0x11/0x13
[  482.345629]  [<ffffffff81128af0>] vfs_fstatat+0x44/0x71
[  482.345631]  [<ffffffff81128b7b>] vfs_lstat+0x1e/0x20
[  482.345632]  [<ffffffff81128b9c>] sys_newlstat+0x1f/0x40
[  482.345634]  [<ffffffff81075944>] ? trace_hardirqs_on_caller+0x12d/0x164
[  482.345636]  [<ffffffff811e04fe>] ?  trace_hardirqs_on_thunk+0x3a/0x3f
[  482.345638]  [<ffffffff8107441b>] ? trace_hardirqs_off+0xd/0xf
[  482.345640]  [<ffffffff8134d002>] system_call_fastpath+0x16/0x1b
[  482.515004]  [<ffffffff8107441b>] ? trace_hardirqs_off+0xd/0xf
[  482.520870]  [<ffffffff8134d002>] system_call_fastpath+0x16/0x1b

At this point, CPU hotplug stops and other processes get stuck in a
similar deadlock waiting for 5689 to unlock. RCU reports stalls but
it is collateral damage.

Most of the deadlocked processes have sysfs_dentry_revalidate()
in common and while the cause of the deadlock is unclear to me, it
feels like a race between udev receiving an fsnotify for cpuonline
versus udev receiving another fsnotify for cpuoffline.

During online or offline, a number of dentries are being created and
deleted. udev is receiving fsnotifies of the activity. I suspect what
is happening is due to insufficient locking that one of the fsnotifies
operates on a dentry that is in the process of being dropped from
dcache. Looking at sysfs, it looks like there is a global sysfs_mutex
that protects the sysfs directory tree from concurrent reclaims. Almost
all operations involving directory inodes and dentries take place
under the sysfs_mutex - linking, unlinking, patch searching lookup,
renames and readdir.

d_invalidate is slightly different. It is mostly under the mutex but
if the dentry has to be removed from the dcache, the mutex is dropped.
This patch holds the mutex for the dcache operation to protect the
dentry from concurrent operations while it is being dropped. Once
applied, this particular bug no longer occurs.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 fs/sysfs/dir.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/sysfs/dir.c b/fs/sysfs/dir.c
index 7fdf6a7..acaf21d 100644
--- a/fs/sysfs/dir.c
+++ b/fs/sysfs/dir.c
@@ -279,8 +279,8 @@ static int sysfs_dentry_revalidate(struct dentry *dentry, struct nameidata *nd)
 	if (strcmp(dentry->d_name.name, sd->s_name) != 0)
 		goto out_bad;
 
-	mutex_unlock(&sysfs_mutex);
 out_valid:
+	mutex_unlock(&sysfs_mutex);
 	return 1;
 out_bad:
 	/* Remove the dentry from the dcache hashes.
@@ -294,7 +294,6 @@ out_bad:
 	 * to the dcache hashes.
 	 */
 	is_dir = (sysfs_type(sd) == SYSFS_DIR);
-	mutex_unlock(&sysfs_mutex);
 	if (is_dir) {
 		/* If we have submounts we must allow the vfs caches
 		 * to lie about the state of the filesystem to prevent
@@ -305,6 +304,7 @@ out_bad:
 		shrink_dcache_parent(dentry);
 	}
 	d_drop(dentry);
+	mutex_unlock(&sysfs_mutex);
 	return 0;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
