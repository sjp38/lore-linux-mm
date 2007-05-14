Subject: Re: [PATCH 0/2] convert mmap_sem to a scalable rw_mutex
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20070514120737.GE31234@wotan.suse.de>
References: <20070511131541.992688403@chello.nl>
	 <20070511155621.GA13150@elte.hu> <46449F61.2060004@cosmosbay.com>
	 <1178903913.2781.20.camel@lappy>  <20070514120737.GE31234@wotan.suse.de>
Content-Type: text/plain
Date: Mon, 14 May 2007 14:57:28 +0200
Message-Id: <1179147448.6810.79.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Eric Dumazet <dada1@cosmosbay.com>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@tv-sign.ru>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-05-14 at 14:07 +0200, Nick Piggin wrote:
> On Fri, May 11, 2007 at 07:18:33PM +0200, Peter Zijlstra wrote:
> > On Fri, 2007-05-11 at 18:52 +0200, Eric Dumazet wrote:
> > > 
> > > But I personally find this new rw_mutex not scalable at all if you have some 
> > > writers around.
> > > 
> > > percpu_counter_sum is just a L1 cache eater, and O(NR_CPUS)
> > 
> > Yeah, that is true; there are two occurences, the one in
> > rw_mutex_read_unlock() is not strictly needed for correctness.
> > 
> > Write locks are indeed quite expensive. But given the ratio of
> > reader:writer locks on mmap_sem (I'm not all that familiar with other
> > rwsem users) this trade-off seems workable.
> 
> I guess the problem with that logic is assuming the mmap_sem read side
> always needs to be scalable. Given the ratio of threaded:unthreaded
> apps, maybe the trade-off swings away from favour?

Could be; I've been bashing my head against the wall trying to find a
scalable write side solution. But so far only got a massive dent in my
brain from the effort.

Perhaps I can do a similar optimistic locking for my rcu-btree as I did
for the radix tree. That way most of the trouble would be endowed upon
the vmas instead of the mm itself. And then it would be up to user-space
to ensure it has in the order of nr_cpu_ids arenas to work in.

Also, as Hugh pointed out in an earlier thread; mmap_sem's write side
also protects the page tables, so we'd need to fix that up too;
assumedly the write side equivalent of the vma lock would then protect
all underlying page tables....

/me drifting away, rambling incoherently,..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
