Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
	by kanga.kvack.org (Postfix) with ESMTP id 918476B0035
	for <linux-mm@kvack.org>; Wed, 24 Sep 2014 04:57:30 -0400 (EDT)
Received: by mail-lb0-f169.google.com with SMTP id b12so10302450lbj.0
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 01:57:29 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e7si21929847lag.100.2014.09.24.01.57.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 24 Sep 2014 01:57:27 -0700 (PDT)
Date: Wed, 24 Sep 2014 10:57:24 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/2] ext4: Fix mmap data corruption when blocksize <
 pagesize
Message-ID: <20140924085724.GA21864@quack.suse.cz>
References: <1411484603-17756-1-git-send-email-jack@suse.cz>
 <1411484603-17756-3-git-send-email-jack@suse.cz>
 <20140924084519.GA21987@quack.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="MGYHOYXEY6WxJCY8"
Content-Disposition: inline
In-Reply-To: <20140924084519.GA21987@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, linux-ext4@vger.kernel.org, Ted Tso <tytso@mit.edu>, Jan Kara <jack@suse.cz>, xfs@oss.sgi.com


--MGYHOYXEY6WxJCY8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed 24-09-14 10:45:19, Jan Kara wrote:
> On Tue 23-09-14 17:03:23, Jan Kara wrote:
> > Use block_create_hole() when hole is being created in a file so that
> > ->page_mkwrite() will get called for the partial tail page if it is
> > mmaped (see the first patch in the series for details).
>   Just out of curiosity I did a change similar to this one for ext4 to XFS
> and indeed it fixed generic/030 test failures for XFS with blocksize 1k.
  Just for reference attached the patch I was testing - I can resend with
proper changelog etc. if people are fine with this approach.

								Honza

> > Signed-off-by: Jan Kara <jack@suse.cz>
> > ---
> >  fs/ext4/inode.c | 6 +++++-
> >  1 file changed, 5 insertions(+), 1 deletion(-)
> > 
> > diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
> > index 3aa26e9117c4..fdcb007c2c9e 100644
> > --- a/fs/ext4/inode.c
> > +++ b/fs/ext4/inode.c
> > @@ -4536,8 +4536,12 @@ int ext4_setattr(struct dentry *dentry, struct iattr *attr)
> >  				ext4_orphan_del(NULL, inode);
> >  				goto err_out;
> >  			}
> > -		} else
> > +		} else {
> > +			loff_t old_size = inode->i_size;
> > +
> >  			i_size_write(inode, attr->ia_size);
> > +			block_create_hole(inode, old_size, inode->i_size);
> > +		}
> >  
> >  		/*
> >  		 * Blocks are going to be removed from the inode. Wait
> > -- 
> > 1.8.1.4
> > 
> -- 
> Jan Kara <jack@suse.cz>
> SUSE Labs, CR
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ext4" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--MGYHOYXEY6WxJCY8
Content-Type: text/x-patch; charset=us-ascii
Content-Disposition: attachment; filename="0001-xfs-Fix-mmap-data-corruption.patch"


--MGYHOYXEY6WxJCY8--
