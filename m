Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C783F8D003A
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 09:14:45 -0500 (EST)
In-reply-to: <20110120124043.GA4347@infradead.org> (message from Christoph
	Hellwig on Thu, 20 Jan 2011 07:40:43 -0500)
Subject: Re: [PATCH] mm: prevent concurrent unmap_mapping_range() on the same
 inode
References: <E1PftfG-0007w1-Ek@pomaz-ex.szeredi.hu> <20110120124043.GA4347@infradead.org>
Message-Id: <E1PfvGx-00086O-IA@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 20 Jan 2011 15:13:59 +0100
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, hughd@google.com, gurudas.pai@oracle.com, lkml20101129@newton.leun.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 20 Jan 2011, Christoph Hellwig wrote:
> On Thu, Jan 20, 2011 at 01:30:58PM +0100, Miklos Szeredi wrote:
> > From: Miklos Szeredi <mszeredi@suse.cz>
> > 
> > Running a fuse filesystem with multiple open()'s in parallel can
> > trigger a "kernel BUG at mm/truncate.c:475"
> > 
> > The reason is, unmap_mapping_range() is not prepared for more than
> > one concurrent invocation per inode.  For example:
> > 
> >   thread1: going through a big range, stops in the middle of a vma and
> >      stores the restart address in vm_truncate_count.
> > 
> >   thread2: comes in with a small (e.g. single page) unmap request on
> >      the same vma, somewhere before restart_address, finds that the
> >      vma was already unmapped up to the restart address and happily
> >      returns without doing anything.
> > 
> > Another scenario would be two big unmap requests, both having to
> > restart the unmapping and each one setting vm_truncate_count to its
> > own value.  This could go on forever without any of them being able to
> > finish.
> > 
> > Truncate and hole punching already serialize with i_mutex.  Other
> > callers of unmap_mapping_range() do not, and it's difficult to get
> > i_mutex protection for all callers.  In particular ->d_revalidate(),
> > which calls invalidate_inode_pages2_range() in fuse, may be called
> > with or without i_mutex.
> 
> 
> Which I think is mostly a fuse problem.  I really hate bloating the
> generic inode (into which the address_space is embedded) with another
> mutex for deficits in rather special case filesystems. 

As Hugh pointed out unmap_mapping_range() has grown a varied set of
callers, which are difficult to fix up wrt i_mutex.  Fuse was just an
example.

I don't like the bloat either, but this is the best I could come up
with for fixing this problem generally.  If you have a better idea,
please share it.

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
