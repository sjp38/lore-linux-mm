Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 08BC26B0038
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 06:43:38 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id o135so14272635qke.3
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 03:43:38 -0800 (PST)
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com. [209.85.220.174])
        by mx.google.com with ESMTPS id v1si15257224qki.194.2017.03.06.03.43.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Mar 2017 03:43:36 -0800 (PST)
Received: by mail-qk0-f174.google.com with SMTP id v125so87083650qkh.2
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 03:43:36 -0800 (PST)
Message-ID: <1488800614.2989.4.camel@redhat.com>
Subject: Re: [PATCH 0/3] mm/fs: get PG_error out of the writeback reporting
 business
From: Jeff Layton <jlayton@redhat.com>
Date: Mon, 06 Mar 2017 06:43:34 -0500
In-Reply-To: <871subkst8.fsf@notabene.neil.brown.name>
References: <20170305133535.6516-1-jlayton@redhat.com>
	 <871subkst8.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.com>, viro@zeniv.linux.org.uk, konishi.ryusuke@lab.ntt.co.jp
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-nilfs@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On Mon, 2017-03-06 at 14:06 +1100, NeilBrown wrote:
> On Sun, Mar 05 2017, Jeff Layton wrote:
> 
> > I recently did some work to wire up -ENOSPC handling in ceph, and found
> > I could get back -EIO errors in some cases when I should have instead
> > gotten -ENOSPC. The problem was that the ceph writeback code would set
> > PG_error on a writeback error, and that error would clobber the mapping
> > error.
> > 
> > While I fixed that problem by simply not setting that bit on errors,
> > that led me down a rabbit hole of looking at how PG_error is being
> > handled in the kernel.
> 
> Speaking of rabbit holes... I thought to wonder how IO error propagate
> up from NFS.
> It doesn't use SetPageError or mapping_set_error() for files (except in
> one case that looks a bit odd).
> It has an "nfs_open_context" and store the latest error in ctx->error.
> 
> So when you get around to documenting how this is supposed to work, it
> would be worth while describing the required observable behaviour, and
> note that while filesystems can use mapping_set_error() to achieve this,
> they don't have to.
> 
> I notice that
>   drivers/staging/lustre/lustre/llite/rw.c
>   fs/afs/write.c
>   fs/btrfs/extent_io.c
>   fs/cifs/file.c
>   fs/jffs2/file.c
>   fs/jfs/jfs_metapage.c
>   fs/ntfs/aops.c
> 
> (and possible others) all have SetPageError() calls that seem to be
> in response to a write error to a file, but don't appear to have
> matching mapping_set_error() calls.  Did you look at these?  Did I miss
> something?
> 

Those are all in writepage implementations, and the callers of writepage
all call mapping_set_error if it returns error. The exception is
write_one_page, which is typically used for writing out dir info and
such, and so it's not really necessary there.

Now that I look though, I think I may have gotten the page migration
codepath wrong. I had convinced myself it was ok before, but looking
again, I think we probably need to add a mapping_set_error call to 
writeout() as well. I'll go over that more carefully in a little while.

> > 
> > This patch series is a few fixes for things that I 100% noticed by
> > inspection. I don't have a great way to test these since they involve
> > error handling. I can certainly doctor up a kernel to inject errors
> > in this code and test by hand however if these look plausible up front.
> > 
> > Jeff Layton (3):
> >   nilfs2: set the mapping error when calling SetPageError on writeback
> >   mm: don't TestClearPageError in __filemap_fdatawait_range
> >   mm: set mapping error when launder_pages fails
> > 
> >  fs/nilfs2/segment.c |  1 +
> >  mm/filemap.c        | 19 ++++---------------
> >  mm/truncate.c       |  6 +++++-
> >  3 files changed, 10 insertions(+), 16 deletions(-)
> > 
> > -- 
> > 2.9.3

-- 
Jeff Layton <jlayton@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
