Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id ECCAE8D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 20:37:06 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id p2T0b4ZQ020443
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 17:37:04 -0700
Received: from qyk36 (qyk36.prod.google.com [10.241.83.164])
	by hpaq2.eem.corp.google.com with ESMTP id p2T0aVMH012666
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 17:37:02 -0700
Received: by qyk36 with SMTP id 36so2029637qyk.18
        for <linux-mm@kvack.org>; Mon, 28 Mar 2011 17:37:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110329091254.20c7cfcb.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110328093957.089007035@suse.cz>
	<AANLkTi=CPMxOg3juDiD-_hnBsXKdZ+at+i9c1YYM=vv1@mail.gmail.com>
	<20110329091254.20c7cfcb.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 28 Mar 2011 17:37:02 -0700
Message-ID: <BANLkTin4J5kiysPdQD2aTC52U4-dy04C1g@mail.gmail.com>
Subject: Re: [RFC 0/3] Implementation of cgroup isolation
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Suleiman Souhlal <suleiman@google.com>

On Mon, Mar 28, 2011 at 5:12 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Mon, 28 Mar 2011 11:01:18 -0700
> Ying Han <yinghan@google.com> wrote:
>
>> On Mon, Mar 28, 2011 at 2:39 AM, Michal Hocko <mhocko@suse.cz> wrote:
>> > Hi all,
>> >
>> > Memory cgroups can be currently used to throttle memory usage of a group of
>> > processes. It, however, cannot be used for an isolation of processes from
>> > the rest of the system because all the pages that belong to the group are
>> > also placed on the global LRU lists and so they are eligible for the global
>> > memory reclaim.
>> >
>> > This patchset aims at providing an opt-in memory cgroup isolation. This
>> > means that a cgroup can be configured to be isolated from the rest of the
>> > system by means of cgroup virtual filesystem (/dev/memctl/group/memory.isolated).
>>
>> Thank you Hugh pointing me to the thread. We are working on similar
>> problem in memcg currently
>>
>> Here is the problem we see:
>> 1. In memcg, a page is both on per-memcg-per-zone lru and global-lru.
>> 2. Global memory reclaim will throw page away regardless of cgroup.
>> 3. The zone->lru_lock is shared between per-memcg-per-zone lru and global-lru.
>>
>> And we know:
>> 1. We shouldn't do global reclaim since it breaks memory isolation.
>> 2. There is no need for a page to be on both LRU list, especially
>> after having per-memcg background reclaim.
>>
>> So our approach is to take off page from global lru after it is
>> charged to a memcg. Only pages allocated at root cgroup remains in
>> global LRU, and each memcg reclaims pages on its isolated LRU.
>>
>
> Why you don't use cpuset and virtual nodes ? It's what you want.

We've been running cpuset + fakenuma nodes configuration in google to
provide memory isolation. The configuration of having the virtual box
is complex which user needs to know great details of the which node to
assign to which cgroup. That is one of the motivations for us moving
towards to memory controller which simply do memory accounting no
matter where pages are allocated.

By saying that, memcg simplified the memory accounting per-cgroup but
the memory isolation is broken. This is one of examples where pages
are shared between global LRU and per-memcg LRU. It is easy to get
cgroup-A's page evicted by adding memory pressure to cgroup-B.

The approach we are thinking to make the page->lru exclusive solve the
problem. and also we should be able to break the zone->lru_lock
sharing.

--Ying




>
> Thanks,
> -Kame
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
