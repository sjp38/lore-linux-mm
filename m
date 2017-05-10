Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id F347B2808A3
	for <linux-mm@kvack.org>; Wed, 10 May 2017 07:57:55 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id o52so8028629wrb.10
        for <linux-mm@kvack.org>; Wed, 10 May 2017 04:57:55 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l14si2854228wrb.253.2017.05.10.04.57.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 10 May 2017 04:57:54 -0700 (PDT)
Date: Wed, 10 May 2017 13:48:40 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v4 14/27] fs: new infrastructure for writeback error
 handling and reporting
Message-ID: <20170510114840.GF25137@quack2.suse.cz>
References: <20170509154930.29524-1-jlayton@redhat.com>
 <20170509154930.29524-15-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170509154930.29524-15-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org, dhowells@redhat.com, akpm@linux-foundation.org, hch@infradead.org, ross.zwisler@linux.intel.com, mawilcox@microsoft.com, jack@suse.com, viro@zeniv.linux.org.uk, corbet@lwn.net, neilb@suse.de, clm@fb.com, tytso@mit.edu, axboe@kernel.dk, josef@toxicpanda.com, hubcap@omnibond.com, rpeterso@redhat.com, bo.li.liu@oracle.com

On Tue 09-05-17 11:49:17, Jeff Layton wrote:
> Most filesystems currently use mapping_set_error and
> filemap_check_errors for setting and reporting/clearing writeback errors
> at the mapping level. filemap_check_errors is indirectly called from
> most of the filemap_fdatawait_* functions and from
> filemap_write_and_wait*. These functions are called from all sorts of
> contexts to wait on writeback to finish -- e.g. mostly in fsync, but
> also in truncate calls, getattr, etc.
> 
> The non-fsync callers are problematic. We should be reporting writeback
> errors during fsync, but many places spread over the tree clear out
> errors before they can be properly reported, or report errors at
> nonsensical times.
> 
> If I get -EIO on a stat() call, there is no reason for me to assume that
> it is because some previous writeback failed. The fact that it also
> clears out the error such that a subsequent fsync returns 0 is a bug,
> and a nasty one since that's potentially silent data corruption.
> 
> This patch adds a small bit of new infrastructure for setting and
> reporting errors during address_space writeback. While the above was my
> original impetus for adding this, I think it's also the case that
> current fsync semantics are just problematic for userland. Most
> applications that call fsync do so to ensure that the data they wrote
> has hit the backing store.
> 
> In the case where there are multiple writers to the file at the same
> time, this is really hard to determine. The first one to call fsync will
> see any stored error, and the rest get back 0. The processes with open
> fds may not be associated with one another in any way. They could even
> be in different containers, so ensuring coordination between all fsync
> callers is not really an option.
> 
> One way to remedy this would be to track what file descriptor was used
> to dirty the file, but that's rather cumbersome and would likely be
> slow. However, there is a simpler way to improve the semantics here
> without incurring too much overhead.
> 
> This set adds an errseq_t to struct address_space, and a corresponding
> one is added to struct file. Writeback errors are recorded in the
> mapping's errseq_t, and the one in struct file is used as the "since"
> value.
> 
> This changes the semantics of the Linux fsync implementation such that
> applications can now use it to determine whether there were any
> writeback errors since fsync(fd) was last called (or since the file was
> opened in the case of fsync having never been called).
> 
> Note that those writeback errors may have occurred when writing data
> that was dirtied via an entirely different fd, but that's the case now
> with the current mapping_set_error/filemap_check_error infrastructure.
> This will at least prevent you from getting a false report of success.
> 
> The new behavior is still consistent with the POSIX spec, and is more
> reliable for application developers. This patch just adds some basic
> infrastructure for doing this. Later patches will change the existing
> code to use this new infrastructure.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>

Just one nit below. Otherwise the patch looks good to me. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

> diff --git a/fs/file_table.c b/fs/file_table.c
> index 954d510b765a..d6138b6411ff 100644
> --- a/fs/file_table.c
> +++ b/fs/file_table.c
> @@ -168,6 +168,7 @@ struct file *alloc_file(const struct path *path, fmode_t mode,
>  	file->f_path = *path;
>  	file->f_inode = path->dentry->d_inode;
>  	file->f_mapping = path->dentry->d_inode->i_mapping;
> +	file->f_wb_err = filemap_sample_wb_error(file->f_mapping);

Why do you sample here when you also sample in do_dentry_open()? I didn't
find any alloc_file() callers that would possibly care about writeback
errors... 

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
