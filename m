Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 24F4B6B00AE
	for <linux-mm@kvack.org>; Tue, 25 Mar 2014 02:50:31 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id r10so41590pdi.7
        for <linux-mm@kvack.org>; Mon, 24 Mar 2014 23:50:30 -0700 (PDT)
Received: from e28smtp05.in.ibm.com (e28smtp05.in.ibm.com. [122.248.162.5])
        by mx.google.com with ESMTPS id m9si10858416pab.454.2014.03.24.23.50.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 24 Mar 2014 23:50:29 -0700 (PDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <maddy@linux.vnet.ibm.com>;
	Tue, 25 Mar 2014 12:20:25 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id CC2103940048
	for <linux-mm@kvack.org>; Tue, 25 Mar 2014 12:20:21 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s2P6o81Z3342834
	for <linux-mm@kvack.org>; Tue, 25 Mar 2014 12:20:08 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s2P6oK2l016380
	for <linux-mm@kvack.org>; Tue, 25 Mar 2014 12:20:21 +0530
From: Madhavan Srinivasan <maddy@linux.vnet.ibm.com>
Subject: [PATCH 0/1] mm: FAULT_AROUND_ORDER patchset performance data for powerpc
Date: Tue, 25 Mar 2014 12:20:14 +0530
Message-Id: <1395730215-11604-1-git-send-email-maddy@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, kirill.shutemov@linux.intel.com, rusty@rustcorp.com.au, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, ak@linux.intel.com, peterz@infradead.org, mingo@kernel.org, Madhavan Srinivasan <maddy@linux.vnet.ibm.com>

Performance data for different FAULT_AROUND_ORDER values from 4 socket
Power7 system (128 Threads and 128GB memory) is below.  Fault around order (FAO)
value of 3 looks more advantageous.

FAULT_AROUND_ORDER      Baseline        1               3               4		5               7

Linux build (make -j64)
minor-faults		7184385		5874015		4567289		4318518		4193815		4159193
times in seconds	61.433776136	60.865935292	59.245368038	60.630675011	60.56587624	59.828271924

Linux rebuild (make -j64)
minor-faults		303018		226392		146170		132480		126878		126236
times in seconds	5.659819172	5.723996942	5.591238319	5.622533357	5.878811995	5.550133096

Two synthetic tests: access every word in file in sequential/random order.
Marginal Performance gains seen for FAO value of 3 when compared to value
of 4.

Sequential access 16GiB file
FAULT_AROUND_ORDER      Baseline        1               3               4		5               7
1 thread
       minor-faults	262302		131192		32873		16486		8291		2351
       times in seconds	53.071497352	52.945826882	52.931417302	52.928577184	52.859285439	53.116800539
8 threads
       minor-faults	2097314		1051046		263336		131715		66098		16653
       times in seconds	54.385698561	54.603652339	54.771282004	54.488565674	54.496701531	54.962142189
32 threads
       minor-faults	8389267		4218595		1059961		531319		266463		67271
       times in seconds	60.61715047	60.827964038	60.46412673	60.266045885	60.492398315	60.24531921
64 threads
       minor-faults	16777455	8485998		2178582		1092106		544302		137693
       times in seconds	86.471334554	84.412415735	85.208303832	84.331473392	85.598793479	84.695469266
128 threads
       minor-faults	33555267	17734522	4710107		2380821		1182707		292077
       times in seconds	117.535385569	114.291359037	112.593908276	113.081807611	114.358686588	114.491043011

Random access 1GiB file
FAULT_AROUND_ORDER      Baseline        1               3               4		5               7
1 thread
       minor-faults	16503		8664		2149		1126		610		437
       times in seconds	43.843573808	48.042069805	50.580779682	54.282884593	52.641739876	51.803302129
8 threads
       minor-faults	131201		70916		17760		8665		4250		1149
       times in seconds	46.262626804	55.942851041	56.629191584	57.97044714	55.417557594	56.019709166
32 threads
       minor-faults	524959		265980		67282		33601		16930		4316
       times in seconds	67.754175928	69.85012331	71.750338061	71.053074643	68.90728294	71.250103217
64 threads
       minor-faults	1048831		528829		133256		66700		33428		8776
       times in seconds	96.674025305	93.109961822	87.441777715	91.986332028	88.686748472	93.101434306
128 threads
       minor-faults	2098043		1053224		266271		133702		66966		17276
       times in seconds	156.525792044	152.117971403	147.523673243	148.560226602	148.596575663	149.389288429

Worst case scenario: we touch one page every 16M to demonstrate overhead.

Touch only one page in page table in 16GiB file
FAULT_AROUND_ORDER      Baseline        1               3               4		5               7
1 thread
       minor-faults	1077		1064		1051		1048		1046		1045
       times in seconds	0.00615347	0.008327379	0.019775282	0.034444003	0.05905971	0.220863339
8 threads
       minor-faults	8252		8239		8226		8223		8220		8224
       times in seconds	0.04387392	0.059859294	0.113897648	0.199707764	0.361585762	1.343366843
32 threads
       minor-faults	32852		32841		32825		32826		32824		32828
       times in seconds	0.191404544	0.21907773	0.433207123	0.72430447	1.334983196	4.97727449
64 threads
       minor-faults	65652		65642		65629		65622		65623		65634
       times in seconds	0.402140429	0.510806718	0.854288645	1.412329805	2.556707704	8.711074863
128 threads
       minor-faults	131255		131239		131228		131228		131229		131243
       times in seconds	0.817782148	1.124631348	2.023730928	3.184792382	5.331392072	17.309524609

Madhavan Srinivasan (1):
  mm: move FAULT_AROUND_ORDER to arch/

 arch/powerpc/include/asm/pgtable.h |    6 ++++++
 arch/x86/include/asm/pgtable.h     |    5 +++++
 include/asm-generic/pgtable.h      |   10 ++++++++++
 mm/memory.c                        |    2 --
 4 files changed, 21 insertions(+), 2 deletions(-)

-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
