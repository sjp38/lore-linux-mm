Date: Sat, 1 Apr 2006 15:59:42 +1000
From: Nathan Scott <nathans@sgi.com>
Subject: Re: Avoid excessive time spend on concurrent slab shrinking
Message-ID: <20060401155942.E961681@wobbly.melbourne.sgi.com>
References: <Pine.LNX.4.64.0603311441400.8465@schroedinger.engr.sgi.com> <20060331150120.21fad488.akpm@osdl.org> <Pine.LNX.4.64.0603311507130.8617@schroedinger.engr.sgi.com> <20060331153235.754deb0c.akpm@osdl.org> <Pine.LNX.4.64.0603311541260.8948@schroedinger.engr.sgi.com> <20060331160032.6e437226.akpm@osdl.org> <Pine.LNX.4.64.0603311619590.9173@schroedinger.engr.sgi.com> <20060331172518.40a5b03d.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060331172518.40a5b03d.akpm@osdl.org>; from akpm@osdl.org on Fri, Mar 31, 2006 at 05:25:18PM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Christoph Lameter <clameter@sgi.com>, nickpiggin@yahoo.com.au, linux-mm@kvack.org, dgc@melbourne.sgi.com
List-ID: <linux-mm.kvack.org>

On Fri, Mar 31, 2006 at 05:25:18PM -0800, Andrew Morton wrote:
> Christoph Lameter <clameter@sgi.com> wrote:
> ...
> It appears that we're being busy in xfs_iextract(), but it would be sad if
> the problem was really lock contention in xfs_iextract(), and we just
> happened to catch it when it was running.
> 
> Or maybe xfs_iextract is just slow.  So this is one thing we need to get to
> the bottom of (profiles might tell us).

I assume (profiles would be good to prove it) we are spending
time walking the hash bucket list there Christoph (while we're
holding the ch_lock spinlock on the hash bucket)?  [CC'ing Dave
Chinner for any further comment, he's been looking at the chash
list for unrelated reasons recently..]

> Assuming that there's nothing we can do to improve the XFS situation, our
> options appear to be, in order of preference:
> 
> a) move some/all of dispose_list() outside iprune_mutex.
> 
> b) make iprune_mutex an rwlock, take it for reading around
>    dispose_list(), for writing elsewhere.
> 
> c) go back to single-threading shrink_slab (or just shrink_icache_memory())
> 
>    For this one we'd need to understand which observations prompted Nick
>    to make shrinker_rwsem an rwsem?
> 
> We also need to understand why this has become worse.  Perhaps xfs_iextract
> got slower (cc's Nathan).  Do you have any idea whenabout in kernel history
> this started happening?

Nothings changed in xfs_iextract for many years.  Its quite possible
the simple hash with linked list buckets is no longer an effective
choice of algorithm here for the inode cluster hash... or perhaps the
hash table is too small... or... but anyway, I would not expect any
difference between kernel versions here (esp. the two vendor kernel
versions Christoph will be comparing - they'll be behaving exactly
the same way in this regard from XFS's POV as the code in question is
identical).

Its also quite possible some other performance bottleneck was moved
out of the way, and lock contention on the chashlist lock is now the
next biggest thing in line..

If its useful for experimenting, Christoph, you can easily tweak the
cluster hash size manually by dinking with xfs_iget.c::xfs_chash_init.

cheers.

-- 
Nathan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
