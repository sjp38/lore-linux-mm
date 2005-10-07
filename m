Subject: Re: [PATCH] dcache: separate slab for directory dentries
From: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: <1128601731.9358.2.camel@kleikamp.austin.ibm.com>
References: <20050911105709.GA16369@thunk.org>
	 <20050911120045.GA4477@in.ibm.com> <20050912031636.GB16758@thunk.org>
	 <20050913084752.GC4474@in.ibm.com>
	 <20050913215932.GA1654338@melbourne.sgi.com>
	 <20051006062739.GP9519161@melbourne.sgi.com>
	 <1128601731.9358.2.camel@kleikamp.austin.ibm.com>
Content-Type: text/plain
Message-Id: <1128657277.6710.826.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Date: Fri, 07 Oct 2005 13:54:37 +1000
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Kleikamp <shaggy@austin.ibm.com>
Cc: David Chinner <dgc@sgi.com>, Bharata B Rao <bharata@in.ibm.com>, Dipankar Sarma <dipankar@in.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2005-10-06 at 22:28, Dave Kleikamp wrote:
> On Thu, 2005-10-06 at 16:27 +1000, David Chinner wrote:
> > +static struct dentry * d_realloc_for_inode(struct dentry * dentry,
> > +					   struct inode *inode)
> > +{
> > +	int flags = 0;
> > +	struct dentry *new;
> > [...]
> > +	new = __d_alloc(parent, &dentry->d_name, dentry->d_flags | flags);
> > +
> > +	spin_lock(&dcache_lock);
> > +
> > +	BUG_ON(new == NULL);	/* TODO */
> > +	if (new) {
> > +//		new->d_op = dentry->d_op;
> > +//		new->d_fsdata = dentry->d_fsdata;
> > +	}
> > +	
> > +	return new;
> > +}
> 
> Isn't this leaking the original dentry?  Shouldn't it be doing a dput or
> at least a d_free here?

While it has been some months since I wrote this, and it was not
intended to be a production patch, I don't believe it leaks dentries.

The function is called on the path real_lookup() to i_op->lookup() to
d_splice_alias(), and the original dentry allocated in real_lookup()
is d_put() there if a non-NULL new dentry pointer is passed back up
via d_splice_alias() and i_op->lookup().

>From the 2.6.5-based tree this patch was developed in:

static struct dentry * real_lookup(struct dentry * parent, struct qstr *
name, struct nameidata *nd)
{
...
                struct dentry * dentry = d_alloc(parent, name);
                result = ERR_PTR(-ENOMEM);
                if (dentry) {
                        result = dir->i_op->lookup(dir, dentry, nd);
                        if (result)
                                dput(dentry);
                        else
                                result = dentry;
                }
...
}

STATIC struct dentry *
linvfs_lookup(
        struct inode    *dir,
        struct dentry   *dentry,
        struct nameidata *nd)
{
...
        VOP_LOOKUP(vp, dentry, &cvp, 0, NULL, NULL, error);
...                                                              
        return d_splice_alias(LINVFS_GET_IP(cvp), dentry);
}

Had this been a production patch I might have mentioned this
subtlety in the comments ;-)

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
