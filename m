Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 9AEA26B0062
	for <linux-mm@kvack.org>; Mon,  4 Jun 2012 23:25:42 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <030ff158-3b2b-47a6-98d7-5010f7a9ce6b@default>
Date: Mon, 4 Jun 2012 20:25:22 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: zsmalloc concerns
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>, Konrad Wilk <konrad.wilk@oracle.com>

Hi Minchan (and all) --

I promised you that after the window closed, I would
write up my concerns about zsmalloc. My preference would
be to use zsmalloc, but there are definitely tradeoffs
and my objective is to make zcache and RAMster ready
for enterprise customers so I would use a different
or captive allocator if these zsmalloc issues can't
be overcome.

Thanks,
Dan

=3D=3D=3D

Zsmalloc is designed to maximize density of items that vary in
size between 0<size<PAGE_SIZE, but especially when the mean
item size significantly exceeds PAGE_SIZE/2.  It is primarily
useful when there are a large quantity of such items to be
stored with little or no space wasted; if the quantity
is small and/or some wasted space is acceptable, existing
kernel allocators (e.g. slab) may be sufficient.  In the
case of zcache (and zram and ramster), where a large fraction
of RAM is used to store zpages (lzo1x-compressed pages),
zsmalloc seems to be a good match.  It is unclear whether
zsmalloc will ever have another user -- unless that user is
also storing large quantities of compressed pages.

Zcache is currently one primary user of zsmalloc, however
zcache only uses zsmalloc for anonymous/swap ("frontswap")
pages, not for file ("cleancache") pages.  For file pages,
zcache uses the captive "zbud" allocator; this is because
zcache requires a shrinker for cleancache pages, by which
entire pageframes can be easily reclaimed.  Zsmalloc doesn't
currently have shrinker capability and, because its
storage patterns in and across physical pageframes are
quite complex (to maximize density), an intelligent reclaim
implementation may be difficult to design race-free.  And
implementing reclaim opaquely (i.e. while maintaining a clean
layering) may be impossible.

A good analogy might be linked-lists.  Zsmalloc is like
a singly-linked list (space-efficient but not as flexible)
and zbud is like a doubly-linked list (not as space-efficient
but more flexible).  One has to choose the best data
structure according to the functionality required.

Some believe that the next step in zcache evolution will
require shrinking of both frontswap and cleancache pages.
Andrea has also stated that he thinks frontswap shrinking
will be a must for any future KVM-tmem implementation.
But preliminary investigations indicate that pageframe reclaim
of frontswap pages may be even more difficult with zsmalloc.
Until this issue is resolved (either by an adequately working
implementation of reclaim with zsmalloc or via demonstration
that zcache reclaim is unnecessary), the future use of zsmalloc
by zcache is cloudy.

I'm currently rewriting zbud as a foundation to investigate
some reclaim policy ideas that I think will be useful both for
KVM and for making zcache "enterprise ready."  When that is
done, we will see if zsmalloc can achieve the same flexibility.

A few related comments about these allocators and their users:

Zsmalloc relies on some clever underlying virtual-to-physical
mapping manipulations to ensure that its users can store and
retrieve items.  These manipulations are necessary on HIGHMEM
processors, but the cost is unclear on non-HIGHMEM processors.
(Manipulating TLB entries is not inexpensive.)  For zcache, the
overhead may be irrelevant as long as it is a small fraction
of the cost of compression/decompression, but it is worth
measuring (worst case) to verify.

Zbud can implement efficient reclaim because no more than two
items ever reside in the same pageframe and items never
cross a pageframe boundary.  While zbud storage is certainly
less dense than zsmalloc, the density is probably sufficient
if the size of items is bell-curve distributed with a mean
size of PAGE_SIZE/2 (or slightly less).  This is true for
many workloads, but datasets where the vast majority of items
exceed PAGE_SIZE/2 render zbud useless.  Note, however, that
zcache (due to its foundation on transcendent memory) currently
implements an admission policy that rejects pages when extreme
datasets are encountered.  In other words, zbud would handle
these workloads simply by rejecting the pages, resulting
in performance no worse (approximately) than if zcache were
not present.

RAMster maintains data structures to both point to zpages
that are local and remote.  Remote pages are identified
by a handle-like bit sequence while local pages are identified
by a true pointer.  (Note that ramster currently will not
run on a HIGHMEM machine.)  RAMster currently differentiates
between the two via a hack: examining the LSB.  If the
LSB is set, it is a handle referring to a remote page.
This works with xvmalloc and zbud but not with zsmalloc's
opaque handle.  A simple solution would require zsmalloc
to reserve the LSB of the opaque handle as must-be-zero.

Zram is actually a good match for current zsmalloc because
its storage grows to a pre-set RAM maximum size and cannot
shrink again.  Reclaim is not possible without a massive
redesign (and that redesign is essentially zcache).  But as
a result of its grow-but-never-shrink design, zram may have
some significant performance implications on most workloads
and system configurations.  It remains to be seen if its
niche usage will warrant promotion from the staging tree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
