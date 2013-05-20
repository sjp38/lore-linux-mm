Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 8F2AE6B0002
	for <linux-mm@kvack.org>; Mon, 20 May 2013 11:25:00 -0400 (EDT)
Message-ID: <519A407B.9030205@parallels.com>
Date: Mon, 20 May 2013 19:25:47 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v7 18/34] fs: convert fs shrinkers to new scan/count API
References: <1368994047-5997-1-git-send-email-glommer@openvz.org>  <1368994047-5997-19-git-send-email-glommer@openvz.org> <1369038304.2728.37.camel@menhir> <519A2951.9040908@parallels.com>
In-Reply-To: <519A2951.9040908@parallels.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Whitehouse <swhiteho@redhat.com>
Cc: Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, Dave Chinner <david@fromorbit.com>, hughd@google.com, Dave Chinner <dchinner@redhat.com>, Adrian Hunter <adrian.hunter@intel.com>

On 05/20/2013 05:46 PM, Glauber Costa wrote:
> On 05/20/2013 12:25 PM, Steven Whitehouse wrote:
>> Hi,
>>
>> On Mon, 2013-05-20 at 00:07 +0400, Glauber Costa wrote:
>>> From: Dave Chinner <dchinner@redhat.com>
>>>
>>> Convert the filesystem shrinkers to use the new API, and standardise
>>> some of the behaviours of the shrinkers at the same time. For
>>> example, nr_to_scan means the number of objects to scan, not the
>>> number of objects to free.
>>>
>>> I refactored the CIFS idmap shrinker a little - it really needs to
>>> be broken up into a shrinker per tree and keep an item count with
>>> the tree root so that we don't need to walk the tree every time the
>>> shrinker needs to count the number of objects in the tree (i.e.
>>> all the time under memory pressure).
>>>
>>> [ glommer: fixes for ext4, ubifs, nfs, cifs and glock. Fixes are
>>>   needed mainly due to new code merged in the tree ]
>>> Signed-off-by: Dave Chinner <dchinner@redhat.com>
>>> Signed-off-by: Glauber Costa <glommer@openvz.org>
>>> Acked-by: Mel Gorman <mgorman@suse.de>
>>> Acked-by: Artem Bityutskiy <artem.bityutskiy@linux.intel.com>
>>> Acked-by: Jan Kara <jack@suse.cz>
>>> CC: Steven Whitehouse <swhiteho@redhat.com>
>>> CC: Adrian Hunter <adrian.hunter@intel.com>
>>> ---
>>>  fs/ext4/extents_status.c | 30 ++++++++++++++++------------
>>>  fs/gfs2/glock.c          | 28 +++++++++++++++-----------
>>>  fs/gfs2/main.c           |  3 ++-
>>>  fs/gfs2/quota.c          | 12 +++++++-----
>>>  fs/gfs2/quota.h          |  4 +++-
>>>  fs/mbcache.c             | 51 ++++++++++++++++++++++++++++--------------------
>>>  fs/nfs/dir.c             | 18 ++++++++++++++---
>>>  fs/nfs/internal.h        |  4 +++-
>>>  fs/nfs/super.c           |  3 ++-
>>>  fs/nfsd/nfscache.c       | 31 ++++++++++++++++++++---------
>>>  fs/quota/dquot.c         | 34 +++++++++++++++-----------------
>>>  fs/ubifs/shrinker.c      | 20 +++++++++++--------
>>>  fs/ubifs/super.c         |  3 ++-
>>>  fs/ubifs/ubifs.h         |  3 ++-
>>>  14 files changed, 151 insertions(+), 93 deletions(-)
>> [snip]
>>>  		return 0;
>>> diff --git a/fs/gfs2/glock.c b/fs/gfs2/glock.c
>>> index 3bd2748..4ddbccb 100644
>>> --- a/fs/gfs2/glock.c
>>> +++ b/fs/gfs2/glock.c
>>> @@ -1428,21 +1428,22 @@ __acquires(&lru_lock)
>>>   * gfs2_dispose_glock_lru() above.
>>>   */
>>>  
>>> -static void gfs2_scan_glock_lru(int nr)
>>> +static long gfs2_scan_glock_lru(int nr)
>>>  {
>>>  	struct gfs2_glock *gl;
>>>  	LIST_HEAD(skipped);
>>>  	LIST_HEAD(dispose);
>>> +	long freed = 0;
>>>  
>>>  	spin_lock(&lru_lock);
>>> -	while(nr && !list_empty(&lru_list)) {
>>> +	while ((nr-- >= 0) && !list_empty(&lru_list)) {
>>>  		gl = list_entry(lru_list.next, struct gfs2_glock, gl_lru);
>>>  
>>>  		/* Test for being demotable */
>>>  		if (!test_and_set_bit(GLF_LOCK, &gl->gl_flags)) {
>>>  			list_move(&gl->gl_lru, &dispose);
>>>  			atomic_dec(&lru_count);
>>> -			nr--;
>>> +			freed++;
>>>  			continue;
>>>  		}
>>>  
>>
>> This seems to change behaviour so that nr is no longer the number of
>> items to be demoted, but instead the max number of items to scan in
>> order to look for items to be demoted. Does that mean that nr has
>> changed its meaning now?
>>
>> Steve.
>>
> No, this should be the max number to be demoted, no change.
> This test above should then be freed < nr.
> 
> I will update, thanks for spotting.
> 
Dave,

I am auditing the other conversions now for patterns like this.
In the ashmem driver, you wrote:

- * 'nr_to_scan' is the number of objects (pages) to prune, or 0 to
query how
- * many objects (pages) we have in total.
+ * 'nr_to_scan' is the number of objects to scan for freeing.

Can you please clarify what is your intention here? For me, nr_to_scan
is still the amount we should try to free - and it has been this way for
a while - even if we have to *scan* more objects than this, because
some of them cannot be freed.

In the shrinkers you have been converting, I actually found both kinds
of behaviors: In some of them you test for freed >= nr_to_scan, and in
others, --nr_to_scan > 0

My assumption is that scanning the objects is cheap comparing to the
other cache operations we do, filling or unfilling, so whoever could,
should incur the extra couple of scans to make sure that we free as many
objects as requested *if we can*.

I am changing all shrinkers now to behave consistently like this, i.e.
bailing out in freed > nr_to_scan instead of nr_to_scan == 0 (for most
of them is thankfully obvious, those two things being the same).

If you for any reason wanted nr_to_scan to mean # of objects *scanned*,
not freed, IOW, if this is not a mistake, please say so and justify.

Thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
