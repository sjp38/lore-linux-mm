Date: Wed, 25 Jan 2006 16:18:46 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] hugepage allocator cleanup
Message-ID: <20060125151846.GB25666@wotan.suse.de>
References: <20060125091103.GA32653@wotan.suse.de> <20060125150513.GF7655@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060125150513.GF7655@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@osdl.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 25, 2006 at 07:05:13AM -0800, William Lee Irwin III wrote:
> On Wed, Jan 25, 2006 at 10:11:03AM +0100, Nick Piggin wrote:
> > This is a slight rework of the mechanism for allocating "fresh" hugepages.
> > Comments?
> > --
> > Insert "fresh" huge pages into the hugepage allocator by the same
> > means as they are freed back into it. This reduces code size and
> > allows enqueue_huge_page to be inlined into the hugepage free
> > fastpath.
> > Eliminate occurances of hugepages on the free list with non-zero
> > refcount. This can allow stricter refcount checks in future. Also
> > required for lockless pagecache.
> 
> I don't really see any particular benefit to the rearrangement for
> hugetlb's own sake.

I like the fact that freelist pages always have a zero refcount now.
And I thought it was quite neat to set up the page for the new allocator
then free straight into it... but you're right, there is no *particular*
benefit ;)

> Explaining more about how it it's needed for the
> lockless pagecache might help.
> 

OK. Though obviously I don't want to introduce any ugliness or
hackery to core code just for lockless pagecache (which may not
ever go in itself).

Basically with lockless pagecache it becomes possible that any
page taken out of the page allocator may have its refcount raised
by another thread.

That other thread is looking for a pagecache page, if it takes
a reused one, it will quickly drop the refcount again.

So it is important not to muddle the count.  A 1->0 transition
(as currently when allocating fresh pages for the first time)
needs to be done with a dec-and-test rather than a plain set.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
