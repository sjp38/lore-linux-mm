Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id CBF166B13F2
	for <linux-mm@kvack.org>; Fri, 10 Feb 2012 00:51:53 -0500 (EST)
Received: by vcbf13 with SMTP id f13so1153765vcb.14
        for <linux-mm@kvack.org>; Thu, 09 Feb 2012 21:51:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120208093120.GA18993@localhost>
References: <CAHH2K0b-+T4dspJPKq5TH25aH58TEr+7yvq0-HMkbFi0ghqAfA@mail.gmail.com>
 <20120208093120.GA18993@localhost>
From: Greg Thelen <gthelen@google.com>
Date: Thu, 9 Feb 2012 21:51:31 -0800
Message-ID: <CAHH2K0bmURXpk6-4D9q7ErppVyMJjKMsn37MenwqcP_nnT66Mw@mail.gmail.com>
Subject: Re: memcg writeback (was Re: [Lsf-pc] [LSF/MM TOPIC] memcg topics.)
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

(removed lsf-pc@lists.linux-foundation.org because this really isn't
program committee matter)

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
>
> - 20% dirty ratio is mostly an overkill for large memory systems.
> =A0It's often enough to hold 10-30s worth of dirty data for them, which
> =A0is 1-3GB for one 100MB/s disk. This is the reason vm.dirty_bytes is
> =A0introduced: someone wants to do some <1% dirty ratio.

Have you encountered situations where it's desirable to have more than
20% dirty ratio?  I imagine that if the dirty working set is larger
than 20% increasing dirty ratio would prevent rewrites.

Leaking dirty memory to a root global dirty pool is concerning.  I
suspect that under some conditions such pages may remain remain in
root after writeback indefinitely as clean pages.  I admit this may
not be the common case, but having such leaks into root can allow low
priority jobs access entire machine denying service to higher priority
jobs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
