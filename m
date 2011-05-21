Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 729666B0047
	for <linux-mm@kvack.org>; Fri, 20 May 2011 20:23:50 -0400 (EDT)
Received: by bwz17 with SMTP id 17so5108437bwz.14
        for <linux-mm@kvack.org>; Fri, 20 May 2011 17:23:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110520145008.1ea51f41.akpm@linux-foundation.org>
References: <20110520123749.d54b32fa.kamezawa.hiroyu@jp.fujitsu.com>
	<20110520124753.56730b37.kamezawa.hiroyu@jp.fujitsu.com>
	<20110520145008.1ea51f41.akpm@linux-foundation.org>
Date: Sat, 21 May 2011 09:23:46 +0900
Message-ID: <BANLkTi=y40Q5WcogT0VX2kwnYRWfi5jdSA@mail.gmail.com>
Subject: Re: [PATCH 7/8] memcg static scan reclaim for asyncrhonous reclaim
From: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, hannes@cmpxchg.org, Michal Hocko <mhocko@suse.cz>

2011/5/21 Andrew Morton <akpm@linux-foundation.org>:
> On Fri, 20 May 2011 12:47:53 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
>> Ostatic scan rate async memory reclaim for memcg.
>>
>> This patch implements a routine for asynchronous memory reclaim for memo=
ry
>> cgroup, which will be triggered when the usage is near to the limit.
>> This patch includes only code codes for memory freeing.
>>
>> Asynchronous memory reclaim can be a help for reduce latency because
>> memory reclaim goes while an application need to wait or compute somethi=
ng.
>>
>> To do memory reclaim in async, we need some thread or worker.
>> Unlike node or zones, memcg can be created on demand and there may be
>> a system with thousands of memcgs. So, the number of jobs for memcg
>> asynchronous memory reclaim can be big number in theory. So, node kswapd
>> codes doesn't fit well. And some scheduling on memcg layer will be appre=
ciated.
>>
>> This patch implements a static scan rate memory reclaim.
>> When shrink_mem_cgroup_static_scan() is called, it scans pages at most
>> MEMCG_STATIC_SCAN_LIMIT(2048) pages and returnes how memory shrinking
>> was hard. When the function returns false, the caller can assume memory
>> reclaim on the memcg seemed difficult and can add some scheduling delay
>> for the job.
>
> Fully and carefully define the new term "static scan rate"?
>

Ah, yes. It's need to be explained.

>> Note:
>> =A0 - I think this concept can be used for enhancing softlimit, too.
>> =A0 =A0 But need more study.
>>
>>
>> ...
>>
>> + =A0 =A0 =A0 =A0 =A0 =A0 total_scan +=3D nr[l];
>> + =A0 =A0 }
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* Asynchronous reclaim for memcg uses static scan rate for =
avoiding
>> + =A0 =A0 =A0* too much cpu consumption in a memcg. Adjust the scan coun=
t to fit
>> + =A0 =A0 =A0* into scan_limit.
>> + =A0 =A0 =A0*/
>> + =A0 =A0 if (total_scan > sc->scan_limit) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 for_each_evictable_lru(l) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!nr[l] < SWAP_CLUSTER_MAX)
>
> That statement doesn't do what you think it does!
>
....that's my bug. will be fixed or removed in the next version.

>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr[l] =3D div64_u64(nr[l] * sc=
->scan_limit, total_scan);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr[l] =3D max((unsigned long)S=
WAP_CLUSTER_MAX, nr[l]);
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 }
>
> This gets included in CONFIG_CGROUP_MEM_RES_CTLR=3Dn kernels. =A0Needless=
ly?
>
Yes, no global reclaim uses scan_limit, now. I'll add a
scanning_global_lru() check
and compiler can hide this.

> It also has the potential to affect non-memcg behaviour at runtime.
>
Hmm, if scan_limit is set by mistake....ok, I'll add scanning_global_lru().


>> =A0}
>>
>> @@ -1938,6 +1955,11 @@ restart:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (nr_reclaimed >=3D nr_to_reclaim && prior=
ity < DEF_PRIORITY)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 =A0 =A0 =A0 =A0 /*
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* static scan rate memory reclaim ?
>
> I still don't know what "static scan rate" means :(
>
static scan rate ....maybe my English skill is also bad ;(

Maybe I should name this as "stable scan rate per run" or "limited
scan reclaim",
 it means when it's invoked, scan pages up to the scan_limit, at most.
In usual reclaim, it tries to reclaim some amount of pages and may need to =
scan
the whole memory. But this logic stops and returns to the caller when
hits scan_limit.


>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (sc->nr_scanned > sc->scan_limit)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> =A0 =A0 =A0 }
>> =A0 =A0 =A0 sc->nr_reclaimed +=3D nr_reclaimed;
>>
>>
>> ...
>>
>> +static void shrink_mem_cgroup_node(int nid,
>> + =A0 =A0 =A0 =A0 =A0 =A0 int priority, struct scan_control *sc)
>> +{
>> + =A0 =A0 unsigned long this_scanned =3D 0;
>> + =A0 =A0 unsigned long this_reclaimed =3D 0;
>> + =A0 =A0 int i;
>> +
>> + =A0 =A0 for (i =3D 0; i < NODE_DATA(nid)->nr_zones; i++) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct zone *zone =3D NODE_DATA(nid)->node_zon=
es + i;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (!populated_zone(zone))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (!mem_cgroup_zone_reclaimable_pages(sc->mem=
_cgroup, nid, i))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* If recent scan didn't go good, do writepate=
 */
>> + =A0 =A0 =A0 =A0 =A0 =A0 sc->nr_scanned =3D 0;
>> + =A0 =A0 =A0 =A0 =A0 =A0 sc->nr_reclaimed =3D 0;
>> + =A0 =A0 =A0 =A0 =A0 =A0 shrink_zone(priority, zone, sc);
>> + =A0 =A0 =A0 =A0 =A0 =A0 this_scanned +=3D sc->nr_scanned;
>> + =A0 =A0 =A0 =A0 =A0 =A0 this_reclaimed +=3D sc->nr_reclaimed;
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (this_reclaimed >=3D sc->nr_to_reclaim)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (sc->scan_limit < this_scanned)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (need_resched())
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>
> Whoa! =A0Explain?
>
>> + =A0 =A0 }
>> + =A0 =A0 sc->nr_scanned =3D this_scanned;
>> + =A0 =A0 sc->nr_reclaimed =3D this_reclaimed;
>> + =A0 =A0 return;
>> +}
>> +
>> +#define MEMCG_ASYNCSCAN_LIMIT =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(2048)
>
> Needs documentation. =A0What happens if I set it to 1024?
>
I will do and explain why 2048 now.

>> +bool mem_cgroup_shrink_static_scan(struct mem_cgroup *mem, long require=
d)
>
> Exported function has no interface documentation.
>
> `required' appears to have units of "number of pages". =A0Should be unsig=
ned.
>
>
yes, I'll fix and add documents.

> +{
>> + =A0 =A0 int nid, priority, noscan;
>
> `noscan' is poorly named and distressingly mysterious. =A0Basically I
> don't have a clue what you're doing with this.
>
> It should be unsigned.
>

ok, I'll think of better name ....hmm, scan_failed  or no_reclaimable_pages=
.


>> + =A0 =A0 unsigned long total_scanned, total_reclaimed, reclaim_target;
>> + =A0 =A0 struct scan_control sc =3D {
>> + =A0 =A0 =A0 =A0 =A0 =A0 .gfp_mask =A0 =A0 =A0=3D GFP_HIGHUSER_MOVABLE,
>> + =A0 =A0 =A0 =A0 =A0 =A0 .may_unmap =A0 =A0 =3D 1,
>> + =A0 =A0 =A0 =A0 =A0 =A0 .may_swap =A0 =A0 =A0=3D 1,
>> + =A0 =A0 =A0 =A0 =A0 =A0 .order =A0 =A0 =A0 =A0 =3D 0,
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* we don't writepage in our scan. but kick fl=
usher threads */
>> + =A0 =A0 =A0 =A0 =A0 =A0 .may_writepage =3D 0,
>> + =A0 =A0 };
>> + =A0 =A0 struct mem_cgroup *victim, *check_again;
>> + =A0 =A0 bool congested =3D true;
>> +
>> + =A0 =A0 total_scanned =3D 0;
>> + =A0 =A0 total_reclaimed =3D 0;
>> + =A0 =A0 reclaim_target =3D min(required, MEMCG_ASYNCSCAN_LIMIT/2L);
>> + =A0 =A0 sc.swappiness =3D mem_cgroup_swappiness(mem);
>> +
>> + =A0 =A0 noscan =3D 0;
>> + =A0 =A0 check_again =3D NULL;
>> +
>> + =A0 =A0 do {
>> + =A0 =A0 =A0 =A0 =A0 =A0 victim =3D mem_cgroup_select_victim(mem);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (!mem_cgroup_test_reclaimable(victim)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_release_victim(vict=
im);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* if selected a hopeless vi=
ctim again, give up.
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (check_again =3D=3D victim)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!check_again)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 check_again =
=3D victim;
>> + =A0 =A0 =A0 =A0 =A0 =A0 } else
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 check_again =3D NULL;
>> + =A0 =A0 } while (check_again);
>
> What's all this trying to do?
>
This tries to do walk hierarchy of memcg and select a victim memcg
to be scanned under given memcg. But if all pages under the memcg is
unevictable,
we have no job. So, this gives up when the same memcg found twice, which is
unevictable. This works because current select_victim() is round-robin....

Yes, need to be documented.


>> + =A0 =A0 current->flags |=3D PF_SWAPWRITE;
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* We can use arbitrary priority for our run because we just=
 scan
>> + =A0 =A0 =A0* up to MEMCG_ASYNCSCAN_LIMIT and reclaim only the half of =
it.
>> + =A0 =A0 =A0* But, we need to have early-give-up chance for avoid cpu h=
ogging.
>> + =A0 =A0 =A0* So, start from a small priority and increase it.
>> + =A0 =A0 =A0*/
>> + =A0 =A0 priority =3D DEF_PRIORITY;
>> +
>> + =A0 =A0 while ((total_scanned < MEMCG_ASYNCSCAN_LIMIT) &&
>> + =A0 =A0 =A0 =A0 =A0 =A0 (total_reclaimed < reclaim_target)) {
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* select a node to scan */
>> + =A0 =A0 =A0 =A0 =A0 =A0 nid =3D mem_cgroup_select_victim_node(victim);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 sc.mem_cgroup =3D victim;
>> + =A0 =A0 =A0 =A0 =A0 =A0 sc.nr_scanned =3D 0;
>> + =A0 =A0 =A0 =A0 =A0 =A0 sc.scan_limit =3D MEMCG_ASYNCSCAN_LIMIT - tota=
l_scanned;
>> + =A0 =A0 =A0 =A0 =A0 =A0 sc.nr_reclaimed =3D 0;
>> + =A0 =A0 =A0 =A0 =A0 =A0 sc.nr_to_reclaim =3D reclaim_target - total_re=
claimed;
>> + =A0 =A0 =A0 =A0 =A0 =A0 shrink_mem_cgroup_node(nid, priority, &sc);
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (sc.nr_scanned) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 total_scanned +=3D sc.nr_scann=
ed;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 total_reclaimed +=3D sc.nr_rec=
laimed;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 noscan =3D 0;
>> + =A0 =A0 =A0 =A0 =A0 =A0 } else
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 noscan++;
>> + =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_release_victim(victim);
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* ok, check condition */
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (total_scanned > total_reclaimed * 2)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wakeup_flusher_threads(sc.nr_s=
canned);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (mem_cgroup_async_should_stop(mem))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* If memory reclaim seems heavy, return that =
we're congested */
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (total_scanned > MEMCG_ASYNCSCAN_LIMIT/4 &&
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 total_scanned > total_reclaimed*8)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 =A0 =A0 =A0 =A0 /*
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* The whole system is busy or some status u=
pdate
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* is not synched. It's better to wait for a=
 while.
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> + =A0 =A0 =A0 =A0 =A0 =A0 if ((noscan > 1) || (need_resched()))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>
> So we bale out if there were two priority levels at which
> shrink_mem_cgroup_node() didn't scan any pages? =A0What on earth???
>
I thought there is a case that a memcg contains only ANON in a node
on swapless system or all pages are isolated or some...

> And what was the point in calling shrink_mem_cgroup_node() if it didn't
> scan anything?

I wonder if there are threads in synchronous relcaim we can have race.

> I could understand using nr_reclaimed...
>
I'll reconsider why I inserted this..(I might add this before fixing
get_scan_count()..0

Maybe I can remove this check because I don't hit this case, and later,
memcg can have some logic similar to zone->all_unreclaimable.



>> + =A0 =A0 =A0 =A0 =A0 =A0 /* ok, we can do deeper scanning. */
>> + =A0 =A0 =A0 =A0 =A0 =A0 priority--;
>> + =A0 =A0 }
>> + =A0 =A0 current->flags &=3D ~PF_SWAPWRITE;
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* If we successfully freed the half of target, report that
>> + =A0 =A0 =A0* memory reclaim went smoothly.
>> + =A0 =A0 =A0*/
>> + =A0 =A0 if (total_reclaimed > reclaim_target/2)
>> + =A0 =A0 =A0 =A0 =A0 =A0 congested =3D false;
>> +out:
>> + =A0 =A0 return congested;
>> +}
>> =A0#endif
>
>
>
> I dunno, the whole thing seems sprinkled full of arbitrary assumptions
> and guess-and-giggle magic numbers. =A0I expect a lot of this stuff is
> just unnecessary. =A0And if it _is_ necessary then I'd expect there to
> be lots of situations and corner cases in which it malfunctions,
> because the magic numbers weren't tuned to that case.

Hmm, ok, I'll make this function simpler and add explanation to numbers.


Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
