Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 070C26B002C
	for <linux-mm@kvack.org>; Wed,  8 Feb 2012 15:54:34 -0500 (EST)
Received: by qcsd16 with SMTP id d16so690540qcs.14
        for <linux-mm@kvack.org>; Wed, 08 Feb 2012 12:54:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120208093120.GA18993@localhost>
References: <CAHH2K0b-+T4dspJPKq5TH25aH58TEr+7yvq0-HMkbFi0ghqAfA@mail.gmail.com>
	<20120208093120.GA18993@localhost>
Date: Wed, 8 Feb 2012 12:54:33 -0800
Message-ID: <CALWz4izTS_E3uHLLfq3c9=LCuEh_yykmfrRAv4G1gUHumzGDzQ@mail.gmail.com>
Subject: Re: memcg writeback (was Re: [Lsf-pc] [LSF/MM TOPIC] memcg topics.)
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Greg Thelen <gthelen@google.com>, Jan Kara <jack@suse.cz>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, lsf-pc@lists.linux-foundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Wed, Feb 8, 2012 at 1:31 AM, Wu Fengguang <fengguang.wu@intel.com> wrote=
:
> On Tue, Feb 07, 2012 at 11:55:05PM -0800, Greg Thelen wrote:
>> On Fri, Feb 3, 2012 at 1:40 AM, Wu Fengguang <fengguang.wu@intel.com> wr=
ote:
>> > If moving dirty pages out of the memcg to the 20% global dirty pages
>> > pool on page reclaim, the above OOM can be avoided. It does change the
>> > meaning of memory.limit_in_bytes in that the memcg tasks can now
>> > actually consume more pages (up to the shared global 20% dirty limit).
>>
>> This seems like an easy change, but unfortunately the global 20% pool
>> has some shortcomings for my needs:
>>
>> 1. the global 20% pool is not moderated. =A0One cgroup can dominate it
>> =A0 =A0 and deny service to other cgroups.
>
> It is moderated by balance_dirty_pages() -- in terms of dirty ratelimit.
> And you have the freedom to control the bandwidth allocation with some
> async write I/O controller.
>
> Even though there is no direct control of dirty pages, we can roughly
> get it as the side effect of rate control. Given
>
> =A0 =A0 =A0 =A0ratelimit_cgroup_A =3D 2 * ratelimit_cgroup_B
>
> There will naturally be more dirty pages for cgroup A to be worked by
> the flusher. And the dirty pages will be roughly balanced around
>
> =A0 =A0 =A0 =A0nr_dirty_cgroup_A =3D 2 * nr_dirty_cgroup_B
>
> when writeout bandwidths for their dirty pages are equal.
>
>> 2. the global 20% pool is free, unaccounted memory. =A0Ideally cgroups o=
nly
>> =A0 =A0 use the amount of memory specified in their memory.limit_in_byte=
s. =A0The
>> =A0 =A0 goal is to sell portions of a system. =A0Global resource like th=
e 20% are an
>> =A0 =A0 undesirable system-wide tax that's shared by jobs that may not e=
ven
>> =A0 =A0 perform buffered writes.
>
> Right, it is the shortcoming.
>
>> 3. Setting aside 20% extra memory for system wide dirty buffers is a lot=
 of
>> =A0 =A0 memory. =A0This becomes a larger issue when the global dirty_rat=
io is
>> =A0 =A0 higher than 20%.
>
> Yeah the global pool scheme does mean that you'd better allocate at
> most 80% memory to individual memory cgroups, otherwise it's possible
> for a tiny memcg doing dd writes to push dirty pages to global LRU and
> *squeeze* the size of other memcgs.
>
> However I guess it should be mitigated by the fact that
>
> - we typically already reserve some space for the root memcg

Can you give more details on that? AFAIK, we don't treat root cgroup
differently than other sub-cgroups, except root cgroup doesn't have
limit.

In general, I don't like the idea of shared pool in root for all the
dirty pages.

Imagining a system which has nothing running under root and every
application runs within sub-cgroup. It is easy to track and limit each
cgroup's memory usage, but not the pages being moved to root. We have
been experiencing difficulties of tracking pages being re-parented to
root, and this will make it even harder.

--Ying

>
> - 20% dirty ratio is mostly an overkill for large memory systems.
> =A0It's often enough to hold 10-30s worth of dirty data for them, which
> =A0is 1-3GB for one 100MB/s disk. This is the reason vm.dirty_bytes is
> =A0introduced: someone wants to do some <1% dirty ratio.
>
> Thanks,
> Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
