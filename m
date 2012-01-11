Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 948BE6B005C
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 05:11:15 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [RFC PATCH 0/2] Improve reliability of CPU hotplug
Date: Wed, 11 Jan 2012 10:11:06 +0000
Message-Id: <1326276668-19932-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Gilad Ben-Yossef <gilad@benyossef.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Miklos Szeredi <mszeredi@novell.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Greg KH <gregkh@suse.de>, Gong Chen <gong.chen@intel.com>, Mel Gorman <mgorman@suse.de>

Recent stress tests doing CPU online/offline in a loop revealed at
least two separate bugs. They result in CPUs either being deadlocked on
a spinlock or the machine halting entirely. My reproduction case used
a large numbers of simultaneous kernel compiles on an 8-core machine
while CPUs were continually being brought online and offline in a
loop.

This small series includes two patches that allow hotplug stress tests
to pass for me when applied to 3.2.  This does not claim to solve
all CPU hotplug problems.  For example, the test configuration did
not have PREEMPT enabled but there is no harm in eliminating these
bugs at least.

Patch 1 looks at a sysfs dirent problem whereby under stress a dentry
	lock is taken twice. This is a sysfs-specific test but a dcache
	related fix also exists as an RFC.

Patch 2 notes that the page allocator is sending IPIs without calling
	get_online_cpus() to protect the cpuonline mask from changes.
	In low memory situations, this allows an IPI to be sent to a
	CPU going offline. This patch fixes drain_all_pages() and then
	changes the page allocator to only drain local lists with
	preempt disabled instead of sending an IPI on the grounds the
	IPI costs while having a marginal benefit.

 fs/sysfs/dir.c  |    4 ++--
 mm/page_alloc.c |   16 ++++++++++++----
 2 files changed, 14 insertions(+), 6 deletions(-)

-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
