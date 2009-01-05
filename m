Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 34E3F6B00C0
	for <linux-mm@kvack.org>; Mon,  5 Jan 2009 16:05:01 -0500 (EST)
Subject: Re: [patch] mm: fix lockless pagecache reordering bug (was Re:
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20090105201258.GN6959@linux.vnet.ibm.com>
References: <20081230042333.GC27679@wotan.suse.de>
	 <20090103214443.GA6612@infradead.org> <20090105014821.GA367@wotan.suse.de>
	 <20090105041959.GC367@wotan.suse.de> <20090105064838.GA5209@wotan.suse.de>
	 <49623384.2070801@aon.at> <20090105164135.GC32675@wotan.suse.de>
	 <alpine.LFD.2.00.0901050859430.3057@localhost.localdomain>
	 <20090105180008.GE32675@wotan.suse.de>
	 <alpine.LFD.2.00.0901051027011.3057@localhost.localdomain>
	 <20090105201258.GN6959@linux.vnet.ibm.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Mon, 05 Jan 2009 22:04:51 +0100
Message-Id: <1231189491.11687.22.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: paulmck@linux.vnet.ibm.com
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Peter Klotz <peter.klotz@aon.at>, stable@kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Christoph Hellwig <hch@infradead.org>, Roman Kononov <kernel@kononov.ftml.net>, linux-kernel@vger.kernel.org, xfs@oss.sgi.com, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2009-01-05 at 12:12 -0800, Paul E. McKenney wrote:
> On Mon, Jan 05, 2009 at 10:44:27AM -0800, Linus Torvalds wrote:
> > On Mon, 5 Jan 2009, Nick Piggin wrote:
> > > On Mon, Jan 05, 2009 at 09:30:55AM -0800, Linus Torvalds wrote:
> > > Putting an rcu_dereference there might work, but I think it misses a 
> > > subtlety of this code.
> > 
> > No, _you_ miss the subtlety of something that can change under you.
> > 
> > Look at radix_tree_deref_slot(), and realize that without the 
> > rcu_dereference(), the compiler would actually be allowed to think that it 
> > can re-load anything from *pslot several times. So without my one-liner 
> > patch, the compiler can actually do this:
> > 
> > 	register = load_from_memory(pslot)
> > 	if (radix_tree_is_indirect_ptr(register))
> > 		goto fail:
> > 	return load_from_memory(pslot);
> > 
> >    fail:
> > 	return RADIX_TREE_RETRY;
> 
> My guess is that Nick believes that the value in *pslot cannot change
> in such as way as to cause radix_tree_is_indirect_ptr()'s return value
> to change within a given RCU grace period, and that Linus disagrees.

Nick's belief would indeed be true IFF all modifying ops including all
uses of radix_tree_replace_slot() are serialized wrt. each other.

However, since radix_tree_deref_slot() is the counterpart of
radix_tree_replace_slot(), one would indeed expect rcu_dereference()
therein, much like Linus suggests.

While what Nick says is true, the lifetime management of the data
objects is arranged externally from the radix tree -- I still think we
need the rcu_dereference() even for that argument, as we want to support
RCU lifetime management as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
