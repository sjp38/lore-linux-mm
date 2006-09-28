Date: Thu, 28 Sep 2006 09:36:40 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Checking page_count(page) in invalidate_complete_page
Message-Id: <20060928093640.14ecb1b1.akpm@osdl.org>
In-Reply-To: <451BF7BC.1040807@oracle.com>
References: <4518333E.2060101@oracle.com>
	<20060925141036.73f1e2b3.akpm@osdl.org>
	<45185D7E.6070104@yahoo.com.au>
	<451862C5.1010900@oracle.com>
	<45186481.1090306@yahoo.com.au>
	<45186DC3.7000902@oracle.com>
	<451870C6.6050008@yahoo.com.au>
	<4518835D.3080702@oracle.com>
	<451886FB.50306@yahoo.com.au>
	<451BF7BC.1040807@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: chuck.lever@oracle.com
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Trond Myklebust <Trond.Myklebust@netapp.com>, Steve Dickson <steved@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 28 Sep 2006 12:26:36 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> Hi Nick-
> 
> Nick Piggin wrote:
> >> The page references I'm noting are:
> >>
> >> 1.  add_to_page_cache_lru  1 -> 2
> >>
> >> 2.  do_generic_mapping_read, released in nfs_do_filldir
> >>
> >> 3.  read_cache_page, released in nfs_readdir
> >>
> >> 4.  pagevec_lookup (from invalidate_inode_pages2_range)  2 -> 3
> >>
> >> The odd thing is some of the pages for the directory are released, so 
> >> they must have a ref count of 2 *after* the pagevec_lookup.  Looks 
> >> like more investigation is needed.
> > 
> > 
> > Well they could get flushed out of the lru add pagevecs which drops 
> > their count. Just to
> > test that theory you could run lru_add_drain_all() at the start of the 
> > invalidate function.
> > That's not going to actually fix the problem, but it might help 2.6.18 
> > limp along when
> > combined with some other work.
> 
> I've verified that the pages that fail to be invalidated are indeed 
> languishing in the per-CPU lru-add pagevec.  Adding a call to 
> lru_add_drain_all() to the invalidate_inode_pages2() path does fix the 
> NFS readdir problem.
> 
> I think a call to lru_add_drain_all() belongs in both the 
> invalidate_inode_pages() and the invalidate_inode_pages2() path.  Do you 
> agree?

Yes.  But the page-pinned-by-vmscan scenario which you earlier identified
can still happen, I believe.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
