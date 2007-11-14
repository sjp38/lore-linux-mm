Subject: Re: [PATCH 3/3] nfs: use ->mmap_prepare() to avoid an AB-BA
	deadlock
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <1195076485.7584.66.camel@heimdal.trondhjem.org>
References: <20071114200136.009242000@chello.nl>
	 <20071114201528.514434000@chello.nl> <20071114212246.GA31048@wotan.suse.de>
	 <1195075905.22457.3.camel@lappy>
	 <1195076485.7584.66.camel@heimdal.trondhjem.org>
Content-Type: text/plain
Date: Wed, 14 Nov 2007 22:50:34 +0100
Message-Id: <1195077034.22457.6.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-fsdevel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-11-14 at 16:41 -0500, Trond Myklebust wrote:
> On Wed, 2007-11-14 at 22:31 +0100, Peter Zijlstra wrote:
> > On Wed, 2007-11-14 at 22:22 +0100, Nick Piggin wrote:
> > > On Wed, Nov 14, 2007 at 09:01:39PM +0100, Peter Zijlstra wrote:
> > > > Normal locking order is:
> > > > 
> > > >   i_mutex
> > > >     mmap_sem
> > > > 
> > > > However NFS's ->mmap hook, which is called under mmap_sem, can take i_mutex.
> > > > Avoid this potential deadlock by doing the work that requires i_mutex from
> > > > the new ->mmap_prepare().
> > > > 
> > > > [ Is this sufficient, or does it introduce a race? ]
> > > 
> > > Seems like an OK patchset in my opinion. I don't know much about NFS
> > > unfortunately, but I wonder what prevents the condition fixed by
> > > nfs_revalidate_mapping from happening again while the mmap is active...?
> > 
> > As the changelog might have suggested, I'm not overly sure of the nfs
> > requirements myself. I think it just does a best effort at getting the
> > pages coherent with other clients, and then hopes for the best.
> > 
> > I'll let Trond enlighten us further before I make an utter fool of
> > myself :-)
> 
> The NFS client needs to check the validity of already cached data before
> it allows those pages to be mmapped. If it finds out that the cache is
> stale, then we need to call invalidate_inode_pages2() to clear out the
> cache and refresh it from the server. The inode->i_mutex is necessary in
> order to prevent races between the new writes and the cache invalidation
> code.

Right, but I guess what Nick asked is, if pages could be stale to start
with, how is that avoided in the future.

The way I understand it, this re-validate is just a best effort at
getting a coherent image.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
