Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id BF2E96B004D
	for <linux-mm@kvack.org>; Mon, 23 Apr 2012 19:19:13 -0400 (EDT)
Received: by lagz14 with SMTP id z14so73459lag.14
        for <linux-mm@kvack.org>; Mon, 23 Apr 2012 16:19:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALWz4ix+MC_NuNdvQU3T8BhP+BULPLktLyNQ8osnrMOa2nfhdw@mail.gmail.com>
References: <1335214564-17619-1-git-send-email-yinghan@google.com>
	<CAHGf_=pGhtieRpUqbF4GmAKt5XXhf_2y8c+EzGNx-cgqPNvfJw@mail.gmail.com>
	<CALWz4ix+MC_NuNdvQU3T8BhP+BULPLktLyNQ8osnrMOa2nfhdw@mail.gmail.com>
Date: Mon, 23 Apr 2012 16:19:11 -0700
Message-ID: <CALWz4iyiXRcjBtJKEtW56GeWNGDcqmTv+=DeKVcpTx8vhkEbQA@mail.gmail.com>
Subject: Re: [RFC PATCH] do_try_to_free_pages() might enter infinite loop
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, Nick Piggin <npiggin@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

++cc Nick on the right email address...

--Ying

On Mon, Apr 23, 2012 at 4:18 PM, Ying Han <yinghan@google.com> wrote:
> On Mon, Apr 23, 2012 at 3:20 PM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
>> On Mon, Apr 23, 2012 at 4:56 PM, Ying Han <yinghan@google.com> wrote:
>>> This is not a patch targeted to be merged at all, but trying to underst=
and
>>> a logic in global direct reclaim.
>>>
>>> There is a logic in global direct reclaim where reclaim fails on priori=
ty 0
>>> and zone->all_unreclaimable is not set, it will cause the direct to sta=
rt over
>>> from DEF_PRIORITY. In some extreme cases, we've seen the system hang wh=
ich is
>>> very likely caused by direct reclaim enters infinite loop.
>>>
>>> There have been serious patches trying to fix similar issue and the lat=
est
>>> patch has good summary of all the efforts:
>>>
>>> commit 929bea7c714220fc76ce3f75bef9056477c28e74
>>> Author: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>>> Date: =A0 Thu Apr 14 15:22:12 2011 -0700
>>>
>>> =A0 =A0vmscan: all_unreclaimable() use zone->all_unreclaimable as a nam=
e
>>>
>>> Kosaki explained the problem triggered by async zone->all_unreclaimable=
 and
>>> zone->pages_scanned where the later one was being checked by direct rec=
laim.
>>> However, after the patch, the problem remains where the setting of
>>> zone->all_unreclaimable is asynchronous with zone is actually reclaimab=
le or not.
>>>
>>> The zone->all_unreclaimable flag is set by kswapd by checking zone->pag=
es_scanned in
>>> zone_reclaimable(). Is that possible to have zone->all_unreclaimable =
=3D=3D false while
>>> the zone is actually unreclaimable?
>>>
>>> 1. while kswapd in reclaim priority loop, someone frees a page on the z=
one. It
>>> will end up resetting the pages_scanned.
>>>
>>> 2. kswapd is frozen for whatever reason. I noticed Kosaki's covered the
>>> hibernation case by checking oom_killer_disabled, but not sure if that =
is
>>> everything we need to worry about. The key point here is that direct re=
claim
>>> relies on a flag which is set by kswapd asynchronously, that doesn't so=
und safe.
>>
>> If kswapd was frozen except hibernation, why don't you add frozen
>> check instead of
>> hibernation check? And when and why is that happen?
>
> I haven't tried to reproduce the issue, so everything is based on
> eye-balling the code. The problem is that we have the potential
> infinite loop in direct reclaim where it keeps trying as long as
> !zone->all_unreclaimable.
>
> The flag is only set by kswapd and it will skip setting the flag if
> the following condition is true:
>
> zone->pages_scanned < zone_reclaimable_pages(zone) * 6;
>
> In a few-pages-on-lru condition, the zone->pages_scanned is easily
> remains 0 and also it is reset to 0 everytime a page being freed.
> Then, i will cause global direct reclaim entering infinite loop.
>
>
>>
>>
>>>
>>> Instead of keep fixing the problem, I am wondering why we have the logi=
c
>>> "not oom but keep trying reclaim w/ priority 0 reclaim failure" at the =
first place:
>>>
>>> Here is the patch introduced the logic initially:
>>>
>>> commit 408d85441cd5a9bd6bc851d677a10c605ed8db5f
>>> Author: Nick Piggin <npiggin@suse.de>
>>> Date: =A0 Mon Sep 25 23:31:27 2006 -0700
>>>
>>> =A0 =A0[PATCH] oom: use unreclaimable info
>>>
>>> However, I didn't find detailed description of what problem the commit =
trying
>>> to fix and wondering if the problem still exist after 5 years. I would =
be happy
>>> to see the later case where we can consider to revert the initial patch=
.
>>
>> This patch fixed one of false oom issue. Think,
>>
>> 1. thread-a reach priority-0.
>> 2. thread-b was exited and free a lot of pages.
>> 3. thread-a call out_of_memory().
>>
>> This is not very good because we now have enough memory....
>
> Isn't that being covered by the following in __alloc_pages_may_oom() ?
>
>>-------/*
>>------- * Go through the zonelist yet one more time, keep very high water=
mark
>>------- * here, this is only to catch a parallel oom killing, we must fai=
l if
>>------- * we're still under heavy pressure.
>>------- */
>>-------page =3D get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask,
>>------->-------order, zonelist, high_zoneidx,
>>------->-------ALLOC_WMARK_HIGH|ALLOC_CPUSET,
>>------->-------preferred_zone, migratetype);
>
> Thanks
>
> --Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
