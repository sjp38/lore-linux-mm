Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 67B336B02E1
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 05:38:54 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id f187so83149931ite.5
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 02:38:54 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z31si3938186ita.41.2017.04.25.02.38.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 25 Apr 2017 02:38:53 -0700 (PDT)
Date: Tue, 25 Apr 2017 10:17:20 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v3 10/20] fuse: set mapping error in writepage_locked
 when it fails
Message-ID: <20170425081720.GA2793@quack2.suse.cz>
References: <20170424132259.8680-1-jlayton@redhat.com>
 <20170424132259.8680-11-jlayton@redhat.com>
 <20170424160431.GK23988@quack2.suse.cz>
 <1493054076.2895.17.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1493054076.2895.17.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-cifs@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, osd-dev@open-osd.org, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org, dhowells@redhat.com, akpm@linux-foundation.org, hch@infradead.org, ross.zwisler@linux.intel.com, mawilcox@microsoft.com, jack@suse.com, viro@zeniv.linux.org.uk, corbet@lwn.net, neilb@suse.de, clm@fb.com, tytso@mit.edu, axboe@kernel.dk

On Mon 24-04-17 13:14:36, Jeff Layton wrote:
> On Mon, 2017-04-24 at 18:04 +0200, Jan Kara wrote:
> > On Mon 24-04-17 09:22:49, Jeff Layton wrote:
> > > This ensures that we see errors on fsync when writeback fails.
> > > 
> > > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > 
> > Hum, but do we really want to clobber mapping errors with temporary stuff
> > like ENOMEM? Or do you want to handle that in mapping_set_error?
> > 
> 
> Right now we don't really have such a thing as temporary errors in the
> writeback codepath. If you return an error here, the data doesn't stay
> dirty or anything, and I think we want to ensure that that gets reported
> via fsync.
> 
> I'd like to see us add better handling for retryable errors for stuff
> like ENOMEM or EAGAIN. I think this is the first step toward that
> though. Once we have more consistent handling of writeback errors in
> general, then we can start doing more interesting things with retryable
> errors.
> 
> So yeah, I this is the right thing to do for now.

OK, fair enough. And question number 2):

Who is actually responsible for setting the error in the mapping when error
happens inside ->writepage()? Is it the ->writepage() callback or the
caller of ->writepage()? Or something else? Currently it seems to be a
strange mix (e.g. mm/page-writeback.c: __writepage() calls
mapping_set_error() when ->writepage() returns error) so I'd like to
understand what's the plan and have that recorded in the changelogs.

								Honza

> 
> > 
> > > ---
> > >  fs/fuse/file.c | 1 +
> > >  1 file changed, 1 insertion(+)
> > > 
> > > diff --git a/fs/fuse/file.c b/fs/fuse/file.c
> > > index ec238fb5a584..07d0efcb050c 100644
> > > --- a/fs/fuse/file.c
> > > +++ b/fs/fuse/file.c
> > > @@ -1669,6 +1669,7 @@ static int fuse_writepage_locked(struct page *page)
> > >  err_free:
> > >  	fuse_request_free(req);
> > >  err:
> > > +	mapping_set_error(page->mapping, error);
> > >  	end_page_writeback(page);
> > >  	return error;
> > >  }
> > > -- 
> > > 2.9.3
> > > 
> > > 
> 
> -- 
> Jeff Layton <jlayton@redhat.com>
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
