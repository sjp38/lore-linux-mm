Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id F1A0B6B0010
	for <linux-mm@kvack.org>; Wed, 14 Sep 2011 23:35:30 -0400 (EDT)
From: Satoru Moriya <satoru.moriya@hds.com>
Date: Wed, 14 Sep 2011 23:33:34 -0400
Subject: Re: [PATCH -v2 -mm] add extra free kbytes tunable
Message-ID: <65795E11DBF1E645A09CEC7EAEE94B9CAFE00221@USINDEVS02.corp.hds.com>
References: <20110901105208.3849a8ff@annuminas.surriel.com>
	<20110901100650.6d884589.rdunlap@xenotime.net>
	<20110901152650.7a63cb8b@annuminas.surriel.com>
 <20110901145819.4031ef7c.akpm@linux-foundation.org>,<E1FA588BC672D846BDBB452FCA1E308C2389B4@USINDEVS02.corp.hds.com>
In-Reply-To: <E1FA588BC672D846BDBB452FCA1E308C2389B4@USINDEVS02.corp.hds.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
Cc: Randy Dunlap <rdunlap@xenotime.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Seiji Aguchi <saguchi@redhat.com>, "hughd@google.com" <hughd@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

On 09/02/2011 12:31 PM, Satoru Moriya wrote:
> On 09/01/2011 05:58 PM, Andrew Morton wrote:
>> On Thu, 1 Sep 2011 15:26:50 -0400
>> Rik van Riel <riel@redhat.com> wrote:
> Anyway, now I'm testing this patch and will report a test result later.

Sorry for late reply. Here is my test result.

I ran some sample workloads and measure memory allocation latency
(latency of __alloc_page_nodemask()).
The test is like following:

 - CPU: 1 socket, 4 core
 - Memory: 4GB

 - Background load:
   $ dd if=3D/dev/zero of=3D/tmp/tmp1
   $ dd if=3D/dev/zero of=3D/tmp/tmp2
   $ dd if=3D/dev/zero of=3D/tmp/tmp3

 - Main load:
   $ mapped-file-stream 1 $((1024 * 1024 * 640))  --(*)

 (*) This is made by Johannes Weiner
     https://lkml.org/lkml/2010/8/30/226

     It allocates/access 640MByte memory at a burst.

The result is follwoing:

                               |         |  extra   |
                               | default |  kbytes  |
--------------------------------------------------------------
min_free_kbytes                |    8113 |   8113   |
extra_free_kbytes              |       0 | 640*1024 | (KB)
--------------------------------------------------------------
worst latency                  | 517.762 |  20.775  | (usec)
--------------------------------------------------------------
vmstat result                  |         |          |
 nr_vmscan_write               |       0 |      0   |
 pgsteal_dma                   |       0 |      0   |
 pgsteal_dma32                 |  143667 | 144882   |
 pgsteal_normal                |   31486 |  27001   |
 pgsteal_movable               |       0 |      0   |
 pgscan_kswapd_dma             |       0 |      0   |
 pgscan_kswapd_dma32           |  138617 | 156351   |
 pgscan_kswapd_normal          |   30593 |  27955   |
 pgscan_kswapd_movable         |       0 |      0   |
 pgscan_direct_dma             |       0 |      0   |
 pgscan_direct_dma32           |    5050 |      0   |
 pgscan_direct_normal          |     896 |      0   |
 pgscan_direct_movable         |       0 |      0   |
 kswapd_steal                  |  169207 | 171883   |
 kswapd_inodesteal             |       0 |      0   |
 kswapd_low_wmark_hit_quickly  |      43 |     45   |
 kswapd_high_wmark_hit_quickly |       1 |      0   |
 allocstall                    |      32 |      0   |


As you can see, in the default case there were 32 direct reclaim (allocstal=
l)
and its worst latency was 517.762 usecs. This value may be larger if
a process would sleep or issue I/O in the direct reclaim path. OTOH,
ii the other case where I add extra free bytes, there were no direct
reclaim and its worst latency was 20.775 usecs.

In this test case, we can avoid direct reclaim and keep a latency low.

Tested-by: Satoru Moriya <satoru.moriya@hds.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
