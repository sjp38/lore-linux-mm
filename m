Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C76B26B0038
	for <linux-mm@kvack.org>; Mon, 15 May 2017 07:18:40 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id a66so100282873pfl.6
        for <linux-mm@kvack.org>; Mon, 15 May 2017 04:18:40 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y11si10375637pgo.382.2017.05.15.04.18.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 15 May 2017 04:18:39 -0700 (PDT)
Date: Mon, 15 May 2017 12:42:46 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v4 15/27] fs: retrofit old error reporting API onto new
 infrastructure
Message-ID: <20170515104246.GC16182@quack2.suse.cz>
References: <20170509154930.29524-1-jlayton@redhat.com>
 <20170509154930.29524-16-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170509154930.29524-16-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org, dhowells@redhat.com, akpm@linux-foundation.org, hch@infradead.org, ross.zwisler@linux.intel.com, mawilcox@microsoft.com, jack@suse.com, viro@zeniv.linux.org.uk, corbet@lwn.net, neilb@suse.de, clm@fb.com, tytso@mit.edu, axboe@kernel.dk, josef@toxicpanda.com, hubcap@omnibond.com, rpeterso@redhat.com, bo.li.liu@oracle.com

On Tue 09-05-17 11:49:18, Jeff Layton wrote:
> Now that we have a better way to store and report errors that occur
> during writeback, we need to convert the existing codebase to use it. We
> could just adapt all of the filesystem code and related infrastructure
> to the new API, but that's a lot of churn.
> 
> When it comes to setting errors in the mapping, filemap_set_wb_error is
> a drop-in replacement for mapping_set_error. Turn that function into a
> simple wrapper around the new one.
> 
> Because we want to ensure that writeback errors are always reported at
> fsync time, inject filemap_report_wb_error calls much closer to the
> syscall boundary, in call_fsync.
> 
> For fsync calls (and things like the nfsd equivalent), we either return
> the error that the fsync operation returns, or the one returned by
> filemap_report_wb_error. In both cases, we advance the file->f_wb_err to
> the latest value. This allows us to provide new fsync semantics that
> will return errors that may have occurred previously and been viewed
> via other file descriptors.
> 
> The final piece of the puzzle is what to do about filemap_check_errors
> calls that are being called directly or via filemap_* functions. Here,
> we must take a little "creative license".
> 
> Since we now handle advancing the file->f_wb_err value at the generic
> filesystem layer, we no longer need those callers to clear errors out
> of the mapping or advance an errseq_t.
> 
> A lot of the existing codebase relies on being getting an error back
> from those functions when there is a writeback problem, so we do still
> want to have them report writeback errors somehow.
> 
> When reporting writeback errors, we will always report errors that have
> occurred since a particular point in time. With the old writeback error
> reporting, the time we used was "since it was last tested/cleared" which
> is entirely arbitrary and potentially racy. Now, we can at least report
> the latest error that has occurred since an arbitrary point in time
> (represented as a sampled errseq_t value).
> 
> In the case where we don't have a struct file to work with, this patch
> just has the wrappers sample the current mapping->wb_err value, and use
> that as an arbitrary point from which to check for errors.

I think this is really dangerous and we shouldn't do this. You are quite
likely to lose IO errors in such calls because you will ignore all errors
that happened during previous background writeback or even for IO that
managed to complete before we called filemap_fdatawait(). Maybe we need to
keep the original set-clear-bit IO error reporting for these cases, until
we can convert them to fdatawait_range_since()?

> That's probably not "correct" in all cases, particularly in the case of
> something like filemap_fdatawait, but I'm not sure it's any worse than
> what we already have, and this gives us a basis from which to work.
> 
> A lot of those callers will likely want to change to a model where they
> sample the errseq_t much earlier (perhaps when starting a transaction),
> store it in an appropriate place and then use that value later when
> checking to see if an error occurred.
> 
> That will almost certainly take some involvement from other subsystem
> maintainers. I'm quite open to adding new API functions to help enable
> this if that would be helpful, but I don't really want to do that until
> I better understand what's needed.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>

...

> diff --git a/fs/f2fs/file.c b/fs/f2fs/file.c
> index 5f7317875a67..7ce13281925f 100644
> --- a/fs/f2fs/file.c
> +++ b/fs/f2fs/file.c
> @@ -187,6 +187,7 @@ static int f2fs_do_sync_file(struct file *file, loff_t start, loff_t end,
>  		.nr_to_write = LONG_MAX,
>  		.for_reclaim = 0,
>  	};
> +	errseq_t since = READ_ONCE(file->f_wb_err);
>  
>  	if (unlikely(f2fs_readonly(inode->i_sb)))
>  		return 0;
> @@ -265,6 +266,8 @@ static int f2fs_do_sync_file(struct file *file, loff_t start, loff_t end,
>  	}
>  
>  	ret = wait_on_node_pages_writeback(sbi, ino);
> +	if (ret == 0)
> +		ret = filemap_check_wb_error(NODE_MAPPING(sbi), since);
>  	if (ret)
>  		goto out;

So this conversion looks wrong and actually points to a larger issue with
the scheme. The problem is there are two mappings that come into play here
- file_inode(file)->i_mapping which is the data mapping and
NODE_MAPPING(sbi) which is the metadata mapping (and this is not a problem
specific to f2fs. For example ext2 also uses this scheme where block
devices' mapping is the metadata mapping). And we need to merge error
information from these two mappings so for the stamping scheme to work,
we'd need two stamps stored in struct file. One for data mapping and one
for metadata mapping. Or maybe there's some more clever scheme but for now
I don't see one...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
