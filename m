Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7AD146B0005
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 13:59:52 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l4so70116903wml.0
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 10:59:52 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id mn4si40803251wjb.101.2016.08.10.10.59.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Aug 2016 10:59:51 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u7AHrqMh095336
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 13:59:49 -0400
Received: from e18.ny.us.ibm.com (e18.ny.us.ibm.com [129.33.205.208])
	by mx0a-001b2d01.pphosted.com with ESMTP id 24qm9r1n31-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 13:59:49 -0400
Received: from localhost
	by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Wed, 10 Aug 2016 13:59:48 -0400
Date: Wed, 10 Aug 2016 12:59:40 -0500
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: mm: Initialise per_cpu_nodestats for all online pgdats at boot
References: <20160804092404.GI2799@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20160804092404.GI2799@techsingularity.net>
Message-Id: <20160810175940.GA12039@arbab-laptop.austin.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Paul Mackerras <paulus@ozlabs.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org

On Thu, Aug 04, 2016 at 10:24:04AM +0100, Mel Gorman wrote:
>[    1.713998] Unable to handle kernel paging request for data at address 0xff7a10000
>[    1.714164] Faulting instruction address: 0xc000000000270cd0
>[    1.714304] Oops: Kernel access of bad area, sig: 11 [#1]
>[    1.714414] SMP NR_CPUS=2048 NUMA PowerNV
>[    1.714530] Modules linked in:
>[    1.714647] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.7.0-kvm+ #118
>[    1.714786] task: c000000ff0680010 task.stack: c000000ff0704000
>[    1.714926] NIP: c000000000270cd0 LR: c000000000270ce8 CTR: 0000000000000000
>[    1.715093] REGS: c000000ff0707900 TRAP: 0300   Not tainted  (4.7.0-kvm+)
>[    1.715232] MSR: 9000000102009033 <SF,HV,VEC,EE,ME,IR,DR,RI,LE,TM[E]>  CR: 846b6824  XER: 20000000
>[    1.715748] CFAR: c000000000008768 DAR: 0000000ff7a10000 DSISR: 42000000 SOFTE: 1
>GPR00: c000000000270d08 c000000ff0707b80 c0000000011fb200 0000000000000000
>GPR04: 0000000000000800 0000000000000000 0000000000000000 0000000000000000
>GPR08: ffffffffffffffff 0000000000000000 0000000ff7a10000 c00000000122aae0
>GPR12: c000000000a1e440 c00000000fb80000 c00000000000c188 0000000000000000
>GPR16: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
>GPR20: 0000000000000000 0000000000000000 0000000000000000 c000000000cecad0
>GPR24: c000000000d035b8 c000000000d6cd18 c000000000d6cd18 c000001fffa86300
>GPR28: 0000000000000000 c000001fffa96300 c000000001230034 c00000000122eb18
>[    1.717484] NIP [c000000000270cd0] refresh_zone_stat_thresholds+0x80/0x240
>[    1.717568] LR [c000000000270ce8] refresh_zone_stat_thresholds+0x98/0x240
>[    1.717648] Call Trace:
>[    1.717687] [c000000ff0707b80] [c000000000270d08] refresh_zone_stat_thresholds+0xb8/0x240 (unreliable)

I've been investigating node hotplug. That path is also going to require 
initialization of per_cpu_nodestats. This worked for me:

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 3894b65..41266dc 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1219,6 +1219,7 @@ static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
  
  	/* init node's zones as empty zones, we don't have any present pages.*/
  	free_area_init_node(nid, zones_size, start_pfn, zholes_size);
+	pgdat->per_cpu_nodestats = alloc_percpu(struct per_cpu_nodestat);
  
  	/*
  	 * The node we allocated has no zone fallback lists. For avoiding
@@ -1249,6 +1250,7 @@ static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
  static void rollback_node_hotadd(int nid, pg_data_t *pgdat)
  {
  	arch_refresh_nodedata(nid, NULL);
+	free_percpu(pgdat->per_cpu_nodestats);
  	arch_free_nodedata(pgdat);
  	return;
  }

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
