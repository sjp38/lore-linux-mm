Date: Tue, 25 Dec 2007 19:41:32 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][patch 2/2] mem notifications v3 improvement for large system
In-Reply-To: <20071225192625.D273.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20071225164832.D267.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20071225192625.D273.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20071225193327.D276.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@kvack.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, Daniel =?ISO-2022-JP?B?U3AbJEJpTxsoQmc=?= <daniel.spang@gmail.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

2nd improvement
test2

2. after test1, run file I/O
   console1# LANG=C; while [ 1 ] ;do sleep 1; date; vmstat 1 1 -S M -a; done
   console2# dd if=/dev/zero of=tmp bs=100M count=10

result:
   - swap out unoccured.
   - cache increase about 1GB.
   - anon freed about 1GB.

very good!


$ pgrep mem_notify|wc -l
11079
$ dd if=/dev/zero of=tmp1 bs=100M count=10
$ pgrep mem_notify|wc -l
10307

$ LANG=C; while [ 1 ] ;do sleep 1; date; vmstat 1 1 -S M ; done
Wed Dec 26 04:36:19 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 0  0      0     70     42    211    0    0    54   425  785 3145  5  4 89  1  0
Wed Dec 26 04:36:20 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 0  0      0     70     42    211    0    0    54   424  784 3142  5  4 89  1  0
Wed Dec 26 04:36:21 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 0  0      0     70     42    211    0    0    54   424  784 3139  5  4 89  1  0
Wed Dec 26 04:36:22 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 0  0      0     70     42    211    0    0    54   424  783 3136  5  4 89  1  0
Wed Dec 26 04:36:23 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 0  1      0     70     42    211    0    0    54   423  783 3133  5  4 89  1  0
Wed Dec 26 04:36:24 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 0  0      0     70     42    211    0    0    54   423  782 3130  5  4 89  1  0
Wed Dec 26 04:36:25 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 0  0      0     70     42    211    0    0    54   422  782 3128  5  4 89  1  0
Wed Dec 26 04:36:26 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 0  0      0     70     42    211    0    0    54   422  781 3125  5  4 89  1  0
Wed Dec 26 04:36:35 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
820  6      0     89     45   1052    0    0    53   482 1133 3466  5  5 89  1  0
Wed Dec 26 04:36:36 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
355  6      0     87     45   1124    0    0    53   497 1132 3521  5  5 89  1  0
Wed Dec 26 04:36:37 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
241  6      0     88     45   1188    0    0    53   512 1132 3576  5  5 89  1  0
Wed Dec 26 04:36:38 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 0  3      0     93     45   1208    0    0    53   529 1131 3632  5  5 89  1  0
Wed Dec 26 04:36:39 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 0  4      0     93     45   1208    0    0    53   545 1130 3687  5  5 89  1  0
Wed Dec 26 04:36:40 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
830  4      0     93     45   1208    0    0    53   560 1129 3741  5  5 89  2  0
Wed Dec 26 04:36:41 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
103  4      0     93     45   1208    0    0    53   575 1128 3794  5  5 89  2  0
Wed Dec 26 04:36:42 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
133  4      0     94     45   1208    0    0    53   587 1128 3846  5  5 89  2  0
Wed Dec 26 04:36:43 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
59  4      0     97     45   1208    0    0    53   603 1127 3898  5  5 88  2  0


/kosaki

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
