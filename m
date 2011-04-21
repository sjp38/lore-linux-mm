Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 05C418D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 05:05:22 -0400 (EDT)
Received: by iwg8 with SMTP id 8so1874194iwg.14
        for <linux-mm@kvack.org>; Thu, 21 Apr 2011 02:05:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110421174616.4fd79c5e.kamezawa.hiroyu@jp.fujitsu.com>
References: <1303185466-2532-1-git-send-email-yinghan@google.com>
	<20110421124357.c94a03a5.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTi=a967ofJGV1_i2vMb9QDGuK7vtog@mail.gmail.com>
	<20110421174616.4fd79c5e.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 21 Apr 2011 18:05:21 +0900
Message-ID: <BANLkTimueD3mNTKx6JsgRgAkB3WkGU7GrA@mail.gmail.com>
Subject: Re: [PATCH 1/3] memcg kswapd thread pool (Was Re: [PATCH V6 00/10]
 memcg: per cgroup background reclaim
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Ying Han <yinghan@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Thu, Apr 21, 2011 at 5:46 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Thu, 21 Apr 2011 17:10:23 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> Hi Kame,
>>
>> On Thu, Apr 21, 2011 at 12:43 PM, KAMEZAWA Hiroyuki
>> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> > Ying, please take this just a hint, you don't need to implement this as is.
>> > ==
>> > Now, memcg-kswapd is created per a cgroup. Considering there are users
>> > who creates hundreds on cgroup on a system, it consumes too much
>> > resources, memory, cputime.
>> >
>> > This patch creates a thread pool for memcg-kswapd. All memcg which
>> > needs background recalim are linked to a list and memcg-kswapd
>> > picks up a memcg from the list and run reclaim. This reclaimes
>> > SWAP_CLUSTER_MAX of pages and putback the memcg to the lail of
>> > list. memcg-kswapd will visit memcgs in round-robin manner and
>> > reduce usages.
>> >
>>
>> I didn't look at code yet but as I just look over the description, I
>> have a concern.
>> We have discussed LRU separation between global and memcg.
>
> Please discuss global LRU in other thread. memcg-kswapd is not related
> to global LRU _at all_.
>
> And this patch set is independent from the things we discussed at LSF.
>
>
>> The clear goal is that how to keep _fairness_.
>>
>> For example,
>>
>> memcg-1 : # pages of LRU : 64
>> memcg-2 : # pages of LRU : 128
>> memcg-3 : # pages of LRU : 256
>>
>> If we have to reclaim 96 pages, memcg-1 would be lost half of pages.
>> It's much greater than others so memcg 1's page LRU rotation cycle
>> would be very fast, then working set pages in memcg-1 don't have a
>> chance to promote.
>> Is it fair?
>>
>> I think we should consider memcg-LRU size as doing round-robin.
>>
>
> This set doesn't implement a feature to handle your example case, at all.

Sure. Sorry for the confusing.
I don't mean global LRU but it a fairness although this series is
based on per-memcg targeting.

>
> This patch set handles
>
> memcg-1: # pages of over watermark : 64
> memcg-2: # pages of over watermark : 128
> memcg-3: # pages of over watermark : 256
>
> And finally reclaim all pages over watermarks which user requested.
> Considering fairness, what we consider is in what order we reclaim
> memory memcg-1, memcg-2, memcg-3 and how to avoid unnecessary cpu
> hogging at reclaiming memory all (64+128+256)
>
> This thread pool reclaim 32 pages per iteration with patch-1 and visit all
> in round-robin.
> With patch-2, reclaim 32*weight pages per iteration on each memcg.
>

I should have seen the patch [2/3] before posting the comment.
Maybe you seem consider my concern.
Okay. I will look the idea.

>
> Thanks,
> -Kame
>
>



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
