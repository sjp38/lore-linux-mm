Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f45.google.com (mail-ee0-f45.google.com [74.125.83.45])
	by kanga.kvack.org (Postfix) with ESMTP id 74FD36B0031
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 13:13:47 -0500 (EST)
Received: by mail-ee0-f45.google.com with SMTP id b15so1673136eek.18
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 10:13:46 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id s6si9710011eel.140.2014.02.07.10.13.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 07 Feb 2014 10:13:45 -0800 (PST)
Date: Fri, 7 Feb 2014 13:13:32 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] drop_caches: add some documentation and info message
Message-ID: <20140207181332.GG6963@cmpxchg.org>
References: <1391794851-11412-1-git-send-email-hannes@cmpxchg.org>
 <52F51E19.9000406@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52F51E19.9000406@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@sr71.net>, Michal Hocko <mhocko@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Feb 07, 2014 at 12:55:37PM -0500, Rik van Riel wrote:
> On 02/07/2014 12:40 PM, Johannes Weiner wrote:
> 
> >@@ -59,6 +60,9 @@ int drop_caches_sysctl_handler(ctl_table *table, int write,
> >  	if (ret)
> >  		return ret;
> >  	if (write) {
> >+		printk_ratelimited(KERN_INFO "%s (%d): dropped kernel caches: %d\n",
> >+				   current->comm, task_pid_nr(current),
> >+				   sysctl_drop_caches);
> >  		if (sysctl_drop_caches & 1)
> >  			iterate_supers(drop_pagecache_sb, NULL);
> >  		if (sysctl_drop_caches & 2)
> >
> 
> Would it be better to print this after the operation
> has completed?

It would make more sense grammatically :-) Either way is fine with me,
updated below to inform after the fact.

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

Add a bit more documentation about it, and add a little KERN_NOTICE.

[akpm@linux-foundation.org: checkpatch fixes]
Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
Signed-off-by: Michal Hocko <mhocko@suse.cz>
Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 Documentation/sysctl/vm.txt | 33 +++++++++++++++++++++++++++------
 fs/drop_caches.c            |  4 ++++
 2 files changed, 31 insertions(+), 6 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index d614a9b6a280..36278c610a5f 100644
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
+	cat (1234): dropped kernel caches: 3
+
+These are informational only.  They do not mean that anything is wrong
+with your system.
 
 ==============================================================
 
diff --git a/fs/drop_caches.c b/fs/drop_caches.c
index 9fd702f5bfb2..02ae3386e08f 100644
--- a/fs/drop_caches.c
+++ b/fs/drop_caches.c
@@ -5,6 +5,7 @@
 #include <linux/kernel.h>
 #include <linux/mm.h>
 #include <linux/fs.h>
+#include <linux/ratelimit.h>
 #include <linux/writeback.h>
 #include <linux/sysctl.h>
 #include <linux/gfp.h>
@@ -63,6 +64,9 @@ int drop_caches_sysctl_handler(ctl_table *table, int write,
 			iterate_supers(drop_pagecache_sb, NULL);
 		if (sysctl_drop_caches & 2)
 			drop_slab();
+		printk_ratelimited(KERN_INFO "%s (%d): dropped kernel caches: %d\n",
+				   current->comm, task_pid_nr(current),
+				   sysctl_drop_caches);
 	}
 	return 0;
 }
-- 
1.8.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
