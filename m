Message-ID: <447B8CE6.5000208@yahoo.com.au>
Date: Tue, 30 May 2006 10:08:06 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [rfc][patch] remove racy sync_page?
References: <447AC011.8050708@yahoo.com.au> <20060529121556.349863b8.akpm@osdl.org>
In-Reply-To: <20060529121556.349863b8.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mason@suse.com, andrea@suse.de, hugh@veritas.com, axboe@suse.de, torvalds@osdl.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Mon, 29 May 2006 19:34:09 +1000
> Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 
> 
>>I'm not completely sure whether this is the bug or not,
> 
> 
> "the bug".  Are we suposed to know what yo're referring to here?

You were supposed to know, if I hadn't made a typo :) "a bug".

> 
> 
>>nor what would be
>>the performance consequences of my attached fix (wrt the block layer). So
>>you're probably cc'ed because I've found similar threads with your names
>>on them.
>>
> 
> 
> The performance risk is that someone will do lock_page() against a page
> whose IO is queued-but-not-yet-kicked-off.  We'll go to sleep with no IO
> submitted until kblockd or someone else kicks off the IO for us.

Yes.

> 
> Try disabling kblockd completely, see what effect that has on performance.

Which is what I want to know. I don't exactly have an interesting
disk setup.

>>Can we get rid of the whole thing, confusing memory barriers and all? Nobody
>>uses anything but the default sync_page, and if block rq plugging is terribly
>>bad for performance, perhaps it should be reworked anyway? It shouldn't be a
>>correctness thing, right?
> 
> 
> What this means is that it is not legal to run lock_page() against a
> pagecache page if you don't have a ref on the inode.

Yes. So set_page_dirty_lock is broken, right?
And the wait_on_page_stuff needs an inode ref.
Also splice seems to have broken sync_page.

> 
> iirc the main (only?) offender here is direct-io reads into MAP_SHARED
> pagecache.  (And similar things, like infiniband and nfs-direct).

Well yes, writing to a page would be the main reason to set it dirty.
Is splice broken as well? I'm not sure that it always has a ref on the
inode when stealing a page.

It sounds like you think fixing the set_page_dirty_lock callers wouldn't
be too difficult? I wouldn't know (although the ptrace one should be
able to be turned into a set_page_dirty, because we're holding mmap_sem).

You're sure about all other lock_page()rs? I'm not, given that
set_page_dirty_lock got it so wrong. But you'd have a better idea than
me.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
