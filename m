Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 2FA5F6B0068
	for <linux-mm@kvack.org>; Thu,  3 Jan 2013 02:33:45 -0500 (EST)
Date: Thu, 3 Jan 2013 18:33:39 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 7/8] zswap: add to mm/
Message-ID: <20130103073339.GF3120@dastard>
References: <1355262966-15281-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1355262966-15281-8-git-send-email-sjenning@linux.vnet.ibm.com>
 <0e91c1e5-7a62-4b89-9473-09fff384a334@default>
 <50E32255.60901@linux.vnet.ibm.com>
 <50E4588E.6080001@linux.vnet.ibm.com>
 <28a63847-7659-44c4-9c33-87f5d50b2ea0@default>
 <50E479AD.9030502@linux.vnet.ibm.com>
 <9955b9e0-731b-4cbf-9db0-683fcd32f944@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9955b9e0-731b-4cbf-9db0-683fcd32f944@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Wed, Jan 02, 2013 at 11:04:24AM -0800, Dan Magenheimer wrote:
> > From: Dave Hansen [mailto:dave@linux.vnet.ibm.com]
> > Subject: Re: [PATCH 7/8] zswap: add to mm/
> 
> Hi Dave --
> 
> I suspect we are in violent agreement but just to make sure...
> 
> Although zswap is the current example, I guess I am discussing
> a bigger issue, which IMHO is much more important:  How should
> compression be utilized in the kernel (if at all)?  Zswap is
> simply one implementation of in-kernel compression (handling
> anonymous pages only) and zcache is another (handling both
> anonymous pages and pagecache pages).   Each has some
> limited policy, and policy defaults built-in, but neither IMHO
> is adequately aware of (let alone integrated with) MM policy to
> be useful to a broad set of end users and to be enabled by default
> by generic distros.
>  
> > On 01/02/2013 09:26 AM, Dan Magenheimer wrote:
> > > However if one compares the total percentage
> > > of RAM used for zpages by zswap vs the total percentage of RAM
> > > used by slab, I suspect that the zswap number will dominate,
> > > perhaps because zswap is storing primarily data and slab is
> > > storing primarily metadata?
> > 
> > That's *obviously* 100% dependent on how you configure zswap.  But, that
> > said, most of _my_ systems tend to sit with about 5% of memory in
> > reclaimable slab 
> 
> The 5% "sitting" number for slab is somewhat interesting, but
> IMHO irrelevant here. The really interesting value is what percent
> is used by slab when the system is under high memory pressure; I'd
> imagine that number would be much smaller.  True?

Not at all. The amount of slab memory used is wholly dependent on
workload. I have plenty of workloads with severe memory pressure
that I test with that sit at a steady state of >80% of ram in slab
caches. These workloads are filesytem metadata intensive rather than
data intensive, that's exactly the right cache balance for the
system to have....

Thinking that there is a fixed amount of memory that you should
reserve for some subsystem is simply the wrong approach to take.
caches are dynamic and the correct system balance should result of
the natural behaviour of the reclaim algorithms.

The shrinker infrastructure doesn't set any set size goals - it
simply tries to balance the reclaim across all the shrinkers and
relative to the page cache.  If a cache is under allocation
pressure, then it will grow to the point that reclaim is balanced
with the allocation pressure and they won't grow any further. If the
allocation pressure drops, then the cache will shrink if overall
memory pressure is maintained.....

> > > I don't claim to be any kind of expert here, but I'd imagine
> > > that MM doesn't try to manage the total amount of slab space
> > > because slab is "a cost of doing business".

>From the above it should be obvious that the MM subsystem really
does manage the total amount of slab space being used....

> > > However, for
> > > in-kernel compression to be widely useful, IMHO it will be
> > > critical for MM to somehow load balance between total pageframes
> > > used for compressed pages vs total pageframes used for
> > > normal pages, just as today it needs to balance between
> > > active and inactive pages.
> > 
> > The issue isn't about balancing.  It's about reclaim where the VM only
> > cares about whole pages.  If our subsystem (zwhatever or slab) is only
> > designed to reclaim _parts_ of pages, can we be successful in returning
> > whole pages to the VM?
> 
> IMHO, it's about *both* balancing _and_ reclaim.  One remaining
> major point of debate between zcache and zswap is that zcache
> accepts lower density to ensure that whole pages can be easily
> returned to the VM (and thus allow balancing) while zswap targets
> best density (by using zsmalloc) and doesn't address returning
> whole pages to the VM.

And so the two subsystems need different reclaim implementations.
And, well, that's exactly what we have shrinkers for - implmenting
subsystem specific reclaim policy. The shrinker infrastructure is
responsible for them keeping balance between all the caches that
have shrinkers and the size of the page cache...

> > The slab shrinkers only work on parts of pages (singular slab objects).
> >  Yet, it does appear that they function well enough when we try to
> > reclaim from them.  I've never seen a slab's sizes spiral out of control
> > due to fragmentation.
> 
> Perhaps this is because the reclaimable slab objects are mostly
> metadata which is highly connected to reclaimable data objects?
> E.g. reclaiming most reclaimable data pages also coincidentally
> reclaims most slab objects?

No, that's not true. Caches can have some very complex
heirarchies with dependencies across multiple slabs and shrinkers,
not to mention that the caches don't even need to be related to filesystems or the
page cache. Indeed, look at the shrinkers attached to the memory
pools used by the acceleration engines for graphics hardware...

There are also cases where we've moved metadata caches out of the
page cache into shrinker controlled caches because the page cache
reclaim is too simplistic to handle the complex relationships
between filesystem metadata. We've done this in XFS, and IIRC btrfs
did this recently as well...

> (Also, it is not the slab size that would be the issue here but
> its density... i.e. if, after shrinking, 1000 pageframes contain
> only 2000 various 4-byt objects, that would be "out of control".
> Is there any easy visibility into slab density?)

/proc/slabinfo via slabtop, perhaps?

Active / Total Objects (% used)    : 1798915 / 1913060 (94.0%)
 Active / Total Slabs (% used)      : 238160 / 238169 (100.0%)
 Active / Total Caches (% used)     : 119 / 203 (58.6%)
 Active / Total Size (% used)       : 843529.59K / 859896.40K (98.1%)
 Minimum / Average / Maximum Object : 0.02K / 0.45K / 4096.00K

  OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME                   
689872 688486  99%    0.88K 172468        4    689872K xfs_inode
294320 288968  98%    0.19K  14716       20     58864K dentry
212380 173765  81%    0.10K   5740       37     22960K buffer_head
192576 179537  93%    0.06K   3264       59     13056K size-64
 82705  82248  99%    0.22K   4865       17     19460K xfs_ili
 48180  43787  90%    0.31K   4015       12     16060K xfs_buf
 47712  40480  84%    0.03K    426      112      1704K size-32
 44572  38447  86%    0.17K   2026       22      8104K vm_area_struct
.....

> In any case, I would posit that both the nature of zpages and their
> average size relative to a whole page is quite unusual compared to slab.

Doesn't sound at all unusual.

> So while there may be some useful comparisons between zswap
> and slab, the differences may warrant dramatically different policy.

There may be differences, but it doesn't sound like there's anything
you can't implment with an appropriate shrinker implmentation....

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
