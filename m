Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id D09CA6B0253
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 15:28:06 -0400 (EDT)
Received: by widjy10 with SMTP id jy10so66406484wid.1
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 12:28:06 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gz6si4973364wjc.171.2015.07.01.12.28.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 01 Jul 2015 12:28:04 -0700 (PDT)
Date: Wed, 1 Jul 2015 21:28:00 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 49/51] buffer, writeback: make __block_write_full_page()
 honor cgroup writeback
Message-ID: <20150701192800.GM7252@quack.suse.cz>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-50-git-send-email-tj@kernel.org>
 <20150701192102.GK7252@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150701192102.GK7252@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru, Andrew Morton <akpm@linux-foundation.org>

On Wed 01-07-15 21:21:02, Jan Kara wrote:
> On Fri 22-05-15 17:14:03, Tejun Heo wrote:
> > [__]block_write_full_page() is used to implement ->writepage in
> > various filesystems.  All writeback logic is now updated to handle
> > cgroup writeback and the block cgroup to issue IOs for is encoded in
> > writeback_control and can be retrieved from the inode; however,
> > [__]block_write_full_page() currently ignores the blkcg indicated by
> > inode and issues all bio's without explicit blkcg association.
> > 
> > This patch adds submit_bh_blkcg() which associates the bio with the
> > specified blkio cgroup before issuing and uses it in
> > __block_write_full_page() so that the issued bio's are associated with
> > inode_to_wb_blkcg_css(inode).
> 
> One comment below...
> 
> > @@ -44,6 +45,9 @@
> >  #include <trace/events/block.h>
> >  
> >  static int fsync_buffers_list(spinlock_t *lock, struct list_head *list);
> > +static int submit_bh_blkcg(int rw, struct buffer_head *bh,
> > +			   unsigned long bio_flags,
> 
> The argument bio_flags is unused. What is is good for?

Ah, sorry, I guess I'm too tired. I now see how bio_flags are used. The
patch looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.com>

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
