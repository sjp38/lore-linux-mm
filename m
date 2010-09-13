Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B5AD06B0105
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 06:20:46 -0400 (EDT)
Received: by iwn33 with SMTP id 33so6568635iwn.14
        for <linux-mm@kvack.org>; Mon, 13 Sep 2010 03:20:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100913100759.GE23508@csn.ul.ie>
References: <1283770053-18833-1-git-send-email-mel@csn.ul.ie>
	<1283770053-18833-4-git-send-email-mel@csn.ul.ie>
	<20100907152533.GB4620@barrios-desktop>
	<20100908110403.GB29263@csn.ul.ie>
	<20100908145245.GG4620@barrios-desktop>
	<20100909085436.GJ29263@csn.ul.ie>
	<20100912153744.GA3563@barrios-desktop>
	<20100913085549.GA23508@csn.ul.ie>
	<AANLkTimkSU5G1qO0JDp8An5ofM2BPoPY0SGUOuTvSuOL@mail.gmail.com>
	<20100913100759.GE23508@csn.ul.ie>
Date: Mon, 13 Sep 2010 19:20:37 +0900
Message-ID: <AANLkTikz0uv_7tDYQ--WAT5g0SHaMhUeSmo0U7WkHonb@mail.gmail.com>
Subject: Re: [PATCH 03/10] writeback: Do not congestion sleep if there are no
 congested BDIs or significant writeback
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Linux Kernel List <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 13, 2010 at 7:07 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> On Mon, Sep 13, 2010 at 06:48:10PM +0900, Minchan Kim wrote:
>> >> > > > <SNIP>
>> >> > > > I'm not saying it is. The objective is to identify a situation =
where
>> >> > > > sleeping until the next write or congestion clears is pointless=
. We have
>> >> > > > already identified that we are not congested so the question is=
 "are we
>> >> > > > writing a lot at the moment?". The assumption is that if there =
is a lot
>> >> > > > of writing going on, we might as well sleep until one completes=
 rather
>> >> > > > than reclaiming more.
>> >> > > >
>> >> > > > This is the first effort at identifying pointless sleeps. Bette=
r ones
>> >> > > > might be identified in the future but that shouldn't stop us ma=
king a
>> >> > > > semi-sensible decision now.
>> >> > >
>> >> > > nr_bdi_congested is no problem since we have used it for a long t=
ime.
>> >> > > But you added new rule about writeback.
>> >> > >
>> >> >
>> >> > Yes, I'm trying to add a new rule about throttling in the page allo=
cator
>> >> > and from vmscan. As you can see from the results in the leader, we =
are
>> >> > currently sleeping more than we need to.
>> >>
>> >> I can see the about avoiding congestion_wait but can't find about
>> >> (writeback < incative / 2) hueristic result.
>> >>
>> >
>> > See the leader and each of the report sections entitled
>> > "FTrace Reclaim Statistics: congestion_wait". It provides a measure of
>> > how sleep times are affected.
>> >
>> > "congest waited" are waits due to calling congestion_wait. "conditiona=
l waited"
>> > are those related to wait_iff_congested(). As you will see from the re=
ports,
>> > sleep times are reduced overall while callers of wait_iff_congested() =
still
>> > go to sleep. The reports entitled "FTrace Reclaim Statistics: vmscan" =
show
>> > how reclaim is behaving and indicators so far are that reclaim is not =
hurt
>> > by introducing wait_iff_congested().
>>
>> I saw =A0the result.
>> It was a result about effectiveness _both_ nr_bdi_congested and
>> (writeback < inactive/2).
>> What I mean is just effectiveness (writeback < inactive/2) _alone_.
>
> I didn't measured it because such a change means that wait_iff_congested(=
)
> ignored BDI congestion. If we were reclaiming on a NUMA machine for examp=
le,
> it could mean that a BDI gets flooded with requests if we only checked th=
e
> ratios of one zone if little writeback was happening in that zone at the
> time. It did not seem like a good idea to ignore congestion.

You seem to misunderstand my word.
Sorry for not clear sentence.

I don't mean ignore congestion.
First of all, we should consider congestion of bdi.
My meant is whether we need adding up (nr_writeback < nr_inacive /2)
heuristic plus congestion bdi.
It wasn't previous version in your patch but it showed up in this version.
So I thought apparently you have any evidence why we should add such heuris=
tic.

>
>> If we remove (writeback < inactive / 2) check and unconditionally
>> return, how does the behavior changed?
>>
>
> Based on just the workload Johannes sent, scanning and completion times b=
oth
> increased without any improvement in the scanning/reclaim ratio (a bad re=
sult)
> hence why this logic was introduced to back off where there is some
> writeback taking place even if the BDI is not congested.

Yes. That's what I want. At least, comment of function should have it
to understand the logic.  In addition, It would be better to add the
number to show how it back off well.


>
> --
> Mel Gorman
> Part-time Phd Student =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
Linux Technology Center
> University of Limerick =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 IB=
M Dublin Software Lab
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
