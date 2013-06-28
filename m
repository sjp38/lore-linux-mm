Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 106D16B0037
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 09:55:43 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Fri, 28 Jun 2013 09:55:42 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 58DC9C90042
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 09:55:38 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5SDsUGL289486
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 09:54:30 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5SDsROO017758
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 10:54:30 -0300
Date: Fri, 28 Jun 2013 19:24:22 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/6] Basic scheduler support for automatic NUMA balancing
Message-ID: <20130628135422.GA21895@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <1372257487-9749-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1372257487-9749-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

* Mel Gorman <mgorman@suse.de> [2013-06-26 15:37:59]:

> It's several months overdue and everything was quiet after 3.8 came out
> but I recently had a chance to revisit automatic NUMA balancing for a few
> days. I looked at basic scheduler integration resulting in the following
> small series. Much of the following is heavily based on the numacore series
> which in itself takes part of the autonuma series from back in November. In
> particular it borrows heavily from Peter Ziljstra's work in "sched, numa,
> mm: Add adaptive NUMA affinity support" but deviates too much to preserve
> Signed-off-bys. As before, if the relevant authors are ok with it I'll
> add Signed-off-bys (or add them yourselves if you pick the patches up).


Here is a snapshot of the results of running autonuma-benchmark running on 8
node 64 cpu system with hyper threading disabled. Ran 5 iterations for each
setup

	KernelVersion: 3.9.0-mainline_v39+()
				Testcase:      Min      Max      Avg
				  numa01:  1784.16  1864.15  1800.16
				  numa02:    32.07    32.72    32.59

	KernelVersion: 3.9.0-mainline_v39+() + mel's patches
				Testcase:      Min      Max      Avg  %Change
				  numa01:  1752.48  1859.60  1785.60    0.82%
				  numa02:    47.21    60.58    53.43  -39.00%

So numa02 case; we see a degradation of around 39%.

Details below
-----------------------------------------------------------------------------------------

numa01
	KernelVersion: 3.9.0-mainline_v39+()
	 Performance counter stats for '/usr/bin/time -f %e %S %U %c %w -o start_bench.out -a ./numa01':
		   554,289 cs                                                           [100.00%]
		    26,727 migrations                                                   [100.00%]
		 1,982,054 faults                                                       [100.00%]
		     5,819 migrate:mm_migrate_pages                                    

	    1784.171745972 seconds time elapsed

	numa01 1784.16 352.58 68140.96 141242 4862

	KernelVersion: 3.9.0-mainline_v39+() + mel's patches
	 Performance counter stats for '/usr/bin/time -f %e %S %U %c %w -o start_bench.out -a ./numa01':

		 1,072,118 cs                                                           [100.00%]
		    43,796 migrations                                                   [100.00%]
		 5,226,896 faults                                                       [100.00%]
		     2,815 migrate:mm_migrate_pages                                    

	    1763.961631143 seconds time elapsed

	numa01 1763.95 321.62 78358.88 233740 2712


numa02
	KernelVersion: 3.9.0-mainline_v39+()

	 Performance counter stats for '/usr/bin/time -f %e %S %U %c %w -o start_bench.out -a ./numa02':

		    14,018 cs                                                           [100.00%]
		     1,209 migrations                                                   [100.00%]
		    40,847 faults                                                       [100.00%]
		       629 migrate:mm_migrate_pages                                    

	      32.729238004 seconds time elapsed

	numa02 32.72 51.25 1415.06 6013 111

	KernelVersion: 3.9.0-mainline_v39+() + mel's patches

	 Performance counter stats for '/usr/bin/time -f %e %S %U %c %w -o start_bench.out -a ./numa02':

		    35,891 cs                                                           [100.00%]
		     1,579 migrations                                                   [100.00%]
		   173,443 faults                                                       [100.00%]
		     1,106 migrate:mm_migrate_pages                                    

	      53.970814899 seconds time elapsed

	numa02 53.96 128.90 2301.90 9291 148

Notes:
In the numa01 case, we see a slight benefit + lesser system and user time.
We see more context switches and task migrations but lesser page migrations.


In the numa02 case, we see a larger degradation + higher system + higher user
time. We see more context switches and more page migrations too.

-- 
Thanks and Regards
Srikar Dronamraju

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
