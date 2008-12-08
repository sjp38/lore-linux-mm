Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB8D09WU029811
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 8 Dec 2008 22:00:09 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E92345DD78
	for <linux-mm@kvack.org>; Mon,  8 Dec 2008 22:00:09 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B1D445DD77
	for <linux-mm@kvack.org>; Mon,  8 Dec 2008 22:00:09 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1EA911DB804B
	for <linux-mm@kvack.org>; Mon,  8 Dec 2008 22:00:09 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6FB441DB8048
	for <linux-mm@kvack.org>; Mon,  8 Dec 2008 22:00:08 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] vmscan: skip freeing memory from zones with lots free
In-Reply-To: <20081129195357.813D.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20081128231933.8daef193.akpm@linux-foundation.org> <20081129195357.813D.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20081208205842.53F8.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  8 Dec 2008 22:00:07 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

Hi

verry sorry for late responce.

> > My changelog does not adequately explain the reasons.
> > 
> > But we don't want to rediscover these reasons in early 2010 :(  Some trolling
> > of the linux-mm and lkml archives around those dates might help us avoid
> > a mistake here.
> 
> I hope to digg past discussion archive.
> Andrew, plese wait merge this patch awhile.

I search past archive patiently.
But unfortunately, I don't find the reason at all.

this reverting fix appeared at 2.6.3-mm3 suddenly.

	http://marc.info/?l=linux-kernel&m=107749956707874&w=2

but I don't find related discussion at near month.
So, I guess akpm find anything problem by himself.


Therefore, instead, I'd like to talk about rik patch safeness by mesurement.


1. Checked this patch break reclaim balancing?


run FFSB bench by following conf.
---------------------------------------------------
directio=0
time=300

[filesystem0]
location=/mnt/sdb1/kosaki/ffsb
num_files=20
num_dirs=10
max_filesize=91534338
min_filesize=65535
[end0]

[threadgroup0]
num_threads=10
write_size=2816
write_blocksize=4096
read_size=2816
read_blocksize=4096
create_weight=100
write_weight=30
read_weight=100
[end0]
--------------------------------------------------------

<without patch>


pgscan_kswapd_dma 10624
pgscan_kswapd_normal 20640

        -> normal/dma ratio 20640 / 10624 = 1.9

pgscan_direct_dma 576
pgscan_direct_normal 2528

        -> normal/dma ratio 2528 / 576 = 4.38

<with patch>

pgscan_kswapd_dma    21824
pgscan_kswapd_normal 47424

        -> normal/dma ratio 20640 / 10624 = 2.17

pgscan_direct_dma     1632
pgscan_direct_normal  6912

        -> normal/dma ratio 2528 / 576 = 4.23


The reason is simple.
This patch only works following two case.

  1) Another process freed large memory in direct reclaim processing.
  2) Another process reclaimed large memory in direct reclaim processing.

IOW, its logic doesn't works on typical workload at all.


2. Mesured most benefit case. (IOW, much thread concurrently process swap-out at the same time)

$ ./hackbench 140 process 300  (ten times mesurement)


	2.6.28-rc6   +this patch
	+bail-out
	--------------------------
	62.514        29.270 
	225.698       30.209 
	114.694       20.881 
	179.108       19.795 
	111.080       19.563 
	189.796       19.226 
	114.124       13.330 
	112.999       10.280 
	227.842        9.669 
	81.869        10.113 

avg	141.972       18.234 
std	55.937         7.099 
min	62.514         9.669 
max	227.842       30.209 


	-> about 10 times improvement


3. Mesured worst case (much thread without swap)

mesured following three case. (ten times)

$ ./hackbench 125 process 3000
$ ./hackbench 130 process 3000
$ ./hackbench 135 process 3000


              2.6.28-rc6
            + evice streaming first          + skip freeing memory
            + rvr bail out
            + kosaki bail out improve

nr_group      125     130      135               125     130      135
	    ----------------------------------------------------------
	    67.302   68.269   77.161		89.450   75.328  173.437 
	    72.616   72.712   79.060 		69.843 	 74.145   76.217 
	    72.475   75.712   77.735 		73.531 	 76.426   85.527 
	    69.229   73.062   78.814 		72.472 	 74.891   75.129 
	    71.551   74.392   78.564 		69.423 	 73.517   75.544 
	    69.227   74.310   78.837 		72.543 	 75.347   79.237 
	    70.759   75.256   76.600 		70.477 	 77.848   90.981 
	    69.966   76.001   78.464 		71.792 	 78.722   92.048 
	    69.068   75.218   80.321 		71.313 	 74.958   78.113 
	    72.057   77.151   79.068 		72.306 	 75.644   79.888 

avg	    70.425   74.208   78.462 		73.315 	 75.683   90.612 
std	     1.665    2.348    1.007  	 	 5.516 	  1.514   28.218 
min	    67.302   68.269   76.600 		69.423 	 73.517   75.129 
max	    72.616   77.151   80.321 		89.450 	 78.722  173.437 


	-> 1 - 10% slow down
	   because zone_watermark_ok() is a bit slow function.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
