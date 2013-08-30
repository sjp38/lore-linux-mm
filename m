Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 76AD66B0075
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 09:30:48 -0400 (EDT)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Fri, 30 Aug 2013 18:49:20 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 2FC983940061
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 19:00:28 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7UDWMx835979440
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 19:02:23 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r7UDUZaJ023881
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 19:00:36 +0530
Message-ID: <52209D95.10808@linux.vnet.ibm.com>
Date: Fri, 30 Aug 2013 18:56:45 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RESEND RFC PATCH v3 00/35] mm: Memory Power Management
References: <20130830131221.4947.99764.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130830131221.4947.99764.stgit@srivatsabhat.in.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, dave@sr71.net, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
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

Here are the results, with vanilla 3.11-rc7 and with this patchset applied:

                  Free regions at test-start   Free regions after test-run
Without patchset               242                         18
With patchset                  238                        121

This shows that this patchset performs tremendously better than vanilla
kernel in terms of keeping the memory allocations consolidated to a minimum
no. of memory regions. Note that the amount of memory consumed at the end of
the run is 0, so it shows the drastic extent to which the mainline kernel can
fragment memory by spreading a handful of pages across many memory regions.
And since this patchset teaches the kernel to understand the memory region
granularity/boundaries and influences the MM decisions effectively, it shows
a significant improvement over mainline. Also, this improvement is with the
allocator changes alone; targeted compaction (which was dropped in this
version) is expected to show even more benefits.

Below is the log of the variation of the no. of completely free regions
from the beginning to the end of the test, at 1 second intervals (total
test-run takes 1 minute).

         Vanilla 3.11-rc7         With this patchset
                242                     238
                242                     238
                242                     238
                242                     238
                242                     238
                239                     236
                221                     215
                196                     181
                171                     139
                144                     112
                117                     78
                69                      48
                49                      24
                27                      21
                15                      21
                15                      21
                15                      21
                15                      21
                15                      21
                15                      21
                15                      22
                15                      22
                15                      23
                15                      23
                15                      27
                15                      29
                15                      29
                15                      30
                15                      30
                15                      30
                15                      30
                15                      30
                15                      30
                15                      30
                15                      32
                15                      33
                15                      33
                15                      33
                15                      33
                15                      36
                15                      42
                15                      42
                15                      44
                15                      48
                16                      111
                17                      114
                17                      114
                17                      114
                17                      115
                17                      115
                17                      115
                17                      115
                17                      115
                17                      115
                17                      115
                17                      115
                17                      115
                17                      115
                17                      115
                17                      115
                17                      115
                17                      115
                17                      115
                17                      116
                17                      116
                17                      116
                17                      116
                17                      116
                17                      116
                17                      116
                17                      116
                17                      116
                17                      116
                17                      116
                17                      116
                18                      121


It is interesting to also examine the fragmentation of memory by
looking at the per-region statistics added by this patchset.

Statistics for vanilla 3.11-rc7 kernel:
======================================

We can see from the statistics that there is a lot of fragmentation
among the MOVABLE migratetype.

Node 0, zone   Normal
  pages free     15751188
        min      5575
        low      6968
        high     8362
        scanned  0
        spanned  16252928
        present  16252928
        managed  15989951

Per-region page stats	 present	 free

	Region      0 	      1 	   1024
	Region      1 	 131072 	 131072
	Region      2 	 131072 	 131072
	Region      3 	 131072 	 131072
	Region      4 	 131072 	 131072
	Region      5 	 131072 	 130045
	Region      6 	 131072 	 131032
	Region      7 	 131072 	 131023
	Region      8 	 131072 	 131022
	Region      9 	 131072 	 131062
	Region     10 	 131072 	 131055
	Region     11 	 131072 	 131064
	Region     12 	 131072 	 131047
	Region     13 	 131072 	 131051
	Region     14 	 131072 	 131056
	Region     15 	 131072 	 131046
	Region     16 	 131072 	 131051
	Region     17 	 131072 	 131061
	Region     18 	 131072 	 131030
	Region     19 	 131072 	 130168
	Region     20 	 131072 	 131937
	Region     21 	 131072 	 131067
	Region     22 	 131072 	 131028
	Region     23 	 131072 	 131051
	Region     24 	 131072 	 131041
	Region     25 	 131072 	 131047
	Region     26 	 131072 	 131051
	Region     27 	 131072 	 131054
	Region     28 	 131072 	 131049
	Region     29 	 131072 	 130994
	Region     30 	 131072 	 131059
	Region     31 	 131072 	 131060
	Region     32 	 131072 	 131051
	Region     33 	 131072 	 131047
	Region     34 	 131072 	 131050
	Region     35 	 131072 	 131050
	Region     36 	 131072 	 131039
	Region     37 	 131072 	 131053
	Region     38 	 131072 	 131045
	Region     39 	 131072 	 130275
	Region     40 	 131072 	 131807
	Region     41 	 131072 	 131050
	Region     42 	 131072 	 131051
	Region     43 	 131072 	 131037
	Region     44 	 131072 	 131052
	Region     45 	 131072 	 131011
	Region     46 	 131072 	 131026
	Region     47 	 131072 	 130285
	Region     48 	 131072 	 131810
	Region     49 	 131072 	 131046
	Region     50 	 131072 	 131049
	Region     51 	 131072 	 131054
	Region     52 	 131072 	 131064
	Region     53 	 131072 	 131053
	Region     54 	 131072 	 131019
	Region     55 	 131072 	 130997
	Region     56 	 131072 	 131039
	Region     57 	 131072 	 131058
	Region     58 	 131072 	 130182
	Region     59 	 131072 	 131057
	Region     60 	 131072 	 131063
	Region     61 	 131072 	 131046
	Region     62 	 131072 	 131055
	Region     63 	 131072 	 131060
	Region     64 	 131072 	 131049
	Region     65 	 131072 	 131042
	Region     66 	 131072 	 131048
	Region     67 	 131072 	 131052
	Region     68 	 131072 	 130997
	Region     69 	 131072 	 131046
	Region     70 	 131072 	 131045
	Region     71 	 131072 	 131028
	Region     72 	 131072 	 131054
	Region     73 	 131072 	 131048
	Region     74 	 131072 	 131052
	Region     75 	 131072 	 131043
	Region     76 	 131072 	 131052
	Region     77 	 131072 	 130542
	Region     78 	 131072 	 131556
	Region     79 	 131072 	 131048
	Region     80 	 131072 	 131043
	Region     81 	 131072 	 130548
	Region     82 	 131072 	 131551
	Region     83 	 131072 	 131019
	Region     84 	 131072 	 131033
	Region     85 	 131072 	 131047
	Region     86 	 131072 	 131059
	Region     87 	 131072 	 131054
	Region     88 	 131072 	 131043
	Region     89 	 131072 	 131035
	Region     90 	 131072 	 131044
	Region     91 	 131072 	 130538
	Region     92 	 131072 	 131560
	Region     93 	 131072 	 131063
	Region     94 	 131072 	 131033
	Region     95 	 131072 	 131046
	Region     96 	 131072 	 131048
	Region     97 	 131072 	 131049
	Region     98 	 131072 	 131058
	Region     99 	 131072 	 131048
	Region    100 	 131072 	 130484
	Region    101 	 131072 	 131557
	Region    102 	 131072 	 131038
	Region    103 	 131072 	 131044
	Region    104 	 131072 	 131040
	Region    105 	 131072 	 130988
	Region    106 	 131072 	 131039
	Region    107 	 131072 	 131009
	Region    108 	 131072 	 131059
	Region    109 	 131072 	 131049
	Region    110 	 131072 	 131050
	Region    111 	 131072 	 131042
	Region    112 	 131072 	 131052
	Region    113 	 131072 	 131053
	Region    114 	 131072 	 131067
	Region    115 	 131072 	 131062
	Region    116 	 131072 	 131072
	Region    117 	 131072 	 131072
	Region    118 	 131072 	 129860
	Region    119 	 131072 	 125402
	Region    120 	 131072 	  63109
	Region    121 	 131072 	  84301
	Region    122 	 131072 	  17009
	Region    123 	 131072 	      0
	Region    124 	 131071 	      0



Page block order: 10
Pages per block:  1024

Free pages count per migrate type at order       0      1      2      3      4      5      6      7      8      9     10 
Node    0, zone      DMA, type    Unmovable      1      2      2      1      3      2      0      0      1      1      0 
Node    0, zone      DMA, type  Reclaimable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone      DMA, type      Movable      0      0      0      0      0      0      0      0      0      0      2 
Node    0, zone      DMA, type      Reserve      0      0      0      0      0      0      0      0      0      0      1 
Node    0, zone      DMA, type      Isolate      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone    DMA32, type    Unmovable      0      1      0      0      0      0      1      1      1      1      0 
Node    0, zone    DMA32, type  Reclaimable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone    DMA32, type      Movable      8     10     12      8     10      8      8      6      5      7    436 
Node    0, zone    DMA32, type      Reserve      0      0      0      0      0      0      0      0      0      0      1 
Node    0, zone    DMA32, type      Isolate      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, type    Unmovable   8982   9711   5941   2108    611    189      9      0      1      1      0 
Node    0, zone   Normal, type  Reclaimable      0      0      0      0      1      0      0      1      0      0      0 
Node    0, zone   Normal, type      Movable   2349   4937   5264   3716   2323   1859   1689   1602   1412   1310  13826 
Node    0, zone   Normal, type      Reserve      0      0      0      0      0      0      0      0      0      0      2 
Node    0, zone   Normal, type      Isolate      0      0      0      0      0      0      0      0      0      0      0 

Node    0, zone   Normal, R  0      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R  1      Movable      0      0      0      0      0      0      0      0      0      0    127 
Node    0, zone   Normal, R  2      Movable      0      0      0      0      0      0      0      0      0      0    128 
Node    0, zone   Normal, R  3      Movable      0      0      0      0      0      0      0      0      0      0    128 
Node    0, zone   Normal, R  4      Movable      0      0      0      0      0      0      0      0      0      0    128 
Node    0, zone   Normal, R  5      Movable      3      3      3      3      3      3      3      3      3      3    124 
Node    0, zone   Normal, R  6      Movable     18     25     25     24     23     22     23     19     19     14    111 
Node    0, zone   Normal, R  7      Movable      7     16     18     16     12     13     14      8      7      9    119 
Node    0, zone   Normal, R  8      Movable     12     17     18     17     11     11     13     11     10     11    117 
Node    0, zone   Normal, R  9      Movable      6      6      7      7      5      6      6      6      6      6    122 
Node    0, zone   Normal, R 10      Movable      7     10     11     11     11     11     11     11     11      9    118 
Node    0, zone   Normal, R 11      Movable      8      8      8      8      8      8      8      8      6      7    121 
Node    0, zone   Normal, R 12      Movable      5      7     11     11     11     11     11     11     11     11    117 
Node    0, zone   Normal, R 13      Movable     15     18     18     18     18     18     18     18     18     12    113 
Node    0, zone   Normal, R 14      Movable      6      9     10      8      9      9      9      9      9      9    119 
Node    0, zone   Normal, R 15      Movable     10     12     15     15     13     14     12     13     13     13    115 
Node    0, zone   Normal, R 16      Movable      3      4      6      7      7      7      7      7      5      6    122 
Node    0, zone   Normal, R 17      Movable      1      4      5      5      5      5      5      5      5      5    123 
Node    0, zone   Normal, R 18      Movable     14     22     25     23     22     21     22     22     22     20    107 
Node    0, zone   Normal, R 19      Movable      6      7      7      7      7      7      7      8      7      7    120 
Node    0, zone   Normal, R 20      Movable      9     10     11     13     13     13     11     11     12     10    118 
Node    0, zone   Normal, R 21      Movable      3      4      4      4      4      4      2      3      3      3    125 
Node    0, zone   Normal, R 22      Movable      6     11     16     11     14     12     13     13     11     12    116 
Node    0, zone   Normal, R 23      Movable     11     14     15     15     15     15     15     15     13     14    114 
Node    0, zone   Normal, R 24      Movable      7     11     13     14     14     14     12     13     13     13    115 
Node    0, zone   Normal, R 25      Movable      7     12     12     13     11     12     12     12     12     12    116 
Node    0, zone   Normal, R 26      Movable      5      9     11     11     11     11     11     11      9     10    118 
Node    0, zone   Normal, R 27      Movable      8     13     13     13     11     10     11      9      8      9    119 
Node    0, zone   Normal, R 28      Movable     11     13     13     12     11     12     12     10      9      8    119 
Node    0, zone   Normal, R 29      Movable     20     27     28     27     26     24     22     22     19     17    109 
Node    0, zone   Normal, R 30      Movable      5      9      9      9      9      9      9      9      9      7    120 
Node    0, zone   Normal, R 31      Movable      6      7      6      7      7      7      7      7      7      5    122 
Node    0, zone   Normal, R 32      Movable      1      5      8      8      8      8      8      8      8      8    120 
Node    0, zone   Normal, R 33      Movable      5      9     10     11     11     11     11     11     11      9    118 
Node    0, zone   Normal, R 34      Movable      6      8      9     10      8      7      8      8      8      8    120 
Node    0, zone   Normal, R 35      Movable     14     18     16     17     17     15     16     16     14     13    114 
Node    0, zone   Normal, R 36      Movable     11     16     19     19     17     18     16     17     15     16    112 
Node    0, zone   Normal, R 37      Movable     15     17     17     17     17     17     17     17     15     14    113 
Node    0, zone   Normal, R 38      Movable      7     13     15     15     15     15     15     15     13     12    115 
Node    0, zone   Normal, R 39      Movable     11     18     19     19     17     16     17     15     15     11    114 
Node    0, zone   Normal, R 40      Movable     13     21     18     18     19     15     15     16     13     13    115 
Node    0, zone   Normal, R 41      Movable      4      7     10     10     10     10     10     10     10     10    118 
Node    0, zone   Normal, R 42      Movable     13     15     16     14     11     13     13     13     13     11    116 
Node    0, zone   Normal, R 43      Movable     13     16     16     18     18     18     18     18     14     16    112 
Node    0, zone   Normal, R 44      Movable     10     11     11     12     12     12     12     12     12     12    116 
Node    0, zone   Normal, R 45      Movable     13     19     20     22     21     22     20     21     17     15    111 
Node    0, zone   Normal, R 46      Movable     10     16     16     19     19     19     19     19     15     15    112 
Node    0, zone   Normal, R 47      Movable     11     15     15     13     14     14     14     14     13     11    115 
Node    0, zone   Normal, R 48      Movable      8     15     17     17     15     16     14     15     12     14    115 
Node    0, zone   Normal, R 49      Movable      8      9     11     12     12     12     12     10     11      9    118 
Node    0, zone   Normal, R 50      Movable      9     12     14     14     14     12     13     13     13     13    115 
Node    0, zone   Normal, R 51      Movable      8     11     12     12     12     12     12     12     10      7    119 
Node    0, zone   Normal, R 52      Movable      8      8      8      8      8      8      8      8      8      8    120 
Node    0, zone   Normal, R 53      Movable      9     12     13     13     13     13     13     13     13     11    116 
Node    0, zone   Normal, R 54      Movable     11     14     19     19     18     19     15     17     15     10    115 
Node    0, zone   Normal, R 55      Movable     13     14     15     16     17     16     17     17     15     16    112 
Node    0, zone   Normal, R 56      Movable      3      8     11     12     12     12     12     10      9     10    118 
Node    0, zone   Normal, R 57      Movable      4      9      9      7      8      8      8      8      8      8    120 
Node    0, zone   Normal, R 58      Movable      6      8      8      8      8      8      8      8      6      7    120 
Node    0, zone   Normal, R 59      Movable      7     11     11     11     11     11     11     11      9     10    118 
Node    0, zone   Normal, R 60      Movable      3      4      5      5      5      5      5      5      5      5    123 
Node    0, zone   Normal, R 61      Movable      8     15     16     14     13     14     14     12     13     11    116 
Node    0, zone   Normal, R 62      Movable      7     10     11     11     11     11     11     11     11     11    117 
Node    0, zone   Normal, R 63      Movable      4      4      6      6      6      6      6      6      6      4    123 
Node    0, zone   Normal, R 64      Movable      9     12     14     14     14     14     14     14     12     13    115 
Node    0, zone   Normal, R 65      Movable      6      8     11     12     12     12     12     12     10      9    118 
Node    0, zone   Normal, R 66      Movable     20     22     22     16     19     19     15     17     13     11    115 
Node    0, zone   Normal, R 67      Movable      4      8     10      8      7      8      8      8      8      6    121 
Node    0, zone   Normal, R 68      Movable     13     20     22     23     23     24     18     19     20     18    109 
Node    0, zone   Normal, R 69      Movable      4      9     10     11     11     11     11      9      8      9    119 
Node    0, zone   Normal, R 70      Movable      9     14     16     16     16     16     14     15     13     12    115 
Node    0, zone   Normal, R 71      Movable      8     18     22     22     22     22     20     21     17     17    110 
Node    0, zone   Normal, R 72      Movable      4      5      8      8      8      8      8      8      8      8    120 
Node    0, zone   Normal, R 73      Movable     18     21     21     21     17     17     18     18     18     16    111 
Node    0, zone   Normal, R 74      Movable      4      8     10     10     10     10     10     10     10      8    119 
Node    0, zone   Normal, R 75      Movable      9      9     12     13     13     13     13     13      9     11    117 
Node    0, zone   Normal, R 76      Movable     12     16     16     14     13     14     14     14      8      9    118 
Node    0, zone   Normal, R 77      Movable     14     14     15     15     15     15     15     15     13     15    113 
Node    0, zone   Normal, R 78      Movable      8     10     14     14     14     14     14     14     12     12    116 
Node    0, zone   Normal, R 79      Movable      8     10     13     13      9     11      9     10     10      6    120 
Node    0, zone   Normal, R 80      Movable     11     14     15     16     16     16     16     16     12     14    114 
Node    0, zone   Normal, R 81      Movable      4      8      8      8      8      8      8      8      8      9    119 
Node    0, zone   Normal, R 82      Movable     17     23     24     24     22     23     19     21     21     12    112 
Node    0, zone   Normal, R 83      Movable      5      7      8      9      9     10      6      8      8      6    121 
Node    0, zone   Normal, R 84      Movable     17     22     25     25     23     24     24     20     16     19    109 
Node    0, zone   Normal, R 85      Movable      9     15     16     16     16     16     16     16     10     11    116 
Node    0, zone   Normal, R 86      Movable      3      8      8      8      8      8      6      7      5      6    122 
Node    0, zone   Normal, R 87      Movable     10     12     13     13     11     10     11     11      7      9    119 
Node    0, zone   Normal, R 88      Movable     15     20     17     15     15     16     16     14      9     12    116 
Node    0, zone   Normal, R 89      Movable     15     18     20     21     21     19     20     20     16     18    110 
Node    0, zone   Normal, R 90      Movable      8     16     15     14     15     15     13     14     12     13    115 
Node    0, zone   Normal, R 91      Movable      6     10     10     11     11     11     11     11      9      7    119 
Node    0, zone   Normal, R 92      Movable     14     15     17     17     17     17     17     17     15     13    114 
Node    0, zone   Normal, R 93      Movable      5      5      6      6      6      6      6      6      6      6    122 
Node    0, zone   Normal, R 94      Movable     15     27     25     26     26     26     26     26     20     19    107 
Node    0, zone   Normal, R 95      Movable     12     15     17     17     15     16     14     13     14     10    116 
Node    0, zone   Normal, R 96      Movable     10     15     16     16     16     16     16     14     15     15    113 
Node    0, zone   Normal, R 97      Movable      5      8      9     10      8      9      9      9      9      7    120 
Node    0, zone   Normal, R 98      Movable      8     11     11     11     11     11     11      9     10     10    118 
Node    0, zone   Normal, R 99      Movable     10     13     15     15     15     15     15     15     15     11    115 
Node    0, zone   Normal, R100      Movable     32     42     48     44     44     45     39     40     23     25     99 
Node    0, zone   Normal, R101      Movable      9     14     16     16     14     15     15     15     15     14    114 
Node    0, zone   Normal, R102      Movable     18     24     25     23     22     23     21     22     18     18    109 
Node    0, zone   Normal, R103      Movable     12     16     18     16     15     14     15     15     11     13    115 
Node    0, zone   Normal, R104      Movable     14     17     20     20     20     20     20     20     20     18    109 
Node    0, zone   Normal, R105      Movable     16     24     35     32     32     33     31     30     25     26    101 
Node    0, zone   Normal, R106      Movable     11     18     20     20     20     20     18     19     19     15    111 
Node    0, zone   Normal, R107      Movable     11     29     33     33     33     33     33     33     25     25    101 
Node    0, zone   Normal, R108      Movable     13     13     13     13     13     13     13     13     13     13    115 
Node    0, zone   Normal, R109      Movable      3      5      9      9      9      9      9      9      9      9    119 
Node    0, zone   Normal, R110      Movable     12     15     16     16     16     16     16     16     10     13    115 
Node    0, zone   Normal, R111      Movable      8     13     16     16     16     16     16     14     15     11    115 
Node    0, zone   Normal, R112      Movable      6      9      5      4      4      5      5      5      3      2    125 
Node    0, zone   Normal, R113      Movable      1      2      2      2      3      1      2      2      2      2    126 
Node    0, zone   Normal, R114      Movable      1      3      3      3      3      3      3      3      1      2    126 
Node    0, zone   Normal, R115      Movable      4      5      4      5      5      5      5      5      5      5    123 
Node    0, zone   Normal, R116      Movable      0      0      0      0      0      0      0      0      0      0    128 
Node    0, zone   Normal, R117      Movable      0      0      0      0      0      0      0      0      0      0    128 
Node    0, zone   Normal, R118      Movable     10     33     34     22     18     17     14     14     14     11    114 
Node    0, zone   Normal, R119      Movable     36    117    163    146    143    138    126    102     85     66     39 
Node    0, zone   Normal, R120      Movable    366    963    961    572    191     57     35     19     19      5      5 
Node    0, zone   Normal, R121      Movable    802   2065   2211   1260    425    128     45     14      7      0      0 
Node    0, zone   Normal, R122      Movable    123    328    322    160     37      6      1      0      0      0      0 
Node    0, zone   Normal, R123      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R124      Movable      0      0      0      0      0      0      0      0      0      0      0 

Number of blocks type         Unmovable  Reclaimable      Movable      Reserve      Isolate 
Node 0, zone      DMA                 1            0            2            1            0 
Node 0, zone    DMA32                 1            0          506            1            0 
Node 0, zone   Normal               227           38        15605            2            0 

Node 0, zone      DMA R  0            1            0            2            1            0 
Node 0, zone    DMA32 R  0            0            0          124            1            0 
Node 0, zone    DMA32 R  1            0            0          128            0            0 
Node 0, zone    DMA32 R  2            0            0          128            0            0 
Node 0, zone    DMA32 R  3            1            0          127            0            0 
Node 0, zone    DMA32 R  4            0            0            0            0            0 
Node 0, zone    DMA32 R  5            0            0            0            0            0 
Node 0, zone    DMA32 R  6            0            0            0            0            0 
Node 0, zone    DMA32 R  7            0            0            0            0            0 
Node 0, zone   Normal R  0            0            0            0            1            0 
Node 0, zone   Normal R  1            0            0          126            2            0 
Node 0, zone   Normal R  2            0            0          128            0            0 
Node 0, zone   Normal R  3            0            0          128            0            0 
Node 0, zone   Normal R  4            0            0          128            0            0 
Node 0, zone   Normal R  5            0            1          127            0            0 
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
Node 0, zone   Normal R 58            0            1          127            0            0 
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
Node 0, zone   Normal R118            0            1          127            0            0 
Node 0, zone   Normal R119            0            4          124            0            0 
Node 0, zone   Normal R120           62           18           48            0            0 
Node 0, zone   Normal R121           63            1           64            0            0 
Node 0, zone   Normal R122          102           12           14            0            0 
Node 0, zone   Normal R123            0            0          128            0            0 
Node 0, zone   Normal R124            0            0          128            0            0 


Statistics with this patchset applied:
=====================================

Comparing these statistics with that of vanilla kernel, we see that the
fragmentation is significantly lesser, as seen in the MOVABLE migratetype.

Node 0, zone   Normal
  pages free     15731928
        min      5575
        low      6968
        high     8362
        scanned  0
        spanned  16252928
        present  16252928
        managed  15989885

Per-region page stats	 present	 free

	Region      0 	      1 	   1024
	Region      1 	 131072 	  11137
	Region      2 	 131072 	  83876
	Region      3 	 131072 	  72134
	Region      4 	 131072 	 116194
	Region      5 	 131072 	 116393
	Region      6 	 131072 	 130746
	Region      7 	 131072 	 131040
	Region      8 	 131072 	 131072
	Region      9 	 131072 	 131072
	Region     10 	 131072 	 131072
	Region     11 	 131072 	 131035
	Region     12 	 131072 	 131072
	Region     13 	 131072 	 130112
	Region     14 	 131072 	 131976
	Region     15 	 131072 	 131061
	Region     16 	 131072 	 131038
	Region     17 	 131072 	 131045
	Region     18 	 131072 	 131039
	Region     19 	 131072 	 131029
	Region     20 	 131072 	 131072
	Region     21 	 131072 	 131051
	Region     22 	 131072 	 131066
	Region     23 	 131072 	 131070
	Region     24 	 131072 	 131069
	Region     25 	 131072 	 131032
	Region     26 	 131072 	 131040
	Region     27 	 131072 	 131072
	Region     28 	 131072 	 131069
	Region     29 	 131072 	 131056
	Region     30 	 131072 	 131045
	Region     31 	 131072 	 131070
	Region     32 	 131072 	 131055
	Region     33 	 131072 	 131053
	Region     34 	 131072 	 131042
	Region     35 	 131072 	 131065
	Region     36 	 131072 	 130987
	Region     37 	 131072 	 131072
	Region     38 	 131072 	 131068
	Region     39 	 131072 	 131014
	Region     40 	 131072 	 131044
	Region     41 	 131072 	 131067
	Region     42 	 131072 	 131071
	Region     43 	 131072 	 131045
	Region     44 	 131072 	 131072
	Region     45 	 131072 	 131068
	Region     46 	 131072 	 131038
	Region     47 	 131072 	 131069
	Region     48 	 131072 	 131072
	Region     49 	 131072 	 131070
	Region     50 	 131072 	 131054
	Region     51 	 131072 	 131064
	Region     52 	 131072 	 131072
	Region     53 	 131072 	 131042
	Region     54 	 131072 	 131041
	Region     55 	 131072 	 131072
	Region     56 	 131072 	 131066
	Region     57 	 131072 	 131072
	Region     58 	 131072 	 131072
	Region     59 	 131072 	 131068
	Region     60 	 131072 	 131057
	Region     61 	 131072 	 131072
	Region     62 	 131072 	 131041
	Region     63 	 131072 	 131046
	Region     64 	 131072 	 131053
	Region     65 	 131072 	 131072
	Region     66 	 131072 	 131072
	Region     67 	 131072 	 131072
	Region     68 	 131072 	 131067
	Region     69 	 131072 	 131041
	Region     70 	 131072 	 131071
	Region     71 	 131072 	 131052
	Region     72 	 131072 	 131071
	Region     73 	 131072 	 131072
	Region     74 	 131072 	 131066
	Region     75 	 131072 	 131072
	Region     76 	 131072 	 131072
	Region     77 	 131072 	 131065
	Region     78 	 131072 	 131067
	Region     79 	 131072 	 131072
	Region     80 	 131072 	 131071
	Region     81 	 131072 	 131056
	Region     82 	 131072 	 131072
	Region     83 	 131072 	 131072
	Region     84 	 131072 	 131072
	Region     85 	 131072 	 131072
	Region     86 	 131072 	 131062
	Region     87 	 131072 	 131072
	Region     88 	 131072 	 131067
	Region     89 	 131072 	 131057
	Region     90 	 131072 	 131072
	Region     91 	 131072 	 131026
	Region     92 	 131072 	 131072
	Region     93 	 131072 	 131067
	Region     94 	 131072 	 131057
	Region     95 	 131072 	 131072
	Region     96 	 131072 	 131072
	Region     97 	 131072 	 131072
	Region     98 	 131072 	 131072
	Region     99 	 131072 	 131037
	Region    100 	 131072 	 131072
	Region    101 	 131072 	 131072
	Region    102 	 131072 	 131071
	Region    103 	 131072 	 131072
	Region    104 	 131072 	 131072
	Region    105 	 131072 	 131072
	Region    106 	 131072 	 131072
	Region    107 	 131072 	 131072
	Region    108 	 131072 	 131072
	Region    109 	 131072 	 131072
	Region    110 	 131072 	 131072
	Region    111 	 131072 	 131056
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
	Region    122 	 131072 	 128263
	Region    123 	 131072 	      0
	Region    124 	 131071 	     53

Page block order: 10
Pages per block:  1024

Free pages count per migrate type at order       0      1      2      3      4      5      6      7      8      9     10 
Node    0, zone      DMA, type    Unmovable      1      2      2      1      3      2      0      0      1      1      0 
Node    0, zone      DMA, type  Reclaimable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone      DMA, type      Movable      0      0      0      0      0      0      0      0      0      0      2 
Node    0, zone      DMA, type      Reserve      0      0      0      0      0      0      0      0      0      0      1 
Node    0, zone      DMA, type      Isolate      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone    DMA32, type    Unmovable      0      1      0      0      0      0      1      1      1      1    127 
Node    0, zone    DMA32, type  Reclaimable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone    DMA32, type      Movable      9     10     12      8     10      8      8      6      5      7    309 
Node    0, zone    DMA32, type      Reserve      0      0      0      0      0      0      0      0      0      0      1 
Node    0, zone    DMA32, type      Isolate      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, type    Unmovable  10879   9467   6585   2559   1859    630     81      7      1      2    108 
Node    0, zone   Normal, type  Reclaimable      1      1      1      1      0      1      0      1      0      0     81 
Node    0, zone   Normal, type      Movable    690   3282   4967   2628   1209    810    677    554    468    375   8006 
Node    0, zone   Normal, type      Reserve      0      0      0      0      0      0      0      0      0      0      2 
Node    0, zone   Normal, type      Isolate      0      0      0      0      0      0      0      0      0      0      0 

Node    0, zone   Normal, R  0      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R  1      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R  2      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R  3      Movable     50   2600   4277   1986    588    193     90     42     18      1      1 
Node    0, zone   Normal, R  4      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R  5      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R  6      Movable     52     65     71     57     60     57     51     45     39     29     91 
Node    0, zone   Normal, R  7      Movable      2      1      3      2      2      1      2      2      2      2    126 
Node    0, zone   Normal, R  8      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R  9      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 10      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 11      Movable      5      7      8      5      6      7      7      3      3      4    124 
Node    0, zone   Normal, R 12      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 13      Movable      0      0      0      0      0      0      1      0      0      0    127 
Node    0, zone   Normal, R 14      Movable     24     26     29     29     26     28     27     28     24     18    107 
Node    0, zone   Normal, R 15      Movable      9     10     10      8      7      6      7      7      7      7    121 
Node    0, zone   Normal, R 16      Movable      8     13     15     16     14     13     14     14     14     10    116 
Node    0, zone   Normal, R 17      Movable     11     17     14     14     15     15     15     13     12     13    115 
Node    0, zone   Normal, R 18      Movable      9      7      8      5      4      6      6      4      3      4    124 
Node    0, zone   Normal, R 19      Movable      9      8      9      9     11     11      9     10      8      7    120 
Node    0, zone   Normal, R 20      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 21      Movable     13      9     11     10     11      9     10     10     10      8    119 
Node    0, zone   Normal, R 22      Movable      6      6      6      6      6      6      6      6      6      6    122 
Node    0, zone   Normal, R 23      Movable      2      2      2      2      2      2      2      2      2      2    126 
Node    0, zone   Normal, R 24      Movable      3      3      3      3      3      3      3      3      3      3    125 
Node    0, zone   Normal, R 25      Movable     10     11     14     12     12     13     11     12      8      6    120 
Node    0, zone   Normal, R 26      Movable     12     10     16     16     16     16     16     16     16     14    113 
Node    0, zone   Normal, R 27      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 28      Movable      1      0      1      1      1      1      1      1      1      1    127 
Node    0, zone   Normal, R 29      Movable      0      0      0      2      2      2      2      2      2      2    126 
Node    0, zone   Normal, R 30      Movable      1      2      2      3      2      1      2      2      2      0    127 
Node    0, zone   Normal, R 31      Movable      2      2      2      2      2      2      2      2      2      2    126 
Node    0, zone   Normal, R 32      Movable      1      3      2      2      1      2      2      2      2      2    126 
Node    0, zone   Normal, R 33      Movable      3      3      3      3      4      4      4      4      4      4    124 
Node    0, zone   Normal, R 34      Movable      2      2      1      3      2      3      1      2      2      2    126 
Node    0, zone   Normal, R 35      Movable      3      3      4      4      4      4      4      4      4      4    124 
Node    0, zone   Normal, R 36      Movable      3     32     32     35     35     35     35     33     32     23    100 
Node    0, zone   Normal, R 37      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 38      Movable      2      1      2      0      1      1      1      1      1      1    127 
Node    0, zone   Normal, R 39      Movable      4      3      3      2      4      3      2      3      3      1    126 
Node    0, zone   Normal, R 40      Movable      0      4      7      8      8      8      8      8      4      6    122 
Node    0, zone   Normal, R 41      Movable      1      1      2      2      2      2      2      2      2      2    126 
Node    0, zone   Normal, R 42      Movable      1      1      1      1      1      1      1      1      1      1    127 
Node    0, zone   Normal, R 43      Movable      3     13     12     11     12     12     12     12     10      7    119 
Node    0, zone   Normal, R 44      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 45      Movable      4      4      4      4      4      4      4      4      2      3    125 
Node    0, zone   Normal, R 46      Movable      8     13     15     16     16     16     16     16     14     15    113 
Node    0, zone   Normal, R 47      Movable      1      2      2      2      2      2      2      2      2      2    126 
Node    0, zone   Normal, R 48      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 49      Movable      2      2      2      2      2      2      2      2      2      2    126 
Node    0, zone   Normal, R 50      Movable      2      2      6      6      6      6      6      6      6      6    122 
Node    0, zone   Normal, R 51      Movable      2      1      1      0      1      1      1      1      1      1    127 
Node    0, zone   Normal, R 52      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 53      Movable      4      3      4      7      5      6      6      6      4      5    123 
Node    0, zone   Normal, R 54      Movable      3      3      4      1      2      3      3      3      3      3    125 
Node    0, zone   Normal, R 55      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 56      Movable      6      6      4      5      5      5      5      3      4      4    124 
Node    0, zone   Normal, R 57      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 58      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 59      Movable      0      0      1      1      1      1      1      1      1      1    127 
Node    0, zone   Normal, R 60      Movable      1      8      8      8      8      8      8      8      8      8    120 
Node    0, zone   Normal, R 61      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 62      Movable      1      0      0      0      2      2      2      2      0      1    127 
Node    0, zone   Normal, R 63      Movable      2     14     14     14     14     14     14     14     14     14    114 
Node    0, zone   Normal, R 64      Movable      5     12     12     10     11     11     11      9     10      8    119 
Node    0, zone   Normal, R 65      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 66      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 67      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 68      Movable      1      1      0      1      1      1      1      1      1      1    127 
Node    0, zone   Normal, R 69      Movable      3      3      4      5      2      4      4      4      4      2    125 
Node    0, zone   Normal, R 70      Movable      1      1      1      1      1      1      1      1      1      1    127 
Node    0, zone   Normal, R 71      Movable      0      2      6      6      6      6      6      6      6      6    122 
Node    0, zone   Normal, R 72      Movable      1      1      1      1      1      1      1      1      1      1    127 
Node    0, zone   Normal, R 73      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 74      Movable      2      2      1      2      2      2      2      2      2      2    126 
Node    0, zone   Normal, R 75      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 76      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 77      Movable      3      3      4      4      4      4      4      4      4      4    124 
Node    0, zone   Normal, R 78      Movable      1      1      0      1      1      1      1      1      1      1    127 
Node    0, zone   Normal, R 79      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 80      Movable      1      1      1      1      1      1      1      1      1      1    127 
Node    0, zone   Normal, R 81      Movable     16     16     16     16     16     16     16     16     16     16    112 
Node    0, zone   Normal, R 82      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 83      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 84      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 85      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 86      Movable      2      2      0      2      2      2      2      2      2      0    127 
Node    0, zone   Normal, R 87      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 88      Movable      1      1      2      0      1      1      1      1      1      1    127 
Node    0, zone   Normal, R 89      Movable      1      0      0      2      0      1      1      1      1      1    127 
Node    0, zone   Normal, R 90      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 91      Movable      2      6      5      4      5      6      6      4      5      5    123 
Node    0, zone   Normal, R 92      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 93      Movable      1      1      0      1      1      1      1      1      1      1    127 
Node    0, zone   Normal, R 94      Movable      1      2      1      1      2      2      2      0      1      1    127 
Node    0, zone   Normal, R 95      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 96      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 97      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 98      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R 99      Movable      5      4      4      4      4      5      5      5      5      5    123 
Node    0, zone   Normal, R100      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R101      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R102      Movable      1      1      1      1      1      1      1      1      1      1    127 
Node    0, zone   Normal, R103      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R104      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R105      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R106      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R107      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R108      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R109      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R110      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R111      Movable      2      1      1      1      2      2      2      2      2      0    127 
Node    0, zone   Normal, R112      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R113      Movable      0      0      0      0      0      0      0      0      0      0    128 
Node    0, zone   Normal, R114      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R115      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R116      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R117      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R118      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R119      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R120      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R121      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R122      Movable    351    298    271    239    212    203    182    127     94     60     31 
Node    0, zone   Normal, R123      Movable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, R124      Movable      1      0      1      0      1      1      0      0      0      0      0 

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

Kernbench was run with and without the patchset. It shows an overhead of
around 7.8% with the patchset applied.

Vanilla kernel:

Average Optimal load -j 32 Run (std deviation):
Elapsed Time 706.760000
User Time 4536.670000
System Time 1526.610000
Percent CPU 857.000000
Context Switches 2229643.000000
Sleeps 2211767.000000

With patchset:

Average Optimal load -j 32 Run (std deviation):
Elapsed Time 761.010000
User Time 4605.450000
System Time 1535.870000
Percent CPU 806.000000
Context Switches 2247690.000000
Sleeps 2213503.000000

This version (v3) of the patchset focussed more on improving the consolidation
ratio and less on the performance impact. There is plenty of room for
performance optimization, and I'll work on that in future versions.

Regards,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
