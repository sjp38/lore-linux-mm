Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id A67D16B005A
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 01:46:26 -0400 (EDT)
Received: by lahd3 with SMTP id d3so2240972lah.14
        for <linux-mm@kvack.org>; Thu, 16 Aug 2012 22:46:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <502DD8D9.9050009@parallels.com>
References: <1345150439-31003-1-git-send-email-yinghan@google.com>
	<502DD8D9.9050009@parallels.com>
Date: Thu, 16 Aug 2012 22:46:24 -0700
Message-ID: <CALWz4iwUeQNZr+JLmuvHZcRRp3+d__QuvsEP_diNivL_Qdc8Cg@mail.gmail.com>
Subject: Re: [RFC PATCH 3/6] memcg: restructure shrink_slab to walk memcg hierarchy
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org

On Thu, Aug 16, 2012 at 10:38 PM, Glauber Costa <glommer@parallels.com> wrote:
> On 08/17/2012 12:53 AM, Ying Han wrote:
>> This patch moves the main slab shrinking to do_shrink_slab() and restructures
>> shrink_slab() to walk the memory cgroup hiearchy. The memcg context is embedded
>> inside the shrink_control. The underling shrinker will be respecting the new
>> field by only reclaiming slab objects charged to the memcg.
>>
>> The hierarchy walk in shrink_slab() is slightly different than the walk in
>> shrink_zone(), where the latter one walks each memcg once for each priority
>> under concurrent reclaim threads. It makes less sense for slab since they are
>> spread out the system instead of per-zone. So here each shrink_slab() will
>> trigger a full walk of each memcg under the sub-tree.
>>
>> One optimization is under global reclaim, where we skip walking the whole tree
>> but instead pass into shrinker w/ mem_cgroup=NULL. Then it will end up scanning
>> the full dentry lru list.
>>
>> Signed-off-by: Ying Han <yinghan@google.com>
>> ---
>>  mm/vmscan.c |   43 +++++++++++++++++++++++++++++++++++--------
>>  1 files changed, 35 insertions(+), 8 deletions(-)
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 6ffdff6..7a3a1a4 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -204,7 +204,7 @@ static inline int do_shrinker_shrink(struct shrinker *shrinker,
>>   *
>>   * Returns the number of slab objects which we shrunk.
>>   */
>> -unsigned long shrink_slab(struct shrink_control *shrink,
>> +static unsigned long do_shrink_slab(struct shrink_control *shrink,
>>                         unsigned long nr_pages_scanned,
>>                         unsigned long lru_pages)
>>  {
>> @@ -214,12 +214,6 @@ unsigned long shrink_slab(struct shrink_control *shrink,
>>       if (nr_pages_scanned == 0)
>>               nr_pages_scanned = SWAP_CLUSTER_MAX;
>>
>> -     if (!down_read_trylock(&shrinker_rwsem)) {
>> -             /* Assume we'll be able to shrink next time */
>> -             ret = 1;
>> -             goto out;
>> -     }
>> -
>>       list_for_each_entry(shrinker, &shrinker_list, list) {
>>               unsigned long long delta;
>>               long total_scan;
>> @@ -309,8 +303,41 @@ unsigned long shrink_slab(struct shrink_control *shrink,
>>
>>               trace_mm_shrink_slab_end(shrinker, shrink_ret, nr, new_nr);
>>       }
>> +
>> +     return ret;
>> +}
>> +
> It seems to me this will call all shrinkers, regardless of whether or
> not they are memcg-aware. Can't we just skip the ones we know not to be
> memcg-aware?  (basically all non-vfs for the moment...)
>
> My fear is that if called, they will shrink. And that may not be what we
> want.

Are you suggesting to not shrink slabs other than dentry cache? Not
sure if that is what we want
neither. However, maybe we can do that for target reclaim though if
that is what you meant.

--Ying
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
