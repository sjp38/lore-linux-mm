Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E925B6B002C
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 13:46:24 -0400 (EDT)
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id p3SHkH9f019199
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 10:46:18 -0700
Received: from qyg14 (qyg14.prod.google.com [10.241.82.142])
	by hpaq11.eem.corp.google.com with ESMTP id p3SHkALn023650
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 10:46:11 -0700
Received: by qyg14 with SMTP id 14so1558077qyg.19
        for <linux-mm@kvack.org>; Thu, 28 Apr 2011 10:46:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110428123652.GM12437@cmpxchg.org>
References: <20110428121643.b3cbf420.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTimywCF06gfKWFcbAsWtFUbs73rZrQ@mail.gmail.com>
	<20110428180139.6ec67196.kamezawa.hiroyu@jp.fujitsu.com>
	<20110428123652.GM12437@cmpxchg.org>
Date: Thu, 28 Apr 2011 10:46:07 -0700
Message-ID: <BANLkTikJxWmF+8P3-pGeyECaDoV01v77Pg@mail.gmail.com>
Subject: Re: Fw: [PATCH] memcg: add reclaim statistics accounting
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Apr 28, 2011 at 5:36 AM, Johannes Weiner <hannes@cmpxchg.org> wrote=
:
> On Thu, Apr 28, 2011 at 06:01:39PM +0900, KAMEZAWA Hiroyuki wrote:
>> On Wed, 27 Apr 2011 20:43:58 -0700
>> Ying Han <yinghan@google.com> wrote:
>>
>> > On Wed, Apr 27, 2011 at 8:16 PM, KAMEZAWA Hiroyuki
>> > <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> > > sorry, I had wrong TO:...
>> > >
>> > > Begin forwarded message:
>> > >
>> > > Date: Thu, 28 Apr 2011 12:02:34 +0900
>> > > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> > > To: linux-mm@vger.kernel.org
>> > > Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "=
nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.v=
net.ibm.com" <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, "a=
kpm@linux-foundation.org" <akpm@linux-foundation.org>
>> > > Subject: [PATCH] memcg: add reclaim statistics accounting
>> > >
>> > >
>> > >
>> > > Now, memory cgroup provides poor reclaim statistics per memcg. This
>> > > patch adds statistics for direct/soft reclaim as the number of
>> > > pages scans, the number of page freed by reclaim, the nanoseconds of
>> > > latency at reclaim.
>> > >
>> > > It's good to add statistics before we modify memcg/global reclaim, l=
argely.
>> > > This patch refactors current soft limit status and add an unified up=
date logic.
>> > >
>> > > For example, After #cat 195Mfile > /dev/null under 100M limit.
>> > > =A0 =A0 =A0 =A0# cat /cgroup/memory/A/memory.stat
>> > > =A0 =A0 =A0 =A0....
>> > > =A0 =A0 =A0 =A0limit_freed 24592
>> >
>> > why not "limit_steal" ?
>> >
>> > > =A0 =A0 =A0 =A0soft_steal 0
>> > > =A0 =A0 =A0 =A0limit_scan 43974
>> > > =A0 =A0 =A0 =A0soft_scan 0
>> > > =A0 =A0 =A0 =A0limit_latency 133837417
>> > >
>> > > nearly 96M caches are freed. scanned twice. used 133ms.
>> >
>> > Does it make sense to split up the soft_steal/scan for bg reclaim and
>> > direct reclaim? The same for the limit_steal/scan. I am now testing
>> > the patch to add the soft_limit reclaim on global ttfp, and i already
>> > have the patch to add the following:
>> >
>> > kswapd_soft_steal 0
>> > kswapd_soft_scan 0
>> > direct_soft_steal 0
>> > direct_soft_scan 0
>> > kswapd_steal 0
>> > pg_pgsteal 0
>> > kswapd_pgscan 0
>> > pg_scan 0
>> >
>>
>> I'll not post updated version until the end of holidays but my latest pl=
an is
>> adding
>>
>>
>> limit_direct_free =A0 - # of pages freed by limit in foreground (not ste=
aled, you freed by yourself's limit)
>> soft_kswapd_steal =A0 - # of pages stealed by kswapd based on soft limit
>> limit_direct_scan =A0 - # of pages scanned by limit in foreground
>> soft_kswapd_scan =A0 =A0- # of pages scanned by kswapd based on soft lim=
it
>>
>> And then, you can add
>>
>> soft_direct_steal =A0 =A0 - # of pages stealed by foreground reclaim bas=
ed on soft limit
>> soft_direct_scan =A0 =A0 =A0 =A0- # of pages scanned by foreground recla=
im based on soft limit
>>
>> And
>>
>> kern_direct_steal =A0- # of pages stealed by foreground reclaim at memor=
y shortage.
>> kern_direct_scan =A0 - # of pages scanned by foreground reclaim at memor=
y shortage.
>> kern_direct_steal =A0- # of pages stealed by kswapd at memory shortage
>> kern_direct_scan =A0 - # of pages scanned by kswapd at memory shortage
>>
>> (Above kern_xxx number includes soft_xxx in it. ) These will show influe=
nce by
>> other cgroups.
>>
>> And
>>
>> wmark_bg_free =A0 =A0 =A0- # of pages freed by watermark in background(n=
ot kswapd)
>> wmark_bg_scan =A0 =A0 =A0- # of pages scanned by watermark in background=
(not kswapd)
>>
>> Hmm ? too many stats ;)
>
> Indeed, and you have not even taken hierarchical reclaim into account.
> What I propose is the separation of reclaim that happens within a
> memcg due to an internal memcg condition, and reclaim that happens
> within a memcg due to outside conditions - either the hierarchy or
> global memory pressure. =A0Something like the following, maybe?
>
> 1. Limit-triggered direct reclaim
>
> The memory cgroup hits its limit and the task does direct reclaim from
> its own memcg. =A0We probably want statistics for this separately from
> background reclaim to see how successful background reclaim is, the
> same reason we have this separation in the global vmstat as well.
>
> =A0 =A0 =A0 =A0pgscan_direct_limit
> =A0 =A0 =A0 =A0pgfree_direct_limit

Ack.
>
> 2. Limit-triggered background reclaim
>
> This is the watermark-based asynchroneous reclaim that is currently in
> discussion. =A0It's triggered by the memcg breaching its watermark,
> which is relative to its hard-limit. =A0I named it kswapd because I
> still think kswapd should do this job, but it is all open for
> discussion, obviously. =A0Treat it as meaning 'background' or
> 'asynchroneous'.
>
> =A0 =A0 =A0 =A0pgscan_kswapd_limit
> =A0 =A0 =A0 =A0pgfree_kswapd_limit
Ack.

To clarify, the 1 and 2 only count the reclaim which is due to the
pressure from the memcg itself.

> 3. Hierarchy-triggered direct reclaim
>
> A condition outside the memcg leads to a task directly reclaiming from
> this memcg. =A0This could be global memory pressure for example, but
> also a parent cgroup hitting its limit. =A0It's probably helpful to
> assume global memory pressure meaning that the root cgroup hit its
> limit, conceptually. =A0We don't have that yet, but this could be the
> direct softlimit reclaim Ying mentioned above.
>
> =A0 =A0 =A0 =A0pgscan_direct_hierarchy
> =A0 =A0 =A0 =A0pgsteal_direct_hierarchy

For this one, it could be global direct reclaim doing softlimit
pushback or hierarchical reclaim
due to the parent hit its hardlimit. It would be nice if we can
separate them up?

>
> 4. Hierarchy-triggered background reclaim
>
> An outside condition leads to kswapd reclaiming from this memcg, like
> kswapd doing softlimit pushback due to global memory pressure.
>
> =A0 =A0 =A0 =A0pgscan_kswapd_hierarchy
> =A0 =A0 =A0 =A0pgsteal_kswapd_hierarchy

Ack, and this should be only per-node kswap doing doftlimit pushback.

> ---
>
> With these stats in place, you can see how much pressure there is on
> your memcg hierarchy. =A0This includes machine utilization and if you
> overcommitted too much on a global level if there is a lot of reclaim
> activity indicated in the hierarchical stats.
>
> With the limit-based stats, you can see the amount of internal
> pressure of memcgs, which shows you if you overcommitted on a local
> level.
>
> And for both cases, you can also see the effectiveness of background
> reclaim by comparing the direct and the kswapd stats.
>
>> And making current soft_steal/soft_scan planned to be obsolete...
>
> It's in -mm, but not merged upstream.

Yes, and this is part of the effort of adding softlimit pushback in
global kswapd path.

--Ying
>
> Regardless of my proposol for any stats above, I want to ask everybody
> involved that we do not add any more ABI and exports of random
> internals of the memcg reclaim process at this point.
>
> We have a lot of plans and ideas still in flux for memcg reclaim, I
> think it's about the worst point in time to commit ourselves to
> certain behaviour, knobs, and statistics regarding this code.
>
> =A0 =A0 =A0 =A0Hannes
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
