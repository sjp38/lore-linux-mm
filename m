Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 26DA26B0031
	for <linux-mm@kvack.org>; Tue, 16 Jul 2013 11:11:47 -0400 (EDT)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Tue, 16 Jul 2013 15:11:46 -0000
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 505A81FF0050
	for <linux-mm@kvack.org>; Tue, 16 Jul 2013 09:04:59 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6GFAHG0230524
	for <linux-mm@kvack.org>; Tue, 16 Jul 2013 09:10:17 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6GFAEqb004940
	for <linux-mm@kvack.org>; Tue, 16 Jul 2013 09:10:15 -0600
Date: Tue, 16 Jul 2013 20:40:06 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/18] Basic scheduler support for automatic NUMA
 balancing V5
Message-ID: <20130716151006.GA13058@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1373901620-2021-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>



Summary:
Seeing improvement on a 2 node when running autonumabenchmark .
But seeing regression for specjbb for the same box.

Also seeing huge regression when running autonumabenchmark
both on 4 node and 8 node box.


Below is the autonuma benchmark results on a 2 node machine.
Autonuma benchmark results.
mainline v3.9: (Ht enabled)
	Testcase:      Min      Max      Avg   StdDev
	  numa01:   220.12   246.96   239.18     9.69
	  numa02:    41.85    43.02    42.43     0.47
v3.9 + Mel's v5 patches:A (Ht enabled)
	Testcase:      Min      Max      Avg   StdDev  %Change
	  numa01:   239.52   242.99   241.61     1.26   -1.00%
	  numa02:    37.94    38.12    38.05     0.06   11.49%

mainline v3.9:
	Testcase:      Min      Max      Avg   StdDev
	  numa01:   118.72   121.04   120.23     0.83
	  numa02:    36.64    37.56    36.99     0.34
v3.9 + Mel's v5 patches:
	Testcase:      Min      Max      Avg   StdDev  %Change
	  numa01:   111.34   122.28   118.61     3.77    1.32%
	  numa02:    36.23    37.27    36.55     0.37    1.18%

Here are results of specjbb run on a 2 node machine.
Specjbb was run on 3 vms.
In the fit case, one vm was big to fit one node size.
In the no-fit case, one vm was bigger than the node size.


Specjbb results.
---------------------------------------------------------------------------------------
|               |   vm|                          nofit|                            fit|
|               |   vm|          noksm|            ksm|          noksm|            ksm|
|               |   vm|  nothp|    thp|  nothp|    thp|  nothp|    thp|  nothp|    thp|
---------------------------------------------------------------------------------------
| mainline_v39+ | vm_1| 136056| 189423| 135359| 186722| 136983| 191669| 136728| 184253|
| mainline_v39+ | vm_2|  66041|  84779|  64564|  86645|  67426|  84427|  63657|  85043|
| mainline_v39+ | vm_3|  67322|  83301|  63731|  85394|  65015|  85156|  63838|  84199|
| mel_numa_balan| vm_1| 133170| 177883| 136385| 176716| 140650| 174535| 132811| 190120|
| mel_numa_balan| vm_2|  65021|  81707|  62876|  81826|  63635|  84943|  58313|  78997|
| mel_numa_balan| vm_3|  61915|  82198|  60106|  81723|  64222|  81123|  59559|  78299|
| change  %     | vm_1|  -2.12|  -6.09|   0.76|  -5.36|   2.68|  -8.94|  -2.86|   3.18|
| change  %     | vm_2|  -1.54|  -3.62|  -2.61|  -5.56|  -5.62|   0.61|  -8.39|  -7.11|
| change  %     | vm_3|  -8.03|  -1.32|  -5.69|  -4.30|  -1.22|  -4.74|  -6.70|  -7.01|
---------------------------------------------------------------------------------------

numactl o/p

available: 2 nodes (0-1)
node 0 cpus: 0 1 2 3 4 5 12 13 14 15 16 17
node 0 size: 12276 MB
node 0 free: 10574 MB
node 1 cpus: 6 7 8 9 10 11 18 19 20 21 22 23
node 1 size: 12288 MB
node 1 free: 9697 MB
node distances:
node   0   1 
  0:  10  21 
  1:  21  10 


Autonuma results on a 4 node machine.

KernelVersion: 3.9.0(HT)
	Testcase:      Min      Max      Avg   StdDev
	  numa01:   569.80   624.94   593.12    19.14
	  numa02:    18.65    21.32    19.69     0.98

KernelVersion: 3.9.0 + Mel's v5 patches(HT)
	Testcase:      Min      Max      Avg   StdDev  %Change
	  numa01:   718.83   750.46   740.10    11.42  -19.59%
	  numa02:    20.07    22.36    20.97     0.81   -5.72%

KernelVersion: 3.9.0()
	Testcase:      Min      Max      Avg   StdDev
	  numa01:   586.75   628.65   604.15    16.13
	  numa02:    19.67    20.49    19.93     0.29

KernelVersion: 3.9.0 + Mel's v5 patches
	Testcase:      Min      Max      Avg   StdDev  %Change
	  numa01:   741.48   759.37   747.23     6.36  -18.84%
	  numa02:    20.55    22.06    21.21     0.52   -5.80%



	System x3750 M4 -[8722C1A]-

numactl o/p
available: 4 nodes (0-3)
node 0 cpus: 0 1 2 3 4 5 6 7 32 33 34 35 36 37 38 39
node 0 size: 65468 MB
node 0 free: 63069 MB
node 1 cpus: 8 9 10 11 12 13 14 15 40 41 42 43 44 45 46 47
node 1 size: 65536 MB
node 1 free: 63497 MB
node 2 cpus: 16 17 18 19 20 21 22 23 48 49 50 51 52 53 54 55
node 2 size: 65536 MB
node 2 free: 63515 MB
node 3 cpus: 24 25 26 27 28 29 30 31 56 57 58 59 60 61 62 63
node 3 size: 65536 MB
node 3 free: 63659 MB
node distances:
node   0   1   2   3 
  0:  10  11  11  12 
  1:  11  10  12  11 
  2:  11  12  10  11 
  3:  12  11  11  10 

The results on the 8 node also look similar to 4 node.
-- 
Thanks and Regards
Srikar Dronamraju

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
