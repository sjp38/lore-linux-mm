Message-ID: <45B81E5B.1090505@google.com>
Date: Wed, 24 Jan 2007 19:04:59 -0800
From: Ethan Solomita <solo@google.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/5] Add a map to to track dirty pages per node
References: <20070123185242.2640.8367.sendpatchset@schroedinger.engr.sgi.com> <20070123185248.2640.87514.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070123185248.2640.87514.sendpatchset@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, Paul Menage <menage@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Paul Jackson <pj@sgi.com>, Dave Chinner <dgc@sgi.com>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

Do we want this even with WB_SYNC_ALL and WB_SYNC_HOLD? It seems that 
callers from sync_inodes_sb(), which are the ones that pass in those 
options, may want to know that everything is written.
    -- Ethan


Christoph Lameter wrote:
> Index: linux-2.6.20-rc5/fs/fs-writeback.c
> ===================================================================
> --- linux-2.6.20-rc5.orig/fs/fs-writeback.c	2007-01-22 13:31:30.440219103 -0600
> +++ linux-2.6.20-rc5/fs/fs-writeback.c	2007-01-23 12:21:44.669179863 -0600
> @@ -22,6 +22,7 @@
>  #include <linux/blkdev.h>
>  #include <linux/backing-dev.h>
>  #include <linux/buffer_head.h>
> +#include <linux/cpuset.h>
>  #include "internal.h"
>  
>  /**
> @@ -349,6 +350,12 @@ sync_sb_inodes(struct super_block *sb, s
>  			continue;		/* blockdev has wrong queue */
>  		}
>  
> +		if (!cpuset_intersects_dirty_nodes(mapping, wbc->nodes)) {
> +			/* No pages on the nodes under writeback */
> +			list_move(&inode->i_list, &sb->s_dirty);
> +			continue;
> +		}
> +
>  		/* Was this inode dirtied after sync_sb_inodes was called? */
>  		if (time_after(inode->dirtied_when, start))
>  			break;
>   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
