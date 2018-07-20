Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 435E46B0269
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 16:06:06 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id e19-v6so6572297pgv.11
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 13:06:06 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id w25-v6si2673348pga.58.2018.07.20.13.06.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jul 2018 13:06:05 -0700 (PDT)
Date: Fri, 20 Jul 2018 13:06:02 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: INFO: task hung in generic_file_write_iter
Message-Id: <20180720130602.f3d6dc4c943558875a36cb52@linux-foundation.org>
In-Reply-To: <9b9fcdda-c347-53ee-fdbb-8a7d11cf430e@I-love.SAKURA.ne.jp>
References: <0000000000009ce88d05714242a8@google.com>
	<4b349bff-8ad4-6410-250d-593b13d8d496@I-love.SAKURA.ne.jp>
	<9b9fcdda-c347-53ee-fdbb-8a7d11cf430e@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, syzbot <syzbot+9933e4476f365f5d5a1b@syzkaller.appspotmail.com>, linux-mm@kvack.org, mgorman@techsingularity.net, Michal Hocko <mhocko@kernel.org>, ak@linux.intel.com, jack@suse.cz, jlayton@redhat.com, linux-kernel@vger.kernel.org, mawilcox@microsoft.com, syzkaller-bugs@googlegroups.com, tim.c.chen@linux.intel.com, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Fri, 20 Jul 2018 19:36:23 +0900 Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> wrote:

> > 
> > This report is stalling after mount() completed and process used remap_file_pages().
> > I think that we might need to use debug printk(). But I don't know what to examine.
> > 
> 
> Andrew, can you pick up this debug printk() patch?
> I guess we can get the result within one week.

Sure, let's toss it in -next for a while.

> >From 8f55e00b21fefffbc6abd9085ac503c52a302464 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Fri, 20 Jul 2018 19:29:06 +0900
> Subject: [PATCH] fs/buffer.c: add debug print for __getblk_gfp() stall problem
> 
> Among syzbot's unresolved hung task reports, 18 out of 65 reports contain
> __getblk_gfp() line in the backtrace. Since there is a comment block that
> says that __getblk_gfp() will lock up the machine if try_to_free_buffers()
> attempt from grow_dev_page() is failing, let's start from checking whether
> syzbot is hitting that case. This change will be removed after the bug is
> fixed.

I'm not sure that grow_dev_page() is hanging.  It has often been
suspected, but always is proven innocent.  Lets see.

>
> ...
>
> @@ -978,6 +988,9 @@ static sector_t blkdev_max_block(struct block_device *bdev, unsigned int size)
>  	spin_unlock(&inode->i_mapping->private_lock);
>  done:
>  	ret = (block < end_block) ? 1 : -ENXIO;
> +#ifdef CONFIG_DEBUG_AID_FOR_SYZBOT
> +	current->getblk_executed |= 0x08;
> +#endif
>  failed:
>  	unlock_page(page);
>  	put_page(page);
> @@ -1033,6 +1046,12 @@ static sector_t blkdev_max_block(struct block_device *bdev, unsigned int size)

Something is wrong with your diff(1).  That's grow_dev_page(), not
blkdev_max_block().

>  		return NULL;
>  	}
>  
> +#ifdef CONFIG_DEBUG_AID_FOR_SYZBOT
> +	current->getblk_stamp = jiffies;

AFACIT getblk_stamp didn't need to be in the task_struct - it could be
a local.  Doesn't matter much.

> +	current->getblk_executed = 0;
> +	current->getblk_bh_count = 0;
> +	current->getblk_bh_state = 0;
> +#endif
>  	for (;;) {
>  		struct buffer_head *bh;
>  		int ret;
> @@ -1044,6 +1063,18 @@ static sector_t blkdev_max_block(struct block_device *bdev, unsigned int size)
>  		ret = grow_buffers(bdev, block, size, gfp);
>  		if (ret < 0)
>  			return NULL;
> +
> +#ifdef CONFIG_DEBUG_AID_FOR_SYZBOT
> +		if (!time_after(jiffies, current->getblk_stamp + 3 * HZ))
> +			continue;
> +		printk(KERN_ERR "%s(%u): getblk(): executed=%x bh_count=%d bh_state=%lx\n",
> +		       current->comm, current->pid, current->getblk_executed,
> +		       current->getblk_bh_count, current->getblk_bh_state);
> +		current->getblk_executed = 0;
> +		current->getblk_bh_count = 0;
> +		current->getblk_bh_state = 0;
> +		current->getblk_stamp = jiffies;
> +#endif
>  	}
>  }
>  
> @@ -3216,6 +3247,11 @@ int sync_dirty_buffer(struct buffer_head *bh)
>   */
>  static inline int buffer_busy(struct buffer_head *bh)
>  {
> +#ifdef CONFIG_DEBUG_AID_FOR_SYZBOT
> +	current->getblk_executed |= 0x80;
> +	current->getblk_bh_count = atomic_read(&bh->b_count);
> +	current->getblk_bh_state = bh->b_state;
> +#endif

Some explanation of your design wouldn't have hurt.  What does
getblk_executed do, why were these particular fields chosen?

>  	return atomic_read(&bh->b_count) |
>  		(bh->b_state & ((1 << BH_Dirty) | (1 << BH_Lock)));
>  }
>
> ...
>
