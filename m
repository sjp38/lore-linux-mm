Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E012C6B003D
	for <linux-mm@kvack.org>; Thu,  2 Apr 2009 11:28:27 -0400 (EDT)
Date: Thu, 2 Apr 2009 17:28:53 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: Problem in "prune_icache"
Message-ID: <20090402152853.GB17275@atrey.karlin.mff.cuni.cz>
References: <351740.68168.qm@web15302.mail.cnb.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <351740.68168.qm@web15302.mail.cnb.yahoo.com>
Sender: owner-linux-mm@kvack.org
To: HongChao Zhang <zhanghc08@yahoo.com.cn>
Cc: linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

  Hi,

> I'am from Lustre, which is a product of SUN Mirocsystem to implement
> Scaled Distributed FileSystem, and we encounter a deadlock problem 
> in prune_icache, the detailed is,
>  
> during truncating a file, a new update in current journal transaction
> will be created, but it found memory in low level during processing, 
> then it call try_to_free_pages to free some pages, which finially call
> shrink_icache_memory/prune_icache to free cache memory occupied by inodes.
> Note: prune_icache will get and hold "iprune_mutex" during its whole pruning work.
>  
> but at the same time, kswapd have called shrink_icache_memory/prune_icache with 
> "iprune_mutex" locked, which found some inodes to dispose and call 
> clear_inode/DQUOT_DROP/fs-specific-quota-drop-op(say "ldiskfs_dquot_drop" in our case)
> to drop dquot, and this fs-specific-quota-drop-op can call journal_start to
> start a new update, but it found the buffers in current transaction is up to
> j_max_transaction_buffers, so it wake up kjournald to commit the transaction.
> so kjournald will call journal_commit_transaction to commit the transcation,
> which set the state of the transaction as T_LOCKED then check whether there are
> still pending updates for the committing transaction, and it found there is a
> pending update(started in truncating operation, see above), so it will wait
> the update to complete, BUT the update won't be completed for it can't get the
> "iprune_mutex" hold by kswapd, so the deadlock is triggered.
  Yes, this has happened with other filesystems as well (ext3,
ext4,...). The usual solution for this problem is to specify GFP_NOFS to
all allocations that happen while the transaction is open. That way we
never get to recursing back to the filesystem in the allocation. Is
there some reason why that is no-go for you?

									Honza

-- 
Jan Kara <jack@suse.cz>
SuSE CR Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
