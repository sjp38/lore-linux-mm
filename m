Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id CD9736B003D
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 13:27:02 -0500 (EST)
Date: Wed, 4 Feb 2009 19:26:45 +0100
From: Pavel Machek <pavel@suse.cz>
Subject: Re: /proc/sys/vm/drop_caches: add error handling
Message-ID: <20090204182645.GB4797@elf.ucw.cz>
References: <20090203113319.GA2022@elf.ucw.cz> <20090203204456.ECA3.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20090203111447.41e2022c.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090203111447.41e2022c.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi!

> > I think following is clarify more.
> > 
> > 	res = proc_dointvec_minmax(table, write, file, buffer, length, ppos);
> > 	if (res)
> > 		return res;
> > 	if (!write)
> > 		return 0;
> > 	if (sysctl_drop_caches & ~3)
> > 		return -EINVAL;
> > 	if (sysctl_drop_caches & 1)
> > 		drop_pagecache();
> > 	if (sysctl_drop_caches & 2)
> > 		drop_slab();
> > 	return 0;
> > 
> > 
> > otherthings, _very_ looks good to me. :)
> 
> For better or for worse, my intent here was to be
> future-back-compatible.  So if we later add new flags, and people write
> code which uses those new flags, that code won't break on old kernels.

Well, should I move test for &~3 to the end? You'd still get
compatibility, but you'd also get expected error reports.

> Probably that wasn't a very good idea, and such userspace code isn't
> very good.

--- 

Report errors in drop_caches, and document stuff a bit better. 

Signed-off-by: Pavel Machek <pavel@suse.cz>

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 3197fc8..b90f050 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -132,6 +132,10 @@ To free pagecache, dentries and inodes:
 As this is a non-destructive operation and dirty objects are not freeable, the
 user should run `sync' first.
 
+Note that calling this causes some serious latencies, and that this is
+a debug feature; it should not be used for production as it does not
+contain neccessary locking to guarantee safe operation.
+
 ==============================================================
 
 hugepages_treat_as_movable
diff --git a/fs/drop_caches.c b/fs/drop_caches.c
index 3e5637f..f913a64 100644
--- a/fs/drop_caches.c
+++ b/fs/drop_caches.c
@@ -9,8 +9,9 @@
 #include <linux/sysctl.h>
 #include <linux/gfp.h>
 
-/* A global variable is a bit ugly, but it keeps the code simple */
-int sysctl_drop_caches;
+/* A global variable is a bit ugly, and has locking problems,
+   but it keeps the code simple */
+unsigned int sysctl_drop_caches;
 
 static void drop_pagecache_sb(struct super_block *sb)
 {
@@ -65,12 +66,17 @@ static void drop_slab(void)
 int drop_caches_sysctl_handler(ctl_table *table, int write,
 	struct file *file, void __user *buffer, size_t *length, loff_t *ppos)
 {
-	proc_dointvec_minmax(table, write, file, buffer, length, ppos);
-	if (write) {
-		if (sysctl_drop_caches & 1)
-			drop_pagecache();
-		if (sysctl_drop_caches & 2)
-			drop_slab();
-	}
+	int res;
+	res = proc_dointvec_minmax(table, write, file, buffer, length, ppos);
+	if (res)
+		return res;
+	if (!write)
+		return res;
+	if (sysctl_drop_caches & 1)
+		drop_pagecache();
+	if (sysctl_drop_caches & 2)
+		drop_slab();
+	if (sysctl_drop_caches & ~3)
+		return -EINVAL;
 	return 0;
 }


-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
