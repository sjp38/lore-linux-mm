Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6403E440CD7
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 09:33:35 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id 24so4382774qts.23
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 06:33:35 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p48sor4288060qtc.48.2017.11.09.06.33.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 09 Nov 2017 06:33:34 -0800 (PST)
Date: Thu, 9 Nov 2017 09:33:32 -0500
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH 3/4] writeback: introduce super_operations->write_metadata
Message-ID: <20171109143331.hatuy672upnlxb4f@destiny>
References: <1510167660-26196-1-git-send-email-josef@toxicpanda.com>
 <1510167660-26196-3-git-send-email-josef@toxicpanda.com>
 <20171109110102.GC9263@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171109110102.GC9263@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Josef Bacik <josef@toxicpanda.com>, hannes@cmpxchg.org, linux-mm@kvack.org, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, Josef Bacik <jbacik@fb.com>

On Thu, Nov 09, 2017 at 12:01:02PM +0100, Jan Kara wrote:
> On Wed 08-11-17 14:00:59, Josef Bacik wrote:
> > From: Josef Bacik <jbacik@fb.com>
> > 
> > Now that we have metadata counters in the VM, we need to provide a way to kick
> > writeback on dirty metadata.  Introduce super_operations->write_metadata.  This
> > allows file systems to deal with writing back any dirty metadata we need based
> > on the writeback needs of the system.  Since there is no inode to key off of we
> > need a list in the bdi for dirty super blocks to be added.  From there we can
> > find any dirty sb's on the bdi we are currently doing writeback on and call into
> > their ->write_metadata callback.
> > 
> > Signed-off-by: Josef Bacik <jbacik@fb.com>
> 
> This generally looks fine. Just two comments below.
> 
> > @@ -1654,11 +1679,38 @@ static long __writeback_inodes_wb(struct bdi_writeback *wb,
> >  
> >  		/* refer to the same tests at the end of writeback_sb_inodes */
> >  		if (wrote) {
> > -			if (time_is_before_jiffies(start_time + HZ / 10UL))
> > -				break;
> > -			if (work->nr_pages <= 0)
> > +			if (time_is_before_jiffies(start_time + HZ / 10UL) ||
> > +			    work->nr_pages <= 0) {
> > +				done = true;
> >  				break;
> > +			}
> > +		}
> > +	}
> > +
> > +	if (!done && wb_stat(wb, WB_METADATA_DIRTY)) {
> > +		LIST_HEAD(list);
> > +
> > +		spin_unlock(&wb->list_lock);
> > +		spin_lock(&wb->bdi->sb_list_lock);
> > +		list_splice_init(&wb->bdi->dirty_sb_list, &list);
> > +		while (!list_empty(&list)) {
> > +			struct super_block *sb;
> > +
> > +			sb = list_first_entry(&list, struct super_block,
> > +					      s_bdi_list);
> > +			list_move_tail(&sb->s_bdi_list,
> > +				       &wb->bdi->dirty_sb_list);
> 
> It seems superblock never gets out of dirty list this way? Also this series
> misses where a superblock is added to the dirty list which is confusing.
> 

Yeah this is one part I'm less enthusiastic about.  You have to manually add
your super block to the bdi if you want to use this functionality, and then we
use the WB_METADATA_DIRTY counter to see if we even need to do writeback on that
sb.  It's more of "writeback_sb_metadata_will_work_on_this_sb_list", less like
the dirty inode list.  If you look at the btrfs patch I add the sb to our
dirty_sb_list during mount.

> 
> > +			if (!sb->s_op->write_metadata)
> > +				continue;
> > +			if (!trylock_super(sb))
> > +				continue;
> > +			spin_unlock(&wb->bdi->sb_list_lock);
> > +			wrote += writeback_sb_metadata(sb, wb, work);
> > +			spin_lock(&wb->bdi->sb_list_lock);
> > +			up_read(&sb->s_umount);
> >  		}
> > +		spin_unlock(&wb->bdi->sb_list_lock);
> > +		spin_lock(&wb->list_lock);
> >  	}
> >  	/* Leave any unwritten inodes on b_io */
> >  	return wrote;
> > diff --git a/fs/super.c b/fs/super.c
> > index 166c4ee0d0ed..c170a799d3aa 100644
> > --- a/fs/super.c
> > +++ b/fs/super.c
> > @@ -214,6 +214,7 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags,
> >  	spin_lock_init(&s->s_inode_list_lock);
> >  	INIT_LIST_HEAD(&s->s_inodes_wb);
> >  	spin_lock_init(&s->s_inode_wblist_lock);
> > +	INIT_LIST_HEAD(&s->s_bdi_list);
> >  
> >  	if (list_lru_init_memcg(&s->s_dentry_lru))
> >  		goto fail;
> > @@ -446,6 +447,9 @@ void generic_shutdown_super(struct super_block *sb)
> >  	spin_unlock(&sb_lock);
> >  	up_write(&sb->s_umount);
> >  	if (sb->s_bdi != &noop_backing_dev_info) {
> > +		spin_lock(&sb->s_bdi->sb_list_lock);
> > +		list_del_init(&sb->s_bdi_list);
> > +		spin_unlock(&sb->s_bdi->sb_list_lock);
> 
> Verify that the superblock isn't in the dirty list here?
> 

Yeah sure can do.  Thanks,

Josef

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
