Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 291BE6B0008
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 13:26:05 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id c1so1222653wri.22
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 10:26:05 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 6si557697edc.502.2018.03.20.10.26.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Mar 2018 10:26:03 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2KHH8uw082897
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 13:26:02 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2gu5qxu4a6-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 13:26:00 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 20 Mar 2018 17:25:58 -0000
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH] mm/hugetlb: prevent hugetlb VMA to be misaligned
Date: Tue, 20 Mar 2018 18:25:54 +0100
Message-Id: <1521566754-30390-1-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, mhocko@kernel.org

When running the sampler detailed below, the kernel, if built with the VM
debug option turned on (as many distro do), is panicing with the following
message :
kernel BUG at /build/linux-jWa1Fv/linux-4.15.0/mm/hugetlb.c:3310!
Oops: Exception in kernel mode, sig: 5 [#1]
LE SMP NR_CPUS=2048 NUMA PowerNV
Modules linked in: kcm nfc af_alg caif_socket caif phonet fcrypt
		8<--8<--8<--8< snip 8<--8<--8<--8<
CPU: 18 PID: 43243 Comm: trinity-subchil Tainted: G         C  E
4.15.0-10-generic #11-Ubuntu
NIP:  c00000000036e764 LR: c00000000036ee48 CTR: 0000000000000009
REGS: c000003fbcdcf810 TRAP: 0700   Tainted: G         C  E
(4.15.0-10-generic)
MSR:  9000000000029033 <SF,HV,EE,ME,IR,DR,RI,LE>  CR: 24002222  XER:
20040000
CFAR: c00000000036ee44 SOFTE: 1
GPR00: c00000000036ee48 c000003fbcdcfa90 c0000000016ea600 c000003fbcdcfc40
GPR04: c000003fd9858950 00007115e4e00000 00007115e4e10000 0000000000000000
GPR08: 0000000000000010 0000000000010000 0000000000000000 0000000000000000
GPR12: 0000000000002000 c000000007a2c600 00000fe3985954d0 00007115e4e00000
GPR16: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
GPR20: 00000fe398595a94 000000000000a6fc c000003fd9858950 0000000000018554
GPR24: c000003fdcd84500 c0000000019acd00 00007115e4e10000 c000003fbcdcfc40
GPR28: 0000000000200000 00007115e4e00000 c000003fbc9ac600 c000003fd9858950
NIP [c00000000036e764] __unmap_hugepage_range+0xa4/0x760
LR [c00000000036ee48] __unmap_hugepage_range_final+0x28/0x50
Call Trace:
[c000003fbcdcfa90] [00007115e4e00000] 0x7115e4e00000 (unreliable)
[c000003fbcdcfb50] [c00000000036ee48]
__unmap_hugepage_range_final+0x28/0x50
[c000003fbcdcfb80] [c00000000033497c] unmap_single_vma+0x11c/0x190
[c000003fbcdcfbd0] [c000000000334e14] unmap_vmas+0x94/0x140
[c000003fbcdcfc20] [c00000000034265c] exit_mmap+0x9c/0x1d0
[c000003fbcdcfce0] [c000000000105448] mmput+0xa8/0x1d0
[c000003fbcdcfd10] [c00000000010fad0] do_exit+0x360/0xc80
[c000003fbcdcfdd0] [c0000000001104c0] do_group_exit+0x60/0x100
[c000003fbcdcfe10] [c000000000110584] SyS_exit_group+0x24/0x30
[c000003fbcdcfe30] [c00000000000b184] system_call+0x58/0x6c
Instruction dump:
552907fe e94a0028 e94a0408 eb2a0018 81590008 7f9c5036 0b090000 e9390010
7d2948f8 7d2a2838 0b0a0000 7d293038 <0b090000> e9230086 2fa90000 419e0468
---[ end trace ee88f958a1c62605 ]---

The panic is due to a VMA pointing to a hugetlb area while the
vma->vm_start or vma->vm_end field are not aligned to the huge page
boundaries. The sampler is just unmapping a part of the hugetlb area,
leading to 2 VMAs which are not well aligned.  The same could be achieved
by calling madvise() situation, as it is when running:
stress-ng --shm-sysv 1

The hugetlb code is assuming that the VMA will be well aligned when it is
unmapped, so we must prevent such a VMA to be split or shrink to a
misaligned address.

This patch is preventing this by checking the new VMA's boundaries when a
VMA is modified by calling vma_adjust().

If this patch is applied, stable should be Cced.

--- Sampler used to hit the panic
nclude <sys/ipc.h>

unsigned long page_size;

int main(void)
{
    int shmid, ret=1;
    void *addr;

    setbuf(stdout, NULL);
    page_size = getpagesize();

    shmid = shmget(0x1410, LENGTH, IPC_CREAT | SHM_HUGETLB | SHM_R |
SHM_W);
    if (shmid < 0) {
	perror("shmget");
	exit(1);
    }

    printf("shmid: %d\n", shmid);

    addr = shmat(shmid, NULL, 0);
    if (addr == (void*)-1) {
	perror("shmat");
	goto out;
    }

    /*
     * The following munmap() call will split the VMA in 2, leading to
     * unaligned to huge page size VMAs which will trigger a check when
     * shmdt() is called.
     */
    if (munmap(addr + HPSIZE + page_size, page_size)) {
	perror("munmap");
	goto out;
    }

    if (shmdt(addr)) {
	perror("shmdt");
	goto out;
    }

    printf("test done.\n");
    ret = 0;

out:
    shmctl(shmid, IPC_RMID, NULL);
    return ret;
}
--- End of code

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 mm/mmap.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/mm/mmap.c b/mm/mmap.c
index 188f195883b9..5dbf4b69a798 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -692,6 +692,17 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
 	long adjust_next = 0;
 	int remove_next = 0;
 
+	if (is_vm_hugetlb_page(vma)) {
+		/*
+		 * We must check against the huge page boundarie to not
+		 * create misaligned VMA.
+		 */
+		struct hstate *h = hstate_vma(vma);
+
+		if (start & ~huge_page_mask(h) || end & ~huge_page_mask(h))
+			return -EINVAL;
+	}
+
 	if (next && !insert) {
 		struct vm_area_struct *exporter = NULL, *importer = NULL;
 
-- 
2.7.4
