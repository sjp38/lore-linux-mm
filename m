Date: Wed, 2 May 2007 15:00:20 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: 2.6.22 -mm merge plans -- vm bugfixes
In-Reply-To: <4638009E.3070408@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0705021418030.16517@blonde.wat.veritas.com>
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
 <4636FDD7.9080401@yahoo.com.au> <Pine.LNX.4.64.0705011931520.16502@blonde.wat.veritas.com>
 <4638009E.3070408@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <andrea@suse.de>, Christoph Hellwig <hch@infradead.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2 May 2007, Nick Piggin wrote:
> Hugh Dickins wrote:
> > 
> > But I was quite disappointed when
> > mm-fix-fault-vs-invalidate-race-for-linear-mappings-fix.patch
> > appeared, putting double unmap_mapping_range calls in.  Certainly
> > you were wrong to take the one out, but a pity to end up with two.
> > 
> > Your comment says/said:
> > The nopage vs invalidate race fix patch did not take care of truncating
> > private COW pages. Mind you, I'm pretty sure this was previously racy
> > even for regular truncate, not to mention vmtruncate_range.
> > 
> > vmtruncate_range (holepunch) was deficient I agree, and though we
> > can now take out your second unmap_mapping_range there, that's only
> > because I've slipped one into shmem_truncate_range.  In due course it
> > needs to be properly handled by noting the range in shmem inode info.
> > 
> > (I think you couldn't take that approach, noting invalid range in
> > ->mapping while invalidating, because NFS has/had some cases of
> > invalidate_whatever without i_mutex?)
> 
> Sorry, I didn't parse this?

I meant that i_size is used to protect against truncation races, but
we have no equivalent inval_start,inval_end in the struct inode or
struct address_space, such as could be used for similar protection
against races while invalidating.

And that IIRC there are places where NFS was doing the invalidation
without i_mutex: so there could be concurrent invalidations, so one
inval_start,inval_end in the structure wouldn't be enough anyway.

> But I wonder whether it is better to do
> it in vmtruncate_range than the filesystem? Private COWed pages are
> not really a filesystem "thing"...

It wasn't the thought of private COWed pages which made me put a
second unmap_mapping_range in shmem_truncate_range, it was its own
internal file<->swap consistency which needed that (as a quick fix).
The real fix to be having a trunc_start,trunc_end or whatever in
the shmem_inode_info (assuming it's not wanted in the common inode:
might be if holepunch spreads e.g. it's been mentioned with fallocate).

Re private COWed pages and holepunch: Miklos and I agree that really
it would be better for holepunch _not_ to remove them - but that's
rather off-topic.

More on-topic, since you suggest doing more within vmtruncate_range
than the filesystem: no, I'm afraid that's misdesigned, and I want
to move almost all of it into the filesystem ->truncate_range.
Because, if what vmtruncate_range is doing before it gets to the
filesystem isn't to be just a waste of time, the filesystem needs
to know what's going on in advance - just as notify_change warns
the filesystem about a coming truncation.  But easier than inventing
some new notification is to move it all into the filesystem, with
unmap_mapping_range+truncate_inode_pages_range its library helpers.

> 
> > But I'm pretty sure (to use your words!) regular truncate was not racy
> > before: I believe Andrea's sequence count was handling that case fine,
> > without a second unmap_mapping_range.
> 
> OK, I think you're right. I _think_ it should also be OK with the
> lock_page version as well: we should not be able to have any pages
> after the first unmap_mapping_range call, because of the i_size
> write. So if we have no pages, there is nothing to 'cow' from.

I'd be delighted if you can remove those later unmap_mapping_ranges.
As I recall, the important thing for the copy pages is to be holding
the page lock (or whatever other serialization) on the copied page
still while the copy page is inserted into pagetable: that looks
to be so in your __do_fault.

> > But it is a shame, and leaves me wondering what you gained with the
> > page lock there.
> > 
> > One thing gained is ease of understanding, and if your later patches
> > build an edifice upon the knowledge of holding that page lock while
> > faulting, I've no wish to undermine that foundation.
> 
> It also fixes a bug, doesn't it? ;)

Well, I'd come to think that perhaps the bugs would be solved by
that second unmap_mapping_range alone, so the pagelock changes
just a misleading diversion.

I'm not sure how I feel about that: calling unmap_mapping_range a
second time feels such a cheat, but if (big if) it does solve the
races, and the pagelock method is as expensive as your numbers
now suggest...

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
