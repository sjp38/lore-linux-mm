Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 7381D6B002C
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 09:00:15 -0500 (EST)
Date: Mon, 20 Feb 2012 15:00:10 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: reclaim the LRU lists full of dirty/writeback pages
Message-ID: <20120220140010.GF6799@quack.suse.cz>
References: <CAHH2K0bmURXpk6-4D9q7ErppVyMJjKMsn37MenwqcP_nnT66Mw@mail.gmail.com>
 <20120210114706.GA4704@localhost>
 <20120211124445.GA10826@localhost>
 <4F36816A.6030609@redhat.com>
 <20120212031029.GA17435@localhost>
 <20120213154313.GD6478@quack.suse.cz>
 <20120214100348.GA7000@localhost>
 <20120214132950.GE1934@quack.suse.cz>
 <20120216040019.GB17597@localhost>
 <20120217164133.GA4871@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120217164133.GA4871@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Greg Thelen <gthelen@google.com>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>

On Sat 18-02-12 00:41:33, Wu Fengguang wrote:
> > > > And I find the pageout works seem to have some problems with ext4.
> > > > For example, this can be easily triggered with 10 dd tasks running
> > > > inside the 100MB limited memcg:
> > >   So journal thread is getting stuck while committing transaction. Most
> > > likely waiting for some dd thread to stop a transaction so that commit can
> > > proceed. The processes waiting in start_this_handle() are just secondary
> > > effect resulting from the first problem. It might be interesting to get
> > > stack traces of all bloked processes when the journal thread is stuck.
> > 
> > For completeness of discussion, citing your conclusion on my private
> > data feed:
> > 
> > : We enter memcg reclaim from grab_cache_page_write_begin() and are
> > : waiting in congestion_wait(). Because grab_cache_page_write_begin() is
> > : called with transaction started, this blocks transaction from
> > : committing and subsequently blocks all other activity on the
> > : filesystem. The fact is this isn't new with your patches, just your
> > : changes or the fact that we are running in a memory constrained cgroup
> > : make this more visible.
> 
> Maybe I'm missing some deep FS restrictions, but can this page
> allocation (and the one in ext4_write_begin) be moved before
> ext4_journal_start()? So that the page reclaim can throttle the
> __GFP_WRITE allocations at will.
  You are missing the fact that in this way, things would deadlock quickly.
Lock ordering of ext4 is 'transaction start' -> 'page lock' (so that
writepages may be efficient) and so you cannot really have it differently
here - you can think of transaction start - transaction end pair as a
lock - unlock for lock ordering purposes. You could play some tricks like
allocating the page without locking, starting a transaction, locking a page
and checking that everything is OK but it isn't really nice and when memory
pressure is big, the gain is questionable.

								Honza
> ---
>  fs/ext4/inode.c |   22 +++++++++++-----------
>  1 file changed, 11 insertions(+), 11 deletions(-)
> 
> --- linux.orig/fs/ext4/inode.c	2012-02-18 00:10:27.000000000 +0800
> +++ linux/fs/ext4/inode.c	2012-02-18 00:31:19.000000000 +0800
> @@ -2398,38 +2398,38 @@ static int ext4_da_write_begin(struct fi
>  	if (ext4_nonda_switch(inode->i_sb)) {
>  		*fsdata = (void *)FALL_BACK_TO_NONDELALLOC;
>  		return ext4_write_begin(file, mapping, pos,
>  					len, flags, pagep, fsdata);
>  	}
>  	*fsdata = (void *)0;
>  	trace_ext4_da_write_begin(inode, pos, len, flags);
>  retry:
> +	page = grab_cache_page_write_begin(mapping, index, flags);
> +	if (!page) {
> +		ret = -ENOMEM;
> +		goto out;
> +	}
> +	*pagep = page;
> +
>  	/*
>  	 * With delayed allocation, we don't log the i_disksize update
>  	 * if there is delayed block allocation. But we still need
>  	 * to journalling the i_disksize update if writes to the end
>  	 * of file which has an already mapped buffer.
>  	 */
>  	handle = ext4_journal_start(inode, 1);
>  	if (IS_ERR(handle)) {
>  		ret = PTR_ERR(handle);
> +		unlock_page(page);
> +		page_cache_release(page);
> +		if (pos + len > inode->i_size)
> +			truncate_inode_pages(inode->i_mapping, inode->i_size);
>  		goto out;
>  	}
> -	/* We cannot recurse into the filesystem as the transaction is already
> -	 * started */
> -	flags |= AOP_FLAG_NOFS;
> -
> -	page = grab_cache_page_write_begin(mapping, index, flags);
> -	if (!page) {
> -		ext4_journal_stop(handle);
> -		ret = -ENOMEM;
> -		goto out;
> -	}
> -	*pagep = page;
>  
>  	ret = __block_write_begin(page, pos, len, ext4_da_get_block_prep);
>  	if (ret < 0) {
>  		unlock_page(page);
>  		ext4_journal_stop(handle);
>  		page_cache_release(page);
>  		/*
>  		 * block_write_begin may have instantiated a few blocks
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
