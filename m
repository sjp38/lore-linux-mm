Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id B85196B02E1
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 06:35:20 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id i18so47432118qte.1
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 03:35:20 -0700 (PDT)
Received: from mail-qt0-f179.google.com (mail-qt0-f179.google.com. [209.85.216.179])
        by mx.google.com with ESMTPS id a48si21564387qte.93.2017.04.25.03.35.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Apr 2017 03:35:19 -0700 (PDT)
Received: by mail-qt0-f179.google.com with SMTP id c45so135578176qtb.1
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 03:35:17 -0700 (PDT)
Message-ID: <1493116513.2758.1.camel@redhat.com>
Subject: Re: [PATCH v3 10/20] fuse: set mapping error in writepage_locked
 when it fails
From: Jeff Layton <jlayton@redhat.com>
Date: Tue, 25 Apr 2017 06:35:13 -0400
In-Reply-To: <20170425081720.GA2793@quack2.suse.cz>
References: <20170424132259.8680-1-jlayton@redhat.com>
	 <20170424132259.8680-11-jlayton@redhat.com>
	 <20170424160431.GK23988@quack2.suse.cz>
	 <1493054076.2895.17.camel@redhat.com>
	 <20170425081720.GA2793@quack2.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-cifs@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, osd-dev@open-osd.org, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org, dhowells@redhat.com, akpm@linux-foundation.org, hch@infradead.org, ross.zwisler@linux.intel.com, mawilcox@microsoft.com, jack@suse.com, viro@zeniv.linux.org.uk, corbet@lwn.net, neilb@suse.de, clm@fb.com, tytso@mit.edu, axboe@kernel.dk

On Tue, 2017-04-25 at 10:17 +0200, Jan Kara wrote:
> On Mon 24-04-17 13:14:36, Jeff Layton wrote:
> > On Mon, 2017-04-24 at 18:04 +0200, Jan Kara wrote:
> > > On Mon 24-04-17 09:22:49, Jeff Layton wrote:
> > > > This ensures that we see errors on fsync when writeback fails.
> > > > 
> > > > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > > 
> > > Hum, but do we really want to clobber mapping errors with temporary stuff
> > > like ENOMEM? Or do you want to handle that in mapping_set_error?
> > > 
> > 
> > Right now we don't really have such a thing as temporary errors in the
> > writeback codepath. If you return an error here, the data doesn't stay
> > dirty or anything, and I think we want to ensure that that gets reported
> > via fsync.
> > 
> > I'd like to see us add better handling for retryable errors for stuff
> > like ENOMEM or EAGAIN. I think this is the first step toward that
> > though. Once we have more consistent handling of writeback errors in
> > general, then we can start doing more interesting things with retryable
> > errors.
> > 
> > So yeah, I this is the right thing to do for now.
> 
> OK, fair enough. And question number 2):
> 
> Who is actually responsible for setting the error in the mapping when error
> happens inside ->writepage()? Is it the ->writepage() callback or the
> caller of ->writepage()? Or something else? Currently it seems to be a
> strange mix (e.g. mm/page-writeback.c: __writepage() calls
> mapping_set_error() when ->writepage() returns error) so I'd like to
> understand what's the plan and have that recorded in the changelogs.
> 

That's an excellent question.

I think we probably want the writepage/launder_page operations to call
mapping_set_error. That makes it possible for filesystems (e.g. NFS) to
handle their own error tracking and reporting without using the new
infrastructure. If they never call mapping_set_error then we'll always
just return whatever their ->fsync operation returns on an fsync.

I'll make another pass through the tree and see whether we have some
mapping_set_error calls that should be removed, and will flesh out
vfs.txt to state this. Maybe that file needs a whole section on
writeback error reporting? Hmmm...

That probably also means that I should drop patch 8 from this series
(mm: ensure that we set mapping error if writeout fails), since that
should be happening in writepage already.

> > 
> > > 
> > > > ---
> > > >  fs/fuse/file.c | 1 +
> > > >  1 file changed, 1 insertion(+)
> > > > 
> > > > diff --git a/fs/fuse/file.c b/fs/fuse/file.c
> > > > index ec238fb5a584..07d0efcb050c 100644
> > > > --- a/fs/fuse/file.c
> > > > +++ b/fs/fuse/file.c
> > > > @@ -1669,6 +1669,7 @@ static int fuse_writepage_locked(struct page *page)
> > > >  err_free:
> > > >  	fuse_request_free(req);
> > > >  err:
> > > > +	mapping_set_error(page->mapping, error);
> > > >  	end_page_writeback(page);
> > > >  	return error;
> > > >  }
> > > > -- 
> > > > 2.9.3
> > > > 
> > > > 
> > 
> > -- 
> > Jeff Layton <jlayton@redhat.com>

-- 
Jeff Layton <jlayton@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
