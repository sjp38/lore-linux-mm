Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 35F4F6B0273
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 07:48:32 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id y6so35664983lff.0
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 04:48:32 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id al10si1425846wjc.183.2016.09.22.04.48.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Sep 2016 04:48:31 -0700 (PDT)
Date: Thu, 22 Sep 2016 13:48:28 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 4/4] writeback: introduce super_operations->write_metadata
Message-ID: <20160922114828.GN2834@quack2.suse.cz>
References: <1474405068-27841-1-git-send-email-jbacik@fb.com>
 <1474405068-27841-5-git-send-email-jbacik@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1474405068-27841-5-git-send-email-jbacik@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <jbacik@fb.com>
Cc: linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, jack@suse.com, viro@zeniv.linux.org.uk, dchinner@redhat.com, hch@lst.de, linux-mm@kvack.org, hannes@cmpxchg.org

On Tue 20-09-16 16:57:48, Josef Bacik wrote:
> Now that we have metadata counters in the VM, we need to provide a way to kick
> writeback on dirty metadata.  Introduce super_operations->write_metadata.  This
> allows file systems to deal with writing back any dirty metadata we need based
> on the writeback needs of the system.  Since there is no inode to key off of we
> need a list in the bdi for dirty super blocks to be added.  From there we can
> find any dirty sb's on the bdi we are currently doing writeback on and call into
> their ->write_metadata callback.
> 
> Signed-off-by: Josef Bacik <jbacik@fb.com>
> ---
>  fs/fs-writeback.c                | 72 ++++++++++++++++++++++++++++++++++++----
>  fs/super.c                       |  7 ++++
>  include/linux/backing-dev-defs.h |  2 ++
>  include/linux/fs.h               |  4 +++
>  mm/backing-dev.c                 |  2 ++
>  5 files changed, 81 insertions(+), 6 deletions(-)
> 

...

> +	if (!done && sb->s_op->write_metadata) {
> +		spin_unlock(&wb->list_lock);
> +		wrote += writeback_sb_metadata(sb, wb, work);
> +		spin_unlock(&wb->list_lock);
		^^^
		spin_lock();

Otherwise the patch looks good to me. So feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

after fixing the above.

								Honza

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
