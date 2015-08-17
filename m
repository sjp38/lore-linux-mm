Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 52C726B0255
	for <linux-mm@kvack.org>; Mon, 17 Aug 2015 19:44:36 -0400 (EDT)
Received: by pdrh1 with SMTP id h1so61508511pdr.0
        for <linux-mm@kvack.org>; Mon, 17 Aug 2015 16:44:35 -0700 (PDT)
Received: from mail-pd0-x22c.google.com (mail-pd0-x22c.google.com. [2607:f8b0:400e:c02::22c])
        by mx.google.com with ESMTPS id zc8si26972922pac.59.2015.08.17.16.44.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Aug 2015 16:44:35 -0700 (PDT)
Received: by pdob1 with SMTP id b1so5426121pdo.2
        for <linux-mm@kvack.org>; Mon, 17 Aug 2015 16:44:35 -0700 (PDT)
Date: Mon, 17 Aug 2015 16:43:13 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] shmem: recalculate file inode when fstat
In-Reply-To: <1436558977-31712-1-git-send-email-yuzhao@google.com>
Message-ID: <alpine.LSU.2.11.1508171628280.2945@eggly.anvils>
References: <1436558977-31712-1-git-send-email-yuzhao@google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu Zhao <yuzhao@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 10 Jul 2015, Yu Zhao wrote:

> Shmem uses shmem_recalc_inode to update i_blocks when it allocates
> page, undoes range or swaps. But mm can drop clean page without
> notifying shmem. This makes fstat sometimes return out-of-date
> block size.
> 
> The problem can be partially solved when we add
> inode_operations->getattr which calls shmem_recalc_inode to update
> i_blocks for fstat.
> 
> shmem_recalc_inode also updates counter used by statfs and
> vm_committed_as. For them the situation is not changed. They still
> suffer from the discrepancy after dropping clean page and before
> the function is called by aforementioned triggers.

"partially" indeed.

Thanks, your patch is sensible in itself, though nobody cared before;
and I hope nobody is fooled by your improvement into thinking that
shmem_recalc_inode() does a very good job.

I looked once again into how to improve the situation, but yet again
had to retreat for now: as I found before, mapping->a_ops->freepage
almost does what's needed, but is frustratingly not quite usable.

So let's go with your patch: I'll add my signoff and send on to
akpm for 4.3.

Hugh

> 
> Signed-off-by: Yu Zhao <yuzhao@google.com>
> ---
>  mm/shmem.c | 16 ++++++++++++++++
>  1 file changed, 16 insertions(+)
> 
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 4caf8ed..37e7933 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -542,6 +542,21 @@ void shmem_truncate_range(struct inode *inode, loff_t lstart, loff_t lend)
>  }
>  EXPORT_SYMBOL_GPL(shmem_truncate_range);
>  
> +static int shmem_getattr(struct vfsmount *mnt, struct dentry *dentry,
> +			 struct kstat *stat)
> +{
> +	struct inode *inode = dentry->d_inode;
> +	struct shmem_inode_info *info = SHMEM_I(inode);
> +
> +	spin_lock(&info->lock);
> +	shmem_recalc_inode(inode);
> +	spin_unlock(&info->lock);
> +
> +	generic_fillattr(inode, stat);
> +
> +	return 0;
> +}
> +
>  static int shmem_setattr(struct dentry *dentry, struct iattr *attr)
>  {
>  	struct inode *inode = d_inode(dentry);
> @@ -3122,6 +3137,7 @@ static const struct file_operations shmem_file_operations = {
>  };
>  
>  static const struct inode_operations shmem_inode_operations = {
> +	.getattr	= shmem_getattr,
>  	.setattr	= shmem_setattr,
>  #ifdef CONFIG_TMPFS_XATTR
>  	.setxattr	= shmem_setxattr,
> -- 
> 2.4.3.573.g4eafbef

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
