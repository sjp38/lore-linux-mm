Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 8DB436B00FB
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 05:48:13 -0400 (EDT)
Received: by iwn33 with SMTP id 33so6532575iwn.14
        for <linux-mm@kvack.org>; Mon, 13 Sep 2010 02:48:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100913085549.GA23508@csn.ul.ie>
References: <1283770053-18833-1-git-send-email-mel@csn.ul.ie>
	<1283770053-18833-4-git-send-email-mel@csn.ul.ie>
	<20100907152533.GB4620@barrios-desktop>
	<20100908110403.GB29263@csn.ul.ie>
	<20100908145245.GG4620@barrios-desktop>
	<20100909085436.GJ29263@csn.ul.ie>
	<20100912153744.GA3563@barrios-desktop>
	<20100913085549.GA23508@csn.ul.ie>
Date: Mon, 13 Sep 2010 18:48:10 +0900
Message-ID: <AANLkTimkSU5G1qO0JDp8An5ofM2BPoPY0SGUOuTvSuOL@mail.gmail.com>
Subject: Re: [PATCH 03/10] writeback: Do not congestion sleep if there are no
 congested BDIs or significant writeback
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Linux Kernel List <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 13, 2010 at 5:55 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> On Mon, Sep 13, 2010 at 12:37:44AM +0900, Minchan Kim wrote:
>> > > > > > <SNIP>
>> > > > > >
>> > > > > > + * in sleeping but cond_resched() is called in case the curre=
nt process has
>> > > > > > + * consumed its CPU quota.
>> > > > > > + */
>> > > > > > +long wait_iff_congested(struct zone *zone, int sync, long tim=
eout)
>> > > > > > +{
>> > > > > > + =A0 long ret;
>> > > > > > + =A0 unsigned long start =3D jiffies;
>> > > > > > + =A0 DEFINE_WAIT(wait);
>> > > > > > + =A0 wait_queue_head_t *wqh =3D &congestion_wqh[sync];
>> > > > > > +
>> > > > > > + =A0 /*
>> > > > > > + =A0 =A0* If there is no congestion, check the amount of writ=
eback. If there
>> > > > > > + =A0 =A0* is no significant writeback and no congestion, just=
 cond_resched
>> > > > > > + =A0 =A0*/
>> > > > > > + =A0 if (atomic_read(&nr_bdi_congested[sync]) =3D=3D 0) {
>> > > > > > + =A0 =A0 =A0 =A0 =A0 unsigned long inactive, writeback;
>> > > > > > +
>> > > > > > + =A0 =A0 =A0 =A0 =A0 inactive =3D zone_page_state(zone, NR_IN=
ACTIVE_FILE) +
>> > > > > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone_pag=
e_state(zone, NR_INACTIVE_ANON);
>> > > > > > + =A0 =A0 =A0 =A0 =A0 writeback =3D zone_page_state(zone, NR_W=
RITEBACK);
>> > > > > > +
>> > > > > > + =A0 =A0 =A0 =A0 =A0 /*
>> > > > > > + =A0 =A0 =A0 =A0 =A0 =A0* If less than half the inactive list=
 is being written back,
>> > > > > > + =A0 =A0 =A0 =A0 =A0 =A0* reclaim might as well continue
>> > > > > > + =A0 =A0 =A0 =A0 =A0 =A0*/
>> > > > > > + =A0 =A0 =A0 =A0 =A0 if (writeback < inactive / 2) {
>> > > > >
>> > > > > I am not sure this is best.
>> > > > >
>> > > >
>> > > > I'm not saying it is. The objective is to identify a situation whe=
re
>> > > > sleeping until the next write or congestion clears is pointless. W=
e have
>> > > > already identified that we are not congested so the question is "a=
re we
>> > > > writing a lot at the moment?". The assumption is that if there is =
a lot
>> > > > of writing going on, we might as well sleep until one completes ra=
ther
>> > > > than reclaiming more.
>> > > >
>> > > > This is the first effort at identifying pointless sleeps. Better o=
nes
>> > > > might be identified in the future but that shouldn't stop us makin=
g a
>> > > > semi-sensible decision now.
>> > >
>> > > nr_bdi_congested is no problem since we have used it for a long time=
