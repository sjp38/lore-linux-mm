Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id AA5956B02E1
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 07:19:14 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id o3so17455906pgn.13
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 04:19:14 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t126si22029280pgb.42.2017.04.25.04.19.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 25 Apr 2017 04:19:13 -0700 (PDT)
Date: Tue, 25 Apr 2017 13:19:03 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v3 10/20] fuse: set mapping error in writepage_locked
 when it fails
Message-ID: <20170425111903.GI2793@quack2.suse.cz>
References: <20170424132259.8680-1-jlayton@redhat.com>
 <20170424132259.8680-11-jlayton@redhat.com>
 <20170424160431.GK23988@quack2.suse.cz>
 <1493054076.2895.17.camel@redhat.com>
 <20170425081720.GA2793@quack2.suse.cz>
 <1493116513.2758.1.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1493116513.2758.1.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-cifs@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, osd-dev@open-osd.org, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org, dhowells@redhat.com, akpm@linux-foundation.org, hch@infradead.org, ross.zwisler@linux.intel.com, mawilcox@microsoft.com, jack@suse.com, viro@zeniv.linux.org.uk, corbet@lwn.net, neilb@suse.de, clm@fb.com, tytso@mit.edu, axboe@kernel.dk

On Tue 25-04-17 06:35:13, Jeff Layton wrote:
> On Tue, 2017-04-25 at 10:17 +0200, Jan Kara wrote:
> > On Mon 24-04-17 13:14:36, Jeff Layton wrote:
> > > On Mon, 2017-04-24 at 18:04 +0200, Jan Kara wrote:
> > > > On Mon 24-04-17 09:22:49, Jeff Layton wrote:
> > > > > This ensures that we see errors on fsync when writeback fails.
> > > > > 
> > > > > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > > > 
> > > > Hum, but do we really want to clobber mapping errors with temporary stuff
> > > > like ENOMEM? Or do you want to handle that in mapping_set_error?
> > > > 
> > > 
> > > Right now we don't really have such a thing as temporary errors in the
> > > writeback codepath. If you return an error here, the data doesn't stay
> > > dirty or anything, and I think we want to ensure that that gets reported
> > > via fsync.
> > > 
> > > I'd like to see us add better handling for retryable errors for stuff
> > > like ENOMEM or EAGAIN. I think this is the first step toward that
> > > though. Once we have more consistent handling of writeback errors in
> > > general, then we can start doing more interesting things with retryable
> > > errors.
> > > 
> > > So yeah, I this is the right thing to do for now.
> > 
> > OK, fair enough. And question number 2):
> > 
> > Who is actually responsible for setting the error in the mapping when error
> > happens inside ->writepage()? Is it the ->writepage() callback or the
> > caller of ->writepage()? Or something else? Currently it seems to be a
> > strange mix (e.g. mm/page-writeback.c: __writepage() calls
> > mapping_set_error() when ->writepage() returns error) so I'd like to
> > understand what's the plan and have that recorded in the changelogs.
> > 
> 
> That's an excellent question.
> 
> I think we probably want the writepage/launder_page operations to call
> mapping_set_error. That makes it possible for filesystems (e.g. NFS) to
> handle their own error tracking and reporting without using the new
> infrastructure. If they never call mapping_set_error then we'll always
> just return whatever their ->fsync operation returns on an fsync.

OK, makes sense. It is also in line with what you did for DAX, 9p, or here
for FUSE. So feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

for this patch but please also add a sentense that ->writepage() is
responsible for calling mapping_set_error() if it fails and page is not
redirtied to the changelogs of patches changing writepage handlers.

> I'll make another pass through the tree and see whether we have some
> mapping_set_error calls that should be removed, and will flesh out
> vfs.txt to state this. Maybe that file needs a whole section on
> writeback error reporting? Hmmm...

I think it would be nice to have all the logic described in one place. So
+1 from me.

> That probably also means that I should drop patch 8 from this series
> (mm: ensure that we set mapping error if writeout fails), since that
> should be happening in writepage already.

Yes.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
