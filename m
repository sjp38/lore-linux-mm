Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 16DB16B0033
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 10:58:44 -0400 (EDT)
Date: Tue, 30 Jul 2013 16:58:34 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] hugetlb: fix lockdep splat caused by pmd sharing
Message-ID: <20130730145834.GA32226@laptop.programming.kicks-ass.net>
References: <20130730142957.GG15847@dhcp22.suse.cz>
 <1375195560-23888-1-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1375195560-23888-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Jul 30, 2013 at 04:46:00PM +0200, Michal Hocko wrote:
> which is a false positive caused by hugetlb pmd sharing code which
> allocates a new pmd from withing mappint->i_mmap_mutex. If this
> allocation causes reclaim then the lockdep detector complains that we
> might self-deadlock.
> 
> This is not correct though, because hugetlb pages are not reclaimable so
> their mapping will be never touched from the reclaim path.
> 
> The patch tells lockup detector that hugetlb i_mmap_mutex is special
> by assigning it a separate lockdep class so it won't report possible
> deadlocks on unrelated mappings.
> 
> Reported-by: Dave Jones <davej@redhat.com>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---
>  fs/hugetlbfs/inode.c | 8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index a3f868a..230533d 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -463,6 +463,12 @@ static struct inode *hugetlbfs_get_root(struct super_block *sb,
>  	return inode;
>  }
>  
> +/*
> + * Now, reclaim path never holds hugetlbfs_inode->i_mmap_mutex while it could
> + * hold normal inode->i_mmap_mutex so this annotation avoids a lockdep splat.

How about something like:

/*
 * Hugetlbfs is not reclaimable; therefore its i_mmap_mutex will never
 * be taken from reclaim -- unlike regular filesystems. This needs an
 * annotation because huge_pmd_share() does an allocation under
 * i_mmap_mutex.
 */

It clarifies the exact conditions and makes easier to verify the
validity of the annotation.

> + */
> +struct lock_class_key hugetlbfs_i_mmap_mutex_key;
> +
>  static struct inode *hugetlbfs_get_inode(struct super_block *sb,
>  					struct inode *dir,
>  					umode_t mode, dev_t dev)
> @@ -474,6 +480,8 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb,
>  		struct hugetlbfs_inode_info *info;
>  		inode->i_ino = get_next_ino();
>  		inode_init_owner(inode, dir, mode);
> +		lockdep_set_class(&inode->i_mapping->i_mmap_mutex,
> +				&hugetlbfs_i_mmap_mutex_key);
>  		inode->i_mapping->a_ops = &hugetlbfs_aops;
>  		inode->i_mapping->backing_dev_info =&hugetlbfs_backing_dev_info;
>  		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
> -- 
> 1.8.3.2
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
