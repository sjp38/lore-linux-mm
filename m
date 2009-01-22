Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 0934A6B0044
	for <linux-mm@kvack.org>; Thu, 22 Jan 2009 12:22:55 -0500 (EST)
Date: Thu, 22 Jan 2009 17:22:39 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 2.6.28 1/2] memory: improve find_vma
In-Reply-To: <8c5a844a0901220851g1c21169al4452825564487b9a@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0901221658550.14302@blonde.anvils>
References: <8c5a844a0901220851g1c21169al4452825564487b9a@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Daniel Lowengrub <lowdanie@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 22 Jan 2009, Daniel Lowengrub wrote:
> The goal of this patch is to improve the efficiency of the find_vma
> function in mm/mmap.c. The function first checks whether the vma
> stored in the cache is the one it's looking for. Currently, it's
> possible for the cache to be correct and still get rejected because
> the function checks whether the given address is inside the vma in the
> cache, not whether the cached vma is the smallest one that's bigger
> than the address.  To solve this problem I turned the list of vma's
> into a doubly linked list, and using that list made a function that
> can check if a given vma is the one that find_vma is looking for.
> This gives a greater number of cache hits than the standerd method.
> The doubly linked list can be used to optimize other parts of the
> memory management as well.  I'll implement some of those possibilities
> in the next patch.
> Signed-off-by: Daniel Lowengrub <lowdanie@gmail.com>

Do you have some performance figures to support this patch?
Some of the lmbench tests may be appropriate.

The thing is, expanding vm_area_struct to include another pointer
will have its own cost, which may well outweigh the efficiency
(in one particular case) which you're adding.  Expanding mm_struct
for this would be much more palatable, but I don't think that flies.

And it seems a little greedy to require both an rbtree and a doubly
linked list for working our way around the vmas.

I suspect that originally your enhancement would only have hit when
extending the stack: which I guess isn't enough to justify the cost.
But it could well be that unmapped area handling has grown more
complex down the years, and you get some hits now from that.

You mention using the doubly linked list to optimize some other parts
of mm too: I guess those interfaces where we have to pass around prev
would be simplified, are you thinking of those, or something else?

(I don't think we need unmap_vmas to go backwards!)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
