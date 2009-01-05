Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D25E26B00B6
	for <linux-mm@kvack.org>; Mon,  5 Jan 2009 15:13:08 -0500 (EST)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n05KBn0l014434
	for <linux-mm@kvack.org>; Mon, 5 Jan 2009 15:11:49 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n05KD6ef186620
	for <linux-mm@kvack.org>; Mon, 5 Jan 2009 15:13:06 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n05LDA44026184
	for <linux-mm@kvack.org>; Mon, 5 Jan 2009 16:13:17 -0500
Date: Mon, 5 Jan 2009 12:12:58 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [patch] mm: fix lockless pagecache reordering bug (was Re:
	BUG: soft lockup - is this XFS problem?)
Message-ID: <20090105201258.GN6959@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20081230042333.GC27679@wotan.suse.de> <20090103214443.GA6612@infradead.org> <20090105014821.GA367@wotan.suse.de> <20090105041959.GC367@wotan.suse.de> <20090105064838.GA5209@wotan.suse.de> <49623384.2070801@aon.at> <20090105164135.GC32675@wotan.suse.de> <alpine.LFD.2.00.0901050859430.3057@localhost.localdomain> <20090105180008.GE32675@wotan.suse.de> <alpine.LFD.2.00.0901051027011.3057@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.0901051027011.3057@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Peter Klotz <peter.klotz@aon.at>, stable@kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Christoph Hellwig <hch@infradead.org>, Roman Kononov <kernel@kononov.ftml.net>, linux-kernel@vger.kernel.org, xfs@oss.sgi.com, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 05, 2009 at 10:44:27AM -0800, Linus Torvalds wrote:
> On Mon, 5 Jan 2009, Nick Piggin wrote:
> > On Mon, Jan 05, 2009 at 09:30:55AM -0800, Linus Torvalds wrote:
> > Putting an rcu_dereference there might work, but I think it misses a 
> > subtlety of this code.
> 
> No, _you_ miss the subtlety of something that can change under you.
> 
> Look at radix_tree_deref_slot(), and realize that without the 
> rcu_dereference(), the compiler would actually be allowed to think that it 
> can re-load anything from *pslot several times. So without my one-liner 
> patch, the compiler can actually do this:
> 
> 	register = load_from_memory(pslot)
> 	if (radix_tree_is_indirect_ptr(register))
> 		goto fail:
> 	return load_from_memory(pslot);
> 
>    fail:
> 	return RADIX_TREE_RETRY;

My guess is that Nick believes that the value in *pslot cannot change
in such as way as to cause radix_tree_is_indirect_ptr()'s return value
to change within a given RCU grace period, and that Linus disagrees.

Whatever the answer, I would argue for -at- -least- a comment explaining
why it is safe.  I am not seeing the objection to rcu_dereference(), but
I must confess that it has been awhile since I have looked closely at
the radix_tree code.  :-/

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
