Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id D9F2B6B005A
	for <linux-mm@kvack.org>; Mon, 20 Aug 2012 14:12:52 -0400 (EDT)
Received: by lahd3 with SMTP id d3so4103191lah.14
        for <linux-mm@kvack.org>; Mon, 20 Aug 2012 11:12:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <50323968.1030503@jp.fujitsu.com>
References: <1343942658-13307-1-git-send-email-yinghan@google.com>
	<20120803152234.GE8434@dhcp22.suse.cz>
	<501BF952.7070202@redhat.com>
	<CALWz4iw6Q500k5qGWaubwLi-3V3qziPuQ98Et9Ay=LS0-PB0dQ@mail.gmail.com>
	<20120806133324.GD6150@dhcp22.suse.cz>
	<CALWz4iw2NqQw3FgjM9k6nbMb7k8Gy2khdyL_9NpGM6T7Ma5t3g@mail.gmail.com>
	<50323968.1030503@jp.fujitsu.com>
Date: Mon, 20 Aug 2012 11:12:50 -0700
Message-ID: <CALWz4izbRBxy4PU2Gs=Hi9q2gWnOYhUGT_dnMaEmWUFKpkooew@mail.gmail.com>
Subject: Re: [PATCH V8 1/2] mm: memcg softlimit reclaim rework
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Mon, Aug 20, 2012 at 6:19 AM, Kamezawa Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> (2012/08/18 7:03), Ying Han wrote:
>>
>> On Mon, Aug 6, 2012 at 6:33 AM, Michal Hocko <mhocko@suse.cz> wrote:
>>>
>>> On Fri 03-08-12 09:34:11, Ying Han wrote:
>>>>
>>>> On Fri, Aug 3, 2012 at 9:16 AM, Rik van Riel <riel@redhat.com> wrote:
>>>>>
>>>>> On 08/03/2012 11:22 AM, Michal Hocko wrote:
>>>>>>
>>>>>>
>>>>>> On Thu 02-08-12 14:24:18, Ying Han wrote:
>>>>>>
>>>>>> I am thinking that we could add a constant for the priority
>>>>>> limit. Something like
>>>>>> #define MEMCG_LOW_SOFTLIMIT_PRIORITY    DEF_PRIORITY
>>>>>>
>>>>>> Although it doesn't seem necessary at the moment, because there is
>>>>>> just
>>>>>> one location where it matters but it could help in the future.
>>>>>> What do you think?
>>>>>
>>>>>
>>>>>
>>>>> I am working on changing the code to find the "highest priority"
>>>>> LRU and reclaim from that list first.  That will obviate the need
>>>>> for such a change. However, the other cleanups and simplifications
>>>>> made by Ying's patch are good to have...
>>>>
>>>>
>>>> So what you guys think to take from here. I can make the change as
>>>> Michal suggested if that would be something helpful future changes.
>>>> However, I wonder whether or not it is necessary.
>>>
>>>
>>> I am afraid we will not move forward without a proper implementation of
>>> the "nobody under soft limit" case. Maybe Rik's idea would just work out
>>> but this patch on it's own could regress so taking it separately is no
>>> go IMO. I like how it reduces the code size but we are not "there" yet...
>>>
>>
>> Sorry for getting back to the thread late. Being distracted to
>> something else which of course happens all the time.
>>
>> Before me jumping into actions of any changes, let me clarify the
>> problem I am facing:
>>
>> All the concerns are related to the configuration where none of the
>> memcg is eligible for reclaim ( usage < softlimit ) under global
>> pressure.   The current code works like the following:
>>
>> 1. walk the memcg tree and for each checks the softlimit
>> 2. if none of the memcg is being reclaimed, then set the ignore_softlimit
>> 3. restart the walk and this round forget about the softlimit
>>
>> There are two problems I heard here:
>> 1. doing a full walk on step 1 would cause potential scalability issue.
>>
>
> Simply thinking, I think maintaining & updating the whole softlimit
> information
> periodically is a way to avoid double-scan. memcg has a percpu event-counter
> and
> css-id bitmap will be enough for keeping information. Then, you can find
> over-softlimit memcg by bitmap scanning.
>
>
>
>> 2. root cgroup is a exception where it always eligible for reclaim (
>> softlimit = 0 always). That will cause root to be punished more than
>> necessary.
>>
>
> When use_hierarchy==0 ?
> How about having implicit softlimit value for root, which is automatically
> calculated from total_ram or the number of tasks in root ?

No, we have use_hierarchy set to 1 for root. Also, as part of the
patchset the softlimit of root is set to 0 and  also can not be
modified later. There is a reason behind it mainly because now we
check the softlimit of a memcg hierarchically.

Calculating the softlimit for root sounds an over-kill and not
necessary. It works fine to have softlimit of root to 0 and we just
need to fix the inefficiency in the code where no non-memcg is above
softlimit. In that case, we don't want to over-punish root.

My current version is to not counting root to set ignore_softlimit
flag, so at least the second round of scanning will look at all the
other memcgs. I don't see a major problem of it apart from the
scalability concern addressed on 1.

--Ying

> Thanks,
> -Kame
>
>
>
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
