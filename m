Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B74846B0025
	for <linux-mm@kvack.org>; Wed, 11 May 2011 23:50:28 -0400 (EDT)
From: Satoru Moriya <satoru.moriya@hds.com>
Date: Wed, 11 May 2011 23:46:37 -0400
Subject: RE: [RFC PATCH -mm] add extra free kbytes tunable
Message-ID: <65795E11DBF1E645A09CEC7EAEE94B9C3FBC06E5@USINDEVS02.corp.hds.com>
References: <20110502212427.42b5a90f@annuminas.surriel.com>
In-Reply-To: <20110502212427.42b5a90f@annuminas.surriel.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Ying Han <yinghan@google.com>, Mel Gorman <mel@suse.de>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>

Hi Rik,

Sorry for slow response.

On 05/02/2011 09:24 PM, Rik van Riel wrote:
>
> This can be used to make the VM free up memory, for when an extra
> workload is to be added to a system, or to temporarily reduce the
> memory use of a virtual machine. In this application, extra_free_kbytes
> would be raised temporarily and reduced again later.  The workload
> management system could also monitor the current workloads with
> reduced memory, to verify that there really is memory space for
> an additional workload, before starting it.
>=20
> It may also be useful for realtime applications that call system
> calls and have a bound on the number of allocations that happen
> in any short time period.  In this application, extra_free_kbytes
> would be left at an amount equal to or larger than than the
> maximum number of allocations that happen in any burst.

I tested it with my simple test case and it worked well.

- System memory: 2GB

- Background load:
  $ dd if=3D/dev/zero of=3D/tmp/tmp_file1 &
  $ dd if=3D/dev/zero of=3D/tmp/tmp_file2 &

- Main load:
  $ mapped-file-stream 1 $((1024 * 1024 * 256))=20

The result is following:

                   | default |  case 1  |  case 2  |  case 3  |=20
----------------------------------------------------------------------
min_free_kbytes    |  5752   |   5752   |   5752   |   5752   |
extra_free_kbytes  |     0   |  64*1024 | 128*1024 | 256*1024 | (KB)
----------------------------------------------------------------------
avereage latency(*)|     4   |      4   |      4   |      4   |
worst latency(*)   |   192   |     52   |     60   |     54   | (usec)
----------------------------------------------------------------------
page fault         | 65535   |  65535   |  65535   |  65535   |
direct reclaim     |    21   |      0   |      0   |      0   | (times)
----------------------------------------------------------------------
vmstat result (**) |         |          |          |          |
 allocstall        |     69  |       0  |       0  |       0  |
 pgscan_steal_*    | 130573  |  128826  |  126258  |  133778  |
 kswapd_steal_*    | 127505  |  128826  |  126258  |  133778  | (times)
 (direct reclaim   |   3068  |       0  |       0  |       0  |
  steal)     =20

(*) Latency per one page allocation(pagefault)
(**)
 $ cat /proc/vmstat > vmstat_start
 $ mapped_file_stream....
 $ cat /proc/vmstat > vmstat_end

  -> "vmstat_end - vmstat_start" for each entry

As you can see, in the default case there were 21 direct reclaims in
the main load and its worst latency was 192 usecs. This may be bigger
if a process would sleep in the direct reclaim path(congestion_wait etc.).
In the other cases, there were no direct reclaim and its worst latencies
were less or equal 60 usecs.

We can avoid direct reclaim and keep a latency low with this knob.

>=20
> I realize nobody really likes this solution to their particular
> issue, but it is hard to deny the simplicity - especially
> considering that this one knob could solve three different issues
> and is fairly simple to understand.

Yeah, this is much simpler than I proposed several month ago.

Thanks,
Satoru

>=20
> Signed-off-by: Rik van Riel<riel@redhat.com>
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
