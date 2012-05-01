Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id AE8136B0044
	for <linux-mm@kvack.org>; Tue,  1 May 2012 12:20:40 -0400 (EDT)
Received: by lbjn8 with SMTP id n8so3097069lbj.14
        for <linux-mm@kvack.org>; Tue, 01 May 2012 09:20:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALWz4iyv1wSkdS0e9iezbpAg_adBhKvxRVqmXX1i4mk3x_V34g@mail.gmail.com>
References: <1335214564-17619-1-git-send-email-yinghan@google.com>
	<CAPa8GCATMxi2ON22T_daE9EMFg8BWgK4vRTDadDFR66aj_uGTg@mail.gmail.com>
	<CALWz4ixeBq7cMoopukaRZxUmH1i0+L4xZ_49B0YpZ4iZuRC+Uw@mail.gmail.com>
	<CAPa8GCC1opy9u6NHy9m=1xU4EfRsHu8VN2kU-bXtRz=z_Mq0PA@mail.gmail.com>
	<CALWz4iyv1wSkdS0e9iezbpAg_adBhKvxRVqmXX1i4mk3x_V34g@mail.gmail.com>
Date: Tue, 1 May 2012 09:20:38 -0700
Message-ID: <CALWz4iy2jiPjoxpP1teGJF+RtS+7G9F_6bsSf2hd4Eh-6wUXLw@mail.gmail.com>
Subject: Re: [RFC PATCH] do_try_to_free_pages() might enter infinite loop
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nick Piggin <npiggin@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

take off the old mailing address of Nick :)

--Ying

On Tue, May 1, 2012 at 9:18 AM, Ying Han <yinghan@google.com> wrote:
> On Mon, Apr 30, 2012 at 8:34 PM, Nick Piggin <npiggin@gmail.com> wrote:
>> On 25 April 2012 04:37, Ying Han <yinghan@google.com> wrote:
>>> On Mon, Apr 23, 2012 at 10:36 PM, Nick Piggin <npiggin@gmail.com> wrote=
:
>>>> On 24 April 2012 06:56, Ying Han <yinghan@google.com> wrote:
>>>>> This is not a patch targeted to be merged at all, but trying to under=
stand
>>>>> a logic in global direct reclaim.
>>>>>
>>>>> There is a logic in global direct reclaim where reclaim fails on prio=
rity 0
>>>>> and zone->all_unreclaimable is not set, it will cause the direct to s=
tart over
>>>>> from DEF_PRIORITY. In some extreme cases, we've seen the system hang =
which is
>>>>> very likely caused by direct reclaim enters infinite loop.
>>>>
>>>> Very likely, or definitely? Can you reproduce it? What workload?
>>>
>>> No, we don't have reproduce workload for that yet. Everything is based
>>> on the watchdog dump file :(
>>>
>>>>
>>>>>
>>>>> There have been serious patches trying to fix similar issue and the l=
atest
>>>>> patch has good summary of all the efforts:
>>>>>
>>>>> commit 929bea7c714220fc76ce3f75bef9056477c28e74
>>>>> Author: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>>>>> Date: =A0 Thu Apr 14 15:22:12 2011 -0700
>>>>>
>>>>> =A0 =A0vmscan: all_unreclaimable() use zone->all_unreclaimable as a n=
ame
>>>>>
>>>>> Kosaki explained the problem triggered by async zone->all_unreclaimab=
le and
>>>>> zone->pages_scanned where the later one was being checked by direct r=
eclaim.
>>>>> However, after the patch, the problem remains where the setting of
>>>>> zone->all_unreclaimable is asynchronous with zone is actually reclaim=
able or not.
>>>>>
>>>>> The zone->all_unreclaimable flag is set by kswapd by checking zone->p=
ages_scanned in
>>>>> zone_reclaimable(). Is that possible to have zone->all_unreclaimable =
=3D=3D false while
>>>>> the zone is actually unreclaimable?
>>>>>
>>>>> 1. while kswapd in reclaim priority loop, someone frees a page on the=
 zone. It
>>>>> will end up resetting the pages_scanned.
>>>>>
>>>>> 2. kswapd is frozen for whatever reason. I noticed Kosaki's covered t=
he
>>>>> hibernation case by checking oom_killer_disabled, but not sure if tha=
t is
>>>>> everything we need to worry about. The key point here is that direct =
reclaim
>>>>> relies on a flag which is set by kswapd asynchronously, that doesn't =
sound safe.
>>>>>
>>>>> Instead of keep fixing the problem, I am wondering why we have the lo=
gic
>>>>> "not oom but keep trying reclaim w/ priority 0 reclaim failure" at th=
e first place:
>>>>>
>>>>> Here is the patch introduced the logic initially:
>>>>>
>>>>> commit 408d85441cd5a9bd6bc851d677a10c605ed8db5f
>>>>> Author: Nick Piggin <npiggin@suse.de>
>>>>> Date: =A0 Mon Sep 25 23:31:27 2006 -0700
>>>>>
>>>>> =A0 =A0[PATCH] oom: use unreclaimable info
>>>>>
>>>>> However, I didn't find detailed description of what problem the commi=
t trying
>>>>> to fix and wondering if the problem still exist after 5 years. I woul=
d be happy
>>>>> to see the later case where we can consider to revert the initial pat=
ch.
>>>>
>>>> The problem we were having is that processes would be killed at seemin=
gly
>>>> random points of time, under heavy swapping, but long before all swap =
was
>>>> used.
>>>>
>>>> The particular problem IIRC was related to testing a lot of guests on =
an s390
>>>> machine. I'm ashamed to have not included more information in the
>>>> changelog -- I suspect it was probably in a small batch of patches wit=
h a
>>>> description in the introductory mail and not properly placed into patc=
hes :(
>>>>
>>>> There are certainly a lot of changes in the area since then, so I coul=
dn't be
>>>> sure of what will happen by taking this out.
>>>>
>>>> I don't think the page allocator "try harder" logic was enough to solv=
e the
>>>> problem, and I think it was around in some form even back then.
>>>>
>>>> The biggest problem is that it's not an exact science. It will never d=
o the
>>>> right thing for everybody, sadly. Even if it is able to allocate pages=
 at a
>>>> very slow rate, this is effectively as good as a hang for some users. =
For
>>>> others, they want to be able to manually intervene before anything is =
killed.
>>>>
>>>> Sorry if this isn't too helpful! Any ideas would be good. Possibly nee=
d to have
>>>> a way to describe these behaviours in an abstract way (i.e., not just =
magic
>>>> numbers), and allow user to tune it.
>>>
>>> Thank you Nick and this is helpful. I looked up on the patches you
>>> mentioned, and I can see what problem they were trying to solve by
>>> that time. However things have been changed a lot, and it is hard to
>>> tell if the problem still remains on the current kernel or not. By
>>> spotting each by each, I see either the patch has been replaced by
>>> different logic or the same logic has been implemented differently.
>>>
>>> For this particular one patch, we now have code which does page alloc
>>> retry before entering OOM. So I am wondering if that will help the OOM
>>> situation by that time.
>>
>> Well it's not doing exactly the same thing, actually. And note that the
>> problem was not about parallel OOM-killing. The fact that the page
>> reclaim has not made any progress when we last called in does not
>> actually mean that it cannot make _any_ progress.
>>
>> My patch is more about detecting the latter case. I don't see there
>> is equivalent logic in page allocator to replace it.
>>
>> But again: this is not a question of correct or incorrect as far as I
>> can see, simply a matter of where you define "hopeless"! I could
>> easily see the need for way to bias that (kill quickly, medium, try to
>> never kill).
>
> That is right. We ( at google) seems to be on the other end of the
> bias where we prefer to oom kill instead of hopelessly looping in the
> reclaim path. Normally if the application gets into that state, the
> performance would be sucks already and they might prefer to be
> restarted :)
>
> Unfortunately, We weren't being able to reproduce the issue with
> synthetic workload. So far it only happens in production with a
> particular workload when the memory runs really really tight.
>
> The current logic seems perfer to reclaim more than going oom kill,
> and that might not fit all user's expectation. However, I guess it is
> hard to convince for any changes since different users has different
> bias as you said....
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
