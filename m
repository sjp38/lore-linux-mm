Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id D41896B0044
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 21:31:23 -0400 (EDT)
Date: Fri, 24 Aug 2012 11:31:18 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 3/3] HWPOISON: prevent inode cache removal to keep
 AS_HWPOISON sticky
Message-ID: <20120824013118.GZ19235@dastard>
References: <1345648655-4497-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1345648655-4497-4-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1345648655-4497-4-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi.kleen@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Rik van Riel <riel@redhat.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Aug 22, 2012 at 11:17:35AM -0400, Naoya Horiguchi wrote:
> "HWPOISON: report sticky EIO for poisoned file" still has a corner case
> where we have possibilities of data lost. This is because in this fix
> AS_HWPOISON is cleared when the inode cache is dropped.
> 
> For example, consider an application in which a process periodically
> (every 10 minutes) writes some logs on a file (and closes it after
> each writes,) and at the end of each day some batch programs run using
> the log file. If a memory error hits on dirty pagecache of this log file
> just after periodic write/close and the inode cache is cleared before the
> next write, then this application is not aware of the error and the batch
> programs will work wrongly.
> 
> To avoid this, this patch makes us pin the hwpoisoned inode on memory
> until we remove or completely truncate the hwpoisoned file.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  fs/inode.c              | 12 ++++++++++++
>  include/linux/pagemap.h | 11 +++++++++++
>  mm/memory-failure.c     |  2 +-
>  mm/truncate.c           |  2 ++
>  4 files changed, 26 insertions(+), 1 deletion(-)
> 
> diff --git v3.6-rc1.orig/fs/inode.c v3.6-rc1/fs/inode.c
> index ac8d904..8742397 100644
> --- v3.6-rc1.orig/fs/inode.c
> +++ v3.6-rc1/fs/inode.c
> @@ -717,6 +717,15 @@ void prune_icache_sb(struct super_block *sb, int nr_to_scan)
>  		}
>  
>  		/*
> +		 * Keep inode caches on memory for user processes to certainly
> +		 * be aware of memory errors.
> +		 */
> +		if (unlikely(mapping_hwpoison(inode->i_mapping))) {
> +			spin_unlock(&inode->i_lock);
> +			continue;
> +		}
> +
> +		/*
>  		 * Referenced or dirty inodes are still in use. Give them
>  		 * another pass through the LRU as we canot reclaim them now.
>  		 */

I don't think you tested this at all. Have a look at what the loop
does more closely - inodes with poisoned mappings will get stuck
and reclaim doesn't make progress past them.

I think you also need to document this inode lifecycle change....

> diff --git v3.6-rc1.orig/mm/truncate.c v3.6-rc1/mm/truncate.c
> index 75801ac..82a994f 100644
> --- v3.6-rc1.orig/mm/truncate.c
> +++ v3.6-rc1/mm/truncate.c
> @@ -574,6 +574,8 @@ void truncate_setsize(struct inode *inode, loff_t newsize)
>  
>  	oldsize = inode->i_size;
>  	i_size_write(inode, newsize);
> +	if (unlikely(mapping_hwpoison(inode->i_mapping) && !newsize))
> +		mapping_clear_hwpoison(inode->i_mapping);

So only a truncate to zero size will clear the poison flag?

What happens if it is the last page in the mapping that is poisoned,
and we truncate that away? Shouldn't that clear the poisoned bit?
What about a hole punch over the poisoned range?

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
