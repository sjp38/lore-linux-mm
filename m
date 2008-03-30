Date: Sun, 30 Mar 2008 17:12:19 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH][-mm][0/2] page reclaim throttle take4
Message-Id: <20080330171152.89D5.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="------_47EF458C0000000089CF_MULTIPART_MIXED_"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

--------_47EF458C0000000089CF_MULTIPART_MIXED_
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit


changelog
========================================
  v3 -> v4:
     o fixed recursive shrink_zone problem.
     o add last_checked variable in shrink_zone for 
       prevent corner case regression.

  v2 -> v3:
     o use wake_up() instead wake_up_all()
     o max reclaimers can be changed Kconfig option and sysctl.
     o some cleanups

  v1 -> v2:
     o make per zone throttle 


background
=====================================
current VM implementation doesn't has limit of # of parallel reclaim.
when heavy workload, it bring to 2 bad things
  - heavy lock contention
  - unnecessary swap out

The end of last year, KAMEZA Hiroyuki proposed the patch of page 
reclaim throttle and explain it improve reclaim time.
	http://marc.info/?l=linux-mm&m=119667465917215&w=2

but unfortunately it works only memcgroup reclaim.
Today, I implement it again for support global reclaim and mesure it.


benefit
=====================================
<<1. fix the bug of incorrect OOM killer>>

if do following commanc, sometimes OOM killer happened.
(OOM happend about 10%)

 $ ./hackbench 125 process 1000

because following bad scenario happend.

   1. memory shortage happend.
   2. many task call shrink_zone at the same time.
   3. all page are isolated from LRU at the same time.
   4. the last task can't isolate any page from LRU.
   5. it cause reclaim failure.
   6. it cause OOM killer.

my patch is directly solution for that problem.


<<2. performance improvement>>
I mesure various parameter of hackbench.

result number mean seconds (i.e. smaller is better)


    num_group    2.6.25-rc5-mm1      previous        current
                                     proposal        proposal
   ------------------------------------------------------------
      80              26.22            25.34          25.61 
      85              27.31            27.03          27.28 
      90              29.23            28.64          28.81 
      95              30.73            32.70          30.17 
     100              32.02            32.77          32.38 
     105              33.97            39.70          31.99 
     110              35.37            50.03          33.04 
     115              36.96            48.64          36.02 
     120              74.05            45.68          37.33 
     125              41.07(*)         64.13          38.88 
     130              86.92            56.30          51.64 
     135             234.62            74.31          57.09 
     140             291.95           117.74          83.76 
     145             425.35           131.99          92.01 
     150             766.92           160.63         128.27

(*) sometimes OOM happend, please don't think this is nice result.

my patch get performance improvement at any parameter.
(attached graph image)

--------_47EF458C0000000089CF_MULTIPART_MIXED_
Content-Type: image/png;
 name="image001.png"
Content-Disposition: attachment;
 filename="image001.png"
Content-Transfer-Encoding: base64

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
--------_47EF458C0000000089CF_MULTIPART_MIXED_
Content-Type: image/png;
 name="image002.png"
Content-Disposition: attachment;
 filename="image002.png"
Content-Transfer-Encoding: base64

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
AABJRU5ErkJggg==
--------_47EF458C0000000089CF_MULTIPART_MIXED_--


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
