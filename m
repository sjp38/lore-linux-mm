Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j96CR9pr015443
	for <linux-mm@kvack.org>; Thu, 6 Oct 2005 08:27:09 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j96CTf9L549958
	for <linux-mm@kvack.org>; Thu, 6 Oct 2005 06:29:41 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j96CSvOo007529
	for <linux-mm@kvack.org>; Thu, 6 Oct 2005 06:28:57 -0600
Subject: Re: [PATCH] dcache: separate slab for directory dentries
From: Dave Kleikamp <shaggy@austin.ibm.com>
In-Reply-To: <20051006062739.GP9519161@melbourne.sgi.com>
References: <20050911105709.GA16369@thunk.org>
	 <20050911120045.GA4477@in.ibm.com> <20050912031636.GB16758@thunk.org>
	 <20050913084752.GC4474@in.ibm.com>
	 <20050913215932.GA1654338@melbourne.sgi.com>
	 <20051006062739.GP9519161@melbourne.sgi.com>
Content-Type: text/plain
Date: Thu, 06 Oct 2005 07:28:50 -0500
Message-Id: <1128601731.9358.2.camel@kleikamp.austin.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: gnb@sgi.com, David Chinner <dgc@sgi.com>
Cc: Bharata B Rao <bharata@in.ibm.com>, Dipankar Sarma <dipankar@in.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2005-10-06 at 16:27 +1000, David Chinner wrote:
> +/*
> + * If the given dentry is not suitable for the inode, reallocate
> + * it, copy across the dentry's data and return the new one.  Only
> + * useful when the dentry has not yet been attached to inode or
> + * hashed, which is why it's a lot simpler than d_move().  Returns
> + * NULL if the dentry is suitable,  Called with dcache_lock, drops
> + * and regains.
> + */
> +static struct dentry * d_realloc_for_inode(struct dentry * dentry,
> +					   struct inode *inode)
> +{
> +	int flags = 0;
> +	struct dentry *new;
> +	struct dentry *parent;
> +	
> +	BUG_ON(dentry == NULL);
> +	BUG_ON(dentry->d_inode != NULL);
> +	BUG_ON(inode == NULL);
> +	BUG_ON(dentry->d_parent == NULL || dentry->d_parent == dentry);
> +
> +	if (S_ISDIR(inode->i_mode))
> +		flags |= DCACHE_DIRSLAB;
> +	if ((flags & DCACHE_DIRSLAB) == (dentry->d_flags & DCACHE_DIRSLAB))
> +		return NULL;	/* dentry is suitable */
> +
> +	parent = dentry->d_parent;
> +	list_del_init(&dentry->d_child);
> +
> +	spin_unlock(&dcache_lock);
> +	
> +	new = __d_alloc(parent, &dentry->d_name, dentry->d_flags | flags);
> +
> +	spin_lock(&dcache_lock);
> +
> +	BUG_ON(new == NULL);	/* TODO */
> +	if (new) {
> +//		new->d_op = dentry->d_op;
> +//		new->d_fsdata = dentry->d_fsdata;
> +	}
> +	
> +	return new;
> +}

Isn't this leaking the original dentry?  Shouldn't it be doing a dput or
at least a d_free here?
-- 
David Kleikamp
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
