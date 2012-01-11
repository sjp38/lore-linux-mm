Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id B6D856B005A
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 13:07:31 -0500 (EST)
Date: Wed, 11 Jan 2012 18:07:23 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/2] fs: sysfs: Do dcache-related updates to sysfs
 dentries under sysfs_mutex
Message-ID: <20120111180723.GF4118@suse.de>
References: <1326276668-19932-1-git-send-email-mgorman@suse.de>
 <1326276668-19932-2-git-send-email-mgorman@suse.de>
 <m1k44y5fls.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <m1k44y5fls.fsf@fess.ebiederm.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Gilad Ben-Yossef <gilad@benyossef.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Miklos Szeredi <mszeredi@novell.com>, Greg KH <gregkh@suse.de>, Gong Chen <gong.chen@intel.com>

On Wed, Jan 11, 2012 at 09:11:27AM -0800, Eric W. Biederman wrote:
> > In Miklos's case, the problem is with the bonding driver but during
> > CPU online or offline, a number of dentries are being created and
> > deleted and this deadlock is also being hit. Looking at sysfs, there
> > is a global sysfs_mutex that protects the sysfs directory tree from
> > concurrent reclaims. Almost all operations involving directory inodes
> > and dentries take place under the sysfs_mutex - linking, unlinking,
> > patch searching lookup, renames and readdir. d_invalidate is slightly
> > different. It is mostly under the mutex but if the dentry has to be
> > removed from the dcache, the mutex is dropped.
> 
> The sysfs_mutex protects the sysfs data structures not the vfs.
> 

Ok.

> > Where as Miklos' patch changes dcache, this patch changes sysfs to
> > consistently hold the mutex for dentry-related operations. Once
> > applied, this particular bug with CPU hotadd/hotremove no longer
> > occurs.
> 
> After taking a quick skim over the code to reacquaint myself with
> it appears that the usage in sysfs is idiomatic.  That is sysfs
> uses shrink_dcache_parent without a lock and in a context where
> the right race could trigger this deadlock.
> 

Yes.

> And in particular I expect you could trigger the same deadlock in
> proc, nfs, and gfs2 with if you can get the timing right.
> 

Agreed. When the dcache-specific fix was being discussed on an external
bugzilla, this came up. It's probably easiest to race in sysfs because
it's possible to create/delete directories faster than is possible
for proc, nfs or gfs2.

> I don't think adding a work-around for the bug in shrink_dcache_parent
> is going to do anything except hide the bug in the VFS, and
> unnecessarily increase the sysfs_mutex hold times.
> 

Ok.

> I may be blind but I don't see a reason at this point to rush out an
> incomplete work-around for the bug in shrink_dcahce_parent instead of
> actually fixing shrink_dcache_parent.
> 

Since I wrote this patch, the dcache specific fix was finished, merged
and I expect it'll make it to stable. Assuming that happens, this patch
will no longer be required.

Thanks Eric.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
