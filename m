Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 281BC6B00AB
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 19:30:57 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so475352pad.30
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 16:30:56 -0700 (PDT)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Thu, 26 Sep 2013 09:30:47 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 9212D3578054
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 09:30:44 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8PNUXsc10748408
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 09:30:33 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8PNUh8k030625
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 09:30:44 +1000
Message-ID: <52437128.7030402@linux.vnet.ibm.com>
Date: Thu, 26 Sep 2013 04:56:32 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [Results] [RFC PATCH v4 00/40] mm: Memory Power Management
References: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, dave@sr71.net, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



Experimental Results:
====================

Test setup:
----------

x86 Sandybridge dual-socket quad core HT-enabled machine, with 128GB RAM.
Memory Region size = 512MB.

Testcase:
--------

Strategy:

Try to allocate and free large chunks of memory (comparable to that of memory
region size) in multiple threads, and examine the number of completely free
memory regions at the end of the run (when all the memory is freed). (Note
that we don't create any pagecache usage here).

Implementation:

Run 20 instances of multi-threaded ebizzy in parallel, with chunksize=256MB,
and no. of threads=32. This means, potentially 20 * 32 threads can allocate/free
memory in parallel, and each alloc/free size will be 256MB, which is half of
the memory region size.

Cmd-line of each ebizzy instance: ./ebizzy -s 268435456 -n 2 -t 32 -S 60


Effectiveness in consolidating allocations:
------------------------------------------

With the above test case, the higher the number of completely free memory
regions at the end of the run, the better is the memory management algorithm
in consolidating allocations.

Here are the results, with vanilla 3.12-rc2 and with this patchset applied:

                  Free regions at test-start   Free regions after test-run
Without patchset               214                          8
With patchset                  210                        202

This shows that this patchset performs tremendously better than vanilla
kernel in terms of keeping the memory allocations consolidated to a minimum
no. of memory regions. Note that the amount of memory consumed at the end of
the run is 0, so it shows the drastic extent to which the mainline kernel can
fragment memory by spreading a handful of pages across many memory regions.
And since this patchset teaches the kernel to understand the memory region
granularity/boundaries and influences the MM decisions effectively, it shows
a significant improvement over mainline.

Below is the log of the variation of the no. of completely free regions
from the beginning to the end of the test, at 1 second intervals (total
test-run takes 1 minute).

         Vanilla 3.12-rc2         With this patchset
                214	                210
                214	                210
                214	                210
                214	                210
                214	                210
                210	                208
                194	                194
                165	                165
                117	                145
                87	                115
                34	                82
                21	                57
                11	                37
                4	                27
                4	                13
                4	                9
                4	                5
                4	                5
                4	                5
                4	                5
                4	                5
                4	                5
                4	                5
                4	                5
                4	                5
                4	                6
                4	                7
                4	                9
                4	                9
                4	                9
                4	                9
                4	                13
                4	                15
                4	                18
                4	                19
                4	                21
                4	                22
                4	                22
                4	                25
                4	                26
                4	                26
                4	                28
                4	                28
                4	                29
                4	                29
                4	                29
                4	                31
                4	                75
                4	                144
                4	                150
                4	                150
                4	                154
                4	                154
                4	                154
                4	                156
                4	                157
                4	                157
                4	                157
                4	                162
                4	                163
                4	                163
                4	                163
                4	                163
                4	                163
                4	                163
                4	                164
                4	                166
                4	                166
                4	                166
                4	                166
                4	                167
                4	                167
                4	                167
                4	                167
                4	                167
                8	                202


It is interesting to also examine the fragmentation of memory by
looking at the per-region statistics added by this patchset.

Statistics for vanilla 3.12-rc2 kernel:
======================================

We can see from the statistics that there is a lot of fragmentation
among the MOVABLE migratetype.

Node 0, zone   Normal
  pages free     15808914
        min      5960
        low      7450
        high     8940
        scanned  0
        spanned  16252928
        present  16252928
        managed  15989606

Per-region page stats	 present	 free

	Region      0 	      1 	   1024
	Region      1 	 131072 	 130935
	Region      2 	 131072 	 130989
	Region      3 	 131072 	 130958
	Region      4 	 131072 	 130958
	Region      5 	 131072 	 130945
	Region      6 	 131072 	 130413
	Region      7 	 131072 	 130493
	Region      8 	 131072 	 131801
	Region      9 	 131072 	 130974
	Region     10 	 131072 	 130969
	Region     11 	 131072 	 130007
	Region     12 	 131072 	 131329
	Region     13 	 131072 	 131513
	Region     14 	 131072 	 130988
	Region     15 	 131072 	 130986
	Region     16 	 131072 	 130992
	Region     17 	 131072 	 130962
	Region     18 	 131072 	 130187
	Region     19 	 131072 	 131729
	Region     20 	 131072 	 130875
	Region     21 	 131072 	 130968
	Region     22 	 131072 	 130961
	Region     23 	 131072 	 130966
	Region     24 	 131072 	 130950
	Region     25 	 131072 	 130915
	Region     26 	 131072 	 130438
	Region     27 	 131072 	 130563
	Region     28 	 131072 	 131831
	Region     29 	 131072 	 130109
	Region     30 	 131072 	 131899
	Region     31 	 131072 	 130949
	Region     32 	 131072 	 130975
	Region     33 	 131072 	 130444
	Region     34 	 131072 	 131478
	Region     35 	 131072 	 131002
	Region     36 	 131072 	 130976
	Region     37 	 131072 	 130950
	Region     38 	 131072 	 130222
	Region     39 	 131072 	 130965
	Region     40 	 131072 	 130820
	Region     41 	 131072 	 131332
	Region     42 	 131072 	 130970
	Region     43 	 131072 	 131485
	Region     44 	 131072 	 130964
	Region     45 	 131072 	 130993
	Region     46 	 131072 	 130966
	Region     47 	 131072 	 130907
	Region     48 	 131072 	 130965
	Region     49 	 131072 	 129989
	Region     50 	 131072 	 131912
	Region     51 	 131072 	 130980
	Region     52 	 131072 	 130970
	Region     53 	 131072 	 130962
	Region     54 	 131072 	 130962
	Region     55 	 131072 	 130984
	Region     56 	 131072 	 131000
	Region     57 	 131072 	 130186
	Region     58 	 131072 	 131717
	Region     59 	 131072 	 130942
	Region     60 	 131072 	 130983
	Region     61 	 131072 	 130440
	Region     62 	 131072 	 131504
	Region     63 	 131072 	 130947
	Region     64 	 131072 	 130947
	Region     65 	 131072 	 130977
	Region     66 	 131072 	 130950
	Region     67 	 131072 	 130201
	Region     68 	 131072 	 130948
	Region     69 	 131072 	 131749
	Region     70 	 131072 	 130986
	Region     71 	 131072 	 130406
	Region     72 	 131072 	 131469
	Region     73 	 131072 	 130964
	Region     74 	 131072 	 130983
	Region     75 	 131072 	 130942
	Region     76 	 131072 	 130470
	Region     77 	 131072 	 130980
	Region     78 	 131072 	 130599
	Region     79 	 131072 	 131880
	Region     80 	 131072 	 130961
	Region     81 	 131072 	 130979
	Region     82 	 131072 	 130991
	Region     83 	 131072 	 130136
	Region     84 	 131072 	 130878
	Region     85 	 131072 	 131867
	Region     86 	 131072 	 130994
	Region     87 	 131072 	 130465
	Region     88 	 131072 	 131488
	Region     89 	 131072 	 130937
	Region     90 	 131072 	 130954
	Region     91 	 131072 	 129897
	Region     92 	 131072 	 131970
	Region     93 	 131072 	 130967
	Region     94 	 131072 	 130941
	Region     95 	 131072 	 130191
	Region     96 	 131072 	 130967
	Region     97 	 131072 	 131182
	Region     98 	 131072 	 131494
	Region     99 	 131072 	 130911
	Region    100 	 131072 	 130832
	Region    101 	 131072 	 130445
	Region    102 	 131072 	 130488
	Region    103 	 131072 	 131951
	Region    104 	 131072 	 130937
	Region    105 	 131072 	 130162
	Region    106 	 131072 	 131724
	Region    107 	 131072 	 130954
	Region    108 	 131072 	 130383
	Region    109 	 131072 	 130477
	Region    110 	 131072 	 132062
	Region    111 	 131072 	 131039
	Region    112 	 131072 	 130960
	Region    113 	 131072 	 131062
	Region    114 	 131072 	 129938
	Region    115 	 131072 	 131989
	Region    116 	 131072 	 130903
	Region    117 	 131072 	 131020
	Region    118 	 131072 	 131032
	Region    119 	 131072 	  98662
	Region    120 	 131072 	 115369
	Region    121 	 131072 	 107352
	Region    122 	 131072 	  33060
	Region    123 	 131072 	      0
	Region    124 	 131071 	     67


Page block order: 10
Pages per block:  1024

Free pages count per migrate type at order       0      1      2      3      4      5      6      7      8      9     10
Node    0, zone      DMA, type    Unmovable      1      2      2      1      3      2      0      0      1      1      0
Node    0, zone      DMA, type  Reclaimable      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone      DMA, type      Movable      0      0      0      0      0      0      0      0      0      0      2
Node    0, zone      DMA, type      Reserve      0      0      0      0      0      0      0      0      0      0      1
Node    0, zone      DMA, type      Isolate      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone    DMA32, type    Unmovable    543    554    431    220     94     18      3      1      0      0      0
Node    0, zone    DMA32, type  Reclaimable      0      1      0     16      8      1      0      1      0      0      0
Node    0, zone    DMA32, type      Movable    754    826    846    811    792    748    659    528    364    168    100
Node    0, zone    DMA32, type      Reserve      0      0      0      0      0      0      0      0      0      0      1
Node    0, zone    DMA32, type      Isolate      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone   Normal, type    Unmovable    567   1880   2103    849    276     34      0      0      0      0      0
Node    0, zone   Normal, type  Reclaimable      1    512    363    237     97     16      7      1      0      0      0
Node    0, zone   Normal, type      Movable   8383  13055  14648  13112  11081   9161   7898   6882   5694   4630   9660
Node    0, zone   Normal, type      Reserve      0      0      0      0      0      0      0      0      0      0      2
Node    0, zone   Normal, type      Isolate      0      0      0      0      0      0      0      0      0      0      0

Node    0, zone   Normal, R  0      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R  1      Movable     75     82     80     85     80     73     76     71     62     48     69 
Node    0, zone   Normal, R  2      Movable     43     49     54     55     55     55     55     45     46     40     84 
Node    0, zone   Normal, R  3      Movable     43     50     62     61     60     53     55     54     47     35     85 
Node    0, zone   Normal, R  4      Movable     40     53     59     58     58     59     57     56     45     35     85 
Node    0, zone   Normal, R  5      Movable     41     50     49     48     47     44     45     40     37     30     93 
Node    0, zone   Normal, R  6      Movable     73     86     92     89     84     82     79     66     56     46     72 
Node    0, zone   Normal, R  7      Movable     73     84     79     86     78     80     80     74     65     48     68 
Node    0, zone   Normal, R  8      Movable     59     71     78     77     85     85     84     71     56     43     74 
Node    0, zone   Normal, R  9      Movable     58     64     67     69     69     65     65     64     59     48     73 
Node    0, zone   Normal, R 10      Movable     53     58     62     61     63     63     61     52     49     45     79 
Node    0, zone   Normal, R 11      Movable     55     64     68     62     60     61     61     57     47     39     81 
Node    0, zone   Normal, R 12      Movable     63     97     98     99     92     93     88     84     68     43     68 
Node    0, zone   Normal, R 13      Movable     29     36     39     39     38     37     36     37     35     27     97 
Node    0, zone   Normal, R 14      Movable     40     46     54     54     52     53     53     51     46     37     85 
Node    0, zone   Normal, R 15      Movable     34     46     51     48     48     47     46     45     42     36     88 
Node    0, zone   Normal, R 16      Movable     46     57     56     58     58     56     55     56     50     39     82 
Node    0, zone   Normal, R 17      Movable     40     45     52     52     54     52     53     47     38     34     89 
Node    0, zone   Normal, R 18      Movable     47     54     62     57     57     55     55     50     40     36     86 
Node    0, zone   Normal, R 19      Movable     49     54     63     61     63     61     60     59     47     48     78 
Node    0, zone   Normal, R 20      Movable     65     83     87     79     74     69     71     65     43     42     79 
Node    0, zone   Normal, R 21      Movable     54     67     73     69     71     71     69     60     51     42     78 
Node    0, zone   Normal, R 22      Movable     51     59     60     65     65     61     57     54     49     41     81 
Node    0, zone   Normal, R 23      Movable     48     55     62     58     59     56     54     50     45     33     87 
Node    0, zone   Normal, R 24      Movable     54     68     70     74     70     68     68     65     57     42     76 
Node    0, zone   Normal, R 25      Movable     60     70     81     79     78     72     70     69     53     46     74 
Node    0, zone   Normal, R 26      Movable     60     69     78     77     78     76     75     66     59     54     68 
Node    0, zone   Normal, R 27      Movable     49     65     72     72     65     69     67     63     47     45     77 
Node    0, zone   Normal, R 28      Movable     67     82     90     89     84     79     79     72     61     43     73 
Node    0, zone   Normal, R 29      Movable     43     47     47     47     46     47     47     46     36     29     92 
Node    0, zone   Normal, R 30      Movable     42     45     46     48     48     44     46     45     44     39     87 
Node    0, zone   Normal, R 31      Movable     77     80     84     79     77     76     72     63     55     42     76 
Node    0, zone   Normal, R 32      Movable     63     68     68     69     68     67     60     62     51     43     78 
Node    0, zone   Normal, R 33      Movable     52     66     71     71     70     69     70     66     58     36     78 
Node    0, zone   Normal, R 34      Movable     48     55     58     60     57     57     56     53     45     41     83 
Node    0, zone   Normal, R 35      Movable     40     47     49     50     50     50     48     45     41     30     91 
Node    0, zone   Normal, R 36      Movable     40     50     53     52     54     46     50     46     38     37     88 
Node    0, zone   Normal, R 37      Movable     56     77     79     75     72     75     71     67     54     44     75 
Node    0, zone   Normal, R 38      Movable     38     48     52     51     50     45     40     38     40     34     90 
Node    0, zone   Normal, R 39      Movable     59     69     68     70     69     68     65     59     47     41     80 
Node    0, zone   Normal, R 40      Movable     34     43     45     43     42     43     44     41     37     34     91 
Node    0, zone   Normal, R 41      Movable     62     75     86     91     88     84     78     73     52     42     75 
Node    0, zone   Normal, R 42      Movable     44     59     56     61     61     55     54     52     42     40     84 
Node    0, zone   Normal, R 43      Movable     45     48     50     53     54     52     49     49     34     35     90 
Node    0, zone   Normal, R 44      Movable     58     71     69     67     66     66     63     63     52     44     77 
Node    0, zone   Normal, R 45      Movable     43     51     54     55     53     50     48     48     43     34     88 
Node    0, zone   Normal, R 46      Movable     52     65     68     70     68     67     68     66     47     47     76 
Node    0, zone   Normal, R 47      Movable     61     65     69     75     71     70     68     64     55     43     76 
Node    0, zone   Normal, R 48      Movable     51     63     69     66     62     61     61     62     52     39     80 
Node    0, zone   Normal, R 49      Movable     51     61     68     69     68     69     64     54     54     41     78 
Node    0, zone   Normal, R 50      Movable     64     76     76     76     76     73     66     67     53     45     76 
Node    0, zone   Normal, R 51      Movable     44     52     58     59     57     56     55     48     48     44     81 
Node    0, zone   Normal, R 52      Movable     48     61     68     68     64     64     63     56     46     45     79 
Node    0, zone   Normal, R 53      Movable     57     69     72     68     67     65     65     60     49     42     79 
Node    0, zone   Normal, R 54      Movable     66     82     83     80     78     78     77     64     59     45     73 
Node    0, zone   Normal, R 55      Movable     44     52     55     51     54     48     49     48     47     38     85 
Node    0, zone   Normal, R 56      Movable     42     47     50     49     48     49     47     46     45     34     88 
Node    0, zone   Normal, R 57      Movable     62     72     73     75     74     75     69     66     54     41     76 
Node    0, zone   Normal, R 58      Movable     63     75     74     71     71     69     67     67     59     42     76 
Node    0, zone   Normal, R 59      Movable     50     68     67     71     66     65     65     64     51     40     79 
Node    0, zone   Normal, R 60      Movable     53     59     63     60     58     56     58     52     47     39     83 
Node    0, zone   Normal, R 61      Movable     58     69     77     70     66     68     65     65     44     42     79 
Node    0, zone   Normal, R 62      Movable     40     46     51     50     51     49     50     50     42     35     88 
Node    0, zone   Normal, R 63      Movable     55     64     67     72     68     68     65     65     52     47     75 
Node    0, zone   Normal, R 64      Movable     47     58     68     66     62     61     59     57     53     42     79 
Node    0, zone   Normal, R 65      Movable     53     62     62     61     63     61     58     50     51     41     81 
Node    0, zone   Normal, R 66      Movable     56     65     75     74     73     74     72     65     59     48     72 
Node    0, zone   Normal, R 67      Movable     43     53     53     54     54     51     49     43     44     31     89 
Node    0, zone   Normal, R 68      Movable     74     77     82     85     77     79     76     76     57     49     70 
Node    0, zone   Normal, R 69      Movable     49     54     62     62     60     61     61     57     48     44     80 
Node    0, zone   Normal, R 70      Movable     64     65     66     64     64     63     64     62     51     37     81 
Node    0, zone   Normal, R 71      Movable     58     76     83     81     78     79     72     66     57     49     71 
Node    0, zone   Normal, R 72      Movable     45     56     64     66     64     63     62     59     53     38     81 
Node    0, zone   Normal, R 73      Movable     54     67     72     73     69     63     67     65     64     45     73 
Node    0, zone   Normal, R 74      Movable     49     59     62     61     60     53     57     53     43     37     85 
Node    0, zone   Normal, R 75      Movable     68     77     86     87     81     72     74     68     58     45     73 
Node    0, zone   Normal, R 76      Movable     56     63     66     61     64     60     60     59     54     38     80 
Node    0, zone   Normal, R 77      Movable     40     56     61     59     56     58     58     52     45     38     84 
Node    0, zone   Normal, R 78      Movable     35     44     49     49     48     49     49     50     45     32     88 
Node    0, zone   Normal, R 79      Movable     52     56     59     55     50     52     53     46     42     34     89 
Node    0, zone   Normal, R 80      Movable     60     65     75     73     64     69     65     65     56     43     76 
Node    0, zone   Normal, R 81      Movable     37     49     53     53     52     53     47     48     41     39     86 
Node    0, zone   Normal, R 82      Movable     55     58     63     61     60     61     59     60     54     41     79 
Node    0, zone   Normal, R 83      Movable     64     84     98     87     93     87     86     82     64     48     66 
Node    0, zone   Normal, R 84      Movable     37     47     49     49     49     49     47     47     40     36     88 
Node    0, zone   Normal, R 85      Movable     40     50     58     57     56     53     51     46     38     34     90 
Node    0, zone   Normal, R 86      Movable     50     56     58     57     54     56     56     54     47     47     79 
Node    0, zone   Normal, R 87      Movable     35     51     54     48     50     49     46     44     38     33     90 
Node    0, zone   Normal, R 88      Movable     60     60     67     68     68     64     64     61     51     44     78 
Node    0, zone   Normal, R 89      Movable     59     89     83     84     84     81     81     80     63     50     67 
Node    0, zone   Normal, R 90      Movable     44     61     63     65     64     63     62     55     57     48     75 
Node    0, zone   Normal, R 91      Movable     63     73     78     80     74     72     73     68     55     55     68 
Node    0, zone   Normal, R 92      Movable     58     70     75     74     76     74     75     67     53     52     72 
Node    0, zone   Normal, R 93      Movable     53     67     69     67     65     63     63     54     53     34     83 
Node    0, zone   Normal, R 94      Movable     69     82     85     84     84     83     84     80     64     49     67 
Node    0, zone   Normal, R 95      Movable     67     74     78     76     78     72     69     66     52     48     73 
Node    0, zone   Normal, R 96      Movable     49     61     67     68     68     68     64     64     55     42     77 
Node    0, zone   Normal, R 97      Movable     78     88     96     94     90     89     85     68     57     49     70 
Node    0, zone   Normal, R 98      Movable     58     70     70     67     65     67     63     63     56     35     81 
Node    0, zone   Normal, R 99      Movable     55     66     81     80     80     75     76     69     59     46     72 
Node    0, zone   Normal, R100      Movable     62     81     86     81     77     74     71     69     56     50     71 
Node    0, zone   Normal, R101      Movable     67     83     83     81     79     75     76     69     57     44     73 
Node    0, zone   Normal, R102      Movable     52     58     68     68     64     65     59     50     46     32     86 
Node    0, zone   Normal, R103      Movable     77     85     82     86     82     75     76     64     53     46     75 
Node    0, zone   Normal, R104      Movable     69     82     92     92     92     90     89     80     69     47     66 
Node    0, zone   Normal, R105      Movable     76     81     83     89     89     85     87     75     54     53     67 
Node    0, zone   Normal, R106      Movable     75     85     90     88     89     83     78     72     46     38     79 
Node    0, zone   Normal, R107      Movable     50     66     69     70     67     69     65     65     46     40     80 
Node    0, zone   Normal, R108      Movable     77     95     95     97     90     89     88     74     54     45     71 
Node    0, zone   Normal, R109      Movable     47     65     67     66     64     63     62     61     50     37     81 
Node    0, zone   Normal, R110      Movable     16     17     17     15     13     15     15     15     11      9    118 
Node    0, zone   Normal, R111      Movable     31     32     32     32     32     32     32     30     19     13    109 
Node    0, zone   Normal, R112      Movable     30     29     40     33     25     28     28     25     19     15    109 
Node    0, zone   Normal, R113      Movable     10     10     10      8      9      9      9      9      9      7    120 
Node    0, zone   Normal, R114      Movable     46     46     48     43     47     44     42     42     31     23     97 
Node    0, zone   Normal, R115      Movable     27     29     28     26     24     24     24     23     20     20    108 
Node    0, zone   Normal, R116      Movable     43     46     42     43     41     44     45     39     26     12    105 
Node    0, zone   Normal, R117      Movable     38     37     39     36     32     33     28     27     29     19    104 
Node    0, zone   Normal, R118      Movable     30     31     29     27     21     23     20     20     17     13    112 
Node    0, zone   Normal, R119      Movable    340   1039   1218    960    611    261     94     36     14      7     37 
Node    0, zone   Normal, R120      Movable    514   2102   2401   2023   1473    838    348     76      8      0      0 
Node    0, zone   Normal, R121      Movable   1034   2065   2561   1913   1163    574    235     62      9      0      0 
Node    0, zone   Normal, R122      Movable    361    571    734    560    363    181     63      7      1      0      0 
Node    0, zone   Normal, R123      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R124      Movable      3      2      3      2      0      1      0      0      0      0      0 

Number of blocks type         Unmovable  Reclaimable      Movable      Reserve      Isolate 
Node 0, zone      DMA                 1            0            2            1            0 
Node 0, zone    DMA32                10            2          495            1            0 
Node 0, zone   Normal               121           41        15708            2            0 

Node 0, zone   Normal R  0            0            0            0            1            0 
Node 0, zone   Normal R  1            0            0          126            2            0 
Node 0, zone   Normal R  2            0            0          128            0            0 
Node 0, zone   Normal R  3            0            0          128            0            0 
Node 0, zone   Normal R  4            0            0          128            0            0 
Node 0, zone   Normal R  5            0            0          128            0            0 
Node 0, zone   Normal R  6            0            0          128            0            0 
Node 0, zone   Normal R  7            0            0          128            0            0 
Node 0, zone   Normal R  8            0            0          128            0            0 
Node 0, zone   Normal R  9            0            0          128            0            0 
Node 0, zone   Normal R 10            0            0          128            0            0 
Node 0, zone   Normal R 11            0            0          128            0            0 
Node 0, zone   Normal R 12            0            0          128            0            0 
Node 0, zone   Normal R 13            0            0          128            0            0 
Node 0, zone   Normal R 14            0            0          128            0            0 
Node 0, zone   Normal R 15            0            0          128            0            0 
Node 0, zone   Normal R 16            0            0          128            0            0 
Node 0, zone   Normal R 17            0            0          128            0            0 
Node 0, zone   Normal R 18            0            0          128            0            0 
Node 0, zone   Normal R 19            0            0          128            0            0 
Node 0, zone   Normal R 20            0            0          128            0            0 
Node 0, zone   Normal R 21            0            0          128            0            0 
Node 0, zone   Normal R 22            0            0          128            0            0 
Node 0, zone   Normal R 23            0            0          128            0            0 
Node 0, zone   Normal R 24            0            0          128            0            0 
Node 0, zone   Normal R 25            0            0          128            0            0 
Node 0, zone   Normal R 26            0            0          128            0            0 
Node 0, zone   Normal R 27            0            0          128            0            0 
Node 0, zone   Normal R 28            0            0          128            0            0 
Node 0, zone   Normal R 29            0            0          128            0            0 
Node 0, zone   Normal R 30            0            0          128            0            0 
Node 0, zone   Normal R 31            0            0          128            0            0 
Node 0, zone   Normal R 32            0            0          128            0            0 
Node 0, zone   Normal R 33            0            0          128            0            0 
Node 0, zone   Normal R 34            0            0          128            0            0 
Node 0, zone   Normal R 35            0            0          128            0            0 
Node 0, zone   Normal R 36            0            0          128            0            0 
Node 0, zone   Normal R 37            0            0          128            0            0 
Node 0, zone   Normal R 38            0            0          128            0            0 
Node 0, zone   Normal R 39            0            0          128            0            0 
Node 0, zone   Normal R 40            0            0          128            0            0 
Node 0, zone   Normal R 41            0            0          128            0            0 
Node 0, zone   Normal R 42            0            0          128            0            0 
Node 0, zone   Normal R 43            0            0          128            0            0 
Node 0, zone   Normal R 44            0            0          128            0            0 
Node 0, zone   Normal R 45            0            0          128            0            0 
Node 0, zone   Normal R 46            0            0          128            0            0 
Node 0, zone   Normal R 47            0            0          128            0            0 
Node 0, zone   Normal R 48            0            0          128            0            0 
Node 0, zone   Normal R 49            0            0          128            0            0 
Node 0, zone   Normal R 50            0            0          128            0            0 
Node 0, zone   Normal R 51            0            0          128            0            0 
Node 0, zone   Normal R 52            0            0          128            0            0 
Node 0, zone   Normal R 53            0            0          128            0            0 
Node 0, zone   Normal R 54            0            0          128            0            0 
Node 0, zone   Normal R 55            0            0          128            0            0 
Node 0, zone   Normal R 56            0            0          128            0            0 
Node 0, zone   Normal R 57            0            0          128            0            0 
Node 0, zone   Normal R 58            0            0          128            0            0 
Node 0, zone   Normal R 59            0            0          128            0            0 
Node 0, zone   Normal R 60            0            0          128            0            0 
Node 0, zone   Normal R 61            0            0          128            0            0 
Node 0, zone   Normal R 62            0            0          128            0            0 
Node 0, zone   Normal R 63            0            0          128            0            0 
Node 0, zone   Normal R 64            0            0          128            0            0 
Node 0, zone   Normal R 65            0            0          128            0            0 
Node 0, zone   Normal R 66            0            0          128            0            0 
Node 0, zone   Normal R 67            0            0          128            0            0 
Node 0, zone   Normal R 68            0            0          128            0            0 
Node 0, zone   Normal R 69            0            0          128            0            0 
Node 0, zone   Normal R 70            0            0          128            0            0 
Node 0, zone   Normal R 71            0            0          128            0            0 
Node 0, zone   Normal R 72            0            0          128            0            0 
Node 0, zone   Normal R 73            0            0          128            0            0 
Node 0, zone   Normal R 74            0            0          128            0            0 
Node 0, zone   Normal R 75            0            0          128            0            0 
Node 0, zone   Normal R 76            0            0          128            0            0 
Node 0, zone   Normal R 77            0            0          128            0            0 
Node 0, zone   Normal R 78            0            0          128            0            0 
Node 0, zone   Normal R 79            0            0          128            0            0 
Node 0, zone   Normal R 80            0            0          128            0            0 
Node 0, zone   Normal R 81            0            0          128            0            0 
Node 0, zone   Normal R 82            0            0          128            0            0 
Node 0, zone   Normal R 83            0            0          128            0            0 
Node 0, zone   Normal R 84            0            0          128            0            0 
Node 0, zone   Normal R 85            0            0          128            0            0 
Node 0, zone   Normal R 86            0            0          128            0            0 
Node 0, zone   Normal R 87            0            0          128            0            0 
Node 0, zone   Normal R 88            0            0          128            0            0 
Node 0, zone   Normal R 89            0            0          128            0            0 
Node 0, zone   Normal R 90            0            0          128            0            0 
Node 0, zone   Normal R 91            0            0          128            0            0 
Node 0, zone   Normal R 92            0            0          128            0            0 
Node 0, zone   Normal R 93            0            0          128            0            0 
Node 0, zone   Normal R 94            0            0          128            0            0 
Node 0, zone   Normal R 95            0            0          128            0            0 
Node 0, zone   Normal R 96            0            0          128            0            0 
Node 0, zone   Normal R 97            0            0          128            0            0 
Node 0, zone   Normal R 98            0            0          128            0            0 
Node 0, zone   Normal R 99            0            0          128            0            0 
Node 0, zone   Normal R100            0            0          128            0            0 
Node 0, zone   Normal R101            0            0          128            0            0 
Node 0, zone   Normal R102            0            0          128            0            0 
Node 0, zone   Normal R103            0            0          128            0            0 
Node 0, zone   Normal R104            0            0          128            0            0 
Node 0, zone   Normal R105            0            0          128            0            0 
Node 0, zone   Normal R106            0            0          128            0            0 
Node 0, zone   Normal R107            0            0          128            0            0 
Node 0, zone   Normal R108            0            0          128            0            0 
Node 0, zone   Normal R109            0            0          128            0            0 
Node 0, zone   Normal R110            0            0          128            0            0 
Node 0, zone   Normal R111            0            0          128            0            0 
Node 0, zone   Normal R112            0            0          128            0            0 
Node 0, zone   Normal R113            0            0          128            0            0 
Node 0, zone   Normal R114            0            0          128            0            0 
Node 0, zone   Normal R115            0            0          128            0            0 
Node 0, zone   Normal R116            0            0          128            0            0 
Node 0, zone   Normal R117            0            0          128            0            0 
Node 0, zone   Normal R118            0            0          128            0            0 
Node 0, zone   Normal R119           15           20           93            0            0 
Node 0, zone   Normal R120            3            2          123            0            0 
Node 0, zone   Normal R121           22            2          104            0            0 
Node 0, zone   Normal R122           81           17           30            0            0 
Node 0, zone   Normal R123            0            0          128            0            0 
Node 0, zone   Normal R124            0            0          128            0            0 



Statistics with this patchset applied:
=====================================

Comparing these statistics with that of vanilla kernel, we see that the
fragmentation is significantly lesser, as seen in the MOVABLE migratetype.

Node 0, zone   Normal
  pages free     15754148
        min      5960
        low      7450
        high     8940
        scanned  0
        spanned  16252928
        present  16252928
        managed  15989474

Per-region page stats	 present	 free

	Region      0 	      1 	   1024
	Region      1 	 131072 	  24206
	Region      2 	 131072 	  85728
	Region      3 	 131072 	  69362
	Region      4 	 131072 	 120699
	Region      5 	 131072 	 121015
	Region      6 	 131072 	 131053
	Region      7 	 131072 	 131072
	Region      8 	 131072 	 131072
	Region      9 	 131072 	 131072
	Region     10 	 131072 	 131069
	Region     11 	 131072 	 130988
	Region     12 	 131072 	 131001
	Region     13 	 131072 	 131067
	Region     14 	 131072 	 131072
	Region     15 	 131072 	 131072
	Region     16 	 131072 	 131072
	Region     17 	 131072 	 131072
	Region     18 	 131072 	 131072
	Region     19 	 131072 	 131072
	Region     20 	 131072 	 131072
	Region     21 	 131072 	 131072
	Region     22 	 131072 	 131072
	Region     23 	 131072 	 131072
	Region     24 	 131072 	 131072
	Region     25 	 131072 	 131072
	Region     26 	 131072 	 131072
	Region     27 	 131072 	 131072
	Region     28 	 131072 	 131031
	Region     29 	 131072 	 131072
	Region     30 	 131072 	 131072
	Region     31 	 131072 	 131072
	Region     32 	 131072 	 131072
	Region     33 	 131072 	 131072
	Region     34 	 131072 	 131036
	Region     35 	 131072 	 131072
	Region     36 	 131072 	 131072
	Region     37 	 131072 	 131064
	Region     38 	 131072 	 131071
	Region     39 	 131072 	 131072
	Region     40 	 131072 	 131036
	Region     41 	 131072 	 131071
	Region     42 	 131072 	 131072
	Region     43 	 131072 	 131072
	Region     44 	 131072 	 131072
	Region     45 	 131072 	 131007
	Region     46 	 131072 	 131072
	Region     47 	 131072 	 131072
	Region     48 	 131072 	 131036
	Region     49 	 131072 	 131072
	Region     50 	 131072 	 131072
	Region     51 	 131072 	 131072
	Region     52 	 131072 	 131072
	Region     53 	 131072 	 131072
	Region     54 	 131072 	 131072
	Region     55 	 131072 	 131038
	Region     56 	 131072 	 131072
	Region     57 	 131072 	 131072
	Region     58 	 131072 	 131071
	Region     59 	 131072 	 131072
	Region     60 	 131072 	 131036
	Region     61 	 131072 	 131065
	Region     62 	 131072 	 131072
	Region     63 	 131072 	 131072
	Region     64 	 131072 	 131071
	Region     65 	 131072 	 131072
	Region     66 	 131072 	 131072
	Region     67 	 131072 	 131072
	Region     68 	 131072 	 131072
	Region     69 	 131072 	 131072
	Region     70 	 131072 	 131072
	Region     71 	 131072 	 131072
	Region     72 	 131072 	 131072
	Region     73 	 131072 	 131072
	Region     74 	 131072 	 131072
	Region     75 	 131072 	 131072
	Region     76 	 131072 	 131072
	Region     77 	 131072 	 131072
	Region     78 	 131072 	 131072
	Region     79 	 131072 	 131072
	Region     80 	 131072 	 131072
	Region     81 	 131072 	 131067
	Region     82 	 131072 	 131072
	Region     83 	 131072 	 131072
	Region     84 	 131072 	 130852
	Region     85 	 131072 	 131072
	Region     86 	 131072 	 131071
	Region     87 	 131072 	 131072
	Region     88 	 131072 	 131072
	Region     89 	 131072 	 131072
	Region     90 	 131072 	 131072
	Region     91 	 131072 	 131072
	Region     92 	 131072 	 131072
	Region     93 	 131072 	 131072
	Region     94 	 131072 	 131072
	Region     95 	 131072 	 131072
	Region     96 	 131072 	 131072
	Region     97 	 131072 	 131072
	Region     98 	 131072 	 131072
	Region     99 	 131072 	 131072
	Region    100 	 131072 	 131072
	Region    101 	 131072 	 131072
	Region    102 	 131072 	 131072
	Region    103 	 131072 	 131072
	Region    104 	 131072 	 131072
	Region    105 	 131072 	 131072
	Region    106 	 131072 	 131072
	Region    107 	 131072 	 131072
	Region    108 	 131072 	 131072
	Region    109 	 131072 	 131072
	Region    110 	 131072 	 131072
	Region    111 	 131072 	 131072
	Region    112 	 131072 	 131072
	Region    113 	 131072 	 131072
	Region    114 	 131072 	 131072
	Region    115 	 131072 	 131072
	Region    116 	 131072 	 131072
	Region    117 	 131072 	 131072
	Region    118 	 131072 	 131072
	Region    119 	 131072 	 131072
	Region    120 	 131072 	 131072
	Region    121 	 131072 	 131072
	Region    122 	 131072 	 128722
	Region    123 	 131072 	      0
	Region    124 	 131071 	     10

Page block order: 10
Pages per block:  1024

Free pages count per migrate type at order       0      1      2      3      4      5      6      7      8      9     10
Node    0, zone      DMA, type    Unmovable      1      2      2      1      3      2      0      0      1      1      0
Node    0, zone      DMA, type  Reclaimable      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone      DMA, type      Movable      0      0      0      0      0      0      0      0      0      0      2
Node    0, zone      DMA, type      Reserve      0      0      0      0      0      0      0      0      0      0      1
Node    0, zone      DMA, type      Isolate      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone    DMA32, type    Unmovable    586    714    497    300    160     93     66     45     36     24     80
Node    0, zone    DMA32, type  Reclaimable      1      1      0      0      1      1      1      1      1      1      0
Node    0, zone    DMA32, type      Movable    781    661    635    594    495    433    339    227    110     56    178
Node    0, zone    DMA32, type      Reserve      0      0      0      0      0      0      0      0      0      0      1
Node    0, zone    DMA32, type      Isolate      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone   Normal, type    Unmovable   4357   4070   4542   3024   1866    955    385     92      8      1    110
Node    0, zone   Normal, type  Reclaimable     11      0      1      1      0      0      0      0      1      1     82
Node    0, zone   Normal, type      Movable    207    272    566    504    482    503    456    303    189    120   2676
Node    0, zone   Normal, type      Reserve      0      0      0      0      0      0      0      0      0      0      2
Node    0, zone   Normal, type      Isolate      0      0      0      0      0      0      0      0      0      0      0

Node    0, zone   Normal, R  0      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R  1      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R  2      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R  3      Movable     58    116    360    320    289    309    276    133     40      7      1 
Node    0, zone   Normal, R  4      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R  5      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R  6      Movable      3     11     11     11     11     11      9     10      8      9    119 
Node    0, zone   Normal, R  7      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R  8      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R  9      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 10      Movable      3      3      3      1      2      2      2      2      2      2    126 
Node    0, zone   Normal, R 11      Movable     22     11     16      4      8      5      8      8      8      4    122 
Node    0, zone   Normal, R 12      Movable     35     25     13     12     13     14      9     10     11      7    119 
Node    0, zone   Normal, R 13      Movable      1      3      3      3      3      1      2      2      2      2    126 
Node    0, zone   Normal, R 14      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 15      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 16      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 17      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 18      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 19      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 20      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 21      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 22      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 23      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 24      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 25      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 26      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 27      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 28      Movable      9      9     11     10     12     12     12     10      7      5    121 
Node    0, zone   Normal, R 29      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 30      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 31      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 32      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 33      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 34      Movable     10     11     11     10     10      7      9      9      9      7    120 
Node    0, zone   Normal, R 35      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 36      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 37      Movable      2      5      5      5      5      5      5      5      5      5    123 
Node    0, zone   Normal, R 38      Movable      1      1      1      1      1      1      1      1      1      1    127 
Node    0, zone   Normal, R 39      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 40      Movable      8      6      6      6      6      7      7      7      7      7    121 
Node    0, zone   Normal, R 41      Movable      1      1      1      1      1      1      1      1      1      1    127 
Node    0, zone   Normal, R 42      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 43      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 44      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 45      Movable      7      8     16     17     16     17     17     15     14     13    114 
Node    0, zone   Normal, R 46      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 47      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 48      Movable      6      5      7      4      7      7      7      7      7      5    122 
Node    0, zone   Normal, R 49      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 50      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 51      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 52      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 53      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 54      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 55      Movable     10     18     20     18     19     19     19     19     15      9    115 
Node    0, zone   Normal, R 56      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 57      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 58      Movable      1      1      1      1      1      1      1      1      1      1    127 
Node    0, zone   Normal, R 59      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 60      Movable      6      9      7      5      6      7      5      6      6      4    123 
Node    0, zone   Normal, R 61      Movable      7      7      5      6      6      6      6      6      6      6    122 
Node    0, zone   Normal, R 62      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 63      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 64      Movable      1      1      1      1      1      1      1      1      1      1    127 
Node    0, zone   Normal, R 65      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 66      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 67      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 68      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 69      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 70      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 71      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 72      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 73      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 74      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 75      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 76      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 77      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 78      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 79      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 80      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 81      Movable      1      3      1      2      2      2      2      2      2      2    126 
Node    0, zone   Normal, R 82      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 83      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 84      Movable     12     14     57     61     59     56     54     46     33     20     97 
Node    0, zone   Normal, R 85      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 86      Movable      1      1      1      1      1      1      1      1      1      1    127 
Node    0, zone   Normal, R 87      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 88      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 89      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 90      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 91      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 92      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 93      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 94      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 95      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 96      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 97      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 98      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 99      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R100      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R101      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R102      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R103      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R104      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R105      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R106      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R107      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R108      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R109      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R110      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R111      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R112      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R113      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R114      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R115      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R116      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R117      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R118      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R119      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R120      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R121      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R122      Movable      2      2      9      3      3     11      2      1      2      1    124 
Node    0, zone   Normal, R123      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R124      Movable      0      1      0      1      0      0      0      0      0      0      0 

Number of blocks type         Unmovable  Reclaimable      Movable      Reserve      Isolate 
Node 0, zone      DMA                 1            0            2            1            0 
Node 0, zone    DMA32               128            0          379            1            0 
Node 0, zone   Normal               384          128        15359            1            0 

Node 0, zone   Normal R  0            0            0            0            1            0 
Node 0, zone   Normal R  1          127            0            0            1            0 
Node 0, zone   Normal R  2            1          127            0            0            0 
Node 0, zone   Normal R  3            0            1          127            0            0 
Node 0, zone   Normal R  4          127            0            1            0            0 
Node 0, zone   Normal R  5          128            0            0            0            0 
Node 0, zone   Normal R  6            1            0          127            0            0 
Node 0, zone   Normal R  7            0            0          128            0            0 
Node 0, zone   Normal R  8            0            0          128            0            0 
Node 0, zone   Normal R  9            0            0          128            0            0 
Node 0, zone   Normal R 10            0            0          128            0            0 
Node 0, zone   Normal R 11            0            0          128            0            0 
Node 0, zone   Normal R 12            0            0          128            0            0 
Node 0, zone   Normal R 13            0            0          128            0            0 
Node 0, zone   Normal R 14            0            0          128            0            0 
Node 0, zone   Normal R 15            0            0          128            0            0 
Node 0, zone   Normal R 16            0            0          128            0            0 
Node 0, zone   Normal R 17            0            0          128            0            0 
Node 0, zone   Normal R 18            0            0          128            0            0 
Node 0, zone   Normal R 19            0            0          128            0            0 
Node 0, zone   Normal R 20            0            0          128            0            0 
Node 0, zone   Normal R 21            0            0          128            0            0 
Node 0, zone   Normal R 22            0            0          128            0            0 
Node 0, zone   Normal R 23            0            0          128            0            0 
Node 0, zone   Normal R 24            0            0          128            0            0 
Node 0, zone   Normal R 25            0            0          128            0            0 
Node 0, zone   Normal R 26            0            0          128            0            0 
Node 0, zone   Normal R 27            0            0          128            0            0 
Node 0, zone   Normal R 28            0            0          128            0            0 
Node 0, zone   Normal R 29            0            0          128            0            0 
Node 0, zone   Normal R 30            0            0          128            0            0 
Node 0, zone   Normal R 31            0            0          128            0            0 
Node 0, zone   Normal R 32            0            0          128            0            0 
Node 0, zone   Normal R 33            0            0          128            0            0 
Node 0, zone   Normal R 34            0            0          128            0            0 
Node 0, zone   Normal R 35            0            0          128            0            0 
Node 0, zone   Normal R 36            0            0          128            0            0 
Node 0, zone   Normal R 37            0            0          128            0            0 
Node 0, zone   Normal R 38            0            0          128            0            0 
Node 0, zone   Normal R 39            0            0          128            0            0 
Node 0, zone   Normal R 40            0            0          128            0            0 
Node 0, zone   Normal R 41            0            0          128            0            0 
Node 0, zone   Normal R 42            0            0          128            0            0 
Node 0, zone   Normal R 43            0            0          128            0            0 
Node 0, zone   Normal R 44            0            0          128            0            0 
Node 0, zone   Normal R 45            0            0          128            0            0 
Node 0, zone   Normal R 46            0            0          128            0            0 
Node 0, zone   Normal R 47            0            0          128            0            0 
Node 0, zone   Normal R 48            0            0          128            0            0 
Node 0, zone   Normal R 49            0            0          128            0            0 
Node 0, zone   Normal R 50            0            0          128            0            0 
Node 0, zone   Normal R 51            0            0          128            0            0 
Node 0, zone   Normal R 52            0            0          128            0            0 
Node 0, zone   Normal R 53            0            0          128            0            0 
Node 0, zone   Normal R 54            0            0          128            0            0 
Node 0, zone   Normal R 55            0            0          128            0            0 
Node 0, zone   Normal R 56            0            0          128            0            0 
Node 0, zone   Normal R 57            0            0          128            0            0 
Node 0, zone   Normal R 58            0            0          128            0            0 
Node 0, zone   Normal R 59            0            0          128            0            0 
Node 0, zone   Normal R 60            0            0          128            0            0 
Node 0, zone   Normal R 61            0            0          128            0            0 
Node 0, zone   Normal R 62            0            0          128            0            0 
Node 0, zone   Normal R 63            0            0          128            0            0 
Node 0, zone   Normal R 64            0            0          128            0            0 
Node 0, zone   Normal R 65            0            0          128            0            0 
Node 0, zone   Normal R 66            0            0          128            0            0 
Node 0, zone   Normal R 67            0            0          128            0            0 
Node 0, zone   Normal R 68            0            0          128            0            0 
Node 0, zone   Normal R 69            0            0          128            0            0 
Node 0, zone   Normal R 70            0            0          128            0            0 
Node 0, zone   Normal R 71            0            0          128            0            0 
Node 0, zone   Normal R 72            0            0          128            0            0 
Node 0, zone   Normal R 73            0            0          128            0            0 
Node 0, zone   Normal R 74            0            0          128            0            0 
Node 0, zone   Normal R 75            0            0          128            0            0 
Node 0, zone   Normal R 76            0            0          128            0            0 
Node 0, zone   Normal R 77            0            0          128            0            0 
Node 0, zone   Normal R 78            0            0          128            0            0 
Node 0, zone   Normal R 79            0            0          128            0            0 
Node 0, zone   Normal R 80            0            0          128            0            0 
Node 0, zone   Normal R 81            0            0          128            0            0 
Node 0, zone   Normal R 82            0            0          128            0            0 
Node 0, zone   Normal R 83            0            0          128            0            0 
Node 0, zone   Normal R 84            0            0          128            0            0 
Node 0, zone   Normal R 85            0            0          128            0            0 
Node 0, zone   Normal R 86            0            0          128            0            0 
Node 0, zone   Normal R 87            0            0          128            0            0 
Node 0, zone   Normal R 88            0            0          128            0            0 
Node 0, zone   Normal R 89            0            0          128            0            0 
Node 0, zone   Normal R 90            0            0          128            0            0 
Node 0, zone   Normal R 91            0            0          128            0            0 
Node 0, zone   Normal R 92            0            0          128            0            0 
Node 0, zone   Normal R 93            0            0          128            0            0 
Node 0, zone   Normal R 94            0            0          128            0            0 
Node 0, zone   Normal R 95            0            0          128            0            0 
Node 0, zone   Normal R 96            0            0          128            0            0 
Node 0, zone   Normal R 97            0            0          128            0            0 
Node 0, zone   Normal R 98            0            0          128            0            0 
Node 0, zone   Normal R 99            0            0          128            0            0 
Node 0, zone   Normal R100            0            0          128            0            0 
Node 0, zone   Normal R101            0            0          128            0            0 
Node 0, zone   Normal R102            0            0          128            0            0 
Node 0, zone   Normal R103            0            0          128            0            0 
Node 0, zone   Normal R104            0            0          128            0            0 
Node 0, zone   Normal R105            0            0          128            0            0 
Node 0, zone   Normal R106            0            0          128            0            0 
Node 0, zone   Normal R107            0            0          128            0            0 
Node 0, zone   Normal R108            0            0          128            0            0 
Node 0, zone   Normal R109            0            0          128            0            0 
Node 0, zone   Normal R110            0            0          128            0            0 
Node 0, zone   Normal R111            0            0          128            0            0 
Node 0, zone   Normal R112            0            0          128            0            0 
Node 0, zone   Normal R113            0            0          128            0            0 
Node 0, zone   Normal R114            0            0          128            0            0 
Node 0, zone   Normal R115            0            0          128            0            0 
Node 0, zone   Normal R116            0            0          128            0            0 
Node 0, zone   Normal R117            0            0          128            0            0 
Node 0, zone   Normal R118            0            0          128            0            0 
Node 0, zone   Normal R119            0            0          128            0            0 
Node 0, zone   Normal R120            0            0          128            0            0 
Node 0, zone   Normal R121            0            0          128            0            0 
Node 0, zone   Normal R122            0            0          128            0            0 
Node 0, zone   Normal R123            0            0          128            0            0 
Node 0, zone   Normal R124            0            0          128            0            0 



Performance impact:
------------------

Kernbench was run with and without the patchset. It shows an _improvement_ of
around 6.8% with the patchset applied. (Which is of course a little unexpected;
I'll dig more on that).

Vanilla kernel:

Average Optimal load -j 32 Run (std deviation):
Elapsed Time 687.140000
User Time 4528.030000
System Time 1382.140000
Percent CPU 860.000000
Context Switches 679060.000000
Sleeps 1343514.000000


With patchset:

Average Optimal load -j 32 Run (std deviation):
Elapsed Time 643.930000
User Time 4371.600000
System Time 985.900000
Percent CPU 831.000000
Context Switches 655479.000000
Sleeps 1360223.000000


Regards,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
