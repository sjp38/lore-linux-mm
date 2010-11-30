Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 49B646B004A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 15:40:26 -0500 (EST)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id oAUKeIwt007991
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 12:40:18 -0800
Received: from vws11 (vws11.prod.google.com [10.241.21.139])
	by wpaz33.hot.corp.google.com with ESMTP id oAUKeGgC032494
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 12:40:17 -0800
Received: by vws11 with SMTP id 11so2317672vws.15
        for <linux-mm@kvack.org>; Tue, 30 Nov 2010 12:40:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101130175443.f01f4d09.kamezawa.hiroyu@jp.fujitsu.com>
References: <1291099785-5433-1-git-send-email-yinghan@google.com>
	<1291099785-5433-2-git-send-email-yinghan@google.com>
	<20101130160838.4c66febf.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTikXzSx3Sjqb1NYZB-EJ76N-UbmiwTo=eOtSOnaP@mail.gmail.com>
	<20101130172710.38de418b.kamezawa.hiroyu@jp.fujitsu.com>
	<20101130175443.f01f4d09.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 30 Nov 2010 12:40:16 -0800
Message-ID: <AANLkTina1A0jFuSZhP8bkOMgHOvo1Fa-0VyoW2zjaoPM@mail.gmail.com>
Subject: Re: [PATCH 1/4] Add kswapd descriptor.
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Nov 30, 2010 at 12:54 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 30 Nov 2010 17:27:10 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
>> On Tue, 30 Nov 2010 17:15:37 +0900
>> Minchan Kim <minchan.kim@gmail.com> wrote:
>>
>> > Ideally, I hope we unify global and memcg of kswapd for easy
>> > maintainance if it's not a big problem.
>> > When we make patches about lru pages, we always have to consider what
>> > I should do for memcg.
>> > And when we review patches, we also should consider what the patch is
>> > missing for memcg.
>> > It makes maintainance cost big. Of course, if memcg maintainers is
>> > involved with all patches, it's no problem as it is.
>> >
>> I know it's not. But thread control of kswapd will not have much merging=
 point.
>> And balance_pgdat() is fully replaced in patch/3. The effort for merging=
 seems
>> not big.

I intended to separate out the logic of per-memcg kswapd logics and
not having it
interfere with existing code. This should help for merging.

>>
>
> kswapd's balance_pgdat() is for following
> =A0- reclaim pages within a node.
> =A0- balancing zones in a pgdat.
>
> memcg's background reclaim needs followings.
> =A0- reclaim pages within a memcg
> =A0- reclaim pages from arbitrary zones, if it's fair, it's good.
> =A0 =A0But it's not important from which zone the pages are reclaimed fro=
m.
> =A0 =A0(I'm not sure we can select "the oldest" pages from divided LRU.)

The current implementation is simple, which it iterates all the nodes
and reclaims pages from the per-memcg-per-zone LRU. As long as the
wmarks is ok, the kswapd is done. Meanwhile, in order to not wasting
cputime on "unreclaimable: nodes ( a node is unreclaimable if all the
zones are unreclaimable), I used the nodemask to record that from the
last scan, and the bit is reset as long as a page is returned back.
This is a similar logic used in the global kswapd.

A potential improvement is to remember the last node we reclaimed
from, and starting from the next node for the next kswapd wake_up.
This avoids the case all the memcg kswapds are reclaiming from the
small node ids on large numa machines.

>
> Then, merging will put 2 _very_ different functionalities into 1 function=
