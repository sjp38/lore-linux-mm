Date: Mon, 29 May 2006 18:32:01 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [rfc][patch] remove racy sync_page?
Message-Id: <20060529183201.0e8173bc.akpm@osdl.org>
In-Reply-To: <447B8CE6.5000208@yahoo.com.au>
References: <447AC011.8050708@yahoo.com.au>
	<20060529121556.349863b8.akpm@osdl.org>
	<447B8CE6.5000208@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mason@suse.com, andrea@suse.de, hugh@veritas.com, axboe@suse.de, torvalds@osdl.org
List-ID: <linux-mm.kvack.org>

On Tue, 30 May 2006 10:08:06 +1000
Nick Piggin <nickpiggin@yahoo.com.au> wrote:

> > 
> > Try disabling kblockd completely, see what effect that has on performance.
> 
> Which is what I want to know. I don't exactly have an interesting
> disk setup.

You don't need one - just a single disk should show up such problems.  I
forget which workloads though.  Perhaps just a linear read (readahead
queues the I/O but doesn't unplug, subsequent lock_page() sulks).

> >>Can we get rid of the whole thing, confusing memory barriers and all? Nobody
> >>uses anything but the default sync_page, and if block rq plugging is terribly
> >>bad for performance, perhaps it should be reworked anyway? It shouldn't be a
> >>correctness thing, right?
> > 
> > 
> > What this means is that it is not legal to run lock_page() against a
> > pagecache page if you don't have a ref on the inode.
> 
> Yes. So set_page_dirty_lock is broken, right?

yup.

> And the wait_on_page_stuff needs an inode ref.
> Also splice seems to have broken sync_page.

Please describe the splice() problem which you've observed.

> > 
> > iirc the main (only?) offender here is direct-io reads into MAP_SHARED
> > pagecache.  (And similar things, like infiniband and nfs-direct).
> 
> Well yes, writing to a page would be the main reason to set it dirty.
> Is splice broken as well? I'm not sure that it always has a ref on the
> inode when stealing a page.

Whereabouts?

> It sounds like you think fixing the set_page_dirty_lock callers wouldn't
> be too difficult? I wouldn't know (although the ptrace one should be
> able to be turned into a set_page_dirty, because we're holding mmap_sem).

No, I think it's damn impossible ;)

get_user_pages() has gotten us a random pagecache page.  How do we
non-racily get at the address_space prior to locking that page?

I don't think we can.

> You're sure about all other lock_page()rs? I'm not, given that
> set_page_dirty_lock got it so wrong. But you'd have a better idea than
> me.

No, I'm not sure.

However it is rare for the kernel to play with pagecache pages against
which the caller doesn't have an inode ref.  Think: how did the caller look
up that page in the first place if not from the address_space in the first
place?

- get_user_pages(): the current problem

- page LRU: OK, uses trylock first.

- pagetable walk??

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
