Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B10D46B0005
	for <linux-mm@kvack.org>; Tue, 27 Feb 2018 12:00:34 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id e127so8364362wmg.7
        for <linux-mm@kvack.org>; Tue, 27 Feb 2018 09:00:34 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v187si7940541wmf.27.2018.02.27.09.00.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Feb 2018 09:00:33 -0800 (PST)
Date: Tue, 27 Feb 2018 18:00:31 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v4 03/12] ext2, dax: finish implementing dax_sem helpers
Message-ID: <20180227170031.lgf5tc3vt3umrwbb@quack2.suse.cz>
References: <151970519370.26729.1011551137381425076.stgit@dwillia2-desk3.amr.corp.intel.com>
 <151970521121.26729.7741760690622342144.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <151970521121.26729.7741760690622342144.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Jan Kara <jack@suse.com>

On Mon 26-02-18 20:20:11, Dan Williams wrote:
> dax_sem_{up,down}_write_sem() allow the ext2 dax semaphore to be compiled
> out in the CONFIG_FS_DAX=n case. However there are still some open coded
> uses of the semaphore. Add dax_sem_{up_read,down_read,_is_locked}()
> helpers and convert all open-coded usages of the semaphore to the
> helpers.

Just one nit below. With that fixed you can add:

Reviewed-by: Jan Kara <jack@suse.cz>

> Cc: Jan Kara <jack@suse.com>
> Cc: <stable@vger.kernel.org>
> Fixes: dee410792419 ("/dev/dax, core: file operations and dax-mmap")
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  fs/ext2/ext2.h  |    6 ++++++
>  fs/ext2/file.c  |    5 ++---
>  fs/ext2/inode.c |    4 +---
>  3 files changed, 9 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/ext2/ext2.h b/fs/ext2/ext2.h
> index 032295e1d386..7ceb29733cdb 100644
> --- a/fs/ext2/ext2.h
> +++ b/fs/ext2/ext2.h
> @@ -711,9 +711,15 @@ struct ext2_inode_info {
>  #ifdef CONFIG_FS_DAX
>  #define dax_sem_down_write(ext2_inode)	down_write(&(ext2_inode)->dax_sem)
>  #define dax_sem_up_write(ext2_inode)	up_write(&(ext2_inode)->dax_sem)
> +#define dax_sem_is_locked(ext2_inode)	rwsem_is_locked(&(ext2_inode)->dax_sem)
> +#define dax_sem_down_read(ext2_inode)	down_read(&(ext2_inode)->dax_sem)
> +#define dax_sem_up_read(ext2_inode)	up_read(&(ext2_inode)->dax_sem)
>  #else
>  #define dax_sem_down_write(ext2_inode)
>  #define dax_sem_up_write(ext2_inode)
> +#define dax_sem_is_locked(ext2_inode)	(true)

This is a bit dangerous as depending on the use of dax_sem_is_locked()
you'd need this to return true or false. E.g. assume we'd have a place
where we'd like to do:

	WARN_ON(dax_sem_is_locked(inode));

or just

	if (dax_sem_is_locked(inode))
		bail out due to congestion...

How I'd solve this is that I'd define:

#define assert_dax_sem_locked(ext2_inode) WARN_ON(rwsem_is_locked(&(ext2_inode)->dax_sem)

and just as do {} while (0) for !CONFIG_FS_DAX.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
