Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id D07C86B006C
	for <linux-mm@kvack.org>; Wed,  2 Jan 2013 12:08:15 -0500 (EST)
MIME-Version: 1.0
Message-ID: <26bb76b3-308e-404f-b2bf-3d19b28b393a@default>
Date: Wed, 2 Jan 2013 09:08:04 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 7/8] zswap: add to mm/
References: <<1355262966-15281-1-git-send-email-sjenning@linux.vnet.ibm.com>>
 <<1355262966-15281-8-git-send-email-sjenning@linux.vnet.ibm.com>>
 <0e91c1e5-7a62-4b89-9473-09fff384a334@default>
 <50E32255.60901@linux.vnet.ibm.com>
In-Reply-To: <50E32255.60901@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, Dave Hansen <dave@linux.vnet.ibm.com>

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Subject: Re: [PATCH 7/8] zswap: add to mm/
>=20
> > I am eagerly studying one of the details of your zswap "flush"
> > code in this patch to see how you solved a problem or two that
> > I was struggling with for the similar mechanism RFC'ed for zcache
> > (see https://lkml.org/lkml/2012/10/3/558).  I like the way
> > that you force the newly-uncompressed to-be-flushed page immediately
> > into a swap bio in zswap_flush_entry via the call to swap_writepage,
> > though I'm not entirely convinced that there aren't some race
> > conditions there.  However, won't swap_writepage simply call
> > frontswap_store instead and re-compress the page back into zswap?
>=20
> I break part of swap_writepage() into a bottom half called
> __swap_writepage() that doesn't include the call to frontswap_store().
> __swap_writepage() is what is called from zswap_flush_entry().  That
> is how I avoid flushed pages recycling back into zswap and the
> potential recursion mentioned.

OK, I missed that.  Nice.  I will see if I can use the
same with zcache and, if so, would be happy to support
the change to swap_writepage.

In your next version, maybe you could break out that chunk
into a separate distinct patch so it can be pulled separately
into Andrew's tree?
=20
> > A second related issue that concerns me is that, although you
> > are now, like zcache2, using an LRU queue for compressed pages
> > (aka "zpages"), there is no relationship between that queue and
> > physical pageframes.  In other words, you may free up 100 zpages
> > out of zswap via zswap_flush_entries, but not free up a single
> > pageframe.  This seems like a significant design issue.  Or am
> > I misunderstanding the code?
>=20
> You understand correctly.  There is room for optimization here and it
> is something I'm working on right now.
>=20
> What I'm looking to do is give zswap a little insight into zsmalloc
> internals,

Not to be at all snide, but had you been as eager to break
the zsmalloc abstraction last spring, a lot of unpleasantness
and extra work might have been avoided. :v(

> namely the ability figure out what class size a particular
> allocation is in and, in the event the store can't be satisfied, flush
> an entry from that exact class size so that we can be assured the
> store will succeed with minimal flushing work.  In this solution,
> there would be an LRU list per zsmalloc class size tracked in zswap.
> The result is LRU-ish flushing overall with class size being the first
> flush selection criteria and LRU as the second.

Clever and definitely useful, though I think there are two related
problems and IIUC this solves only one of them.  The problem it _does_
solve is (A) where to put a new zpage: Move a zpage from the same
class to real-swap-disk and then fill its slot with the new zpage.
The problem it _doesn't_ solve is (B) how to shrink the total number
of pageframes used by zswap, even by a single page.  I believe
(though cannot prove right now) that this latter problem will
need to be solved to implement any suitable MM policy for balancing
pages-used-for-compression vs pages-not-used-for-compression.

I fear that problem (B) is the fundamental concern with
using a high-density storage allocator such as zsmalloc, which
is why I abandoned zsmalloc in favor of a more-predictable-but-
less-dense allocator (zbud).  However, if you have a solution
for (B) as well, I would gladly abandon zbud in zcache (for _both_
cleancache and frontswap pages) and our respective in-kernel
compression efforts would be more easy to merge into one solution
in the future.

> > A third concern is about scalability... the locking seems very
> > coarse-grained.  In zcache, you personally observed and fixed
> > hashbucket contention (see https://lkml.org/lkml/2011/9/29/215).
> > Doesn't zswap's tree_lock essentially use a single tree (per
> > swaptype), i.e. no scalability?
>=20
> The reason the coarse lock isn't a problem for zswap like the hash
> bucket locks where in zcache is that the lock is not held for long
> periods time as it is in zcache.  It is only held while operating on
> the tree, not during compression/decompression and larger memory
> operations.

Hmmm... IIRC, to avoid races in zcache, it was necessary to
update both the data (zpage) and meta-data ("tree" in zswap,
and tmem-data-structure in zcache) atomically.  I will need
to study your code more to understand how zswap avoids this
requirement.  Or if it is obvious to you, I would be grateful
if you would point it out to me.

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
