Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 0AF086B00E8
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 01:12:50 -0400 (EDT)
Date: Mon, 19 Mar 2012 13:07:28 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH 3/4] writeback: Refactor writeback_single_inode()
Message-ID: <20120319050728.GA5191@localhost>
References: <1331283748-12959-1-git-send-email-jack@suse.cz>
 <1331283748-12959-4-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1331283748-12959-4-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Fri, Mar 09, 2012 at 10:02:27AM +0100, Jan Kara wrote:
> The code in writeback_single_inode() is relatively complex. The list
> requeing logic makes sense only for flusher thread but not really for
> sync_inode() or write_inode_now() callers. Also when we want to get
> rid of inode references held by flusher thread, we will need a special
> I_SYNC handling there.
> 
> So separate part of writeback_single_inode() which does the real writeback work
> into __writeback_single_inode(). Make writeback_single_inode() do only stuff
> necessary for callers writing only one inode, and move the special list
> handling into writeback_sb_inodes() and a helper function inode_wb_requeue().
> 
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>  fs/fs-writeback.c                |  264 +++++++++++++++++++++-----------------
>  include/trace/events/writeback.h |   36 ++++-
>  2 files changed, 174 insertions(+), 126 deletions(-)
> 
> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c

> +
> +	ret = __writeback_single_inode(inode, wb, wbc);
> +
> +	spin_lock(&wb->list_lock);
> +	spin_lock(&inode->i_lock);
> +	if (inode->i_state & I_FREEING)
> +		goto out_unlock;
> +	if (inode->i_state & I_DIRTY)
> +		redirty_tail(inode, wb);
> +	else
> +		list_del_init(&inode->i_wb_list);

It seems that the above redirty_tail() and hence I_FREEING check can
be eliminated? writeback_single_inode() does not need to deal with wb
list requeue now, but only need to care about dequeue.

The patch looks fine otherwise.

> +out_unlock:
>  	inode_sync_complete(inode);
> -	trace_writeback_single_inode(inode, wbc, nr_to_write);
> +	spin_unlock(&inode->i_lock);
> +	spin_unlock(&wb->list_lock);
> +
>  	return ret;
>  }
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
