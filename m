Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id AF0B76B024D
	for <linux-mm@kvack.org>; Sun, 25 Jul 2010 04:25:28 -0400 (EDT)
Received: by iwn2 with SMTP id 2so2156497iwn.14
        for <linux-mm@kvack.org>; Sun, 25 Jul 2010 01:25:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100723154638.88C8.A69D9226@jp.fujitsu.com>
References: <20100716191256.736C.A69D9226@jp.fujitsu.com>
	<20100722053113.GL14369@balbir.in.ibm.com>
	<20100723154638.88C8.A69D9226@jp.fujitsu.com>
Date: Sun, 25 Jul 2010 13:55:32 +0530
Message-ID: <AANLkTikpZ8iH1oO1k84kvo2qYYS96LYuNmmw6xJL-1QV@mail.gmail.com>
Subject: Re: [PATCH 1/7] memcg: sc.nr_to_reclaim should be initialized
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nishimura Daisuke <d-nishimura@mtf.biglobe.ne.jp>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 23, 2010 at 1:03 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> * KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2010-07-16 19:13:31]=
:
>>
>> > Currently, mem_cgroup_shrink_node_zone() initialize sc.nr_to_reclaim a=
s 0.
>> > It mean shrink_zone() only scan 32 pages and immediately return even i=
f
>> > it doesn't reclaim any pages.
>> >
>> > This patch fixes it.
>> >
>> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> > ---
>> > =A0mm/vmscan.c | =A0 =A01 +
>> > =A01 files changed, 1 insertions(+), 0 deletions(-)
>> >
>> > diff --git a/mm/vmscan.c b/mm/vmscan.c
>> > index 1691ad0..bd1d035 100644
>> > --- a/mm/vmscan.c
>> > +++ b/mm/vmscan.c
>> > @@ -1932,6 +1932,7 @@ unsigned long mem_cgroup_shrink_node_zone(struct=
 mem_cgroup *mem,
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 struct zone *zone, int nid)
>> > =A0{
>> > =A0 =A0 struct scan_control sc =3D {
>> > + =A0 =A0 =A0 =A0 =A0 .nr_to_reclaim =3D SWAP_CLUSTER_MAX,
>> > =A0 =A0 =A0 =A0 =A0 =A0 .may_writepage =3D !laptop_mode,
>> > =A0 =A0 =A0 =A0 =A0 =A0 .may_unmap =3D 1,
>> > =A0 =A0 =A0 =A0 =A0 =A0 .may_swap =3D !noswap,
>>
>> Could you please do some additional testing on
>>
>> 1. How far does this push pages (in terms of when limit is hit)?
>
> 32 pages per mem_cgroup_shrink_node_zone().
>
> That said, the algorithm is here.
>
> 1. call mem_cgroup_largest_soft_limit_node()
> =A0 calculate largest cgroup
> 2. call mem_cgroup_shrink_node_zone() and shrink 32 pages
> 3. goto 1 if limit is still exceed.
>
> If it's not your intention, can you please your intended algorithm?

We set it to 0, since we care only about a single page reclaim on
hitting the limit. IIRC, in the past we saw an excessive pushback on
reclaiming SWAP_CLUSTER_MAX pages, just wanted to check if you are
seeing the same behaviour even now after your changes.

Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
