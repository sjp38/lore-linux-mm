Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id A58756B000C
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 20:48:32 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id v30-v6so22959096wra.19
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 17:48:32 -0700 (PDT)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id r11-v6si16852730wrc.418.2018.10.17.17.48.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Oct 2018 17:48:31 -0700 (PDT)
Date: Thu, 18 Oct 2018 01:48:26 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 09/29] vfs: combine the clone and dedupe into a single
 remap_file_range
Message-ID: <20181018004826.GB12386@ZenIV.linux.org.uk>
References: <153981625504.5568.2708520119290577378.stgit@magnolia>
 <153981631706.5568.6473120432728396978.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <153981631706.5568.6473120432728396978.stgit@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: david@fromorbit.com, sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, Amir Goldstein <amir73il@gmail.com>, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, ocfs2-devel@oss.oracle.com

On Wed, Oct 17, 2018 at 03:45:17PM -0700, Darrick J. Wong wrote:
> From: Darrick J. Wong <darrick.wong@oracle.com>
> 
> Combine the clone_file_range and dedupe_file_range operations into a
> single remap_file_range file operation dispatch since they're
> fundamentally the same operation.  The differences between the two can
> be made in the prep functions.
> 
> Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> Reviewed-by: Amir Goldstein <amir73il@gmail.com>
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> ---
>  Documentation/filesystems/vfs.txt |   13 +++++------
>  fs/btrfs/ctree.h                  |    8 ++-----
>  fs/btrfs/file.c                   |    3 +-
>  fs/btrfs/ioctl.c                  |   45 +++++++++++++++++++------------------
>  fs/cifs/cifsfs.c                  |   22 +++++++++++-------
>  fs/nfs/nfs4file.c                 |   10 ++++++--
>  fs/ocfs2/file.c                   |   24 +++++++-------------
>  fs/overlayfs/file.c               |   30 ++++++++++++++-----------
>  fs/read_write.c                   |   18 +++++++--------
>  fs/xfs/xfs_file.c                 |   23 ++++++-------------
>  include/linux/fs.h                |   20 +++++++++++++---
>  11 files changed, 110 insertions(+), 106 deletions(-)
> 
> 
> diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
> index a6c6a8af48a2..bb3183334ab9 100644
> --- a/Documentation/filesystems/vfs.txt
> +++ b/Documentation/filesystems/vfs.txt
> @@ -883,8 +883,9 @@ struct file_operations {
>  	unsigned (*mmap_capabilities)(struct file *);
>  #endif
>  	ssize_t (*copy_file_range)(struct file *, loff_t, struct file *, loff_t, size_t, unsigned int);
> -	int (*clone_file_range)(struct file *, loff_t, struct file *, loff_t, u64);
> -	int (*dedupe_file_range)(struct file *, loff_t, struct file *, loff_t, u64);
> +	int (*remap_file_range)(struct file *file_in, loff_t pos_in,
> +				struct file *file_out, loff_t pos_out,
> +				u64 len, unsigned int remap_flags);
>  	int (*fadvise)(struct file *, loff_t, loff_t, int);
>  };

Documentation/filesystems/porting part, please.  And document remap_flags.

> +#define REMAP_FILE_DEDUP		(1 << 0)
> +
> +/*
> + * These flags should be taken care of by the implementation (possibly using
> + * vfs helpers) but can be ignored by the implementation.
> + */
> +#define REMAP_FILE_ADVISORY		(0)

???
