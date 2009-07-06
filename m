Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id F41906B0062
	for <linux-mm@kvack.org>; Mon,  6 Jul 2009 13:32:09 -0400 (EDT)
Date: Mon, 6 Jul 2009 20:10:26 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 1/3] fs: new truncate sequence
Message-ID: <20090706181026.GW2714@wotan.suse.de>
References: <20090706165438.GQ2714@wotan.suse.de> <E1MNsU3-0002Lx-8T@pomaz-ex.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E1MNsU3-0002Lx-8T@pomaz-ex.szeredi.hu>
Sender: owner-linux-mm@kvack.org
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: linux-fsdevel@vger.kernel.org, hch@infradead.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 06, 2009 at 08:00:07PM +0200, Miklos Szeredi wrote:
> > Index: linux-2.6/mm/truncate.c
> > ===================================================================
> > --- linux-2.6.orig/mm/truncate.c
> > +++ linux-2.6/mm/truncate.c
> > @@ -465,3 +465,79 @@ int invalidate_inode_pages2(struct addre
> >  	return invalidate_inode_pages2_range(mapping, 0, -1);
> >  }
> >  EXPORT_SYMBOL_GPL(invalidate_inode_pages2);
> > +
> > +/**
> > + * truncate_pagecache - unmap mappings "freed" by truncate() syscall
> > + * @inode: inode
> > + * @old: old file offset
> > + * @new: new file offset
> > + *
> > + * inode's new i_size must already be written before truncate_pagecache
> > + * is called.
> > + */
> > +void truncate_pagecache(struct inode * inode, loff_t old, loff_t new)
> > +{
> > +	VM_BUG_ON(inode->i_size != new);
> 
> This is not true for fuse (and NFS?) as i_size isn't protected by
> i_mutex during attribute revalidation, and so it can change during the
> truncate.

Hmm, that's probably OK now. filemap_fault has some tricky code
to avoid faulting in pages past i_size, but since that has been
changed to use page lock a while back, the i_size checks can
probably go away.

So long as your filesystems obviously have to ensure the truncate
will not truncate the wrong pages, I can remove the VM_BUG_ON
just fine.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
