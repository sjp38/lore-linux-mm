Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5D8756B003D
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 05:58:38 -0400 (EDT)
Subject: Re: [PATCH 1/2] mm: use list.h for vma list
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <8c5a844a0903110255q45b7cdf4u1453ce40d495ee2c@mail.gmail.com>
References: <8c5a844a0903110255q45b7cdf4u1453ce40d495ee2c@mail.gmail.com>
Content-Type: text/plain
Date: Thu, 12 Mar 2009 10:58:32 +0100
Message-Id: <1236851912.5090.93.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daniel Lowengrub <lowdanie@gmail.com>
Cc: linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, Alexey Dobriyan <adobriyan@gmail.com>, Wolfram Strepp <wstrepp@gmx.de>
List-ID: <linux-mm.kvack.org>

On Wed, 2009-03-11 at 11:55 +0200, Daniel Lowengrub wrote:
> Use the linked list defined list.h for the list of vmas that's stored
> in the mm_struct structure.  Wrapper functions "vma_next" and
> "vma_prev" are also implemented.  Functions that operate on more than
> one vma are now given a list of vmas as input.
> 
> Signed-off-by: Daniel Lowengrub

While this is the approach I've taken for a patch I'm working on, a
better solution has come up if you keep the RB tree (I don't).

It is, however, even more invasive than the this one ;-)

Wolfram has been working on implementing a threaded RB-tree. This means
rb_prev() and rb_next() will be O(1) operations, so you could simply use
those to iterate the vmas.

The only draw-back is that each and every RB-tree user in the kernel
needs to be adapted because its not quite possible to maintain the
current API.

I was planning to help Wolfram do that, but I'm utterly swamped atm. :-(

What needs to be done is introduce rb_left(), rb_right() and rb_node()
helpers that for now look like:

static inline struct rb_node *rb_left(struct rb_node *n)
{
	return n->rb_left;
}

static inline struct rb_node *rb_right(struct rb_node *n)
{
	return n->rb_right;
}

static inline struct rb_node *rb_node(struct rb_node *n)
{
	return n;
}

We need these because the left and right child pointers will be
over-loaded with threading information.

After that we can flip the implementation of the RB-tree.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
