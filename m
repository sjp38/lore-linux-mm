Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5610E6B0169
	for <linux-mm@kvack.org>; Mon, 22 Aug 2011 17:40:26 -0400 (EDT)
Date: Mon, 22 Aug 2011 14:39:54 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] vmscan: use atomic-long for shrinker batching
Message-Id: <20110822143954.18c1539c.akpm@linux-foundation.org>
In-Reply-To: <20110822101727.19462.55289.stgit@zurg>
References: <20110822101721.19462.63082.stgit@zurg>
	<20110822101727.19462.55289.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Chinner <david@fromorbit.com>

On Mon, 22 Aug 2011 14:17:27 +0300
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> Use atomic-long operations instead of looping around cmpxchg().
> 

Seems nice.

> diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
> index 790651b..ac6b8ee 100644
> --- a/include/linux/shrinker.h
> +++ b/include/linux/shrinker.h
> @@ -34,7 +34,7 @@ struct shrinker {
>  
>  	/* These are for internal use */
>  	struct list_head list;
> -	long nr;	/* objs pending delete */
> +	atomic_long_t nr_in_batch; /* objs pending delete */
>  };

This makes shrinker.h have a dependency on atomic.h.  shrinker.h is a
strange thing that doesn't include its own dependent header files - the
shrinker.h includer is responsible for that.  And they both need
fixups, for safety's sake:

 include/linux/fs.h |    2 +-
 include/linux/mm.h |    1 +
 2 files changed, 2 insertions(+), 1 deletion(-)

--- a/include/linux/mm.h~vmscan-use-atomic-long-for-shrinker-batching-fix
+++ a/include/linux/mm.h
@@ -10,6 +10,7 @@
 #include <linux/mmzone.h>
 #include <linux/rbtree.h>
 #include <linux/prio_tree.h>
+#include <linux/atomic.h>
 #include <linux/debug_locks.h>
 #include <linux/mm_types.h>
 #include <linux/range.h>
--- a/include/linux/fs.h~vmscan-use-atomic-long-for-shrinker-batching-fix
+++ a/include/linux/fs.h
@@ -394,8 +394,8 @@ struct inodes_stat_t {
 #include <linux/semaphore.h>
 #include <linux/fiemap.h>
 #include <linux/rculist_bl.h>
-#include <linux/shrinker.h>
 #include <linux/atomic.h>
+#include <linux/shrinker.h>
 
 #include <asm/byteorder.h>
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
