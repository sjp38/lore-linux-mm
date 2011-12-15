Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 605C06B016E
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 03:55:44 -0500 (EST)
Date: Thu, 15 Dec 2011 16:55:41 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH] proc: show readahead state in fdinfo
Message-ID: <20111215085540.GA23966@localhost>
References: <20111129130900.628549879@intel.com>
 <20111129131456.278516066@intel.com>
 <20111129175743.GP24062@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111129175743.GP24062@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Jens Axboe <axboe@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Nov 30, 2011 at 01:57:43AM +0800, Andi Kleen wrote:
> On Tue, Nov 29, 2011 at 09:09:03PM +0800, Wu Fengguang wrote:
> > Record the readahead pattern in ra->pattern and extend the ra_submit()
> > parameters, to be used by the next readahead tracing/stats patches.
> 
> I like this, could it be exported it a bit more formally in /proc for 
> each file descriptor?

How about this?
---
Subject: proc: show readahead state in fdinfo
Date: Thu Dec 15 14:35:56 CST 2011

Append three readahead states to /proc/<PID>/fdinfo/<FD>:

	# cat /proc/self/fdinfo/0
	pos:            0
	flags:          0100002
+	ra_pattern:     initial
+	ra_start:       0		# pages
+	ra_size:        0		# pages

As proposed by Andi: I could imagine a monitoring tool that you run on a
process that tells you what pattern state the various file descriptors
are in and how large the window is.  That would be similar to the tools
for monitoring network connections, which are extremely useful in practice.

CC: Andi Kleen <andi@firstfloor.org>
CC: Miklos Szeredi <mszeredi@suse.cz>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/proc/base.c     |   14 ++++++++++----
 include/linux/fs.h |    1 +
 mm/readahead.c     |    2 +-
 3 files changed, 12 insertions(+), 5 deletions(-)

--- linux-next.orig/fs/proc/base.c	2011-12-15 14:36:04.000000000 +0800
+++ linux-next/fs/proc/base.c	2011-12-15 15:51:35.000000000 +0800
@@ -1885,7 +1885,7 @@ out:
 	return ~0U;
 }
 
-#define PROC_FDINFO_MAX 64
+#define PROC_FDINFO_MAX 128
 
 static int proc_fd_info(struct inode *inode, struct path *path, char *info)
 {
@@ -1920,10 +1920,16 @@ static int proc_fd_info(struct inode *in
 			}
 			if (info)
 				snprintf(info, PROC_FDINFO_MAX,
-					 "pos:\t%lli\n"
-					 "flags:\t0%o\n",
+					 "pos:\t\t%lli\n"
+					 "flags:\t\t0%o\n"
+					 "ra_pattern:\t%s\n"
+					 "ra_start:\t%lu\n"
+					 "ra_size:\t%u\n",
 					 (long long) file->f_pos,
-					 f_flags);
+					 f_flags,
+					 ra_pattern_names[file->f_ra.pattern],
+					 file->f_ra.start,
+					 file->f_ra.size);
 			spin_unlock(&files->file_lock);
 			put_files_struct(files);
 			return 0;
--- linux-next.orig/include/linux/fs.h	2011-12-15 14:36:41.000000000 +0800
+++ linux-next/include/linux/fs.h	2011-12-15 14:36:57.000000000 +0800
@@ -953,6 +953,7 @@ struct file_ra_state {
 
 	loff_t prev_pos;		/* Cache last read() position */
 };
+extern const char * const ra_pattern_names[];
 
 /*
  * Which policy makes decision to do the current read-ahead IO?
--- linux-next.orig/mm/readahead.c	2011-12-15 14:36:28.000000000 +0800
+++ linux-next/mm/readahead.c	2011-12-15 14:36:33.000000000 +0800
@@ -19,7 +19,7 @@
 #include <linux/pagemap.h>
 #include <trace/events/vfs.h>
 
-static const char * const ra_pattern_names[] = {
+const char * const ra_pattern_names[] = {
 	[RA_PATTERN_INITIAL]            = "initial",
 	[RA_PATTERN_SUBSEQUENT]         = "subsequent",
 	[RA_PATTERN_CONTEXT]            = "context",

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
