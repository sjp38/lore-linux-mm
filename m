Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 72FD06B005A
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 16:25:43 -0500 (EST)
Date: Fri, 13 Jan 2012 13:25:40 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 08/11] mm: compaction: Introduce sync-light migration
 for use by compaction
Message-Id: <20120113132540.b2c1b170.akpm@linux-foundation.org>
In-Reply-To: <1323877293-15401-9-git-send-email-mgorman@suse.de>
References: <1323877293-15401-1-git-send-email-mgorman@suse.de>
	<1323877293-15401-9-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Dave Jones <davej@redhat.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Nai Xia <nai.xia@gmail.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 14 Dec 2011 15:41:30 +0000
Mel Gorman <mgorman@suse.de> wrote:

> This patch adds a lightweight sync migrate operation MIGRATE_SYNC_LIGHT
> mode that avoids writing back pages to backing storage. Async
> compaction maps to MIGRATE_ASYNC while sync compaction maps to
> MIGRATE_SYNC_LIGHT. For other migrate_pages users such as memory
> hotplug, MIGRATE_SYNC is used.
> 
> This avoids sync compaction stalling for an excessive length of time,
> particularly when copying files to a USB stick where there might be
> a large number of dirty pages backed by a filesystem that does not
> support ->writepages.
>
> ...
> 
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -525,6 +525,7 @@ enum positive_aop_returns {
>  struct page;
>  struct address_space;
>  struct writeback_control;
> +enum migrate_mode;
>  
>  struct iov_iter {
>  	const struct iovec *iov;
> @@ -614,7 +615,7 @@ struct address_space_operations {
>  	 * is false, it must not block.
>  	 */
>  	int (*migratepage) (struct address_space *,
> -			struct page *, struct page *, bool);
> +			struct page *, struct page *, enum migrate_mode);

I'm getting a huge warning spew from this with my sparc64 gcc-3.4.5. 
I'm not sure why, really.

Forward-declaring an enum in this fashion is problematic because some
compilers (I'm unsure about gcc) use different sizeofs for enums,
depending on the enum's value range.  For example, an enum which only
has values 0...255 can fit into a byte.  (iirc, the compiler actually
put it in a 16-bit storage).

So I propose:

From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm: fix warnings regarding enum migrate_mode

sparc64 allmodconfig:

In file included from include/linux/compat.h:15,
                 from /usr/src/25/arch/sparc/include/asm/siginfo.h:19,
                 from include/linux/signal.h:5,
                 from include/linux/sched.h:73,
                 from arch/sparc/kernel/asm-offsets.c:13:
include/linux/fs.h:618: warning: parameter has incomplete type

It seems that my sparc64 compiler (gcc-3.4.5) doesn't like the forward
declaration of enums.

Fix this by moving the "enum migrate_mode" definition into its own header
file.

Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
Cc: Dave Jones <davej@redhat.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Andy Isaacson <adi@hexapodia.org>
Cc: Nai Xia <nai.xia@gmail.com>
Cc: Johannes Weiner <jweiner@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/fs.h           |    2 +-
 include/linux/migrate.h      |   14 +-------------
 include/linux/migrate_mode.h |   16 ++++++++++++++++
 3 files changed, 18 insertions(+), 14 deletions(-)

diff -puN include/linux/fs.h~mm-fix-warnings-regarding-enum-migrate_mode include/linux/fs.h
--- a/include/linux/fs.h~mm-fix-warnings-regarding-enum-migrate_mode
+++ a/include/linux/fs.h
@@ -10,6 +10,7 @@
 #include <linux/ioctl.h>
 #include <linux/blk_types.h>
 #include <linux/types.h>
+#include <linux/migrate_mode.h>
 
 /*
  * It's silly to have NR_OPEN bigger than NR_FILE, but you can change
@@ -525,7 +526,6 @@ enum positive_aop_returns {
 struct page;
 struct address_space;
 struct writeback_control;
-enum migrate_mode;
 
 struct iov_iter {
 	const struct iovec *iov;
diff -puN include/linux/migrate.h~mm-fix-warnings-regarding-enum-migrate_mode include/linux/migrate.h
--- a/include/linux/migrate.h~mm-fix-warnings-regarding-enum-migrate_mode
+++ a/include/linux/migrate.h
@@ -3,22 +3,10 @@
 
 #include <linux/mm.h>
 #include <linux/mempolicy.h>
+#include <linux/migrate_mode.h>
 
 typedef struct page *new_page_t(struct page *, unsigned long private, int **);
 
-/*
- * MIGRATE_ASYNC means never block
- * MIGRATE_SYNC_LIGHT in the current implementation means to allow blocking
- *	on most operations but not ->writepage as the potential stall time
- *	is too significant
- * MIGRATE_SYNC will block when migrating pages
- */
-enum migrate_mode {
-	MIGRATE_ASYNC,
-	MIGRATE_SYNC_LIGHT,
-	MIGRATE_SYNC,
-};
-
 #ifdef CONFIG_MIGRATION
 #define PAGE_MIGRATION 1
 
diff -puN /dev/null include/linux/migrate_mode.h
--- /dev/null
+++ a/include/linux/migrate_mode.h
@@ -0,0 +1,16 @@
+#ifndef MIGRATE_MODE_H_INCLUDED
+#define MIGRATE_MODE_H_INCLUDED
+/*
+ * MIGRATE_ASYNC means never block
+ * MIGRATE_SYNC_LIGHT in the current implementation means to allow blocking
+ *	on most operations but not ->writepage as the potential stall time
+ *	is too significant
+ * MIGRATE_SYNC will block when migrating pages
+ */
+enum migrate_mode {
+	MIGRATE_ASYNC,
+	MIGRATE_SYNC_LIGHT,
+	MIGRATE_SYNC,
+};
+
+#endif		/* MIGRATE_MODE_H_INCLUDED */
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
