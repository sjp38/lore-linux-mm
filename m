Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 374846B0088
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 18:35:27 -0400 (EDT)
Received: by yenr5 with SMTP id r5so1708982yen.14
        for <linux-mm@kvack.org>; Wed, 27 Jun 2012 15:35:26 -0700 (PDT)
Message-ID: <4FEB8A9A.7030604@inktank.com>
Date: Wed, 27 Jun 2012 17:35:06 -0500
From: Mark Nelson <mark.nelson@inktank.com>
MIME-Version: 1.0
Subject: Re: excessive CPU utilization by isolate_freepages?
References: <4FEB8237.6030402@sandia.gov>
In-Reply-To: <4FEB8237.6030402@sandia.gov>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jim Schutt <jaschut@sandia.gov>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "ceph-devel@vger.kernel.org" <ceph-devel@vger.kernel.org>

On 06/27/2012 04:59 PM, Jim Schutt wrote:
> Hi,
>
> I'm running into trouble with systems going unresponsive,
> and perf suggests it's excessive CPU usage by isolate_freepages().
> I'm currently testing 3.5-rc4, but I think this problem may have
> first shown up in 3.4. I'm only just learning how to use perf,
> so I only currently have results to report for 3.5-rc4.
>
> (FWIW I'm running the my distro version of perf; please let me know
> if I need to compile the tools/perf version to match my kernel.)
>
> The systems in question have 24 SAS drives spread across 3 HBAs,
> running 24 Ceph OSD instances, one per drive. FWIW these servers
> are dual-socket Intel 5675 Xeons w/48 GB memory. I've got ~160
> Ceph Linux clients doing dd simultaneously to a Ceph file system
> backed by 12 of these servers.
>
> In the early phase of such a test, when things are running well,
> here's what vmstat reports for the state of one of these servers:
>
> 2012-06-27 13:56:58.356-06:00
> vmstat -w 4 16
> procs -------------------memory------------------ ---swap-- -----io----
> --system-- -----cpu-------
> r b swpd free buff cache si so bi bo in cs us sy id wa st
> 31 15 0 287216 576 38606628 0 0 2 1158 2 14 1 3 95 0 0
> 27 15 0 225288 576 38583384 0 0 18 2222016 203357 134876 11 56 17 15 0
> 28 17 0 219256 576 38544736 0 0 11 2305932 203141 146296 11 49 23 17 0
> 6 18 0 215596 576 38552872 0 0 7 2363207 215264 166502 12 45 22 20 0
> 22 18 0 226984 576 38596404 0 0 3 2445741 223114 179527 12 43 23 22 0
> 30 12 0 230844 576 38461648 0 0 14 2298537 216580 166661 12 45 23 20 0
> 29 19 0 237856 576 38422884 0 0 5 2332741 209408 157138 12 42 25 22 0
> 17 11 0 222156 576 38483992 0 0 4 2380495 210312 173121 12 39 28 22 0
> 11 13 0 216152 576 38463872 0 0 44 2362186 215236 176454 12 39 27 22 0
> 12 14 0 223704 576 38546720 0 0 2 2395530 214684 177518 12 39 28 22 0
> 39 17 0 219932 576 38598184 0 0 4 2428231 223284 179095 12 42 24 21 0
> 11 10 0 219956 576 38521048 0 0 4 2323853 207472 166665 12 39 28 21 0
> 23 15 0 216580 576 38451904 0 0 3 2241800 201049 163496 11 37 31 21 0
> 9 13 0 225792 576 38451916 0 0 13 2281900 204869 171814 11 36 30 23 0
> 14 12 0 233820 576 38492728 0 0 4 2293423 207686 173019 11 37 31 21 0
> 11 20 0 213796 576 38533208 0 0 3 2288636 205605 168118 11 37 31 21 0
>
>
> The system begins to struggle over the next several
> minutes; here's what vmstat has to say:
>
> 2012-06-27 13:57:58.831-06:00
> vmstat -w 4 16
> procs -------------------memory------------------ ---swap-- -----io----
> --system-- -----cpu-------
> r b swpd free buff cache si so bi bo in cs us sy id wa st
> 21 16 0 224628 576 38526872 0 0 2 1233 9 19 1 4 95 0 0
> 12 19 0 232060 576 38501020 0 0 4 2366769 221418 159890 12 48 20 19 0
> 124 8 0 218548 576 38379656 0 0 13 2103075 199660 108618 11 65 13 12 0
> 24 10 0 300476 576 38230288 0 0 31 1966282 177472 84572 10 76 7 7 0
> 20 16 0 217584 576 38296700 0 0 9 2062571 195936 128810 10 55 20 15 0
> 53 12 0 235720 576 38247968 0 0 30 2035407 196973 133921 10 52 23 15 0
> 20 16 0 360340 576 38067992 0 0 6 2192179 208692 136784 11 54 19 15 0
> 26 10 0 310800 576 38093884 0 0 43 2138772 207105 118718 11 64 12 13 0
> 24 15 0 261108 576 38030828 0 0 68 2174015 205793 135302 11 56 18 15 0
> 9 17 0 241816 576 37982072 0 0 20 2076145 194971 120285 10 60 16 14 0
> 37 15 0 255972 576 37892868 0 0 14 2225076 205694 126954 11 59 16 13 0
> 27 16 0 243212 576 37872704 0 0 6 2249476 210885 134684 12 60 15 14 0
> 30 10 0 217572 576 37795388 0 0 3 2128688 205027 118319 11 66 12 11 0
> 26 11 0 236420 576 37740164 0 0 23 2109709 205105 133925 10 56 19 14 0
> 45 15 0 330056 576 37619896 0 0 15 1948311 196188 119330 10 62 15 13 0
> 54 15 0 242696 576 37631500 0 0 4 2159530 202595 132588 11 59 16 15 0
>
> 2012-06-27 13:58:59.569-06:00
> vmstat -w 4 16
> procs -------------------memory------------------ ---swap-- -----io----
> --system-- -----cpu-------
> r b swpd free buff cache si so bi bo in cs us sy id wa st
> 14 15 0 274932 576 37621548 0 0 2 1301 15 0 1 4 95 0 0
> 44 16 0 278748 576 37509516 0 0 6 2097643 196722 112697 10 66 12 11 0
> 88 14 0 228088 576 37412008 0 0 6 2089559 202206 116146 10 66 13 11 0
> 94 11 0 348348 576 37270624 0 0 7 1906390 181488 87333 9 76 9 6 0
> 42 11 0 215996 576 37288556 0 0 6 1782459 184375 95901 9 74 9 7 0
> 45 11 0 323112 576 37146500 0 0 12 1868376 187814 103947 9 71 11 9 0
> 51 7 0 244560 576 37100124 0 0 35 1767496 181383 107259 9 68 12 11 0
> 74 12 0 221584 576 37016420 0 0 18 1884986 183376 93425 9 75 9 7 0
> 45 10 0 275564 576 36985324 0 0 23 1683688 167223 97036 8 75 9 8 0
> 19 10 0 322176 576 36813176 0 0 14 1747378 177594 97218 8 72 12 8 0
> 122 7 0 225256 576 36838084 0 0 26 1730643 177915 92621 8 75 9 8 0
> 243 10 0 223464 576 36765460 0 0 18 1730158 173059 79373 8 80 6 5 0
> 100 10 0 307528 576 36598456 0 0 4 1738567 174077 79585 9 82 6 4 0
> 243 6 0 370064 576 36358576 0 0 9 1586528 174680 85353 8 81 6 5 0
> 267 2 0 322640 576 36254044 0 0 40 1011650 129389 42277 5 93 1 1 0
> 210 4 0 505092 576 35865460 0 0 25 720825 116356 32422 3 96 1 0 0
>
> 2012-06-27 14:00:03.219-06:00
> vmstat -w 4 16
> procs -------------------memory------------------ ---swap-- -----io----
> --system-- -----cpu-------
> r b swpd free buff cache si so bi bo in cs us sy id wa st
> 75 1 0 566988 576 35664800 0 0 2 1355 21 3 1 4 95 0 0
> 433 1 0 964052 576 35069112 0 0 7 456359 102256 20901 2 98 0 0 0
> 547 3 0 820116 576 34893932 0 0 57 560507 114878 28115 3 96 0 0 0
> 806 2 0 606992 576 34848180 0 0 339 309668 101230 21056 2 98 0 0 0
> 708 1 0 529624 576 34708000 0 0 248 370886 101327 20062 2 97 0 0 0
> 231 5 0 504772 576 34663880 0 0 305 334824 95045 20407 2 97 1 1 0
> 158 6 0 1063088 576 33518536 0 0 531 847435 130696 47140 4 92 1 2 0
> 193 0 0 1449156 576 33035572 0 0 363 371279 94470 18955 2 96 1 1 0
> 266 6 0 1623512 576 32728164 0 0 77 241114 95730 15483 2 98 0 0 0
> 243 8 0 1629504 576 32653080 0 0 81 471018 100223 20920 3 96 0 1 0
> 70 11 0 1342140 576 33084020 0 0 100 925869 139876 56599 6 88 3 3 0
> 211 7 0 1130316 576 33470432 0 0 290 1008984 150699 74320 6 83 6 5 0
> 365 3 0 776736 576 34072772 0 0 182 747167 139436 67135 5 88 4 3 0
> 29 1 0 1528412 576 34110640 0 0 50 612181 137403 77609 4 87 6 3 0
> 266 5 0 1657688 576 34105696 0 0 3 258307 62879 38508 2 93 3 2 0
> 1159 2 0 2002256 576 33775476 0 0 19 88554 42112 14230 1 98 0 0 0
>
>
> Right around 14:00 I was able to get a "perf -a -g"; here's the
> beginning of what "perf report --sort symbol --call-graph fractal,5"
> had to say:
>
> #
> 64.86% [k] _raw_spin_lock_irqsave
> |
> |--97.94%-- isolate_freepages
> | compaction_alloc
> | unmap_and_move
> | migrate_pages
> | compact_zone
> | |
> | |--99.56%-- try_to_compact_pages
> | | __alloc_pages_direct_compact
> | | __alloc_pages_slowpath
> | | __alloc_pages_nodemask
> | | alloc_pages_vma
> | | do_huge_pmd_anonymous_page
> | | handle_mm_fault
> | | do_page_fault
> | | page_fault
> | | |
> | | |--53.53%-- skb_copy_datagram_iovec
> | | | tcp_recvmsg
> | | | inet_recvmsg
> | | | sock_recvmsg
> | | | sys_recvfrom
> | | | system_call_fastpath
> | | | __recv
> | | | |
> | | | --100.00%-- (nil)
> | | |
> | | |--27.80%-- __pthread_create_2_1
> | | | (nil)
> | | |
> | | --18.67%-- memcpy
> | | |
> | | |--57.38%-- 0x50d000005
> | | |
> | | |--34.52%-- 0x3b300bf271940a35
> | | |
> | | --8.10%-- 0x1500000000000009
> | --0.44%-- [...]
> --2.06%-- [...]
>
> 6.15% [k] isolate_freepages_block
> |
> |--99.95%-- isolate_freepages
> | compaction_alloc
> | unmap_and_move
> | migrate_pages
> | compact_zone
> | |
> | |--99.54%-- try_to_compact_pages
> | | __alloc_pages_direct_compact
> | | __alloc_pages_slowpath
> | | __alloc_pages_nodemask
> | | alloc_pages_vma
> | | do_huge_pmd_anonymous_page
> | | handle_mm_fault
> | | do_page_fault
> | | page_fault
> | | |
> | | |--54.40%-- skb_copy_datagram_iovec
> | | | tcp_recvmsg
> | | | inet_recvmsg
> | | | sock_recvmsg
> | | | sys_recvfrom
> | | | system_call_fastpath
> | | | __recv
> | | | |
> | | | --100.00%-- (nil)
> | | |
> | | |--25.19%-- __pthread_create_2_1
> | | | (nil)
> | | |
> | | --20.41%-- memcpy
> | | |
> | | |--40.24%-- 0x3b300bf271940a35
> | | |
> | | |--38.29%-- 0x1500000000000009
> | | |
> | | --21.47%-- 0x50d000005
> | --0.46%-- [...]
> --0.05%-- [...]
>
> 3.96% [.] ceph_crc32c_le
> |
> |--99.99%-- 0xb8057558d0065990
> --0.01%-- [...]
>
> A different system in the same test had a slightly different
> call tree, but isolate_freepages() still seems to show up
> prominently:
>
> #
> 32.32% [k] _raw_spin_lock_irqsave
> |
> |--97.64%-- isolate_freepages
> | compaction_alloc
> | unmap_and_move
> | migrate_pages
> | compact_zone
> | try_to_compact_pages
> | __alloc_pages_direct_compact
> | __alloc_pages_slowpath
> | __alloc_pages_nodemask
> | alloc_pages_vma
> | do_huge_pmd_anonymous_page
> | handle_mm_fault
> | do_page_fault
> | page_fault
> | |
> | |--65.31%-- skb_copy_datagram_iovec
> | | tcp_recvmsg
> | | inet_recvmsg
> | | sock_recvmsg
> | | sys_recvfrom
> | | system_call_fastpath
> | | __recv
> | | |
> | | --100.00%-- (nil)
> | |
> | |--30.98%-- memcpy
> | | |
> | | |--50.60%-- 0x50d0000
> | | |
> | | --49.40%-- 0x50d000005
> | --3.70%-- [...]
> --2.36%-- [...]
>
> 17.10% [k] _raw_spin_lock_irq
> |
> |--98.27%-- isolate_migratepages_range
> | compact_zone
> | try_to_compact_pages
> | __alloc_pages_direct_compact
> | __alloc_pages_slowpath
> | __alloc_pages_nodemask
> | alloc_pages_vma
> | do_huge_pmd_anonymous_page
> | handle_mm_fault
> | do_page_fault
> | page_fault
> | |
> | |--99.85%-- __pthread_create_2_1
> | | (nil)
> | --0.15%-- [...]
> --1.73%-- [...]
>
> 4.59% [k] mutex_spin_on_owner
> |
> --- __mutex_lock_slowpath
> mutex_lock
> |
> |--50.14%-- page_lock_anon_vma
> | |
> | |--99.99%-- try_to_unmap_anon
> | | try_to_unmap
> | | __unmap_and_move
> | | unmap_and_move
> | | migrate_pages
> | | compact_zone
> | | try_to_compact_pages
> | | __alloc_pages_direct_compact
> | | __alloc_pages_slowpath
> | | __alloc_pages_nodemask
> | | alloc_pages_vma
> | | do_huge_pmd_anonymous_page
> | | handle_mm_fault
> | | do_page_fault
> | | page_fault
> | | |
> | | |--99.91%-- __pthread_create_2_1
> | | | (nil)
> | | --0.09%-- [...]
> | --0.01%-- [...]
> |
> |--49.67%-- rmap_walk
> | move_to_new_page
> | __unmap_and_move
> | unmap_and_move
> | migrate_pages
> | compact_zone
> | try_to_compact_pages
> | __alloc_pages_direct_compact
> | __alloc_pages_slowpath
> | __alloc_pages_nodemask
> | alloc_pages_vma
> | do_huge_pmd_anonymous_page
> | handle_mm_fault
> | do_page_fault
> | page_fault
> | |
> | |--99.69%-- __pthread_create_2_1
> | | (nil)
> | --0.31%-- [...]
> --0.20%-- [...]
>
> 4.10% [k] isolate_freepages_block
> |
> |--99.95%-- isolate_freepages
> | compaction_alloc
> | unmap_and_move
> | migrate_pages
> | compact_zone
> | try_to_compact_pages
> | __alloc_pages_direct_compact
> | __alloc_pages_slowpath
> | __alloc_pages_nodemask
> | alloc_pages_vma
> | do_huge_pmd_anonymous_page
> | handle_mm_fault
> | do_page_fault
> | page_fault
> | |
> | |--46.97%-- skb_copy_datagram_iovec
> | | tcp_recvmsg
> | | inet_recvmsg
> | | sock_recvmsg
> | | sys_recvfrom
> | | system_call_fastpath
> | | __recv
> | | |
> | | --100.00%-- (nil)
> | |
> | |--31.79%-- __pthread_create_2_1
> | | (nil)
> | |
> | --21.24%-- memcpy
> | |
> | |--61.90%-- 0x50d000005
> | |
> | --38.10%-- 0x50d0000
> --0.05%-- [...]
>
> 3.65% [.] ceph_crc32c_le
> |
> |--99.86%-- 0xb8057558d0065990
> --0.14%-- [...]
>
>
>
> I seem to be able to recreate this issue at will, so please
> let me know what I can do to help learn what is going on.
>
> Thanks -- Jim
>
> P.S. I got the recipients list via "scripts/get_maintainer.pl -f
> mm/compaction.c";
> please let me know if I should have done something else.
>
> --
> To unsubscribe from this list: send the line "unsubscribe ceph-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at http://vger.kernel.org/majordomo-info.html

Ok, I looked around a bit and found this:

https://lkml.org/lkml/2011/11/9/252

I think the same thing is happening here, ie huge pages are trying to be 
allocated but due to memory fragmentation there are none available. 
try_to_compact_pages is getting called to get a contiguous set of pages, 
but apparently it can't move the pages it needs because they are stuck 
waiting.

According to that post, /sys/block/<device>/bdi/max_ratio can be changed 
to specify what percentage of dirty cache each of your OSDs can use. 
Apparently the default is 20% for each device.

Might be worth a try!

Mark

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
