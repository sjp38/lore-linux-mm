Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA05641
	for <linux-mm@kvack.org>; Mon, 13 Jul 1998 14:30:05 -0400
Subject: Re: More info: 2.1.108 page cache performance on low memory
References: <199807131653.RAA06838@dax.dcs.ed.ac.uk> <m190lxmxmv.fsf@flinx.npwt.net>
Reply-To: Zlatko.Calusic@CARNet.hr
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 13 Jul 1998 20:29:33 +0200
In-Reply-To: ebiederm+eric@npwt.net's message of "13 Jul 1998 13:08:56 -0500"
Message-ID: <87lnpxy582.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@npwt.net>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

ebiederm+eric@npwt.net (Eric W. Biederman) writes:

> >>>>> "ST" == Stephen C Tweedie <sct@redhat.com> writes:
> 
> ST> Hi all,
> ST> OK, a bit more benchmarking is showing bad problems with page ageing.
> ST> I've been running 2.1 with a big ramdisk and without, with page ageing
> ST> and without.  The results for a simple compile job (make a few
> ST> dependency files then compile four .c files) look like this:
> 
> ST> 	2.0.34, 6m ram:			1:22
> 
> ST> 	2.1.108, 16m ram, 10m ramdisk:
> ST> 		With page cache ageing:	Not usable (swap death during boot.)
> ST> 		Without cache ageing:	8:47
> 
> ST> 	2.1.108, 6m ram:
> ST> 		With page cache ageing:	4:14
> ST> 		Without cache ageing:	3:22

I agree that ageing of the page cache has a bad impact on the
performance.

Benchmarking disks reveals much lower read speed, mostly thanks to
unneeded excessive swapping produced by outswapping pages that will be
again swapped in, in few seconds (page cache likes to take 90% of
memory when copying large files). This produces lots of redundant head 
movement (not to mention copying pages...) which effectively cuts read 
speed to half.

I personally run a system with heavily patched VM subsystem, at least
for the last three months.

Sad thing is that my patch mostly undo latest changes. :(

Just to mention, I have 64MB of physical memory, and my machine is
definitely not memory starved, but it also suffers from some of the
recent VM changes.

> 
> O.k. Just a few thoughts.
> 1) We have a minimum size for the buffer cache in percent of physical pages.
>    Setting the minimum to 0% may help.
> 
> 2) If we play with LRU list it may be most practical use page->next and page->prev
>    fields for the list, and for truncate_inode_pages && invalidate_inode_pages
> do something like:
> for(i = 0; i < inode->i_size; i+= PAGE_SIZE) {
> 	page = find_in_page_cache(inode, i);
> 	if (page) 
> 		/* remove it */
> 		;
> }
> And remove the inode->i_pages list.  This should be roughly equivalent
> to the bforgets needed by truncate anyway so should impose not large
> peformance penalty.
> 
> Personally I think it is broken to set the limits of cache sizes
> (buffer & page) to anthing besides: max=100% min=0% by default.

Exactly.

That (removing cache limits) is one of my favorite changes.

Free memory == unused memory == bad policy!

There is no reason why any of the caches would not utilize all of the
free memory at any given moment.

But, we must be very careful to swap out only unneeded pages if we
decide to enlarge cache on the behalf of the text and data pages.

> 
> But now that we have this hand tuneing option in addition to auto
> tuning we should experiment with it as well.
> 

If anybody want to see, I can provide benchmark results, but I'm not
prepared to compile another kernel image if nobody's interested. :)

Regards!
-- 
Posted by Zlatko Calusic           E-mail: <Zlatko.Calusic@CARNet.hr>
---------------------------------------------------------------------
	    10 out of 5 doctors feel it's OK to be skitzo!
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
