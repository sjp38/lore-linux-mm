Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 305FD6B0081
	for <linux-mm@kvack.org>; Sat, 26 May 2012 04:04:09 -0400 (EDT)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Sat, 26 May 2012 02:04:07 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id DF69519D8048
	for <linux-mm@kvack.org>; Sat, 26 May 2012 02:03:41 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4Q83s5e230878
	for <linux-mm@kvack.org>; Sat, 26 May 2012 02:03:54 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4Q83smU001587
	for <linux-mm@kvack.org>; Sat, 26 May 2012 02:03:54 -0600
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH] mm/numa: Fix kernel crash caused by offline node
Date: Sat, 26 May 2012 16:03:51 +0800
Message-Id: <1338019431-13556-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: hannes@cmpxchg.org, akpm@linux-foundation.org, Gavin Shan <shangw@linux.vnet.ibm.com>

I tried to boot the updated kernel (3.4.0+) on IBM power machine.
Unfortunately, I got kernel crash as follows. Then I traced it
down until I found sched/core.c::sched_init_numa tried to allocate
memory from the possible nodes. That doesn't make sense since the
possible nodes might never come in for ever.

Linux version 3.4.0+ (shangw@shangw) (gcc version 4.4.5 (crosstool-NG 1.13.0) ) #154 SMP Sat May 26 15:33:20 CST 2012
:
Unable to handle kernel paging request for data at address 0x00001388
Faulting instruction address: 0xc00000000017d44c
Oops: Kernel access of bad area, sig: 11 [#1]
SMP NR_CPUS=1024 NUMA PowerNV
Modules linked in:
NIP: c00000000017d44c LR: c00000000017d448 CTR: 000000002f805eb0
REGS: c0000007f22836d0 TRAP: 0300   Not tainted  (3.4.0+)
MSR: 9000000000009032 <SF,HV,EE,ME,IR,DR,RI>  CR: 28004082  XER: 00000000
SOFTE: 1
CFAR: c000000000005100
DAR: 0000000000001388, DSISR: 40000000
TASK = c0000007f21c0000[1] 'swapper/0' THREAD: c0000007f2280000 CPU: 0
GPR00: c00000000017d448 c0000007f2283950 c0000000014fa7a0 0000000000000000
GPR04: 0000000000000000 0000000000001380 0000000000000000 0000000000000003
GPR08: 0000000000000010 0000000000000000 000000000001c0bb 0000000000000000
GPR12: 0000000028004088 c00000000ff20000 0000000000000000 0000000000000000
GPR16: 0000000000000000 0000000042abf9f0 0000000000001380 0000000000000000
GPR20: 0000000000d6da70 0000000000000001 c0000007f2283c10 0000000000210d00
GPR24: 0000000000000001 0000000000000001 0000000000000000 0000000000000000
GPR28: 0000000000001380 0000000000000000 c0000000014228e8 00000000000012d0
NIP [c00000000017d44c] .__alloc_pages_nodemask+0xf4/0x88c
LR [c00000000017d448] .__alloc_pages_nodemask+0xf0/0x88c
Call Trace:
[c0000007f2283950] [c00000000017d448] .__alloc_pages_nodemask+0xf0/0x88c (unreliable)
[c0000007f2283af0] [c0000000001ce9dc] .new_slab+0x15c/0x438
[c0000007f2283ba0] [c0000000001cf220] .__slab_alloc+0x3a4/0x510
[c0000007f2283cd0] [c0000000001d0cbc] .kmem_cache_alloc_node_trace+0xbc/0x214
[c0000007f2283d90] [c000000000bf8c00] .sched_init_smp+0x1a8/0x4d4
[c0000007f2283ed0] [c000000000be0384] .kernel_init+0x154/0x2f8
[c0000007f2283f90] [c000000000021478] .kernel_thread+0x54/0x70
Instruction dump:
7bfa6fe2 78000fa4 7f5a0378 e93e8000 80090000 7c1ff838 7bff0020 57e806f7
f90100c8 4182000c 486e6539 60000000 <e81c0008> 3a000000 2fa00000 41de0728

The patch fixes it by allocating memory without node sense. It
should have some performance impact but I'm not sure how much
that will be.

Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
---
 kernel/sched/core.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index a5a9d39..62bd092 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -6406,7 +6406,8 @@ static void sched_init_numa(void)
 			return;
 
 		for (j = 0; j < nr_node_ids; j++) {
-			struct cpumask *mask = kzalloc_node(cpumask_size(), GFP_KERNEL, j);
+			struct cpumask *mask = kzalloc(cpumask_size(), GFP_KERNEL);
+
 			if (!mask)
 				return;
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
