Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 84E0D6B004D
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 18:50:20 -0400 (EDT)
Date: Mon, 31 Aug 2009 23:49:44 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: improving checksum cpu consumption in ksm
In-Reply-To: <4A983C52.7000803@redhat.com>
Message-ID: <Pine.LNX.4.64.0908312233340.23516@sister.anvils>
References: <4A983C52.7000803@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 28 Aug 2009, Izik Eidus wrote:
> 
> As you know we are using checksum (jhash) to know if page is changing too
> often, and then if it does we are not inserting it to the unstable tree (so it
> wont get unstable too much at trivial cases)
> 
> This is highly needed for ksm in some workloads - I have seen production
> visualization server that had about 74 or so giga of ram, and the way ksm was
> running there it would take ksm about 6 mins to finish one memory loop, In
> such case the hashing make sure that we will insert pages that are really not
> changing (about 6 mins) and we are protecting our unstable tree, without it,
> if we will insert any page we will end up with an really really unstable tree
> that probably wont find much.
> 
> (There is a case where we don`t calculate jhash - where we actually find two
> identical pages inside the stable tree)
> 
> So after we know why we want to keep this hash/checksum, we want to look how
> we can reduce the cpu cycles that it consume - jhash is very expensive
> And not only that it take cpu cycles it also dirty the cache by walking over
> the whole page...

Not dirtying the cache, I think, but... my mind's gone blank on the
right word too... wasting it anyway.

I wonder what proportion of the cost is the memory accesses and what
proportion is the cost of the jhash algorithm.  My guesses count for
nothing: it's measurement you should be doing.

But the first thing to try (measure) would be Jozsef's patch, updating
jhash.h from the 1996 Jenkins lookup2 to the 2006 Jenkins lookup3,
which is supposed to be a considerable improvement from all angles.

See http://lkml.org/lkml/2009/2/12/65

I think that was the final version of it: I don't know what happened
after that (beyond Eric questioning "deadbeef", but that won't matter
in your testing) - perhaps it was unclear which maintainer should pick
it up, and it then fell through the cracks?

Or, going the other way, how damaging would it be to unstable tree
integrity to use a cheaper hashing algorithm?  There's no perfection
here, a page that's unchanged for one KSM cycle is no way guaranteed
to be unchanged for the next, that's merely an heuristic.

> 
> As for now i see 2 trivials ways how to solve it: (All we need to know is -
> what pages have been changed)
> 1) use the dirty bit of page tables pointing into the page:
>     We can walk over the page tables, and keep cleaning the dirty bit - we are
> using anonymous pages so it shouldnt matther anyone if we clean the dirty bit,

Well, if you clean the pte dirty bit, you must be sure to transfer that
to the page dirty bit, otherwise the anonymous page will be thrown away
as a zero page (or a clean copy of a swap page) when memory is needed.

And beware of s390, which dirties differently.

>     With this case we win 2 things - 1) no cpu cycles on the expensive jhash,
> and 2) no dirty of the cache
>     the dissadvange of this usage is the PAGE_INVALID we need to call of the
> specific tlbs entries associate with the ptes we are clearing the dirty bit:
>     Is it worst than dirty the cache?, is it going to really hurt applications
> performence? (note we are just tlb_flush specific entries, not the entire tlb)
>     If this going to hurt applications pefromence we are better not to deal
> with it, but what do you think about this?

I think three things.

One, that I've no idea, and it's measurement you need.

Two, please keep in mind that it may not be the TLB flush itself that
matters, but the IPI to do it on other CPUs: how much that costs
depends on how much ksmd is running at the same time as threads
of the apps making use of it.

Three, that if we go in this direction, might it be even better to make
the unstable tree stable? i.e. write protect its contents so that we're
sure a node cannot be poisoned with modified data.  It may be
immediately obvious to you that that's a terrible suggestion (all the
overhead of the write faults), but it's not quite obvious to me yet.

I expect a lot depends on the proportions of pages_shared, pages_sharing,
pages_unshared, pages_volatile.  But as I've said before, I've no
feeling yet (or ever?) for the behaviour of the unstable tree: for
example, I've no grasp of whether a large unstable tree is inherently
less stable (more likely to be seriously poisoned) than a small one,
or not.

> 
>     Taking this further more we can use 'unstable dirty bit tracking' - if we
> look on ksm work loads we can split the memory into three diffrent kind of
> pages:
>     a) pages that are identical
>     b) pages that are not identical and keep changing all the time
>     c) pages that are not identical but doesn't change
> 
>     So taking this three type of pages lets assume ksm was using the following
> way to track pages that are changing:
> 
>     Each time ksm find page that its page tables pointing to it are dirty,:
>       ksm will clean the dirty bits out of the ptes (without INVALID_PAGE
> them),
>       and will continue without inserting the page into the unstable tree.
> 
>     Each time ksm will find page that the page tables pointing to it are
> clean:
>       ksm will calucate jhash to know if the page was changed -
>       this is needed due to the fact that we cleaned the dirty bit,
>       but we didnt tlb_flush the tlb entry pointing to the page,
>       so we have to jhash to make sure if the page was changed.

Interesting.  At first I thought that sounded like a worst of all
worlds solution, but perhaps not: the proportions might make that
a very sensible approach.

But playing with the pte dirty bit without flushing TLB is a dangerous
game: you run the risk that MM will catch it at a moment when it looks
clean and free it.  We could, I suppose, change MM to assume that anon
pages are dirty in VM_MERGEABLE areas; but it feels too early for the
KSM tail to be wagging the MM dog in such a way.

> 
>     Now looking on the three diffrent kind of pages
>     a) pages that are identical:
>           would get find anyway when comparing them inside the stable tree
>     b) pages that are not identical and keep changing all the time:
>           Most of the chances that they will appear dirty on the pte, even
> thougth that the tlb entry was not flushed by ksm,
>           If they still wont be dirty, the jhash check will be run on them to
> know if the page was changed,
>           This meaning that most of the time this optimization will save the
> jhash calcualtion to this kind of pages:
>           beacuse when we will see them dirty, we wont need to calcuate the
> jhash.
>     c) pages that are not identical but doesn't change:
>           This kind of pages will always be clean, so we will clacuate jhash
> on them like before.
>  
> 
> 2) Nehalem cpus with sse 4.1 have crc instruction - the good - it going to be
> faster, the bad - only Nehlem and above cpus will have it
>     (Linux already have support for it)

Sounds perfectly sensible to use hardware CRC where it's available;
I expect other architectures have models which support CRC too.

Assuming the characteristics of the hardware CRC are superior to
or close enough to the characteristics of the jhash - I'm entirely
ignorant of CRCs and hashing matters, perhaps nobody would put a 
CRC into their hardware unless it was good enough (but good enough
for what purpose?).

> 
> What you think?, Or am i too much think about the cpu cycles we are burning
> with the jhash?

I do think KSM burns a lot of CPU; but whether it's the jhash or
whether it's all the other stuff (page table walking, radix tree
walking, memcmping) I've not looked.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
