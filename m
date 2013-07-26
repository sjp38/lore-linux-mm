Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 424AF6B0031
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 08:44:39 -0400 (EDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH resend] drop_caches: add some documentation and info message
Date: Fri, 26 Jul 2013 14:44:29 +0200
Message-Id: <1374842669-22844-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, kosaki.motohiro@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, bp@suse.de, Dave Hansen <dave@linux.vnet.ibm.com>

I would like to resurrect Dave's patch.  It was originally posted here
https://lkml.org/lkml/2010/9/16/250 and I have resurrected it here
https://lkml.org/lkml/2012/10/12/175 for the first time. There didn't
seem to be any strong opposition but the patch has been dropped later
from the mm tree.

To summarize concerns:
Kosaki was worried about possible excessive logging when somebody drops
caches too often (but then he claimed he didn't have a strong opinion on
that) and later acked the patch (https://lkml.org/lkml/2012/10/12/350).
I would even dare to say opposite. If somebody drops caches too often
then I would really like to know that from the log when supporting a
system because it almost for sure means that there is something fishy
going on. It is also worth mentioning that only root can write drop
caches so this is not an flooding attack vector.

Andrew was worried (http://lkml.indiana.edu/hypermail/linux/kernel/1210.3/00605.html)
about people hating us because they are using this as a solution to
their issues. I concur that most of those are just hacks that found
their way into scripts looong time agon and stayed there. We should
rather not feed these cargo cults and rather fix the real bugs. History
has been showing us that users are usually getting rid of old hacks when
something starts screeming at them. So let's screem.

Boris then noted (http://lkml.indiana.edu/hypermail/linux/kernel/1210.3/00659.html)
that he is using drop_caches to make s2ram faster but as others noted
this just adds the overhead to the resume path so it might work only for
certain use cases. Having a low priority message under such conditions
shouldn't such a big deal.

I am bringing the patch up again because this has proved being really
helpful when chasing strange performance issues which (surprise
surprise) turn out to be related to artificially dropped caches done
because the admin thinks this would help... So mostly those who support
machines which are not in their hands would benefit from such a change.

I have just refreshed the original patch on top of the current mm tree
and lowered priority to KERN_INFO to make the message less hysterical.

: From: Dave Hansen <dave@linux.vnet.ibm.com>
: Date: Fri, 12 Oct 2012 14:30:54 +0200
:
: There is plenty of anecdotal evidence and a load of blog posts
: suggesting that using "drop_caches" periodically keeps your system
: running in "tip top shape".  Perhaps adding some kernel
: documentation will increase the amount of accurate data on its use.
:
: If we are not shrinking caches effectively, then we have real bugs.
: Using drop_caches will simply mask the bugs and make them harder
: to find, but certainly does not fix them, nor is it an appropriate
: "workaround" to limit the size of the caches.
:
: It's a great debugging tool, and is really handy for doing things
: like repeatable benchmark runs.  So, add a bit more documentation
: about it, and add a little KERN_NOTICE.  It should help developers
: who are chasing down reclaim-related bugs.

[mhocko@suse.cz: refreshed to current -mm tree]
[akpm@linux-foundation.org: checkpatch fixes]
Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
Signed-off-by: Michal Hocko <mhocko@suse.cz>
Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 Documentation/sysctl/vm.txt | 33 +++++++++++++++++++++++++++------
 fs/drop_caches.c            |  2 ++
 2 files changed, 29 insertions(+), 6 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 36ecc26..15d341a 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -169,18 +169,39 @@ Setting this to zero disables periodic writeback altogether.
 
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
+	cat (1234): dropped kernel caches: 3
+
+These are informational only.  They do not mean that anything is wrong
+with your system.
 
 ==============================================================
 
diff --git a/fs/drop_caches.c b/fs/drop_caches.c
index 9fd702f..c3f44e7 100644
--- a/fs/drop_caches.c
+++ b/fs/drop_caches.c
@@ -59,6 +59,8 @@ int drop_caches_sysctl_handler(ctl_table *table, int write,
 	if (ret)
 		return ret;
 	if (write) {
+		printk(KERN_INFO "%s (%d): dropped kernel caches: %d\n",
+		       current->comm, task_pid_nr(current), sysctl_drop_caches);
 		if (sysctl_drop_caches & 1)
 			iterate_supers(drop_pagecache_sb, NULL);
 		if (sysctl_drop_caches & 2)
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
