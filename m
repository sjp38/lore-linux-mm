Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 855E86B004D
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 13:16:04 -0400 (EDT)
Date: Tue, 22 Sep 2009 19:16:04 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 5/7] ext4: Convert filesystem to the new truncate
	calling convention
Message-ID: <20090922171604.GA31447@duck.suse.cz>
References: <1253200907-31392-1-git-send-email-jack@suse.cz> <1253200907-31392-6-git-send-email-jack@suse.cz> <20090922143604.GA2183@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090922143604.GA2183@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-ext4@vger.kernel.org, linux-mm@kvack.org, npiggin@suse.de, tytso@mit.edu
List-ID: <linux-mm.kvack.org>

On Tue 22-09-09 15:36:04, Al Viro wrote:
> On Thu, Sep 17, 2009 at 05:21:45PM +0200, Jan Kara wrote:
> > CC: linux-ext4@vger.kernel.org
> > CC: tytso@mit.edu
> > Signed-off-by: Jan Kara <jack@suse.cz>
> > ---
> >  fs/ext4/file.c  |    2 +-
> >  fs/ext4/inode.c |  166 ++++++++++++++++++++++++++++++++----------------------
> >  2 files changed, 99 insertions(+), 69 deletions(-)
> > 
> > diff --git a/fs/ext4/file.c b/fs/ext4/file.c
> > index 3f1873f..22f49d7 100644
> > --- a/fs/ext4/file.c
> > +++ b/fs/ext4/file.c
> > @@ -198,7 +198,7 @@ const struct file_operations ext4_file_operations = {
> >  };
> >  
> >  const struct inode_operations ext4_file_inode_operations = {
> > -	.truncate	= ext4_truncate,
> > +	.new_truncate	= 1,
> >  	.setattr	= ext4_setattr,
> >  	.getattr	= ext4_getattr,
> >  #ifdef CONFIG_EXT4_FS_XATTR
> > diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
> > index 58492ab..be25874 100644
> > --- a/fs/ext4/inode.c
> > +++ b/fs/ext4/inode.c
> > @@ -3354,6 +3354,7 @@ static int ext4_journalled_set_page_dirty(struct page *page)
> >  }
> >  
> >  static const struct address_space_operations ext4_ordered_aops = {
> > +	.new_writepage		= 1,
> 
> No.  We already have one half-finished series here; mixing it with another
> one is not going to happen.  Such flags are tolerable only as bisectability
> helpers.  They *must* disappear by the end of series.  Before it can be
> submitted for merge.
> 
> In effect, you are mixing truncate switchover with your writepage one.
> Please, split and reorder.
  Well, this wasn't meant as a final version of those patches. It was
meant as a request for comment whether it makes sence to fix the problem
how I propose to fix it. If we agree on that, I'll go and convert the rest
of filesystems so that we can remove .new_writepage hack. By that time I
hope that new truncate sequence patches will be merged so that dependency
should go away as well...

									Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
