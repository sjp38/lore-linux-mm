Date: Wed, 26 Apr 2000 14:00:31 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [PATCH] 2.3.99-pre6-3+  VM rebalancing
Message-ID: <20000426140031.L3792@redhat.com>
References: <Pine.LNX.4.21.0004251757360.9768-100000@alpha.random> <Pine.LNX.4.21.0004251418520.10408-100000@duckman.conectiva> <20000425113616.A7176@stormix.com> <3905EB26.8DBFD111@mandrakesoft.com> <20000425120657.B7176@stormix.com> <20000426120130.E3792@redhat.com> <200004261125.EAA12302@pizda.ninka.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <200004261125.EAA12302@pizda.ninka.net>; from davem@redhat.com on Wed, Apr 26, 2000 at 04:25:23AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: sct@redhat.com, sim@stormix.com, jgarzik@mandrakesoft.com, riel@nl.linux.org, andrea@suse.de, linux-mm@kvack.org, bcrl@redhat.com, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Apr 26, 2000 at 04:25:23AM -0700, David S. Miller wrote:
> 
>    Getting the VM to respond properly in a way which doesn't freak out
>    in the mass-filescan case is non-trivial.  Simple LRU over all pages
>    simply doesn't cut it.
> 
> I believe this is not true at all.  Clean pages will be preferred to
> toss simply because they are easier to get rid of.

As soon as you differentiate between clean and dirty page again, you
no longer have pure LRU.  We're agreeing here --- LRU on its own is not
enough, you need _some_ mechanism to give preference to the eviction of
clean, pure cache pages.  Whether it's different queues, or separate
mechanisms for swapout as we have now, is a different issue --- the one
thing we cannot afford is blind LRU without any feedback on the
properties of the pages themselves.

> I am of the opinion that vmscan.c:swap_out() is one of our biggest
> problems, because it kills us in the case where a few processes have
> a pagecache page mapped, haven't accessed it in a long time, and
> swap_out doesn't unmap those pages in time for the LRU shrink_mmap
> code to fully toss it.

Yep

> This happens even though these pages are
> excellant candidates for freeing.  So here is where I came to the
> conclusion that LRU needs to have the capability of tossing arbitrary
> pages from process address spaces.  This is why in my experiental
> hacks I just killed swap_out() completely, and taught LRU how to
> do all of the things swap_out did.  I could do this because the
> LRU scanner could go from a page to all mappings of that page, even
> for anonymous and swap pages.

Doing it isn't the problem.  Doing it efficiently is, if you have 
fork() and mremap() in the picture.  With mremap(), you cannot assume
that the virtual address of an anonymous page is the same in all
processes which have the page mapped.

So, basically, to find all the ptes for a given page, you have to
walk every single vma in every single mm which is a fork()ed 
ancestor or descendent of the mm whose address_space you indexed
the page against.

Granted, it's probably faster than the current swap_out mechanism, but
the worst case is still not much fun if you have fragmented address
spaces with a lot of vmas. 

Detecting the right vma isn't hard, because the vma's vm_pgoff is
preserved over mremap().  It's the linear scan that is the danger.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
