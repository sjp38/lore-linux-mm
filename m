Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id 4D6E26B0031
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 16:54:40 -0500 (EST)
Received: by mail-ee0-f47.google.com with SMTP id d49so3210880eek.20
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 13:54:39 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id x7si28497417eef.135.2014.02.10.13.54.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 10 Feb 2014 13:54:38 -0800 (PST)
Date: Mon, 10 Feb 2014 16:54:16 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] drop_caches: add some documentation and info message
Message-ID: <20140210215416.GK6963@cmpxchg.org>
References: <1391794851-11412-1-git-send-email-hannes@cmpxchg.org>
 <52F51E19.9000406@redhat.com>
 <20140207181332.GG6963@cmpxchg.org>
 <20140207123129.84f9fb0aaf32f0e09c78851a@linux-foundation.org>
 <20140207212601.GI6963@cmpxchg.org>
 <20140210125102.86de67241664da038676af7d@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140210125102.86de67241664da038676af7d@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Dave Hansen <dave@sr71.net>, Michal Hocko <mhocko@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Feb 10, 2014 at 12:51:02PM -0800, Andrew Morton wrote:
> On Fri, 7 Feb 2014 16:26:01 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > On Fri, Feb 07, 2014 at 12:31:29PM -0800, Andrew Morton wrote:
> > > On Fri, 7 Feb 2014 13:13:32 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:
> > > 
> > > > @@ -63,6 +64,9 @@ int drop_caches_sysctl_handler(ctl_table *table, int write,
> > > >  			iterate_supers(drop_pagecache_sb, NULL);
> > > >  		if (sysctl_drop_caches & 2)
> > > >  			drop_slab();
> > > > +		printk_ratelimited(KERN_INFO "%s (%d): dropped kernel caches: %d\n",
> > > > +				   current->comm, task_pid_nr(current),
> > > > +				   sysctl_drop_caches);
> > > >  	}
> > > >  	return 0;
> > > >  }
> > > 
> > > My concern with this is that there may be people whose
> > > other-party-provided software uses drop_caches.  Their machines will
> > > now sit there emitting log messages and there's nothing they can do
> > > about it, apart from whining at their vendors.
> > 
> > Ironically, we have a customer that is complaining that we currently
> > do not log these events, and they want to know who in their stack is
> > being idiotic.
> 
> Right.  But if we release a kernel which goes blah on every write to
> drop_caches, that customer has logs full of blahs which they are
> now totally uninterested in.
> 
> > > We could do something like this?
> > 
> > They can already change the log level.
> 
> Suppressing unrelated things...
> 
> >  The below will suppress
> > valuable debugging information in a way that still results in
> > inconspicuous looking syslog excerpts, which somewhat undermines the
> > original motivation for this change.
> 
> Yes, somewhat.  It is a compromise. You can see my concern here?

How about this: we allow disabling the log message, but print the line
of the disabling call so it's clear who dunnit.  To make sure valuable
info is not missing in bug reports, add counters for the two events in
/proc/vmstat.

Does that sound acceptable?

---
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Fri, 12 Oct 2012 14:30:54 +0200
Subject: [patch] drop_caches: add some documentation and info message

There is plenty of anecdotal evidence and a load of blog posts
suggesting that using "drop_caches" periodically keeps your system
running in "tip top shape".  Perhaps adding some kernel documentation
will increase the amount of accurate data on its use.

If we are not shrinking caches effectively, then we have real bugs.
Using drop_caches will simply mask the bugs and make them harder to
find, but certainly does not fix them, nor is it an appropriate
"workaround" to limit the size of the caches.  On the contrary, there
have been bug reports on issues that turned out to be misguided use of
cache dropping.

Dropping caches is a very drastic and disruptive operation that is
good for debugging and running tests, but if it creates bug reports
from production use, kernel developers should be aware of its use.

Add a bit more documentation about it, a syslog message to track down
abusers, and vmstat drop counters to help analyze problem reports.

[akpm@linux-foundation.org: checkpatch fixes]
Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
Signed-off-by: Michal Hocko <mhocko@suse.cz>
Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 Documentation/sysctl/vm.txt   | 33 +++++++++++++++++++++++++++------
 fs/drop_caches.c              | 16 ++++++++++++++--
 include/linux/vm_event_item.h |  1 +
 kernel/sysctl.c               |  4 ++--
 mm/vmstat.c                   |  3 +++
 5 files changed, 47 insertions(+), 10 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index d614a9b6a280..e7e544bc4ead 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -175,18 +175,39 @@ Setting this to zero disables periodic writeback altogether.
 
 drop_caches
 
-Writing to this will cause the kernel to drop clean caches, dentries and
-inodes from memory, causing that memory to become free.
+Writing to this will cause the kernel to drop clean caches, as well as
+reclaimable slab objects like dentries and inodes.  Once dropped, their
+memory becomes free.
 
 To free pagecache:
 	echo 1 > /proc/sys/vm/drop_caches
-To free dentries and inodes:
+To free reclaimable slab objects (includes dentries and inodes):
 	echo 2 > /proc/sys/vm/drop_caches
-To free pagecache, dentries and inodes:
+To free slab objects and pagecache:
 	echo 3 > /proc/sys/vm/drop_caches
 
-As this is a non-destructive operation and dirty objects are not freeable, the
-user should run `sync' first.
+This is a non-destructive operation and will not free any dirty objects.
+To increase the number of objects freed by this operation, the user may run
+`sync' prior to writing to /proc/sys/vm/drop_caches.  This will minimize the
+number of dirty objects on the system and create more candidates to be
+dropped.
+
+This file is not a means to control the growth of the various kernel caches
+(inodes, dentries, pagecache, etc...)  These objects are automatically
+reclaimed by the kernel when memory is needed elsewhere on the system.
+
+Use of this file can cause performance problems.  Since it discards cached
+objects, it may cost a significant amount of I/O and CPU to recreate the
+dropped objects, especially if they were under heavy use.  Because of this,
+use outside of a testing or debugging environment is not recommended.
+
+You may see informational messages in your kernel log when this file is
+used:
+
+	cat (1234): drop_caches: 3
+
+These are informational only.  They do not mean that anything is wrong
+with your system.  To disable them, echo 4 (bit 3) into drop_caches.
 
 ==============================================================
 
diff --git a/fs/drop_caches.c b/fs/drop_caches.c
index 9fd702f5bfb2..9280202e488c 100644
--- a/fs/drop_caches.c
+++ b/fs/drop_caches.c
@@ -59,10 +59,22 @@ int drop_caches_sysctl_handler(ctl_table *table, int write,
 	if (ret)
 		return ret;
 	if (write) {
-		if (sysctl_drop_caches & 1)
+		static int stfu;
+
+		if (sysctl_drop_caches & 1) {
 			iterate_supers(drop_pagecache_sb, NULL);
-		if (sysctl_drop_caches & 2)
+			count_vm_event(DROP_PAGECACHE);
+		}
+		if (sysctl_drop_caches & 2) {
 			drop_slab();
+			count_vm_event(DROP_SLAB);
+		}
+		if (!stfu) {
+			pr_info("%s (%d): drop_caches: %d\n",
+				current->comm, task_pid_nr(current),
+				sysctl_drop_caches);
+		}
+		stfu |= sysctl_drop_caches & 4;
 	}
 	return 0;
 }
diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index c557c6d096de..99a7d0e71f8c 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -37,6 +37,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		PGINODESTEAL, SLABS_SCANNED, KSWAPD_INODESTEAL,
 		KSWAPD_LOW_WMARK_HIT_QUICKLY, KSWAPD_HIGH_WMARK_HIT_QUICKLY,
 		PAGEOUTRUN, ALLOCSTALL, PGROTATED,
+		DROP_PAGECACHE, DROP_SLAB,
 #ifdef CONFIG_NUMA_BALANCING
 		NUMA_PTE_UPDATES,
 		NUMA_HUGE_PTE_UPDATES,
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 49e13e1f8fe6..4b0e0857b4b8 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -126,7 +126,7 @@ static int __maybe_unused neg_one = -1;
 static int zero;
 static int __maybe_unused one = 1;
 static int __maybe_unused two = 2;
-static int __maybe_unused three = 3;
+static int __maybe_unused four = 4;
 static unsigned long one_ul = 1;
 static int one_hundred = 100;
 #ifdef CONFIG_PRINTK
@@ -1283,7 +1283,7 @@ static struct ctl_table vm_table[] = {
 		.mode		= 0644,
 		.proc_handler	= drop_caches_sysctl_handler,
 		.extra1		= &one,
-		.extra2		= &three,
+		.extra2		= &four,
 	},
 #ifdef CONFIG_COMPACTION
 	{
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 72496140ac08..7887588ce8f8 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -810,6 +810,9 @@ const char * const vmstat_text[] = {
 
 	"pgrotated",
 
+	"drop_pagecache",
+	"drop_slab",
+
 #ifdef CONFIG_NUMA_BALANCING
 	"numa_pte_updates",
 	"numa_huge_pte_updates",
-- 
1.8.5.3


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
