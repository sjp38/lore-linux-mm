Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e31.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j97D0280002531
	for <linux-mm@kvack.org>; Fri, 7 Oct 2005 09:00:02 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j97D0wvl515850
	for <linux-mm@kvack.org>; Fri, 7 Oct 2005 07:00:58 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j97D0vES002911
	for <linux-mm@kvack.org>; Fri, 7 Oct 2005 07:00:58 -0600
Subject: Re: [PATCH] dcache: separate slab for directory dentries
From: Dave Kleikamp <shaggy@austin.ibm.com>
In-Reply-To: <1128657277.6710.826.camel@hole.melbourne.sgi.com>
References: <20050911105709.GA16369@thunk.org>
	 <20050911120045.GA4477@in.ibm.com> <20050912031636.GB16758@thunk.org>
	 <20050913084752.GC4474@in.ibm.com>
	 <20050913215932.GA1654338@melbourne.sgi.com>
	 <20051006062739.GP9519161@melbourne.sgi.com>
	 <1128601731.9358.2.camel@kleikamp.austin.ibm.com>
	 <1128657277.6710.826.camel@hole.melbourne.sgi.com>
Content-Type: text/plain
Date: Fri, 07 Oct 2005 08:00:56 -0500
Message-Id: <1128690056.9383.4.camel@kleikamp.austin.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Greg Banks <gnb@melbourne.sgi.com>
Cc: David Chinner <dgc@sgi.com>, Bharata B Rao <bharata@in.ibm.com>, Dipankar Sarma <dipankar@in.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2005-10-07 at 13:54 +1000, Greg Banks wrote:
> On Thu, 2005-10-06 at 22:28, Dave Kleikamp wrote:
> > On Thu, 2005-10-06 at 16:27 +1000, David Chinner wrote:
> > > +static struct dentry * d_realloc_for_inode(struct dentry * dentry,
> > > +					   struct inode *inode)
> > > +{
> > > +	int flags = 0;
> > > +	struct dentry *new;
> > > [...]
> > > +	new = __d_alloc(parent, &dentry->d_name, dentry->d_flags | flags);
> > > +
> > > +	spin_lock(&dcache_lock);
> > > +
> > > +	BUG_ON(new == NULL);	/* TODO */
> > > +	if (new) {
> > > +//		new->d_op = dentry->d_op;
> > > +//		new->d_fsdata = dentry->d_fsdata;
> > > +	}
> > > +	
> > > +	return new;
> > > +}
> > 
> > Isn't this leaking the original dentry?  Shouldn't it be doing a dput or
> > at least a d_free here?
> 
> While it has been some months since I wrote this, and it was not
> intended to be a production patch, I don't believe it leaks dentries.
> 
> The function is called on the path real_lookup() to i_op->lookup() to
> d_splice_alias(), and the original dentry allocated in real_lookup()
> is d_put() there if a non-NULL new dentry pointer is passed back up
> via d_splice_alias() and i_op->lookup().

Yes, you are right.  I've always found the dcache code a little
confusing.  Your patch looks good to me.
-- 
David Kleikamp
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
