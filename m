Date: Tue, 25 Dec 2007 17:31:27 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mem notifications v3
In-Reply-To: <20071225122326.D25C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20071224203250.GA23149@dmt> <20071225122326.D25C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20071225164832.D267.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="------_4770B5D000000000D2FA_MULTIPART_MIXED_"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@kvack.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, Daniel =?ISO-2022-JP?B?U3AbJEJpTxsoQmc=?= <daniel.spang@gmail.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

--------_4770B5D000000000D2FA_MULTIPART_MIXED_
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit

Hi Marcelo-san

I tested your patch.
but unfortunately it doesn't works so good on large system.

description:
--------------------------------------------------------------
test machine
  CPU: Itanium2 x 4
  MEM: 16GB(8GB node x 2 NUMA system)
  SWAP: 2GB

test program:
  mem_notify_test.c
     see attachement
  m.sh
  --------------
$ cat m.sh
#!/bin/sh

num=${1:-1}
mem=${2:-1}

echo $num $mem

for i in `seq 1 $num`; do
    ./mem_notify_test -m $mem &
done
--------------------------------------

1. run >10000 process test
   console1# LANG=C; while [ 1 ] ;do sleep 1; date; vmstat 1 1 -S M -a; done
   console2# sh m.sh 12500


Wed Dec 26 02:00:14 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 3  0      0   1561      7  12213    0    0    35   268   12  203  1  3 95  1  0
Wed Dec 26 02:00:15 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 2  0      0    602      7  13025    0    0    35   268   12  203  1  3 95  1  0

   !! here 7 sec soft lockup !!
Wed Dec 26 02:00:22 JST 2007   
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 8  1     12     42     68  13427    0    0    35   268   82  206  1  3 95  1  0
Wed Dec 26 02:00:23 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
69  0     17     38     64  13438    0    0    35   268   93  207  1  3 95  1  0
Wed Dec 26 02:00:24 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
4955  3     21     36     61  13443    0    0    35   268  103  208  1  3 95  1  0
Wed Dec 26 02:00:25 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
4138  2     28     42     57  13438    0    0    35   268  113  209  1  3 95  1  0
Wed Dec 26 02:00:26 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
5466  1     41     48    514  12975    0    0    35   269  119  211  1  3 95  1  0
Wed Dec 26 02:00:27 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
6082  0     78     38    896  12596    0    0    35   270  124  214  1  3 95  1  0
Wed Dec 26 02:00:28 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 1  5    132     38   1209  12280    0    0    35   271  128  217  1  3 95  1  0
Wed Dec 26 02:00:29 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 2  0    169     38   1484  12003    0    0    35   272  132  219  1  3 95  1  0
Wed Dec 26 02:00:30 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 0 31    248     36   2651  10822    0    0    35   274  133  222  1  3 95  1  0
Wed Dec 26 02:00:32 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
1729  3    323     42   3138  10325    0    0    35   277  134  227  1  3 95  1  0
Wed Dec 26 02:00:33 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 1  2    410     50   3473   9968    0    0    35   279  134  230  1  3 95  1  0
Wed Dec 26 02:00:34 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
574  4    487     52   3737   9690    0    0    35   281  135  234  1  3 95  1  0
Wed Dec 26 02:00:36 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
5203  0    490     42   3794   9641    0    0    35   281  135  236  1  3 95  1  0
Wed Dec 26 02:00:37 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
2256  2    568     36   4025   9400    0    0    35   283  136  240  1  3 95  1  0
Wed Dec 26 02:00:38 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 2  3    631     55   4233   9167    0    0    35   285  136  243  1  3 95  1  0
Wed Dec 26 02:00:41 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
11  2    819     44   4675   8707    0    0    35   290  138  251  1  3 95  1  0
Wed Dec 26 02:00:42 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 2  4    876     48   4782   8588    0    0    35   292  138  254  1  3 95  1  0
Wed Dec 26 02:00:43 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 1  6    945     36   4923   8450    0    0    35   294  139  257  1  3 95  1  0
Wed Dec 26 02:00:44 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
859  6   1001     50   5030   8317    0    0    35   296  139  260  1  3 95  1  0
Wed Dec 26 02:00:46 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 1  2   1099     45   5190   8146    0    0    35   299  140  266  1  3 95  1  0
Wed Dec 26 02:00:47 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
2516  3   1190     47   5314   8009    0    0    35   301  141  270  1  3 95  1  0
Wed Dec 26 02:00:48 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
2141  3   1259     54   5406   7903    0    0    35   303  141  274  1  3 95  1  0
Wed Dec 26 02:00:49 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
3074  2   1314     44   5467   7844    0    0    35   305  141  277  1  3 95  1  0
Wed Dec 26 02:00:50 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 0  1   1314     45   5465   7840    0    0    35   305  142  278  1  3 95  1  0
Wed Dec 26 02:00:51 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 0  0   1313     44   5466   7840    0    0    35   305  142  278  1  3 95  1  0

!! thundering herd restoration after 30sec at swap out start !!
   result: many swap out occured.

# pgrep mem_notify|wc -l
12193

about 300 process receive notify.

problem
  o thundering herd occured multi times on and off.
  o soft lockup occured.
  o notify receive process too few.
  o swap out occured
  

2. after test1, run file I/O
   console1# LANG=C; while [ 1 ] ;do sleep 1; date; vmstat 1 1 -S M -a; done
   console2# dd if=/dev/zero of=tmp bs=100M count=10


$ LANG=C; while [ 1 ] ;do sleep 1; date; vmstat 1 1 -S M -a; done
Wed Dec 26 02:21:35 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 0  0   1615     51   6048   7235    0    0    34   281  158  265  1  3 95  1  0
Wed Dec 26 02:21:36 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 0  0   1615     51   6048   7235    0    0    34   281  158  265  1  3 95  1  0
Wed Dec 26 02:21:37 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 0  0   1615     51   6048   7235    0    0    34   281  158  265  1  3 95  1  0
Wed Dec 26 02:21:38 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 0  0   1615     52   6048   7235    0    0    34   281  158  265  1  3 95  1  0
Wed Dec 26 02:21:39 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
124  6   1683     35   6174   7121    0    0    34   282  159  267  1  3 95  1  0
Wed Dec 26 02:21:40 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
1262  3   1738     53   6293   6982    0    0    34   284  159  270  1  3 95  1  0
Wed Dec 26 02:21:41 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
1546  1   1794     52   6404   6870    0    0    34   285  159  272  1  3 95  1  0
Wed Dec 26 02:21:42 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 0  5   1857     36   6525   6762    0    0    34   287  160  275  1  3 95  1  0
Wed Dec 26 02:21:43 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
3761  7   1896     35   6571   6718    0    0    34   289  160  276  1  3 95  1  0
Wed Dec 26 02:21:44 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 0  6   1898     43   6623   6654    0    0    34   291  160  277  1  3 95  1  0
Wed Dec 26 02:21:45 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 0  9   1921     36   6670   6614    0    0    34   293  160  279  1  3 95  1  0
Wed Dec 26 02:21:46 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
710  4   1944     52   6689   6582    0    0    34   294  161  280  1  3 95  1  0
Wed Dec 26 02:21:47 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 0  9   1958     42   6731   6549    0    0    34   295  161  281  1  3 95  1  0
Wed Dec 26 02:21:48 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 0  6   1978     44   6782   6498    0    0    34   297  161  284  1  3 95  1  0

!! time leap 4 sec !!
Wed Dec 26 02:21:52 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 0 10   2014     47   6864   6414    0    0    34   301  162  289  1  3 95  1  0
Wed Dec 26 02:21:53 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 0 10   2016     38   6881   6407    0    0    34   303  162  290  1  3 95  1  0
Wed Dec 26 02:21:54 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 0  5   2020     45   6884   6399    0    0    34   303  162  291  1  3 95  1  0
Wed Dec 26 02:21:56 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 1  7   2039     43   6932   6359    0    0    34   303  162  295  1  3 95  1  0
Wed Dec 26 02:21:57 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 0  9   2047     36   6777   6529    0    0    34   306  162  297  1  3 95  1  0
Wed Dec 26 02:21:58 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
1501  1   2047     88   6699   6569    0    0    34   307  163  301  1  3 95  1  0
Wed Dec 26 02:21:59 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 0  5   2047     39   6588   6733    0    0    34   307  164  302  1  3 95  1  0
Wed Dec 26 02:22:00 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 0  4   2047     42   6275   7035    0    0    34   308  164  303  1  3 95  1  0
Wed Dec 26 02:22:01 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 0  3   2047     41   6277   7036    0    0    34   310  164  303  1  3 95  1  0
Wed Dec 26 02:22:02 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 0  0   2047     42   6277   7036    0    0    34   310  164  303  1  3 95  1  0
Wed Dec 26 02:22:03 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 0  1   2047     44   6277   7035    0    0    34   313  164  303  1  3 95  1  0
Wed Dec 26 02:22:04 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 0  1   2047     46   6277   7035    0    0    34   314  164  303  1  3 95  1  0
Wed Dec 26 02:22:05 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 0  1   2047     46   6277   7035    0    0    34   316  164  303  1  3 95  1  0
Wed Dec 26 02:22:06 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 1  0   2047     51   6277   7035    0    0    34   316  164  302  1  3 95  1  0
Wed Dec 26 02:22:07 JST 2007
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free  inact active   si   so    bi    bo   in   cs us sy id wa st
 0  0   2047     54   6277   7035    0    0    34   316  164  302  1  3 95  1  0

some process receive notify and exit.
but too few, and it doesn't prevent swap out.

[kosaki@n3234224 mem_notify]$ pgrep mem_notify|wc -l
11992

   -> about 200 process receive notify.
      requirement is 1000 process(= 1GB / 1MB).


/kosaki

--------_4770B5D000000000D2FA_MULTIPART_MIXED_
Content-Type: application/octet-stream;
 name="mem_notify_test.c"
Content-Disposition: attachment;
 filename="mem_notify_test.c"
Content-Transfer-Encoding: base64

I2RlZmluZSBfR05VX1NPVVJDRQ0KI2luY2x1ZGUgPHN0ZGxpYi5oPg0KI2luY2x1ZGUgPHN0ZGlv
Lmg+DQojaW5jbHVkZSA8cG9sbC5oPg0KI2luY2x1ZGUgPHN5cy90eXBlcy5oPg0KI2luY2x1ZGUg
PHN5cy9zdGF0Lmg+DQojaW5jbHVkZSA8ZmNudGwuaD4NCiNpbmNsdWRlIDx0aW1lLmg+DQojaW5j
bHVkZSA8c3lzL21tYW4uaD4NCiNpbmNsdWRlIDxwdGhyZWFkLmg+DQojaW5jbHVkZSA8dW5pc3Rk
Lmg+DQojaW5jbHVkZSA8c3RyaW5nLmg+DQoNCiNkZWZpbmUgREVGQVVMVF9BTExPQ19TSVpFICgx
KQ0KbG9uZyBhbGxvY19zaXplID0gREVGQVVMVF9BTExPQ19TSVpFOw0KDQppbnQgbWFpbihpbnQg
YXJnYywgY2hhcioqIGFyZ3YpDQp7DQogICAgICAgIHN0cnVjdCBwb2xsZmQgcG9sbHRhYmxlOw0K
ICAgICAgICBpbnQgZmQ7DQogICAgICAgIGludCBlcnI7DQogICAgICAgIHZvaWQqIHB0ciA9IE5V
TEw7DQogICAgICAgIGludCBjOw0KICAgICAgICBsb25nIHNpemU7DQoNCiAgICAgICAgd2hpbGUo
KGMgPSBnZXRvcHQoYXJnYywgYXJndiwgIm06IikpICE9IC0xKXsNCiAgICAgICAgICAgICAgICBz
d2l0Y2goYyl7DQogICAgICAgICAgICAgICAgY2FzZSAnbSc6DQogICAgICAgICAgICAgICAgICAg
ICAgICBhbGxvY19zaXplID0gYXRvbChvcHRhcmcpOw0KICAgICAgICAgICAgICAgICAgICAgICAg
YnJlYWs7DQogICAgICAgICAgICAgICAgZGVmYXVsdDoNCiAgICAgICAgICAgICAgICAgICAgICAg
IGJyZWFrOw0KICAgICAgICAgICAgICAgIH0NCiAgICAgICAgfQ0KICAgICAgICBhcmdjIC09IG9w
dGluZDsNCiAgICAgICAgYXJndiArPSBvcHRpbmQ7DQoNCiAgICAgICAgZmQgPSBvcGVuKCIvZGV2
L21lbV9ub3RpZnkiLCBPX1JET05MWSk7DQogICAgICAgIGlmKCBmZCA8IDAgKXsNCiAgICAgICAg
ICAgICAgICBwZXJyb3IoIm9wZW4gIik7DQogICAgICAgICAgICAgICAgZXhpdCgxKTsNCiAgICAg
ICAgfQ0KDQogICAgICAgIHByaW50ZigidHJ5ICVsZCBNQlxuIiwgYWxsb2Nfc2l6ZSk7DQogICAg
ICAgIHNpemUgPSBhbGxvY19zaXplICogMTAyNCAqIDEwMjQ7DQogICAgICAgIHB0ciA9IG1tYXAo
MCwgc2l6ZSwgUFJPVF9SRUFEfFBST1RfV1JJVEUsIE1BUF9QUklWQVRFfE1BUF9BTk9OfE1BUF9Q
T1BVTEFURSwgMCwgMCk7DQogICAgICAgIG1lbXNldChwdHIsIDAsIHNpemUpOw0KDQoNCiAgICAg
ICAgcG9sbHRhYmxlLmZkID0gZmQ7DQogICAgICAgIHBvbGx0YWJsZS5ldmVudHMgPSBQT0xMSU47
DQogICAgICAgIGVyciA9IHBvbGwoJnBvbGx0YWJsZSwgMSwgLTEpOw0KICAgICAgICBpZiggZXJy
IDwgMCApew0KICAgICAgICAgICAgICAgIHBlcnJvcigicG9sbCAiKTsNCiAgICAgICAgfQ0KICAg
ICAgICBpZihwb2xsdGFibGUucmV2ZW50cyl7DQogICAgICAgICAgICAgICAgdGltZV90IGF0aW1l
Ow0KICAgICAgICAgICAgICAgIGludCByZWFkYnVmOw0KDQogICAgICAgICAgICAgICAgZXJyID0g
cmVhZChmZCwgJnJlYWRidWYsIHNpemVvZihpbnQpKTsNCiAgICAgICAgICAgICAgICBwcmludGYo
InJlYWQgJWRcbiIsIGVycik7DQoNCiAgICAgICAgICAgICAgICBhdGltZSA9IHRpbWUoTlVMTCk7
DQogICAgICAgICAgICAgICAgcHJpbnRmKCJwb2xsIHJldCAleCAlc1xuIiwgcG9sbHRhYmxlLnJl
dmVudHMsIGN0aW1lKCZhdGltZSkpOw0KICAgICAgICAgICAgICAgIGV4aXQoMSk7DQogICAgICAg
IH0NCg0KICAgICAgICBwcmludGYoIm1lbV9ub3RpZnkgZXhpdFxuIik7DQogICAgICAgIGV4aXQo
MSk7DQp9
--------_4770B5D000000000D2FA_MULTIPART_MIXED_--


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
