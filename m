Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0EBA76B008A
	for <linux-mm@kvack.org>; Sat, 28 Feb 2009 21:45:24 -0500 (EST)
Date: Sun, 1 Mar 2009 03:45:21 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch][rfc] mm: new address space calls
Message-ID: <20090301024521.GB16742@wotan.suse.de>
References: <20090225104839.GG22785@wotan.suse.de> <20090228232421.GB11191@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090228232421.GB11191@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, Feb 28, 2009 at 06:24:21PM -0500, Christoph Hellwig wrote:
> On Wed, Feb 25, 2009 at 11:48:39AM +0100, Nick Piggin wrote:
> > This is about the last change to generic code I need for fsblock.
> > Comments?
> > 
> > Introduce new address space operations sync and release, which can be used
> > by a filesystem to synchronize and release per-address_space private metadata.
> > They generalise sync_mapping_buffers, invalidate_inode_buffers, and
> > remove_inode_buffers calls, and get another step closer to divorcing
> > buffer heads from core mm/fs code.
> 
> >  void invalidate_inode_buffers(struct inode *inode)
> >  {
> > -	if (inode_has_buffers(inode)) {
> > -		struct address_space *mapping = &inode->i_data;
> > +	struct address_space *mapping = &inode->i_data;
> > +
> > +	if (mapping_has_private(mapping)) {
> >  		struct list_head *list = &mapping->private_list;
> >  		struct address_space *buffer_mapping = mapping->assoc_mapping;
> 
> I'ts not really helping much here as we still directly poke into the
> buffer_head list.

This is in fs/buffer.c.

Or do you object to the definition of mapping_has_private? Yes that
still checks the private_list, but it would be trivial to convert it
over to checking a bit in the mapping now. I just didn't do it because
fsblock also uses the private_list.

> 
> > --- linux-2.6.orig/fs/fs-writeback.c
> > +++ linux-2.6/fs/fs-writeback.c
> > @@ -782,9 +782,15 @@ int generic_osync_inode(struct inode *in
> >  	if (what & OSYNC_DATA)
> >  		err = filemap_fdatawrite(mapping);
> >  	if (what & (OSYNC_METADATA|OSYNC_DATA)) {
> > -		err2 = sync_mapping_buffers(mapping);
> > -		if (!err)
> > -			err = err2;
> > +		if (!mapping->a_ops->sync) {
> > +			err2 = sync_mapping_buffers(mapping);
> > +			if (!err)
> > +				err = err2;
> > +		} else {
> > +			err2 = mapping->a_ops->sync(mapping);
> > +			if (!err)
> > +				err = err2;
> > +		}
> >  	}
> >  	if (what & OSYNC_DATA) {
> >  		err2 = filemap_fdatawait(mapping);
> 
> I'd really prefer not having the default fallbacks, these kinds
> of implicit fallbacks make the code really hard to maintain over
> long term.

That seems to be the default way of adding callbacks, but
I agree I don't like it really and I don't like the existing
fallbacks in the tree.

 
> I also wonder if moving the filemap_fdatawrite/filemap_fdatawait
> into the method would help.  In fact it's surprisingly similar
> to ->fsync in many ways, that I wonder if these should be one
> operation.

It would be nice if possible. Do you have an fsync patchset
coming along?


> >   */
> >  void clear_inode(struct inode *inode)
> >  {
> > +	struct address_space *mapping = &inode->i_data;
> > +
> >  	might_sleep();
> > -	invalidate_inode_buffers(inode);
> > +	if (!mapping->a_ops->release)
> > +		invalidate_inode_buffers(inode);
> 
> That's a weird one.  The implict default shouldn't be in a different
> place from the method.

It really sucks in there. buffer.c even has a "FIXME: invalidate_inode
buffers should not be called in clear_inode"... Of course buffer.c is
never going to be fixed, but I didn't want to carry that over to
fsblock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
