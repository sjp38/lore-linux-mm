Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8FF8D6B000E
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 11:32:11 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id w138-v6so1018437wmw.4
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 08:32:11 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id s5-v6si3552300wre.25.2018.06.29.08.32.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 08:32:10 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w5TFTMK8033305
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 11:32:08 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2jwppe2bn1-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 11:32:07 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 29 Jun 2018 16:32:05 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: Issue fixed by commit 53a59fc67f97 is surfacing again..
Date: Fri, 29 Jun 2018 17:32:00 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <11416e51-08b5-11ec-a2c8-9078c386d895@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

Hi,

The commit 53a59fc67f97 (mm: limit mmu_gather batching to fix soft lockups on
!CONFIG_PREEMPT) fixed soft lockup displayed when large processes exited.

Today on a large system, we are seeing it again :

NMI watchdog: BUG: soft lockup - CPU#1015 stuck for 21s! [forkoff:182534]
Modules linked in: nfsv3 nfs_acl rpcsec_gss_krb5 auth_rpcgss nfsv4 dns_resolver
nfs lockd grace sunrpc fscache af_packet ip_set nfnetlink bridge stp llc
libcrc32c x_tables dm_mod ghash_generic gf128mul vmx_crypto rtc_generic tg3 ses
enclosure scsi_transport_sas ptp pps_core libphy btrfs xor raid6_pq sd_mod
crc32c_vpmsum ipr(X) libata sg scsi_mod autofs4 [last unloaded: ip_tables]
Supported: Yes, External
CPU: 1015 PID: 182534 Comm: forkoff Tainted: G
4.12.14-23-default #1 SLE15
task: c00001f262efcb00 task.stack: c00001f264688000
NIP: c0000000000164c4 LR: c0000000000164c4 CTR: 000000000000aa18
REGS: c00001f26468b570 TRAP: 0901   Tainted: G
(4.12.14-23-default)
MSR: 800000010280b033 <SF,VEC,VSX,EE,FP,ME,IR,DR,RI,LE,TM[E]>
  CR: 42042824  XER: 00000000
CFAR: c00000000099829c SOFTE: 1
GPR00: c0000000002d43b8 c00001f26468b7f0 c00000000116a900 0000000000000900
GPR04: c00014fb0fff6410 f0000005075aa860 0000000000000008 0000000000000000
GPR08: c000000007d39d00 00000000800003d8 00000000800003f7 000014fa8e880000
GPR12: 0000000000002200 c000000007d39d00
NIP [c0000000000164c4] arch_local_irq_restore+0x74/0x90
LR [c0000000000164c4] arch_local_irq_restore+0x74/0x90
Call Trace:
[c00001f26468b7f0] [f0000005075a9500] 0xf0000005075a9500 (unreliable)
[c00001f26468b810] [c0000000002d43b8] free_unref_page_list+0x198/0x280
[c00001f26468b870] [c0000000002e1064] release_pages+0x3d4/0x510
[c00001f26468b950] [c000000000343acc] free_pages_and_swap_cache+0x12c/0x160
[c00001f26468b9a0] [c000000000318a88] tlb_flush_mmu_free+0x68/0xa0
[c00001f26468b9e0] [c00000000031c7ac] zap_pte_range+0x30c/0xa40
[c00001f26468bae0] [c00000000031d344] unmap_page_range+0x334/0x6d0
[c00001f26468bbc0] [c00000000031dc84] unmap_vmas+0x94/0x140
[c00001f26468bc10] [c00000000032b478] exit_mmap+0xe8/0x1f0
[c00001f26468bcd0] [c0000000000ff460] mmput+0x80/0x1c0
[c00001f26468bd00] [c000000000109430] do_exit+0x370/0xc70
[c00001f26468bdd0] [c000000000109e00] do_group_exit+0x60/0x100
[c00001f26468be10] [c000000000109ec4] SyS_exit_group+0x24/0x30
[c00001f26468be30] [c00000000000b088] system_call+0x3c/0x12c
Instruction dump:
994d02ba 2fa30000 409e0024 e92d0020 61298000 7d210164 38210020 e8010010
7c0803a6 4e800020 60000000 4bff4165 <60000000> 4bffffe4 60000000 e92d0020

This has been created on a 32TB node where ~1500 processes, each allocating
10GB, are spawning/exiting in a stressing loop.

As Power is 64K page size based, MAX_GATHER_BATCH = 8189, so
MAX_GATHER_BATCH_COUNT will not exceed 1.

So there is no way to loop in zap_pte_range() due to the batch's limit.
I guess we are never hitting the workaround introduced in the commit
53a59fc67f97. By the way should cond_resched being called in zap_pte_range()
when the flush is due to the batch's limit ?
Something like that :

@@ -1338,7 +1345,7 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
                        if (unlikely(page_mapcount(page) < 0))
                                print_bad_pte(vma, addr, ptent, page);
                        if (unlikely(__tlb_remove_page(tlb, page))) {
-                               force_flush = 1;
+                               force_flush = 2;
                                addr += PAGE_SIZE;
                                break;
                        }
@@ -1398,12 +1405,19 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
         * batch buffers or because we needed to flush dirty TLB
         * entries before releasing the ptl), free the batched
         * memory too. Restart if we didn't do everything.
+        * In the case the flush was due to the batch buffer's limit,
+        * give a chance to the other task to be run to avoid soft lockup
+        * when dealing with large amount of memory.
         */
        if (force_flush) {
+               bool force_sched = (force_flush == 2);
                force_flush = 0;
                tlb_flush_mmu_free(tlb);
-               if (addr != end)
+               if (addr != end) {
+                       if (force_sched)
+                               cond_resched();
                        goto again;
+               }
        }

Anyway, this should not fix the soft lockup I'm facing because
MAX_GATHER_BATCH_COUNT=1 on ppc64.

Indeed, I'm wondering if the 10K pages is too large in some cases, especially
when the node is loaded, and contention on the pte lock is likely to happen.
Here with less than 8k pages processed soft lockup are surfacing.

Should the MAX_GATHER_BATCH limit be forced to lower value on ppc64 or more
code introduced to work around that ?

Cheers,
Laurent.
