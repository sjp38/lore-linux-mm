Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id AA2EF8D0040
	for <linux-mm@kvack.org>; Fri,  1 Apr 2011 23:35:41 -0400 (EDT)
Received: from kpbe13.cbf.corp.google.com (kpbe13.cbf.corp.google.com [172.25.105.77])
	by smtp-out.google.com with ESMTP id p323ZdYe005596
	for <linux-mm@kvack.org>; Fri, 1 Apr 2011 20:35:39 -0700
Received: from iyj12 (iyj12.prod.google.com [10.241.51.76])
	by kpbe13.cbf.corp.google.com with ESMTP id p323Z9i8003443
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 1 Apr 2011 20:35:38 -0700
Received: by iyj12 with SMTP id 12so5248715iyj.13
        for <linux-mm@kvack.org>; Fri, 01 Apr 2011 20:35:34 -0700 (PDT)
Date: Fri, 1 Apr 2011 20:35:41 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] ramfs: fix memleak on no-mmu arch
In-Reply-To: <20110328170220.fc61fb5c.akpm@linux-foundation.org>
Message-ID: <alpine.LSU.2.00.1104011953350.3340@sister.anvils>
References: <1301290355-8980-1-git-send-email-lliubbo@gmail.com> <20110328170220.fc61fb5c.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Bob Liu <lliubbo@gmail.com>, linux-mm@kvack.org, viro@zeniv.linux.org.uk, hch@lst.de, npiggin@kernel.dk, tj@kernel.org, dhowells@redhat.com, lethal@linux-sh.org, magnus.damm@gmail.com

On Mon, 28 Mar 2011, Andrew Morton wrote:
> On Mon, 28 Mar 2011 13:32:35 +0800
> Bob Liu <lliubbo@gmail.com> wrote:
> 
> > On no-mmu arch, there is a memleak duirng shmem test.
> > The cause of this memleak is ramfs_nommu_expand_for_mapping() added page
> > refcount to 2 which makes iput() can't free that pages.
> > ...
> > 
> > diff --git a/fs/ramfs/file-nommu.c b/fs/ramfs/file-nommu.c
> > index 9eead2c..fbb0b47 100644
> > --- a/fs/ramfs/file-nommu.c
> > +++ b/fs/ramfs/file-nommu.c
> > @@ -112,6 +112,7 @@ int ramfs_nommu_expand_for_mapping(struct inode *inode, size_t newsize)
> >  		SetPageDirty(page);
> >  
> >  		unlock_page(page);
> > +		put_page(page);
> >  	}
> >  
> >  	return 0;
> 
> Something is still wrong here.

I don't think so.

> 
> A live, in-use page should have a refcount of three.  One for the
> existence of the page, one for its presence on the page LRU and one for
> its existence in the pagecache radix tree.

No, we don't count 1 for the LRU: it always seems a little odd that
we don't, but that's how it is.  I did dive into the debugger to
check that is really still the case.  And it doesn't really matter
here, since of course we don't count -1 when taking off LRU either.

The pages here are not "in-use" as such: we're just priming the
page cache with them, so they will be found shortly afterwards
when they do come into use, when inserted into the address space.

What if memory pressure comes in and frees them before then?
Er, er, that gave me a nasty turn.  But there's a comment
just above the SetPageDirty visible in Bob's patch, saying
/* prevent the page from being discarded on memory pressure */

> 
> So allocation should do:
> 
> 	alloc_pages()

Yes, it did that (along with a split_page we can ignore here).

> 	add_to_page_cache()
> 	add_to_lru()

And those it did in the combined function add_to_page_cache_lru().

> 
> and deallocation should do
> 
> 	remove_from_lru()
> 	remove_from_page_cache()

Nowadays delete_from_page_cache(), which decrements the reference
acquired in add_to_page_cache().

> 	put_page()
> 
> If this protocol is followed correctly, there is no need to do a
> put_page() during the allocation/setup phase!

There is a get_page() when each page is mapped into the address
space, which then matches the final put_page() you show above.

> 
> I suspect that the problem in nommu really lies in the
> deallocation/teardown phase.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
