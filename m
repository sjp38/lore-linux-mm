Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA25762
	for <linux-mm@kvack.org>; Wed, 10 Feb 1999 14:03:12 -0500
Date: Wed, 10 Feb 1999 20:00:08 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Reply-To: Andrea Arcangeli <andrea@e-mind.com>
Subject: [patch] shrink_mmap from O(num_physpages) to O(nr_lru_pages)
In-Reply-To: <Pine.LNX.3.96.990124192824.208A-100000@laser.bogus>
Message-ID: <Pine.LNX.3.96.990210182856.351C-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: werner@suse.de, linux@billabong.demon.co.uk, justice@quantumres.com, zimerman@deskmail.com, gerritse@wnet.bos.nl, dlux@dlux.sch.bme.hu, jalvo@cloud9.net, ebiederm+eric@ccr.net, steve@netplus.net, "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, Richard Gooch <rgooch@atnf.csiro.au>, "David S. Miller" <davem@dm.cobaltmicro.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

shrink_mmap() in 2.2.2-pre2 is extremely inefficient when the number of
pages in the buffer cache and in the page cache is very low compared with
the number of physical pages (it's just an overkill with 128mbyte of phys 
memory when the system start to have <100pages in the cache).

We are wasting time with the excuse that such wasted time will give us a
view on the state of the memory (checking the shrink_mmap() retval). But
wasting time is really not needed. To know when to swapout we don't need
the info about the size of the cache and of the buffers, but instead we
need info about the usage pattern of the buffer and file cache (if most
of the cache is unused shrink it, otherwise generate new swap cache
freeable pages).

I can't think how much bad can perform the current shrink_mmap() in a
machine that act as DBMS server with say 1.5Giga of shm locked memory and
10/20Mbyte of RAM used as buffer/file cache.

There's another really not nice (only a bit minor) issue about
shrink_mmap(). Since we only have one bit of aging we risk very easily to
free pages from the cache and from the buffers without a perfect lru
basis.

So currently if you have for example 128mbyte of RAM used for 99% in
cache, when you'll run a:

	cat /usr/bin/* >/dev/null

you are not sure that if you'll run it again you won't need I/O even if
the size of /usr/bin is less then 128mbyte.

This happend because you could have this memory pattern:

	A B C D E F G H I L M N O P Q R S T U V Z

(forget the foregin Italy chars because I don't remeber where they are
placed ;)

When you run a proggy you could play with pages H and _then_ F.

	A B C D E F G H I L M N O P Q R S T U V Z
            ^     2   1

But if shrink_mmap() is starting from page C, you'll get the page F freed
before the page H (while instead with a perfect lru algorithm you would
have H freed before F). Explode this scenario with a bit more of pages
than the Italian chars and you'll see the bad behavior.

So I fixed these two issues reimplementing shrink_mmap using a lru list
that avoid shrink_mmap() to waste time with pages that are not in the
buffer cache or in the file cache, and to force shrink_mmap() to free
pages in a perfect lru basis. 

The only remark of my implementation is that it enlarges the kernel of 8
byte for every page in the system. So in my 128mbyte machine I get
262kbyte less of usable ram but I have no dubit that it worth. Other than
this memory wasting issue my implementation is strightforward and clean
(this last adjective from my eyes point of view at least ;). 

Incidentally I also had the idea to make the mem_map struct cacheline
aligned in SMP. I would like if you Richard would try out my patch with
the L1 cachealigned mem_map struct just to see if it will make any
difference for your -sometimes-bad-performances- issues (the reason you
get interested in the page colouring algorithm).

You can download the whole lru patch with included the mem_map
cachealigned thing against 2.2.2-pre2 here: 

	ftp://e-mind.com/pub/linux/kernel-patches/lru-VM-2.2.2-pre2.gz

This other incremental patch against lru-VM-2.2.2-pre2 remove the mem_map
cacheline aligned thing, I would like if people that see variable
performances in SMP could make comparision with and without this patch
applyed: 

	ftp://e-mind.com/pub/linux/kernel-patches/lru-VM-2.2.2-pre2-nocacheline

This last incremental patch again against lru-VM-2.2.2-pre2 try to
preserve the file cache working set, while it try to get rid of swap cache
pages very more easily. I don't think it's the right thing to do but I
would like if you could make comparison:

	ftp://e-mind.com/pub/linux/kernel-patches/lru-VM-2.2.2-pre2-swap-cache-noage

NOTE: you can apply both lru-VM-2.2.2-pre2-nocacheline and
lru-VM-2.2.2-pre2-swap-cache-noage at once over lru-VM-2.2.2-pre2.

The patch is always been rock solid here (never failed since the first
boot yesterday afternoon) so I don't think you have to worry too much
about stability.

I don't have the time to make benchmarks (not more than run a trashing
proggy and see the iteractive feeling and the swapout speed and the
stability). While the swapout speed is mainly the same (due I/O hardware
limits), the iteractive feeling is greatly improved. I don't have numbers
and I would like if somebody of you could produce some number ;). 

I have no dubit that if there is somebody out there that is using a
machine with > 1 Giga of memory of which only <100Mbyte are used in buffer
and cache will see a _great_ improvement with this patch applyed.

Comments?

Andrea Arcangeli

PS. You can find my new lru shrink_mmap() also in 2.2.2-pre2_arca-2.gz

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
