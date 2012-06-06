Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 5C8878D0001
	for <linux-mm@kvack.org>; Wed,  6 Jun 2012 13:34:56 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <0e40bc09-4e05-426e-8379-bb4eb5b36fab@default>
Date: Wed, 6 Jun 2012 10:34:40 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: zsmalloc concerns
References: <030ff158-3b2b-47a6-98d7-5010f7a9ce6b@default>
 <4FCDA87B.7020209@kernel.org>
In-Reply-To: <4FCDA87B.7020209@kernel.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>, Konrad Wilk <konrad.wilk@oracle.com>

> From: Minchan Kim [mailto:minchan@kernel.org]

Hi Minchan --

Reordering the reply a bit...

> > On 06/05/2012 12:25 PM, Dan Magenheimer wrote:
> > Zsmalloc relies on some clever underlying virtual-to-physical
> > mapping manipulations to ensure that its users can store and
> > retrieve items.  These manipulations are necessary on HIGHMEM
>=20
> HIGHMEM processors?
> I think we need it if the system doesn't support HIGHMEM.
> Maybe I am missing your point.

I didn't say it very clearly.  What I meant is that, on
processors that require HIGHMEM, it is always necessary
to do a kmap/kunmap around accessing the contents of a
pageframe referred to by a struct page.  On machines
with no HIGHMEM, the kernel is completely mapped so
kmap/kunmap to kernel space are very simple and fast.

However, whenever a compressed item crosses a page
boundary in zsmalloc, zsmalloc creates a special "pair"
mapping of the two pages, and kmap/kunmaps the pair for
every access.  This is why special TLB tricks must
be used by zsmalloc.  I think this can be expensive
so I consider this a disadvantage of zsmalloc, even
though it is very clever and very useful for storing
a large number of items with size larger than PAGE_SIZE/2.

> What's the requirement for shrinking zsmalloc?
> For example,
>=20
> int shrink_zsmalloc_memory(int nr_pages)
> {
> =09zsmalloc_evict_pages(nr_pages);
> }
>=20
> Could you tell us your detailed requirement?
> Let's see it's possible or not at current zsmalloc.

The objective of the shrinker is to reclaim full
pageframes.  Due to the way zsmalloc works, when
it stores N items in M pages, worst case it
may take N-M zsmalloc "item evictions" before even
a single pageframe is reclaimed.

Next, remember that there may be several "pointers"
(stored as zsmalloc object handles) referencing that page
and there may also be a pointer to an item which
overlaps from an adjacent page.
In zcache, the pointers are stored in the tmem metadata.
This metadata must be purged from tmem before the
pageframe can be reclaimed.  And this must be done
carefully, maybe atomically, because there are various
locks that must be held and released in the correct
order to avoid races and deadlock.  (Holding one
big lock disallowing tmem from operating during reclaim
is an ugly alternative.)

Next, ideally you'd like to be able to reclaim pageframes
in roughly LRU order.  What does LRU mean when many
items stored in the pageframe (and possibly adjacent
pageframes) are added/deleted completely independently?

Last, when that metadata is purged from tmem, for ephemeral
pages the actual stored data can be discarded.  BUT when
the pages are persistent, the data cannot be discarded.
I have preliminary code that decompresses and pushes this
data back into the swapcache.  This too must be atomic.

> > RAMster maintains data structures to both point to zpages
> > that are local and remote.  Remote pages are identified
> > by a handle-like bit sequence while local pages are identified
> > by a true pointer.  (Note that ramster currently will not
> > run on a HIGHMEM machine.)  RAMster currently differentiates
> > between the two via a hack: examining the LSB.  If the
> > LSB is set, it is a handle referring to a remote page.
> > This works with xvmalloc and zbud but not with zsmalloc's
> > opaque handle.  A simple solution would require zsmalloc
> > to reserve the LSB of the opaque handle as must-be-zero.
>=20
> As you know, it's not difficult but break opaque handle's concept.
> I want to avoid that and let you put some identifier into somewhere in zc=
ache.

That would be OK with me if it can be done without a large
increase in memory use.  We have so far avoided adding
additional data to each tmem "pampd".  Adding another
unsigned long worth of data is possible but would require
some bug internal API changes.

There are many data structures in the kernel that take
advantage of unused low bits in a pointer, like what
ramster is doing.

And the opaqueness of the handle could still be preserved
if there are one or more reserved bits and one adds functions
to zsmalloc_set_reserved_bits(&handle) and
zsmalloc_read_reserved_bits(handle).

But this is a nit until we are sure that zsmalloc will meet
the reclaim requirements.

> At least, many embedded device have used zram since compcache was introdu=
ced.
> But not sure, zcache can replace it.
> If zcache can replace it, you will be right.
>=20
> Comparing zcache and zram implementation, it's one of my TODO list.
> So I am happy to see them.
> But I can't do it shorty due to other urgent works.

Zcache has differences, the largest being that zcache currently
works only when the system has a configured swap block device.
Current zcache has issues too, but (as Andrea has observed)
they can be reduced by allowing zcache to be backed, when
necessary, by the swapdisk when memory pressure is high.

> In summary, I WANT TO KNOW your detailed requirement for shrinking zsmall=
oc.

My core requirement is that an implementation exists that can
handle pageframe reclaim efficiently and race-free.  AND for
persistent pages, ensure it is possible to return the data
to the swapcache when the containing pageframe is reclaimed.

I am not saying that zsmalloc *cannot* meet this requirement.
I just think it is already very difficult with a simple
non-opaque allocator such as zbud.  That's why I am trying
to get it all working with zbud first.

Hope that helps!
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
