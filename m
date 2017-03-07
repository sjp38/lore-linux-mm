Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 646506B038B
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 05:26:27 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id u9so109315wme.6
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 02:26:27 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y63si30172280wrb.176.2017.03.07.02.26.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Mar 2017 02:26:25 -0800 (PST)
Date: Tue, 7 Mar 2017 11:26:22 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 0/3] mm/fs: get PG_error out of the writeback reporting
 business
Message-ID: <20170307102622.GB2578@quack2.suse.cz>
References: <20170305133535.6516-1-jlayton@redhat.com>
 <1488724854.2925.6.camel@redhat.com>
 <20170306230801.GA28111@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170306230801.GA28111@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Jeff Layton <jlayton@redhat.com>, viro@zeniv.linux.org.uk, konishi.ryusuke@lab.ntt.co.jp, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-nilfs@vger.kernel.org, NeilBrown <neilb@suse.com>, Jan Kara <jack@suse.cz>

On Mon 06-03-17 16:08:01, Ross Zwisler wrote:
> On Sun, Mar 05, 2017 at 09:40:54AM -0500, Jeff Layton wrote:
> > On Sun, 2017-03-05 at 08:35 -0500, Jeff Layton wrote:
> > > I recently did some work to wire up -ENOSPC handling in ceph, and found
> > > I could get back -EIO errors in some cases when I should have instead
> > > gotten -ENOSPC. The problem was that the ceph writeback code would set
> > > PG_error on a writeback error, and that error would clobber the mapping
> > > error.
> > > 
> > 
> > I should also note that relying on PG_error to report writeback errors
> > is inherently unreliable as well. If someone calls sync() before your
> > fsync gets in there, then you'll likely lose it anyway.
> > 
> > filemap_fdatawait_keep_errors will preserve the error in the mapping,
> > but not the individual PG_error flags, so I think we do want to ensure
> > that the mapping error is set when there is a writeback error and not
> > rely on PG_error bit for that.
> > 
> > > While I fixed that problem by simply not setting that bit on errors,
> > > that led me down a rabbit hole of looking at how PG_error is being
> > > handled in the kernel.
> > > 
> > > This patch series is a few fixes for things that I 100% noticed by
> > > inspection. I don't have a great way to test these since they involve
> > > error handling. I can certainly doctor up a kernel to inject errors
> > > in this code and test by hand however if these look plausible up front.
> > > 
> > > Jeff Layton (3):
> > >   nilfs2: set the mapping error when calling SetPageError on writeback
> > >   mm: don't TestClearPageError in __filemap_fdatawait_range
> > >   mm: set mapping error when launder_pages fails
> > > 
> > >  fs/nilfs2/segment.c |  1 +
> > >  mm/filemap.c        | 19 ++++---------------
> > >  mm/truncate.c       |  6 +++++-
> > >  3 files changed, 10 insertions(+), 16 deletions(-)
> > > 
> > 
> > (cc'ing Ross...)
> > 
> > Just when I thought that only NILFS2 needed a little work here, I see
> > another spot...
> > 
> > I think that we should also need to fix dax_writeback_mapping_range to
> > set a mapping error on writeback as well. It looks like that's not
> > happening today. Something like the patch below (obviously untested).
> > 
> > I'll also plan to follow up with a patch to vfs.txt to outline how
> > writeback errors should be handled by filesystems, assuming that this
> > patchset isn't completely off base.
> > 
> > -------------------8<-----------------------
> > 
> > [PATCH] dax: set error in mapping when writeback fails
> > 
> > In order to get proper error codes from fsync, we must set an error in
> > the mapping range when writeback fails.
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  fs/dax.c | 4 +++-
> >  1 file changed, 3 insertions(+), 1 deletion(-)
> > 
> > diff --git a/fs/dax.c b/fs/dax.c
> > index c45598b912e1..9005d90deeda 100644
> > --- a/fs/dax.c
> > +++ b/fs/dax.c
> > @@ -888,8 +888,10 @@ int dax_writeback_mapping_range(struct address_space *mapping,
> >  
> >  			ret = dax_writeback_one(bdev, mapping, indices[i],
> >  					pvec.pages[i]);
> > -			if (ret < 0)
> > +			if (ret < 0) {
> > +				mapping_set_error(mapping, ret);
> >  				return ret;
> > +			}
> 
> (Adding Jan)
> 
> I tested this a bit, and for the DAX case at least I don't think this does
> what you want.  The current code already returns -EIO if dax_writeback_one()
> hits an error, which bubbles up through the call stack and makes the fsync()
> call in userspace fail with EIO, as we want.  With both ext4 and xfs this
> patch (applied to v4.10) makes it so that we fail the current fsync() due to
> the return value of -EIO, then we fail the next fsync() as well because only
> then do we actually process the AS_EIO flag inside of filemap_check_errors().
> 
> I think maybe the missing piece is that our normal DAX fsync call stack
> doesn't include a call to filemap_check_errors() if we return -EIO.  Here's
> our stack in xfs:
> 
>     dax_writeback_mapping_range+0x32/0x70
>     xfs_vm_writepages+0x8c/0xf0
>     do_writepages+0x21/0x30
>     __filemap_fdatawrite_range+0xc6/0x100
>     filemap_write_and_wait_range+0x44/0x90
>     xfs_file_fsync+0x7a/0x2c0
>     vfs_fsync_range+0x4b/0xb0
>     ? trace_hardirqs_on_caller+0xf5/0x1b0
>     do_fsync+0x3d/0x70
>     SyS_fsync+0x10/0x20
>     entry_SYSCALL_64_fastpath+0x1f/0xc2
> 
> On the subsequent fsync() call we *do* end up calling filemap_check_errors()
> via filemap_fdatawrite_range(), which tests & clears the AS_EIO flag in the
> mapping:
> 
>     filemap_fdatawait_range+0x3b/0x80
>     filemap_write_and_wait_range+0x5a/0x90
>     xfs_file_fsync+0x7a/0x2c0
>     vfs_fsync_range+0x4b/0xb0
>     ? trace_hardirqs_on_caller+0xf5/0x1b0
>     do_fsync+0x3d/0x70
>     SyS_fsync+0x10/0x20
>     entry_SYSCALL_64_fastpath+0x1f/0xc2
> 
> Was your concern just that you didn't think that fsync() was properly
> returning an error when dax_writeback_one() hit an error?  Or is there another
> path by which we need to report the error, where it is actually important that
> we set AS_EIO?  If it's the latter, then I think we need to rework the fsync
> call path so that we both generate and consume AS_EIO on the same call,
> probably in filemap_write_and_wait_range().

So I believe this is due to the special handling of EIO inside
filemap_write_and_wait(). Normally, filemap_check_errors() happens inside
filemap_fdatawait() there however not for EIO returned from
filemap_fdatawrite(). In that case we bail out immediately. So I think
Jeff's patch is correct but we need to change filemap_write_and_wait() to
call also filemap_check_errors() directly on EIO from filemap_fdatawrite().

On a more general note (DAX is actually fine here), I find the current
practice of clearing page dirty bits on error and reporting it just once
problematic. It keeps the system running but data is lost and possibly
without getting the error anywhere where it is useful. We get away with
this because it is a rare event but it seems like a problematic behavior.
But this is more for the discussion at LSF.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
