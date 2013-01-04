Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id CA1216B005D
	for <linux-mm@kvack.org>; Thu,  3 Jan 2013 21:30:35 -0500 (EST)
Date: Fri, 4 Jan 2013 13:30:30 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 7/8] zswap: add to mm/
Message-ID: <20130104023030.GK3120@dastard>
References: <1355262966-15281-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1355262966-15281-8-git-send-email-sjenning@linux.vnet.ibm.com>
 <0e91c1e5-7a62-4b89-9473-09fff384a334@default>
 <50E32255.60901@linux.vnet.ibm.com>
 <50E4588E.6080001@linux.vnet.ibm.com>
 <28a63847-7659-44c4-9c33-87f5d50b2ea0@default>
 <50E479AD.9030502@linux.vnet.ibm.com>
 <9955b9e0-731b-4cbf-9db0-683fcd32f944@default>
 <20130103073339.GF3120@dastard>
 <ac37f7ce-b15a-40f8-9da7-858dea3651b9@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ac37f7ce-b15a-40f8-9da7-858dea3651b9@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Thu, Jan 03, 2013 at 02:37:01PM -0800, Dan Magenheimer wrote:
> > From: Dave Chinner [mailto:david@fromorbit.com]
> > Subject: Re: [PATCH 7/8] zswap: add to mm/
> > 
> > <much useful info from Dave deleted>
> 
> OK, I have suitably proven how little I know about slab
> and have received some needed education from your
> response... Thanks for that Dave.
> 
> So let me ask some questions instead of making
> stupid assumptions.
> 
> > Thinking that there is a fixed amount of memory that you should
> > reserve for some subsystem is simply the wrong approach to take.
> > caches are dynamic and the correct system balance should result of
> > the natural behaviour of the reclaim algorithms.
> >
> > The shrinker infrastructure doesn't set any set size goals - it
> > simply tries to balance the reclaim across all the shrinkers and
> > relative to the page cache... 
> 
> First, it's important to note that zcache/zswap is not
> really a subsystem.  It's simply a way of increasing
> the number of anonymous pages (zswap and zcache) and
> pagecache pages (zcache only) in RAM by using compression.
> Because compressed pages can't be byte-addressed directly,
> pages enter zcache/zswap through a "transformation"
> process I've likened to a Fourier transform:  In
> their compressed state, they must be managed differently
> than normal whole pages.  Compressed anonymous pages must
> transition back to uncompressed before they can be used.
> Compressed pagecache pages (zcache only) can be either
> uncompressed when needed or gratuitously discarded (eventually)
> when not needed.
> 
> So I've been proceeding with the assumption that it is the
> sum of wholepages used by both compressed-anonymous pages
> and uncompressed-anonymous pages that must be managed/balanced,
> and that this sum should be managed similarly to the non-zxxxx
> case of the total number of anonymous pages in the system
> (and similarly for compressed+uncompressed pagecache pages).
> 
> Are you suggesting that slab can/should be used instead?

I'm not suggesting that any specific solution can/should be used.
What I'm trying to point out that is caches and shrinkers do not
need to be slab based. i.e. all that matters is that you have some
allocation method, some method of tracking the allocated objects,
and some method of reclaiming them, and all the details/policies can
be hidden within the subsystem via shrinker based reclaim...

> > And so the two subsystems need different reclaim implementations.
> > And, well, that's exactly what we have shrinkers for - implmenting
> > subsystem specific reclaim policy. The shrinker infrastructure is
> > responsible for them keeping balance between all the caches that
> > have shrinkers and the size of the page cache...
> 
> Given the above, do you think either compressed-anonymous-pages or
> compressed-pagecache-pages are suitable candidates for the shrinker
> infrastructure?

I don't know all the details of what you are trying to do, but you
seem to be describing a two-level heirarchy - a pool of compressed
data and a pool of uncompressed data, and under memory pressure are
migrating data from the uncompressed pool to the compressed pool. On
access, you are migrating back the other way.  Hence it seems to me
that you could implement the process of migration from the
uncompressed pool to the compressed pool as a shrinker so that it
only happens as a result of memory pressure....

> Note that compressed anonymous pages are always dirty so
> cannot be "reclaimed" as such.  But the mechanism that Seth
> and I are working on causes compressed anonymous pages to
> be decompressed and then sent to backing store, which does
> (eventually, after I/O latency) free up pageframes.

The lack of knowledge I have about zcache/zswap means I might be
saying something stupid, but why wouldn't you simply write the
uncompressed page to the backing store and then compress it on IO
completion? If you have to uncompress it for the application to
either modify the page again or write it to the backing store,
doesn't it make things much simpler if the cache only holds clean
pages? And if it only holds clean pages, then another shrinker could
be used to keep the size of it in check....

> Currently zcache does use the shrinker API for reclaiming
> pageframes-used-for-compressed-pagecache-pages.  Since
> these _are_ a form of pagecache pages, is the shrinker suitable?

Yes.

> > There are also cases where we've moved metadata caches out of the
> > page cache into shrinker controlled caches because the page cache
> > reclaim is too simplistic to handle the complex relationships
> > between filesystem metadata. We've done this in XFS, and IIRC btrfs
> > did this recently as well...
> 
> So although the objects in zswap/zcache are less than one page,
> they are still "data" not "metadata", true?

The page cache can be used to hold both filesystem metadata and user
data. As far as you're concerned, the page cache holds "information"
and you cannot make judgements about it's contents....

> In your opinion,
> then, should they be managed by core MM, or by shrinker-controlled
> caches, by some combination, or independently of either?

I think the entire MM could be run by the shrinker based reclaim
infrastructure. You should probably have a read of the discussions
in this thread to get an idea of where we are trying to get to with
the shrinker infrastructure:

https://lkml.org/lkml/2012/11/27/567

(Warning: I don't say very nice things about the zcache/ramster
shrinkers in that patch series. :/ )

> Can slab today suitably manage "larger" objects that exceed
> half-PAGESIZE?  Or "larger" objects, such as 35%-PAGESIZE where
> there would be a great deal of fragmentation?

Have a look at how the kernel heap is implemented:

# grep "^# name\|^size-[0-9]* " /proc/slabinfo | cut -d ":" -f 1
# name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab> 
size-4194304           0      0 4194304    1 1024 
size-2097152           0      0 2097152    1  512 
size-1048576           2      2 1048576    1  256 
size-524288            0      0 524288    1  128 
size-262144            0      0 262144    1   64 
size-131072            0      0 131072    1   32 
size-65536            24     24  65536    1   16 
size-32768             3      3  32768    1    8 
size-16384           281    288  16384    1    4 
size-8192             70     70   8192    1    2 
size-4096            346    346   4096    1    1 
size-2048            580    608   2048    2    1 
size-1024          18745  18980   1024    4    1 
size-512            1234   1264    512    8    1 
size-256            1549   1695    256   15    1 
size-192            4578   5340    192   20    1 
size-64           148919 194405     64   59    1 
size-128           35906  37080    128   30    1 
size-32            40743  47488     32  112    1 

i.e. it's implemented as a bunch of power-of-2 sized slab caches,
with object sizes that range up to 4MB. IIRC, SLUB is better suited
to odd sized objects than SLAB due to it's ability to have multiple
pages per slab even for objects smaller than page sized......

> If so, we should definitely consider slab as an alternative
> for zpage allocation.

Or you could just use kmalloc... ;)

As I said initially - don't think of whether you need to use slab
allocation or otherwise. Start with simple allocation, a tracking
mechanism and a rudimetary shrinker, and then optimise allocation and
reclaim once you understand the limitations of the simple
solution....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
