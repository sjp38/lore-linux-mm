Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8E6676B004A
	for <linux-mm@kvack.org>; Wed,  1 Jun 2011 20:36:20 -0400 (EDT)
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id p520aDhR032472
	for <linux-mm@kvack.org>; Wed, 1 Jun 2011 17:36:13 -0700
Received: from qwb8 (qwb8.prod.google.com [10.241.193.72])
	by kpbe11.cbf.corp.google.com with ESMTP id p520ZtII003201
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 1 Jun 2011 17:36:02 -0700
Received: by qwb8 with SMTP id 8so244876qwb.11
        for <linux-mm@kvack.org>; Wed, 01 Jun 2011 17:35:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTikgqSsg5+49295h7kdZ=sQpZLs4kw@mail.gmail.com>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org> <BANLkTikgqSsg5+49295h7kdZ=sQpZLs4kw@mail.gmail.com>
From: Greg Thelen <gthelen@google.com>
Date: Wed, 1 Jun 2011 17:35:37 -0700
Message-ID: <BANLkTi=kJ-r=bZqB8X+KAu+ueapXYLjxnLNRdxRAkDGWk4k_AA@mail.gmail.com>
Subject: Re: [patch 0/8] mm: memcg naturalization -rc2
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Jun 1, 2011 at 4:52 PM, Hiroyuki Kamezawa
<kamezawa.hiroyuki@gmail.com> wrote:
> 2011/6/1 Johannes Weiner <hannes@cmpxchg.org>:
>> Hi,
>>
>> this is the second version of the memcg naturalization series. =A0The
>> notable changes since the first submission are:
>>
>> =A0 =A0o the hierarchy walk is now intermittent and will abort and
>> =A0 =A0 =A0remember the last scanned child after sc->nr_to_reclaim pages
>> =A0 =A0 =A0have been reclaimed during the walk in one zone (Rik)
>>
>> =A0 =A0o the global lru lists are never scanned when memcg is enabled
>> =A0 =A0 =A0after #2 'memcg-aware global reclaim', which makes this patch
>> =A0 =A0 =A0self-sufficient and complete without requiring the per-memcg =
lru
>> =A0 =A0 =A0lists to be exclusive (Michal)
>>
>> =A0 =A0o renamed sc->memcg and sc->current_memcg to sc->target_mem_cgrou=
p
>> =A0 =A0 =A0and sc->mem_cgroup and fixed their documentation, I hope this=
 is
>> =A0 =A0 =A0better understandable now (Rik)
>>
>> =A0 =A0o the reclaim statistic counters have been renamed. =A0there is n=
o
>> =A0 =A0 =A0more distinction between 'pgfree' and 'pgsteal', it is now
>> =A0 =A0 =A0'pgreclaim' in both cases; 'kswapd' has been replaced by
>> =A0 =A0 =A0'background'
>>
>> =A0 =A0o fixed a nasty crash in the hierarchical soft limit check that
>> =A0 =A0 =A0happened during global reclaim in memcgs that are hierarchica=
l
>> =A0 =A0 =A0but have no hierarchical parents themselves
>>
>> =A0 =A0o properly implemented the memcg-aware unevictable page rescue
>> =A0 =A0 =A0scanner, there were several blatant bugs in there
>>
>> =A0 =A0o documentation on new public interfaces
>>
>> Thanks for your input on the first version.
>>
>> I ran microbenchmarks (sparse file catting, essentially) to stress
>> reclaim and LRU operations. =A0There is no measurable overhead for
>> !CONFIG_MEMCG, memcg disabled during boot, memcg enabled but no
>> configured groups, and hard limit reclaim.
>>
>> I also ran single-threaded kernbenchs in four unlimited memcgs in
>> parallel, contained in a hard-limited hierarchical parent that put
>> constant pressure on the workload. =A0There is no measurable difference
>> in runtime, the pgpgin/pgpgout counters, and fairness among memcgs in
>> this test compared to an unpatched kernel. =A0Needs more evaluation,
>> especially with a higher number of memcgs.
>>
>> The soft limit changes are also proven to work in so far that it is
>> possible to prioritize between children in a hierarchy under pressure
>> and that runtime differences corresponded directly to the soft limit
>> settings in the previously described kernbench setup with staggered
>> soft limits on the groups, but this needs quantification.
>>
>> Based on v2.6.39.
>>
>
> Hmm, I welcome and will review this patches but.....some points I want to=
 say.
>
> 1. No more conflict with Ying's work ?
> =A0 =A0Could you explain what she has and what you don't in this v2 ?
> =A0 =A0If Ying's one has something good to be merged to your set, please
> include it.
>
> 2. it's required to see performance score in commit log.
>
> 3. I think dirty_ratio as 1st big patch to be merged. (But...hmm..Greg ?
> =A0 =A0My patches for asynchronous reclaim is not very important. I can r=
ework it.

I am testing the next version (v8) of the memcg dirty ratio patches.  I exp=
ect
to have it posted for review later this week.

> 4. This work can be splitted into some small works.
> =A0 =A0 a) fix for current code and clean ups
> =A0 =A0 a') statistics
> =A0 =A0 b) soft limit rework
> =A0 =A0 c) change global reclaim
>
> =A0I like (a)->(b)->(c) order. and while (b) you can merge your work
> with Ying's one.
> =A0And for a') , I'd like to add a new file memory.reclaim_stat as I've
> already shown.
> =A0and allow resetting.
>
> =A0Hmm, how about splitting patch 2/8 into small patches and see what hap=
pens in
> =A03.2 or 3.3 ? While that, we can make softlimit works better.
> =A0(and once we do 2/8, our direction will be fixed to the direction to
> remove global LRU.)
>
> 5. please write documentation to explain what new LRU do.
>
> BTW, after this work, lists of ROOT cgroup comes again. I may need to che=
ck
> codes which see memcg is ROOT or not. Because we removed many atomic
> ops in memcg, I wonder ROOT cgroup can be accounted again..
>
> Thanks,
> -Kame
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
