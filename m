Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 188086B0089
	for <linux-mm@kvack.org>; Mon,  6 Dec 2010 21:30:08 -0500 (EST)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id oB72U6VH018977
	for <linux-mm@kvack.org>; Mon, 6 Dec 2010 18:30:06 -0800
Received: from qwd6 (qwd6.prod.google.com [10.241.193.198])
	by kpbe14.cbf.corp.google.com with ESMTP id oB72Tdce001774
	for <linux-mm@kvack.org>; Mon, 6 Dec 2010 18:29:42 -0800
Received: by qwd6 with SMTP id 6so1955070qwd.9
        for <linux-mm@kvack.org>; Mon, 06 Dec 2010 18:29:40 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101202144132.GR2746@balbir.in.ibm.com>
References: <1291099785-5433-1-git-send-email-yinghan@google.com>
	<20101130155327.8313.A69D9226@jp.fujitsu.com>
	<AANLkTi=idNjuptkQuiaOF+GiUDjBaBC9kW370u-041sT@mail.gmail.com>
	<20101202144132.GR2746@balbir.in.ibm.com>
Date: Mon, 6 Dec 2010 18:29:39 -0800
Message-ID: <AANLkTikGTDZMsDBX-YJ+oUzZFA1bLS2eM8UR7ahHdkiQ@mail.gmail.com>
Subject: Re: [RFC][PATCH 0/4] memcg: per cgroup background reclaim
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Dec 2, 2010 at 6:41 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wr=
ote:
> * Ying Han <yinghan@google.com> [2010-11-29 23:03:31]:
>
>> On Mon, Nov 29, 2010 at 10:54 PM, KOSAKI Motohiro
>> <kosaki.motohiro@jp.fujitsu.com> wrote:
>> >> The current implementation of memcg only supports direct reclaim and =
this
>> >> patchset adds the support for background reclaim. Per cgroup backgrou=
nd
>> >> reclaim is needed which spreads out the memory pressure over longer p=
eriod
>> >> of time and smoothes out the system performance.
>> >>
>> >> The current implementation is not a stable version, and it crashes so=
metimes
>> >> on my NUMA machine. Before going further for debugging, I would like =
to start
>> >> the discussion and hear the feedbacks of the initial design.
>> >
>> > I haven't read your code at all. However I agree your claim that memcg
>> > also need background reclaim.
>>
>> Thanks for your comment.
>> >
>> > So if you post high level design memo, I'm happy.
>>
>> My high level design is kind of spreading out into each patch, and
>> here is the consolidated one. This is nothing more but cluing all the
>> commits' messages for the following patches.
>>
>> "
>> The current implementation of memcg only supports direct reclaim and thi=
s
>> patchset adds the support for background reclaim. Per cgroup background
>> reclaim is needed which spreads out the memory pressure over longer peri=
od
>> of time and smoothes out the system performance.
>>
>> There is a kswapd kernel thread for each memory node. We add a different=
 kswapd
>> for each cgroup. The kswapd is sleeping in the wait queue headed at kswa=
pd_wait
>> field of a kswapd descriptor. The kswapd descriptor stores information o=
f node
>> or cgroup and it allows the global and per cgroup background reclaim to =
share
>> common reclaim algorithms. The per cgroup kswapd is invoked at mem_cgrou=
p_charge
>> when the cgroup's memory usage above a threshold--low_wmark. Then the ks=
wapd
>> thread starts to reclaim pages in a priority loop similar to global algo=
rithm.
>> The kswapd is done if the usage below a threshold--high_wmark.
>>
>
> So the logic is per-node/per-zone/per-cgroup right?

Thanks Balbir for your comments:


The kswapd thread is per-cgroup, and the scanning is on per-node and
per-zone. The watermarks is calculated based on the per-cgroup
limit_in_bytes, and kswapd is done whenever the usage_in_bytes is
under the watermarks.
>
>> The per cgroup background reclaim is based on the per cgroup LRU and als=
o adds
>> per cgroup watermarks. There are two watermarks including "low_wmark" an=
d
>> "high_wmark", and they are calculated based on the limit_in_bytes(hard_l=
imit)
>> for each cgroup. Each time the hard_limit is change, the corresponding w=
marks
>> are re-calculated. Since memory controller charges only user pages, ther=
e is
>
> What about memsw limits, do they impact anything, I presume not.
>
>> no need for a "min_wmark". The current calculation of wmarks is a functi=
on of
>> "memory.min_free_kbytes" which could be adjusted by writing different va=
lues
>> into the new api. This is added mainly for debugging purpose.
>
> When you say debugging, can you elaborate?

I am not sure if we would like to keep the memory.min_free_kbytes for
the final version, which is used
to adjust the calculation of per-cgroup wmarks. For now, I am adding
it for performance testing purpose.

>
>>
>> The kswapd() function now is shared between global and per cgroup kswapd=
 thread.
>> It is passed in with the kswapd descriptor which contains the informatio=
n of
>> either node or cgroup. Then the new function balance_mem_cgroup_pgdat is=
 invoked
>> if it is per cgroup kswapd thread. The balance_mem_cgroup_pgdat performs=
 a
>> priority loop similar to global reclaim. In each iteration it invokes
>> balance_pgdat_node for all nodes on the system, which is a new function =
performs
>> background reclaim per node. After reclaiming each node, it checks
>> mem_cgroup_watermark_ok() and breaks the priority loop if returns true. =
A per
>> memcg zone will be marked as "unreclaimable" if the scanning rate is muc=
h
>> greater than the reclaiming rate on the per cgroup LRU. The bit is clear=
ed when
>> there is a page charged to the cgroup being freed. Kswapd breaks the pri=
ority
>> loop if all the zones are marked as "unreclaimable".
>> "
>>
>> Also, I am happy to add more descriptions if anything not clear :)

Sure. :)

--Ying
>>
>
> Thanks for explaining this in detail, it makes the review easier.
>
> --
> =A0 =A0 =A0 =A0Three Cheers,
> =A0 =A0 =A0 =A0Balbir
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
