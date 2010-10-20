Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B13DE6B00B7
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 22:10:52 -0400 (EDT)
Subject: Re: oom_killer crash linux system
From: "Figo.zhang" <zhangtianfei@leadcoretech.com>
In-Reply-To: <20101020013553.GA7428@localhost>
References: <20101018021126.GB8654@localhost>
	 <1287389631.1997.9.camel@myhost>
	 <20101018180919.3AF8.A69D9226@jp.fujitsu.com>
	 <1287454058.2078.12.camel@myhost>
	 <20101019115952.d922763b.kamezawa.hiroyu@jp.fujitsu.com>
	 <AANLkTikw6NizBStoXVz8Br_LYvoLoofsOB+d6-FX2=Be@mail.gmail.com>
	 <20101019142640.44c87807.kamezawa.hiroyu@jp.fujitsu.com>
	 <20101020013553.GA7428@localhost>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 20 Oct 2010 10:06:55 +0800
Message-ID: <1287540415.2069.1.camel@myhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, lKOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "rientjes@google.com" <rientjes@google.com>, figo1802 <figo1802@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


> > page_add_file_rmap() just counts an event where mapcount goes 0->1. 
> > Even if thousands process shares  a page,  it's just counted into file_mapped as 1.
> > 
> > Then, there are 480MB of mapped file caches. Do I miss something ?
> > 
> > Anyway, sum-of-all-lru-of-highmem is 480MB smaller than present pages.
> > and isolated(anon/file) is 0kB.
> > (NORMAL has similar problem)
> 
> hugetlb files? But it's a desktop box. Figo, what's your meminfo?
> 
> The GEM objects may be files not in LRU, however they should be
> accounted into shmem.
> 
> Figo, would you run "page-types -r" for some clues? It can be compiled
> from the kernel tree:
> 
>         cd linux
>         make Documentation/vm
>         sudo Documentation/vm/page-types -r

hi fengguang,
here is the "page-types -r" result:

             flags	page-count       MB  symbolic-flags
long-symbolic-flags
0x0000000000000000	     16494       64
__________________________________	
0x0000000100000000	      8264       32
______________________r___________	reserved
0x0000000000010000	      3010       11
________________T_________________	compound_tail
0x0000000000008000	        76        0
_______________H__________________	compound_head
0x0000008000000000	         1        0
_____________________________c____	uncached
0x0000000400000001	         1        0
L_______________________d_________	locked,mappedtodisk
0x0000000000008014	         1        0
__R_D__________H__________________	referenced,dirty,compound_head
0x0000000000010014	        15        0
__R_D___________T_________________	referenced,dirty,compound_tail
0x0000000400000021	       235        0
L____l__________________d_________	locked,lru,mappedtodisk
0x0000000800000024	        64        0
__R__l___________________P________	referenced,lru,private
0x0000000400000028	       823        3
___U_l__________________d_________	uptodate,lru,mappedtodisk
0x0001000400000028	         2        0
___U_l__________________d_____I___	uptodate,lru,mappedtodisk,readahead
0x000000040000002c	         1        0
__RU_l__________________d_________	referenced,uptodate,lru,mappedtodisk
0x000000000000402c	      3837       14
__RU_l________b___________________	referenced,uptodate,lru,swapbacked
0x0000000800000030	         2        0
____Dl___________________P________	dirty,lru,private
0x0000000800000038	         2        0
___UDl___________________P________	uptodate,dirty,lru,private
0x0000000400000038	         2        0
___UDl__________________d_________	uptodate,dirty,lru,mappedtodisk
0x000000000000403c	        58        0
__RUDl________b___________________
referenced,uptodate,dirty,lru,swapbacked
0x0000000800000060	        53        0
_____lA__________________P________	lru,active,private
0x0000000800000064	         9        0
__R__lA__________________P________	referenced,lru,active,private
0x0000000c00000068	         8        0
___U_lA_________________dP________
uptodate,lru,active,mappedtodisk,private
0x0000000000000068	         2        0
___U_lA___________________________	uptodate,lru,active
0x000000040000006c	         1        0
__RU_lA_________________d_________
referenced,uptodate,lru,active,mappedtodisk
0x0000000800000070	         2        0
____DlA__________________P________	dirty,lru,active,private
0x0000000800000074	         9        0
__R_DlA__________________P________	referenced,dirty,lru,active,private
0x0000000000004078	     17910       69
___UDlA_______b___________________	uptodate,dirty,lru,active,swapbacked
0x000000000000407c	      5079       19
__RUDlA_______b___________________
referenced,uptodate,dirty,lru,active,swapbacked
0x000000080000007c	         1        0
__RUDlA__________________P________
referenced,uptodate,dirty,lru,active,private
0x0004000000008080	        70        0
_______S_______H________________A_	slab,compound_head,slub_frozen
0x0000000000008080	       870        3
_______S_______H__________________	slab,compound_head
0x0000000000000080	      2505        9
_______S__________________________	slab
0x0004000000000080	        51        0
_______S________________________A_	slab,slub_frozen
0x0000000800000328	         1        0
___U_l__WI_______________P________
uptodate,lru,writeback,reclaim,private
0x0000000000000400	      1724        6
__________B_______________________	buddy
0x0000000000000800	         1        0
___________M______________________	mmap
0x0000000000000804	         1        0
__R________M______________________	referenced,mmap
0x0000000400000828	       101        0
___U_l_____M____________d_________	uptodate,lru,mmap,mappedtodisk
0x000000040000082c	       150        0
__RU_l_____M____________d_________
referenced,uptodate,lru,mmap,mappedtodisk
0x0000000000004838	      4595       17
___UDl_____M__b___________________	uptodate,dirty,lru,mmap,swapbacked
0x000000000000483c	         8        0
__RUDl_____M__b___________________
referenced,uptodate,dirty,lru,mmap,swapbacked
0x0000000400000868	         3        0
___U_lA____M____________d_________	uptodate,lru,active,mmap,mappedtodisk
0x000000040000086c	       799        3
__RU_lA____M____________d_________
referenced,uptodate,lru,active,mmap,mappedtodisk
0x0000000000004878	       576        2
___UDlA____M__b___________________
uptodate,dirty,lru,active,mmap,swapbacked
0x000000000000487c	        73        0
__RUDlA____M__b___________________
referenced,uptodate,dirty,lru,active,mmap,swapbacked
0x0000000000005808	        15        0
___U_______Ma_b___________________	uptodate,mmap,anonymous,swapbacked
0x0000000000005828	     74342      290
___U_l_____Ma_b___________________
uptodate,lru,mmap,anonymous,swapbacked
0x000000000000582c	        85        0
__RU_l_____Ma_b___________________
referenced,uptodate,lru,mmap,anonymous,swapbacked
0x000000020004582c	        12        0
__RU_l_____Ma_b___u____m__________
referenced,uptodate,lru,mmap,anonymous,swapbacked,unevictable,mlocked
0x0000000000005838	         2        0
___UDl_____Ma_b___________________
uptodate,dirty,lru,mmap,anonymous,swapbacked
0x0000000000005868	    373077     1457
___U_lA____Ma_b___________________
uptodate,lru,active,mmap,anonymous,swapbacked
0x000000000000586c	        48        0
__RU_lA____Ma_b___________________
referenced,uptodate,lru,active,mmap,anonymous,swapbacked
             total	    515071     2011


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
