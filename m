Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id C0A546B0083
	for <linux-mm@kvack.org>; Wed, 15 Feb 2012 18:35:44 -0500 (EST)
Date: Wed, 15 Feb 2012 15:35:37 -0800
From: Arun Sharma <asharma@fb.com>
Subject: Re: [PATCH v5 3/3] fadvise: implement POSIX_FADV_NOREUSE
Message-ID: <20120215233537.GA20724@dev3310.snc6.facebook.com>
References: <1329006098-5454-1-git-send-email-andrea@betterlinux.com>
 <1329006098-5454-4-git-send-email-andrea@betterlinux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1329006098-5454-4-git-send-email-andrea@betterlinux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Righi <andrea@betterlinux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Shaohua Li <shaohua.li@intel.com>, =?iso-8859-1?Q?P=E1draig?= Brady <P@draigBrady.com>, John Stultz <john.stultz@linaro.org>, Jerry James <jamesjer@betterlinux.com>, Julius Plenz <julius@plenz.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Sun, Feb 12, 2012 at 01:21:38AM +0100, Andrea Righi wrote:
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 386da09..624a73e 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -9,6 +9,7 @@
>  #include <linux/limits.h>
>  #include <linux/ioctl.h>
>  #include <linux/blk_types.h>
> +#include <linux/kinterval.h>
>  #include <linux/types.h>

fs.h is an exported header file, whereas kinterval.h is not. So this
fails scripts/header_check.pl.

I used the workaround below.

 -Arun

diff --git a/fs/inode.c b/fs/inode.c
index d27dbee..1335a5f 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -26,6 +26,7 @@
 #include <linux/ima.h>
 #include <linux/cred.h>
 #include <linux/buffer_head.h> /* for inode_has_buffers */
+#include <linux/kinterval.h>
 #include "internal.h"
 
 /*
@@ -279,7 +280,7 @@ void address_space_init_once(struct address_space *mapping)
 	spin_lock_init(&mapping->private_lock);
 	INIT_RAW_PRIO_TREE_ROOT(&mapping->i_mmap);
 	INIT_LIST_HEAD(&mapping->i_mmap_nonlinear);
-	INIT_KINTERVAL_TREE_ROOT(&mapping->nocache_tree);
+	INIT_KINTERVAL_TREE_ROOT((struct rb_root *) &mapping->nocache_tree);
 	rwlock_init(&mapping->nocache_lock);
 }
 EXPORT_SYMBOL(address_space_init_once);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 74b6a97..b4e45e6 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -9,7 +9,6 @@
 #include <linux/limits.h>
 #include <linux/ioctl.h>
 #include <linux/blk_types.h>
-#include <linux/kinterval.h>
 #include <linux/types.h>
 
 /*
@@ -656,7 +655,7 @@ struct address_space {
 	spinlock_t		private_lock;	/* for use by the address_space */
 	struct list_head	private_list;	/* ditto */
 	struct address_space	*assoc_mapping;	/* ditto */
-	struct rb_root		nocache_tree;	/* noreuse cache range tree */
+	void			*nocache_tree;	/* noreuse cache range tree */
 	rwlock_t		nocache_lock;	/* protect the nocache_tree */
 } __attribute__((aligned(sizeof(long))));
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
