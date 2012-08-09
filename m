Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 9513F6B0044
	for <linux-mm@kvack.org>; Thu,  9 Aug 2012 14:16:46 -0400 (EDT)
Message-ID: <5023FE83.4090200@sandia.gov>
Date: Thu, 9 Aug 2012 12:16:35 -0600
From: "Jim Schutt" <jaschut@sandia.gov>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/5] Improve hugepage allocation success rates
 under load V3
References: <1344520165-24419-1-git-send-email-mgorman@suse.de>
In-Reply-To: <1344520165-24419-1-git-send-email-mgorman@suse.de>
Content-Type: text/plain;
 charset=utf-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, LKML <linux-kernel@vger.kernel.org>

On 08/09/2012 07:49 AM, Mel Gorman wrote:
> Changelog since V2
> o Capture !MIGRATE_MOVABLE pages where possible
> o Document the treatment of MIGRATE_MOVABLE pages while capturing
> o Expand changelogs
>
> Changelog since V1
> o Dropped kswapd related patch, basically a no-op and regresses if fixed (minchan)
> o Expanded changelogs a little
>
> Allocation success rates have been far lower since 3.4 due to commit
> [fe2c2a10: vmscan: reclaim at order 0 when compaction is enabled]. This
> commit was introduced for good reasons and it was known in advance that
> the success rates would suffer but it was justified on the grounds that
> the high allocation success rates were achieved by aggressive reclaim.
> Success rates are expected to suffer even more in 3.6 due to commit
> [7db8889a: mm: have order>  0 compaction start off where it left] which
> testing has shown to severely reduce allocation success rates under load -
> to 0% in one case.  There is a proposed change to that patch in this series
> and it would be ideal if Jim Schutt could retest the workload that led to
> commit [7db8889a: mm: have order>  0 compaction start off where it left].

On my first test of this patch series on top of 3.5, I ran into an
instance of what I think is the sort of thing that patch 4/5 was
fixing.  Here's what vmstat had to say during that period:

----------

2012-08-09 11:58:04.107-06:00
vmstat -w 4 16
procs -------------------memory------------------ ---swap-- -----io---- --system-- -----cpu-------
  r  b       swpd       free       buff      cache   si   so    bi    bo   in   cs  us sy  id wa st
20 14          0     235884        576   38916072    0    0    12 17047  171  133   3  8  85  4  0
18 17          0     220272        576   38955912    0    0    86 2131838 200142 162956  12 38  31 19  0
17  9          0     244284        576   38955328    0    0    19 2179562 213775 167901  13 43  26 18  0
27 15          0     223036        576   38952640    0    0    24 2202816 217996 158390  14 47  25 15  0
17 16          0     233124        576   38959908    0    0     5 2268815 224647 165728  14 50  21 15  0
16 13          0     225840        576   38995740    0    0    52 2253829 216797 160551  14 47  23 16  0
22 13          0     260584        576   38982908    0    0    92 2196737 211694 140924  14 53  19 15  0
16 10          0     235784        576   38917128    0    0    22 2157466 210022 137630  14 54  19 14  0
12 13          0     214300        576   38923848    0    0    31 2187735 213862 142711  14 52  20 14  0
25 12          0     219528        576   38919540    0    0    11 2066523 205256 142080  13 49  23 15  0
26 14          0     229460        576   38913704    0    0    49 2108654 200692 135447  13 51  21 15  0
11 11          0     220376        576   38862456    0    0    45 2136419 207493 146813  13 49  22 16  0
36 12          0     229860        576   38869784    0    0     7 2163463 212223 151812  14 47  25 14  0
16 13          0     238356        576   38891496    0    0    67 2251650 221728 154429  14 52  20 14  0
65 15          0     211536        576   38922108    0    0    59 2237925 224237 156587  14 53  19 14  0
24 13          0     585024        576   38634024    0    0    37 2240929 229040 148192  15 61  14 10  0

2012-08-09 11:59:04.714-06:00
vmstat -w 4 16
procs -------------------memory------------------ ---swap-- -----io---- --system-- -----cpu-------
  r  b       swpd       free       buff      cache   si   so    bi    bo   in   cs  us sy  id wa st
43  8          0     794392        576   38382316    0    0    11 20491  576  420   3 10  82  4  0
127  6          0     579328        576   38422156    0    0    21 2006775 205582 119660  12 70  11  7  0
44  5          0     492860        576   38512360    0    0    46 1536525 173377 85320  10 78   7  4  0
218  9          0     585668        576   38271320    0    0    39 1257266 152869 64023   8 83   7  3  0
101  6          0     600168        576   38128104    0    0    10 1438705 160769 68374   9 84   5  3  0
62  5          0     597004        576   38098972    0    0    93 1376841 154012 63912   8 82   7  4  0
61 11          0     850396        576   37808772    0    0    46 1186816 145731 70453   7 78   9  6  0
124  7          0     437388        576   38126320    0    0    15 1208434 149736 57142   7 86   4  3  0
204 11          0    1105816        576   37309532    0    0    20 1327833 145979 52718   7 87   4  2  0
29  8          0     751020        576   37360332    0    0     8 1405474 169916 61982   9 85   4  2  0
38  7          0     626448        576   37333244    0    0    14 1328415 174665 74214   8 84   5  3  0
23  5          0     650040        576   37134280    0    0    28 1351209 179220 71631   8 85   5  2  0
40 10          0     610988        576   37054292    0    0   104 1272527 167530 73527   7 85   5  3  0
79 22          0    2076836        576   35487340    0    0   750 1249934 175420 70124   7 88   3  2  0
58  6          0     431068        576   36934140    0    0  1000 1366234 169675 72524   8 84   5  3  0
134  9          0     574692        576   36784980    0    0  1049 1305543 152507 62639   8 84   4  4  0

2012-08-09 12:00:09.137-06:00
vmstat -w 4 16
procs -------------------memory------------------ ---swap-- -----io---- --system-- -----cpu-------
  r  b       swpd       free       buff      cache   si   so    bi    bo   in   cs  us sy  id wa st
163  8          0     464308        576   36791368    0    0    11 22210  866  536   3 13  79  4  0
207 14          0     917752        576   36181928    0    0   712 1345376 134598 47367   7 90   1  2  0
123 12          0     685516        576   36296148    0    0   429 1386615 158494 60077   8 84   5  3  0
123 12          0     598572        576   36333728    0    0  1107 1233281 147542 62351   7 84   5  4  0
622  7          0     660768        576   36118264    0    0   557 1345548 151394 59353   7 85   4  3  0
223 11          0     283960        576   36463868    0    0    46 1107160 121846 33006   6 93   1  1  0
104 14          0    3140508        576   33522616    0    0   299 1414709 160879 51422   9 89   1  1  0
100 11          0    1323036        576   35337740    0    0   429 1637733 175817 94471   9 73  10  8  0
91 11          0     673320        576   35918084    0    0   562 1477100 157069 67951   8 83   5  4  0
35 15          0    3486592        576   32983244    0    0   384 1574186 189023 82135   9 81   5  5  0
51 16          0    1428108        576   34962112    0    0   394 1573231 160575 76632   9 76   9  7  0
55  6          0     719548        576   35621284    0    0   425 1483962 160335 79991   8 74  10  7  0
96  7          0    1226852        576   35062608    0    0   803 1531041 164923 70820   9 78   7  6  0
97  8          0     862500        576   35332496    0    0   536 1177949 155969 80769   7 74  13  7  0
23  5          0    6096372        576   30115776    0    0   367 919949 124993 81755   6 62  24  8  0
13  5          0    7427860        576   28368292    0    0   399 915331 153895 102186   6 53  32  9  0

----------

And here's a perf report, captured/displayed with
   perf record -g -a sleep 10
   perf report --sort symbol --call-graph fractal,5
sometime during that period just after 12:00:09, when
the run queueu was > 100.

----------

Processed 0 events and LOST 1175296!

Check IO/CPU overload!

# Events: 208K cycles
#
# Overhead

                                                                                                       Symbol
# ........  .....................................................................................................................................................................................
.................................................................................................................................................................................................
............................................................................................................
#
     34.63%  [k] _raw_spin_lock_irqsave
             |
             |--97.30%-- isolate_freepages
             |          compaction_alloc
             |          unmap_and_move
             |          migrate_pages
             |          compact_zone
             |          compact_zone_order
             |          try_to_compact_pages
             |          __alloc_pages_direct_compact
             |          __alloc_pages_slowpath
             |          __alloc_pages_nodemask
             |          alloc_pages_vma
             |          do_huge_pmd_anonymous_page
             |          handle_mm_fault
             |          do_page_fault
             |          page_fault
             |          |
             |          |--87.39%-- skb_copy_datagram_iovec
             |          |          tcp_recvmsg
             |          |          inet_recvmsg
             |          |          sock_recvmsg
             |          |          sys_recvfrom
             |          |          system_call
             |          |          __recv
             |          |          |
             |          |           --100.00%-- (nil)
             |          |
             |           --12.61%-- memcpy
              --2.70%-- [...]

     14.31%  [k] _raw_spin_lock_irq
             |
             |--98.08%-- isolate_migratepages_range
             |          compact_zone
             |          compact_zone_order
             |          try_to_compact_pages
             |          __alloc_pages_direct_compact
             |          __alloc_pages_slowpath
             |          __alloc_pages_nodemask
             |          alloc_pages_vma
             |          do_huge_pmd_anonymous_page
             |          handle_mm_fault
             |          do_page_fault
             |          page_fault
             |          |
             |          |--83.93%-- skb_copy_datagram_iovec
             |          |          tcp_recvmsg
             |          |          inet_recvmsg
             |          |          sock_recvmsg
             |          |          sys_recvfrom
             |          |          system_call
             |          |          __recv
             |          |          |
             |          |           --100.00%-- (nil)
             |          |
             |           --16.07%-- memcpy
              --1.92%-- [...]

      5.48%  [k] isolate_freepages_block
             |
             |--99.96%-- isolate_freepages
             |          compaction_alloc
             |          unmap_and_move
             |          migrate_pages
             |          compact_zone
             |          compact_zone_order
             |          try_to_compact_pages
             |          __alloc_pages_direct_compact
             |          __alloc_pages_slowpath
             |          __alloc_pages_nodemask
             |          alloc_pages_vma
             |          do_huge_pmd_anonymous_page
             |          handle_mm_fault
             |          do_page_fault
             |          page_fault
             |          |
             |          |--86.01%-- skb_copy_datagram_iovec
             |          |          tcp_recvmsg
             |          |          inet_recvmsg
             |          |          sock_recvmsg
             |          |          sys_recvfrom
             |          |          system_call
             |          |          __recv
             |          |          |
             |          |           --100.00%-- (nil)
             |          |
             |           --13.99%-- memcpy
              --0.04%-- [...]

      5.34%  [.] ceph_crc32c_le
             |
             |--99.95%-- 0xb8057558d0065990
              --0.05%-- [...]

----------

If I understand what this is telling me, skb_copy_datagram_iovec
is responsible for triggering the calls to isolate_freepages_block,
isolate_migratepages_range, and isolate_freepages?

FWIW, I'm using a Chelsio T4 NIC in these hosts, with jumbo frames
and the Linux TCP stack (i.e., no stateful TCP offload).

-- Jim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
