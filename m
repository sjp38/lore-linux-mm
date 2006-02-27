Date: Mon, 27 Feb 2006 07:47:01 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: page_lock_anon_vma(): remove check for mapped page
In-Reply-To: <Pine.LNX.4.61.0602261535350.13368@goblin.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0602270745230.2419@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0602241658030.24668@schroedinger.engr.sgi.com>
 <Pine.LNX.4.61.0602251400520.7164@goblin.wat.veritas.com>
 <Pine.LNX.4.61.0602260359080.9682@goblin.wat.veritas.com>
 <Pine.LNX.4.64.0602252120150.29251@schroedinger.engr.sgi.com>
 <Pine.LNX.4.61.0602261535350.13368@goblin.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 26 Feb 2006, Hugh Dickins wrote:

> > This is so that filesystems can generate their own migration functions. 
> > Filesystem may mantain structures with additional references to the pages 
> > being moved and we cannot move pages with buffers without filesystem 
> > cooperation.
> 
> Hmm.  I'd be happier about them if there were some example in the tree
> of how they should be used from a filesystem: kill the EXPORTs until
> then?  probably too late now, to make that change in 2.6.16.

There is an example in fs/buffer.c and xfs/ext2/ext3 use that sample.

> So long as the filesystem only tries to migrate its own pagecache
> pages, it should be okay (the locking for file pages is not problematic
> as it is for anonymous - probably because we do insist on locking pages
> before truncating or clearing the cache).  But if it were to try to
> migrate the anonymous pages COWed into a private file-based vma,
> without any mmap_sem, then it would be unsafe.  Unlikely mistake.

pagecache pages are not in an anonymous vma and. pte information can be 
reconsituted from the mappings. So the page migration code 
currently simply removes the ptes for those.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
