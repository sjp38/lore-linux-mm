Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 13E036B0002
	for <linux-mm@kvack.org>; Mon, 20 May 2013 19:38:33 -0400 (EDT)
Date: Tue, 21 May 2013 09:38:07 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v7 18/34] fs: convert fs shrinkers to new scan/count API
Message-ID: <20130520233807.GD24543@dastard>
References: <1368994047-5997-1-git-send-email-glommer@openvz.org>
 <1368994047-5997-19-git-send-email-glommer@openvz.org>
 <1369038304.2728.37.camel@menhir>
 <519A2951.9040908@parallels.com>
 <519A407B.9030205@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <519A407B.9030205@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Steven Whitehouse <swhiteho@redhat.com>, Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, hughd@google.com, Dave Chinner <dchinner@redhat.com>, Adrian Hunter <adrian.hunter@intel.com>

On Mon, May 20, 2013 at 07:25:47PM +0400, Glauber Costa wrote:
> On 05/20/2013 05:46 PM, Glauber Costa wrote:
> > On 05/20/2013 12:25 PM, Steven Whitehouse wrote:
> >> Hi,
> >>
> >> On Mon, 2013-05-20 at 00:07 +0400, Glauber Costa wrote:
> >>> From: Dave Chinner <dchinner@redhat.com>
> >>>
> >>> Convert the filesystem shrinkers to use the new API, and standardise
> >>> some of the behaviours of the shrinkers at the same time. For
> >>> example, nr_to_scan means the number of objects to scan, not the
> >>> number of objects to free.
> >>>
> >>> I refactored the CIFS idmap shrinker a little - it really needs to
> >>> be broken up into a shrinker per tree and keep an item count with
> >>> the tree root so that we don't need to walk the tree every time the
> >>> shrinker needs to count the number of objects in the tree (i.e.
> >>> all the time under memory pressure).
> >>>
> >>> [ glommer: fixes for ext4, ubifs, nfs, cifs and glock. Fixes are
> >>>   needed mainly due to new code merged in the tree ]
> >>> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> >>> Signed-off-by: Glauber Costa <glommer@openvz.org>
> >>> Acked-by: Mel Gorman <mgorman@suse.de>
> >>> Acked-by: Artem Bityutskiy <artem.bityutskiy@linux.intel.com>
> >>> Acked-by: Jan Kara <jack@suse.cz>
> >>> CC: Steven Whitehouse <swhiteho@redhat.com>
> >>> CC: Adrian Hunter <adrian.hunter@intel.com>
> >>> ---
> >>>  fs/ext4/extents_status.c | 30 ++++++++++++++++------------
> >>>  fs/gfs2/glock.c          | 28 +++++++++++++++-----------
> >>>  fs/gfs2/main.c           |  3 ++-
> >>>  fs/gfs2/quota.c          | 12 +++++++-----
> >>>  fs/gfs2/quota.h          |  4 +++-
> >>>  fs/mbcache.c             | 51 ++++++++++++++++++++++++++++--------------------
> >>>  fs/nfs/dir.c             | 18 ++++++++++++++---
> >>>  fs/nfs/internal.h        |  4 +++-
> >>>  fs/nfs/super.c           |  3 ++-
> >>>  fs/nfsd/nfscache.c       | 31 ++++++++++++++++++++---------
> >>>  fs/quota/dquot.c         | 34 +++++++++++++++-----------------
> >>>  fs/ubifs/shrinker.c      | 20 +++++++++++--------
> >>>  fs/ubifs/super.c         |  3 ++-
> >>>  fs/ubifs/ubifs.h         |  3 ++-
> >>>  14 files changed, 151 insertions(+), 93 deletions(-)
> >> [snip]
> >>>  		return 0;
> >>> diff --git a/fs/gfs2/glock.c b/fs/gfs2/glock.c
> >>> index 3bd2748..4ddbccb 100644
> >>> --- a/fs/gfs2/glock.c
> >>> +++ b/fs/gfs2/glock.c
> >>> @@ -1428,21 +1428,22 @@ __acquires(&lru_lock)
> >>>   * gfs2_dispose_glock_lru() above.
> >>>   */
> >>>  
> >>> -static void gfs2_scan_glock_lru(int nr)
> >>> +static long gfs2_scan_glock_lru(int nr)
> >>>  {
> >>>  	struct gfs2_glock *gl;
> >>>  	LIST_HEAD(skipped);
> >>>  	LIST_HEAD(dispose);
> >>> +	long freed = 0;
> >>>  
> >>>  	spin_lock(&lru_lock);
> >>> -	while(nr && !list_empty(&lru_list)) {
> >>> +	while ((nr-- >= 0) && !list_empty(&lru_list)) {
> >>>  		gl = list_entry(lru_list.next, struct gfs2_glock, gl_lru);
> >>>  
> >>>  		/* Test for being demotable */
> >>>  		if (!test_and_set_bit(GLF_LOCK, &gl->gl_flags)) {
> >>>  			list_move(&gl->gl_lru, &dispose);
> >>>  			atomic_dec(&lru_count);
> >>> -			nr--;
> >>> +			freed++;
> >>>  			continue;
> >>>  		}
> >>>  
> >>
> >> This seems to change behaviour so that nr is no longer the number of
> >> items to be demoted, but instead the max number of items to scan in
> >> order to look for items to be demoted. Does that mean that nr has
> >> changed its meaning now?

The original code above assumes that nr_to_scan == "number of object
to free". That is wrong: nr_to_scan has always been defined as "the
number of objects to look at to *to try* to free".

Why is nr_to_scan the number of objects to look at? Because it we
take it as the number of objects to free, then we can walk the
entire LRU list looking for objects to free in a single callout.
And when you have several million objects on the LRU list and none
of them are freeable, that adds a huge amount of CPU overhead to the
shrinker scan loop.

And if it really means "free this many objects", then by that
definition stuff like referenced bits in objects are meaningless
(like the inode and dentry caches use) because we simply rotate the
entire referenced objects on the list and make another pass across
the list and start freeing them until we've freed nr_to_scan
objects....

So, nr_to_scan is the number of objects in the cache to *look at*,
not the number of objects to free.

> >> Steve.
> >>
> > No, this should be the max number to be demoted, no change.
> > This test above should then be freed < nr.
> > 
> > I will update, thanks for spotting.
> > 
> Dave,
> 
> I am auditing the other conversions now for patterns like this.
> In the ashmem driver, you wrote:
> 
> - * 'nr_to_scan' is the number of objects (pages) to prune, or 0 to
> query how
> - * many objects (pages) we have in total.
> + * 'nr_to_scan' is the number of objects to scan for freeing.
> 
> Can you please clarify what is your intention here? For me, nr_to_scan
> is still the amount we should try to free - and it has been this way for
> a while - even if we have to *scan* more objects than this, because
> some of them cannot be freed.

Then your understanding of what nr_to_scan means is wrong. See
above.

> In the shrinkers you have been converting, I actually found both kinds
> of behaviors: In some of them you test for freed >= nr_to_scan, and in
> others, --nr_to_scan > 0

That depended on the existing code in the shrinkers and whether it
was obvious or possible to make them behave properly. The ones that
check freed >= nr_to_scan are ones where I've just converted the
interface, and not touched the actual shrinker implementation.

e.g. the ubifs shrinker - I've got no idea exactly what that is
doing, what it is freeing or how much each of those function calls
frees. So rather than screw with something I didn't have the
patience to understand or infratructure to test, I simply changed
the interface. i.e. the shrinker behaves the same as it did before
the interface change.

> My assumption is that scanning the objects is cheap comparing to the
> other cache operations we do, filling or unfilling, so whoever could,
> should incur the extra couple of scans to make sure that we free as many
> objects as requested *if we can*.

No, scanning is extremely expensive. Look at the dcache - we have to
take a spinlock on every object we scan. So if we can't free any
objects at the tail of the LRU, then just how far down that list of
millions of dentries should we walk to find freeable dentries?

This is the whole point of the batch based scan loop - if we have
lots of scanning to do, we do multiple scan callouts. It is up to
the shrinker to either free or rotate unfreeable objects to the
other end of the LRU so they don't get repeatedly scanned by
repeated shrinker scan calls.

The shrinker does not need to guarantee progress or objects are
being freed. We take great advantage of this in the XFS metadata
buffer shrinker for applying heirarchical reclaim priorities to
ensure that important metadata (e.g. btree roots) are not reclaimed
by less important metadata (e.g. btree leaves). We do this inside a
scan pass simply by decrementing the "LRU age" of the buffer and
rotates them to the other end of the LRU. They only get freed when
the "LRU age" reaches zero.

This is simply a more expansive implementation of the inode/dcache
referenced bit handling, but it reinforces the fact that nr_to_scan
!= nr_to_free.


> I am changing all shrinkers now to behave consistently like this, i.e.
> bailing out in freed > nr_to_scan instead of nr_to_scan == 0 (for most
> of them is thankfully obvious, those two things being the same).

No, that's wrong. A shrinker is allowed to free more than it
scanned. This often happens with the dentry cache (parents get
freed), but they aren't directly accounted by the shrinker in this
case.

What it comes down to is what is reported to the shrinker as an
object count, and what is actually scanned to to free those objects.
Several shrinkers count pages, but scan objects that point to an
arbitrary number of pages. Some of those objects amy be freeable,
some may not, but there is not a 1:1 relationship between objects
being scanned and the objects being counted/freed by the shrinker.

Hence a blanket freed > nr_to_scan abort is not the correct thing to
do. The shrinkers that have this sort of non-linear object:cache
size relationship need more change in the shrinker interface to work
correctly, and so all I've done with them is maintain the status
quo. This patchset is for changing infrastructure, not for trying to
fix all the brokenness in the existing shrinkers.

Remember: the count/scan change is only the first step in this
process. Once this is done we can start to move away from the object
based accounting and scanning to something more appropriate for
these non-linear caches. e.g. byte based accounting and scanning.
The shrinker interface is currently very slab-cache centric, and
that is one of the reasons there are all these hacky shrinkers
because the caches they track don't fit into the neat linear slab
object model.

> If you for any reason wanted nr_to_scan to mean # of objects *scanned*,
> not freed, IOW, if this is not a mistake, please say so and justify.

Justification presented. nr_to_scan has *always* meant "# of objects
*scanned*", and this patchset does not change that.

Cheers,

Dave.
> 
> Thanks.
> 
> 
> 
> 

-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
