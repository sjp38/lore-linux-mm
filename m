Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id C35FF6B02EE
	for <linux-mm@kvack.org>; Mon, 15 May 2017 13:59:05 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id u13so54672313qku.11
        for <linux-mm@kvack.org>; Mon, 15 May 2017 10:59:05 -0700 (PDT)
Received: from mail-qt0-f173.google.com (mail-qt0-f173.google.com. [209.85.216.173])
        by mx.google.com with ESMTPS id u25si11343644qtu.127.2017.05.15.10.59.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 May 2017 10:59:04 -0700 (PDT)
Received: by mail-qt0-f173.google.com with SMTP id f55so54280162qta.3
        for <linux-mm@kvack.org>; Mon, 15 May 2017 10:59:04 -0700 (PDT)
Message-ID: <1494871139.4080.3.camel@redhat.com>
Subject: Re: [PATCH v4 15/27] fs: retrofit old error reporting API onto new
 infrastructure
From: Jeff Layton <jlayton@redhat.com>
Date: Mon, 15 May 2017 13:58:59 -0400
In-Reply-To: <20170515104246.GC16182@quack2.suse.cz>
References: <20170509154930.29524-1-jlayton@redhat.com>
	 <20170509154930.29524-16-jlayton@redhat.com>
	 <20170515104246.GC16182@quack2.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org, dhowells@redhat.com, akpm@linux-foundation.org, hch@infradead.org, ross.zwisler@linux.intel.com, mawilcox@microsoft.com, jack@suse.com, viro@zeniv.linux.org.uk, corbet@lwn.net, neilb@suse.de, clm@fb.com, tytso@mit.edu, axboe@kernel.dk, josef@toxicpanda.com, hubcap@omnibond.com, rpeterso@redhat.com, bo.li.liu@oracle.com

On Mon, 2017-05-15 at 12:42 +0200, Jan Kara wrote:
> On Tue 09-05-17 11:49:18, Jeff Layton wrote:
> > Now that we have a better way to store and report errors that occur
> > during writeback, we need to convert the existing codebase to use it. We
> > could just adapt all of the filesystem code and related infrastructure
> > to the new API, but that's a lot of churn.
> > 
> > When it comes to setting errors in the mapping, filemap_set_wb_error is
> > a drop-in replacement for mapping_set_error. Turn that function into a
> > simple wrapper around the new one.
> > 
> > Because we want to ensure that writeback errors are always reported at
> > fsync time, inject filemap_report_wb_error calls much closer to the
> > syscall boundary, in call_fsync.
> > 
> > For fsync calls (and things like the nfsd equivalent), we either return
> > the error that the fsync operation returns, or the one returned by
> > filemap_report_wb_error. In both cases, we advance the file->f_wb_err to
> > the latest value. This allows us to provide new fsync semantics that
> > will return errors that may have occurred previously and been viewed
> > via other file descriptors.
> > 
> > The final piece of the puzzle is what to do about filemap_check_errors
> > calls that are being called directly or via filemap_* functions. Here,
> > we must take a little "creative license".
> > 
> > Since we now handle advancing the file->f_wb_err value at the generic
> > filesystem layer, we no longer need those callers to clear errors out
> > of the mapping or advance an errseq_t.
> > 
> > A lot of the existing codebase relies on being getting an error back
> > from those functions when there is a writeback problem, so we do still
> > want to have them report writeback errors somehow.
> > 
> > When reporting writeback errors, we will always report errors that have
> > occurred since a particular point in time. With the old writeback error
> > reporting, the time we used was "since it was last tested/cleared" which
> > is entirely arbitrary and potentially racy. Now, we can at least report
> > the latest error that has occurred since an arbitrary point in time
> > (represented as a sampled errseq_t value).
> > 
> > In the case where we don't have a struct file to work with, this patch
> > just has the wrappers sample the current mapping->wb_err value, and use
> > that as an arbitrary point from which to check for errors.
> 
> I think this is really dangerous and we shouldn't do this. You are quite
> likely to lose IO errors in such calls because you will ignore all errors
> that happened during previous background writeback or even for IO that
> managed to complete before we called filemap_fdatawait(). Maybe we need to
> keep the original set-clear-bit IO error reporting for these cases, until
> we can convert them to fdatawait_range_since()?
> 

Yes that is a danger.

In fact, late last week I was finally able to make my xfstest work with
btrfs, and started hitting oopses with it because of the way the error
reporting changed. I rolled up a patch to fix that (and it simplifies
the code some, IMO), but other callers of filemap_fdatawait may have
similar problems here.

I'll pick up working on this again in a more piecemeal way. I had
originally looked at doing that, but there are some problematic places
(e.g. buffer.c), where the code is shared by a bunch of different
filesystems that makes it difficult.

We may end up needing some sort of FS_WB_ERRSEQ flag to do this
correctly, at least until the transition to errseq_t is done.

> > That's probably not "correct" in all cases, particularly in the case of
> > something like filemap_fdatawait, but I'm not sure it's any worse than
> > what we already have, and this gives us a basis from which to work.
> > 
> > A lot of those callers will likely want to change to a model where they
> > sample the errseq_t much earlier (perhaps when starting a transaction),
> > store it in an appropriate place and then use that value later when
> > checking to see if an error occurred.
> > 
> > That will almost certainly take some involvement from other subsystem
> > maintainers. I'm quite open to adding new API functions to help enable
> > this if that would be helpful, but I don't really want to do that until
> > I better understand what's needed.
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> 
> ...
> 
> > diff --git a/fs/f2fs/file.c b/fs/f2fs/file.c
> > index 5f7317875a67..7ce13281925f 100644
> > --- a/fs/f2fs/file.c
> > +++ b/fs/f2fs/file.c
> > @@ -187,6 +187,7 @@ static int f2fs_do_sync_file(struct file *file, loff_t start, loff_t end,
> >  		.nr_to_write = LONG_MAX,
> >  		.for_reclaim = 0,
> >  	};
> > +	errseq_t since = READ_ONCE(file->f_wb_err);
> >  
> >  	if (unlikely(f2fs_readonly(inode->i_sb)))
> >  		return 0;
> > @@ -265,6 +266,8 @@ static int f2fs_do_sync_file(struct file *file, loff_t start, loff_t end,
> >  	}
> >  
> >  	ret = wait_on_node_pages_writeback(sbi, ino);
> > +	if (ret == 0)
> > +		ret = filemap_check_wb_error(NODE_MAPPING(sbi), since);
> >  	if (ret)
> >  		goto out;
> 
> So this conversion looks wrong and actually points to a larger issue with
> the scheme. The problem is there are two mappings that come into play here
> - file_inode(file)->i_mapping which is the data mapping and
> NODE_MAPPING(sbi) which is the metadata mapping (and this is not a problem
> specific to f2fs. For example ext2 also uses this scheme where block
> devices' mapping is the metadata mapping). And we need to merge error
> information from these two mappings so for the stamping scheme to work,
> we'd need two stamps stored in struct file. One for data mapping and one
> for metadata mapping. Or maybe there's some more clever scheme but for now
> I don't see one...
> 

Got it -- since there are two mappings, there are two errseq_t's and
you'd need a since cursor for each. I don't really like having to add a
second 32-bit word to struct file, but I also don't see a real
alternative right offhand. May be able to stash it in file->private_data 
for some of these filesystems.

In any case, I'll ponder how to do this in a more piecemeal way.

Thanks for all of the review so far!
-- 
Jeff Layton <jlayton@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
