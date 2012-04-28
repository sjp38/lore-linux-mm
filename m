Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 67C7F6B0044
	for <linux-mm@kvack.org>; Sat, 28 Apr 2012 12:49:08 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <9a5feb3b-af4b-4183-a026-840ec032def8@default>
Date: Sat, 28 Apr 2012 09:48:55 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: swapcache size oddness
References: <f0b2f4a3-f6d4-41e9-943b-d083eec9e106@default>
 <alpine.LSU.2.00.1204272021030.28310@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1204272021030.28310@eggly.anvils>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org

> From: Hugh Dickins [mailto:hughd@google.com]
> Subject: Re: swapcache size oddness

Hi Hugh --

Thanks for your, as usual, quick and thorough response!

> On Fri, 27 Apr 2012, Dan Magenheimer wrote:
>=20
> > In continuing digging through the swap code (with the
> > overall objective of improving zcache policy), I was
> > looking at the size of the swapcache.
> >
> > My understanding was that the swapcache is simply a
> > buffer cache for pages that are actively in the process
> > of being swapped in or swapped out.
>=20
> It's that part of the pagecache for pages on swap.
>=20
> Once written out, as with other pagecache pages written out under
> reclaim, we do expect to reclaim them fairly soon (they're moved to
> the bottom of the inactive list).  But when read back in, we read a
> cluster at a time, hoping to pick up some more useful pages while the
> disk head is there (though of course it may be a headless disk).  We
> don't disassociate those from swap until they're dirtied (or swap
> looks fullish), why should we?

OK.  Yes, I forgot about the pages that are swapped in
"speculatively" rather than on demand.  This will certainly
result in an increase in the size of the swapcache (especially
with Rik's recent change that increases the average effective
cluster size).

> > And keeping pages
> > around in the swapcache is inefficient because every
> > process access to a page in the swapcache causes a
> > minor page fault.
>=20
> What's inefficient about that?  A minor fault is much less
> costly than the major fault of reading them back from disk.

Yes, but a minor fault is much more costly than a read/write.
I guess I was under the mistaken assumption that a page in
the swapcache can never be directly accessed because the
page table would always have it marked as non-present,
in order to avoid races due to multiple process accesses
and I/O.  But I think I see how that is avoided now (at
least for non-shared-memory pages).

> > So I was surprised to see that, under a memory intensive
> > workload, the swapcache can grow quite large.  I have
> > seen it grow to almost half of the size of RAM.
>=20
> Nothing wrong with that, so long as they can be freed and
> used for better purpose when needed.

Due to my mistaken assumption above, I thought a page
in the swap cache was "worse" than a normal anonymous
page (i.e. for system performance).

So really the primary difference between an anonymous page
that is NOT in the swap cache, and an anonymous page
that IS in the swap cache, is that the latter already has
a slot reserved on the swap disk.  (Flags and mapping
differences too of course.)

> > Digging into this oddity, I re-discovered the definition
> > for "vm_swap_full()" which, in scan_swap_map() is a
> > pre-condition for calling __try_to_reclaim_swap().
> > But vm_swap_full() compares how much free swap space
> > there is "on disk", with the total swap space available
> > "on disk" with no regard to how much RAM there is.
> > So on my system, which is running with 1GB RAM and
> > 10GB swap, I think this is the reason that swapcache
> > is growing so large.
> >
> > Am I misunderstanding something?  Or is this code
> > making some (possibly false) assumptions about how
> > swap is/should be sized relative to RAM?  Or maybe the
> > size of swapcache is harmless as long as it doesn't
> > approach total "on disk" size?
>=20
> The size of swapcache is harmless: we break those pages' association
> with swap once a better use for the page comes up.  But the size of
> swapcache does (of course) represent a duplication of what's on swap.
>=20
> As swap becomes full, that duplication becomes wasteful: we may need
> some of the swap already in memory for saving other pages; so break
> the association, freeing the swap for reuse but keeping the page
> (but now it's no longer swapcache).
>=20
> That's what the vm_swap_full() tests are about: choosing to free swap
> when it's duplicated in memory, once it's becoming a scarce resource.

Got it.  Thanks!

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
