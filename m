In-reply-to: <20080317220821.d0adb692.akpm@linux-foundation.org> (message from
	Andrew Morton on Mon, 17 Mar 2008 22:08:21 -0700)
Subject: Re: [patch 6/8] fuse: clean up setting i_size in write
References: <20080317191908.123631326@szeredi.hu>
	<20080317191947.989369784@szeredi.hu> <20080317220821.d0adb692.akpm@linux-foundation.org>
Message-Id: <E1JbX05-0005If-Iu@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Tue, 18 Mar 2008 09:16:49 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: miklos@szeredi.hu, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Mon, 17 Mar 2008 20:19:14 +0100 Miklos Szeredi <miklos@szeredi.hu> wrote:
> 
> > From: Miklos Szeredi <mszeredi@suse.cz>
> > 
> > Extract common code for setting i_size in write functions into a
> > common helper.
> > 
> > Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
> > ---
> >  fs/fuse/file.c |   28 +++++++++++++++-------------
> >  1 file changed, 15 insertions(+), 13 deletions(-)
> > 
> > Index: linux/fs/fuse/file.c
> > ===================================================================
> > --- linux.orig/fs/fuse/file.c	2008-03-17 18:26:04.000000000 +0100
> > +++ linux/fs/fuse/file.c	2008-03-17 18:26:28.000000000 +0100
> > @@ -610,13 +610,24 @@ static int fuse_write_begin(struct file 
> >  	return 0;
> >  }
> >  
> > +static void fuse_write_update_size(struct inode *inode, loff_t pos)
> > +{
> > +	struct fuse_conn *fc = get_fuse_conn(inode);
> > +	struct fuse_inode *fi = get_fuse_inode(inode);
> > +
> > +	spin_lock(&fc->lock);
> > +	fi->attr_version = ++fc->attr_version;
> > +	if (pos > inode->i_size)
> > +		i_size_write(inode, pos);
> > +	spin_unlock(&fc->lock);
> > +}
> >
> > ...
> >
> > @@ -766,12 +772,8 @@ static ssize_t fuse_direct_io(struct fil
> >  	}
> >  	fuse_put_request(fc, req);
> >  	if (res > 0) {
> > -		if (write) {
> > -			spin_lock(&fc->lock);
> > -			if (pos > inode->i_size)
> > -				i_size_write(inode, pos);
> > -			spin_unlock(&fc->lock);
> > -		}
> > +		if (write)
> > +			fuse_write_update_size(inode, pos);
> 
> We require that i_mutex be held here, to prevent i_size_write() deadlocks. 
> Is it held?
> 

No, fuse uses the per connection spinlock to protect against
concurrent calls to i_size_write(), because in some cases holding
i_mutex would be difficult.

Fuse already got painfully bitten by the i_size_write() deadlock, so
I'm well aware of the problem :)

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
