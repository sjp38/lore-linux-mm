Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 1FD706B0047
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 19:10:23 -0400 (EDT)
Received: by iwn33 with SMTP id 33so7224175iwn.14
        for <linux-mm@kvack.org>; Mon, 13 Sep 2010 16:10:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1283770053-18833-1-git-send-email-mel@csn.ul.ie>
References: <1283770053-18833-1-git-send-email-mel@csn.ul.ie>
Date: Tue, 14 Sep 2010 08:10:21 +0900
Message-ID: <AANLkTinq6v3-NKjszYVOR3qxr-UVNoGw0uQjBGcoifVs@mail.gmail.com>
Subject: Re: [PATCH 0/9] Reduce latencies and improve overall reclaim
 efficiency v1
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Linux Kernel List <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 6, 2010 at 7:47 PM, Mel Gorman <mel@csn.ul.ie> wrote:

<snip>

>
> These are just the raw figures taken from /proc/vmstat. It's a rough meas=
ure
> of reclaim activity. Note that allocstall counts are higher because we
> are entering direct reclaim more often as a result of not sleeping in
> congestion. In itself, it's not necessarily a bad thing. It's easier to
> get a view of what happened from the vmscan tracepoint report.
>
> FTrace Reclaim Statistics: vmscan
> =A0 =A0 =A0 =A0 =A0 =A0micro-traceonly-v1r5-micromicro-nocongest-v1r5-mic=
romicro-lowlumpy-v1r5-micromicro-nodirect-v1r5-micro
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0traceonly-v1r5 =A0 =A0nocongest-v1r5 =A0 =
=A0 lowlumpy-v1r5 =A0 =A0 nodirect-v1r5
> Direct reclaims =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0152 =A0 =A0 =A0 =A0941 =A0 =A0 =A0 =A0967 =A0 =A0 =A0 =A0729
> Direct reclaim pages scanned =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0507377 =A0 =
=A01404350 =A0 =A01332420 =A0 =A01450213
> Direct reclaim pages reclaimed =A0 =A0 =A0 =A0 =A0 =A0 =A0 10968 =A0 =A0 =
=A072042 =A0 =A0 =A077186 =A0 =A0 =A041097
> Direct reclaim write file async I/O =A0 =A0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =
=A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
> Direct reclaim write anon async I/O =A0 =A0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =
=A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
> Direct reclaim write file sync I/O =A0 =A0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =
=A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
> Direct reclaim write anon sync I/O =A0 =A0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =
=A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
> Wake kswapd requests =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A012719=
5 =A0 =A0 241025 =A0 =A0 254825 =A0 =A0 188846
> Kswapd wakeups =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 6 =A0 =A0 =A0 =A0 =A01 =A0 =A0 =A0 =A0 =A01 =A0 =A0 =A0 =A0 =A0=
1
> Kswapd pages scanned =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 4210101 =
=A0 =A03345122 =A0 =A03427915 =A0 =A03306356
> Kswapd pages reclaimed =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 2228073 =
=A0 =A02165721 =A0 =A02143876 =A0 =A02194611
> Kswapd reclaim write file async I/O =A0 =A0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =
=A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
> Kswapd reclaim write anon async I/O =A0 =A0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =
=A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
> Kswapd reclaim write file sync I/O =A0 =A0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =
=A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
> Kswapd reclaim write anon sync I/O =A0 =A0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =
=A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
> Time stalled direct reclaim (seconds) =A0 =A0 =A0 =A0 7.60 =A0 =A0 =A0 3.=
03 =A0 =A0 =A0 3.24 =A0 =A0 =A0 3.43
> Time kswapd awake (seconds) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A012.46 =A0 =
=A0 =A0 9.46 =A0 =A0 =A0 9.56 =A0 =A0 =A0 9.40
>
> Total pages scanned =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0471747=
8 =A0 4749472 =A0 4760335 =A0 4756569
> Total pages reclaimed =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A02239041 =
=A0 2237763 =A0 2221062 =A0 2235708
> %age total pages scanned/reclaimed =A0 =A0 =A0 =A0 =A047.46% =A0 =A047.12=
% =A0 =A046.66% =A0 =A047.00%
> %age total pages scanned/written =A0 =A0 =A0 =A0 =A0 =A0 0.00% =A0 =A0 0.=
00% =A0 =A0 0.00% =A0 =A0 0.00%
> %age =A0file pages scanned/written =A0 =A0 =A0 =A0 =A0 =A0 0.00% =A0 =A0 =
0.00% =A0 =A0 0.00% =A0 =A0 0.00%
> Percentage Time Spent Direct Reclaim =A0 =A0 =A0 =A043.80% =A0 =A021.38% =
=A0 =A022.34% =A0 =A023.46%
> Percentage Time kswapd Awake =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A079.92% =A0 =
=A079.56% =A0 =A079.20% =A0 =A080.48%


There is a nitpick about stalled reclaim time.
For example, In direct reclaim

=3D=3D=3D
       trace_mm_vmscan_direct_reclaim_begin(order,
                               sc.may_writepage,
                               gfp_mask);

       nr_reclaimed =3D do_try_to_free_pages(zonelist, &sc);

       trace_mm_vmscan_direct_reclaim_end(nr_reclaimed);
=3D=3D=3D

In this case, Isn't this time accumulated value?
My point is following as.

Process A                                                       Process B
direct reclaim begin
do_try_to_free_pages
cond_resched

                direct reclaim begin

                do_try_to_free_pages

                direct reclaim end
direct reclaim end


So A's result includes B's time so total stall time would be bigger than re=
al.


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
