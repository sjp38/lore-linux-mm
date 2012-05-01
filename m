Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 976816B0044
	for <linux-mm@kvack.org>; Mon, 30 Apr 2012 23:34:31 -0400 (EDT)
Received: by obbwd18 with SMTP id wd18so2784695obb.14
        for <linux-mm@kvack.org>; Mon, 30 Apr 2012 20:34:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALWz4ixeBq7cMoopukaRZxUmH1i0+L4xZ_49B0YpZ4iZuRC+Uw@mail.gmail.com>
References: <1335214564-17619-1-git-send-email-yinghan@google.com>
	<CAPa8GCATMxi2ON22T_daE9EMFg8BWgK4vRTDadDFR66aj_uGTg@mail.gmail.com>
	<CALWz4ixeBq7cMoopukaRZxUmH1i0+L4xZ_49B0YpZ4iZuRC+Uw@mail.gmail.com>
Date: Tue, 1 May 2012 13:34:30 +1000
Message-ID: <CAPa8GCC1opy9u6NHy9m=1xU4EfRsHu8VN2kU-bXtRz=z_Mq0PA@mail.gmail.com>
Subject: Re: [RFC PATCH] do_try_to_free_pages() might enter infinite loop
From: Nick Piggin <npiggin@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On 25 April 2012 04:37, Ying Han <yinghan@google.com> wrote:
> On Mon, Apr 23, 2012 at 10:36 PM, Nick Piggin <npiggin@gmail.com> wrote:
>> On 24 April 2012 06:56, Ying Han <yinghan@google.com> wrote:
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
>>
>> Very likely, or definitely? Can you reproduce it? What workload?
>
> No, we don't have reproduce workload for that yet. Everything is based
> on the watchdog dump file :(
>
>>
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
>> The problem we were having is that processes would be killed at seemingl=
y
>> random points of time, under heavy swapping, but long before all swap wa=
s
>> used.
>>
>> The particular problem IIRC was related to testing a lot of guests on an=
 s390
>> machine. I'm ashamed to have not included more information in the
>> changelog -- I suspect it was probably in a small batch of patches with =
a
>> description in the introductory mail and not properly placed into patche=
s :(
>>
>> There are certainly a lot of changes in the area since then, so I couldn=
't be
>> sure of what will happen by taking this out.
>>
>> I don't think the page allocator "try harder" logic was enough to solve =
the
>> problem, and I think it was around in some form even back then.
>>
>> The biggest problem is that it's not an exact science. It will never do =
the
>> right thing for everybody, sadly. Even if it is able to allocate pages a=
t a
>> very slow rate, this is effectively as good as a hang for some users. Fo=
r
>> others, they want to be able to manually intervene before anything is ki=
lled.
>>
>> Sorry if this isn't too helpful! Any ideas would be good. Possibly need =
to have
>> a way to describe these behaviours in an abstract way (i.e., not just ma=
gic
>> numbers), and allow user to tune it.
>
> Thank you Nick and this is helpful. I looked up on the patches you
> mentioned, and I can see what problem they were trying to solve by
> that time. However things have been changed a lot, and it is hard to
> tell if the problem still remains on the current kernel or not. By
> spotting each by each, I see either the patch has been replaced by
> different logic or the same logic has been implemented differently.
>
> For this particular one patch, we now have code which does page alloc
> retry before entering OOM. So I am wondering if that will help the OOM
> situation by that time.

Well it's not doing exactly the same thing, actually. And note that the
problem was not about parallel OOM-killing. The fact that the page
reclaim has not made any progress when we last called in does not
actually mean that it cannot make _any_ progress.

My patch is more about detecting the latter case. I don't see there
is equivalent logic in page allocator to replace it.

But again: this is not a question of correct or incorrect as far as I
can see, simply a matter of where you define "hopeless"! I could
easily see the need for way to bias that (kill quickly, medium, try to
never kill).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
