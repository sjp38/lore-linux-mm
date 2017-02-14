Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3D29C6B0038
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 09:12:19 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id k15so141443780qtg.5
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 06:12:19 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 1si586619pgo.251.2017.02.14.06.12.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Feb 2017 06:12:18 -0800 (PST)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1EDxxeV106075
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 09:12:17 -0500
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com [202.81.31.143])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28kgdm4u4t-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 09:12:17 -0500
Received: from localhost
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 15 Feb 2017 00:12:14 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 1C14E2BB0045
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 01:12:13 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v1EEC5mD35258544
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 01:12:13 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v1EEBfZC027837
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 01:11:41 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/autonuma: don't use set_pte_at when updating protnone ptes
In-Reply-To: <1486400776-28114-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1486400776-28114-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Date: Tue, 14 Feb 2017 19:41:17 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87a89ovp4q.fsf@skywalker.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, Rik van Riel <riel@surriel.com>, Mel Gorman <mgorman@techsingularity.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> writes:

> Architectures like ppc64, use privilege access bit to mark pte non accessible.
> This implies that kernel can do a copy_to_user to an address marked for numa fault.
> This also implies that there can be a parallel hardware update for the pte.
> set_pte_at cannot be used in such scenarios. Hence switch the pte
> update to use ptep_get_and_clear and set_pte_at combination.
>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

With this and other patches a kvm guest is giving me

  494.542145] khugepaged      D13632  1451      2 0x00000800
[  494.542151] Call Trace:
[  494.542158] [c000000fe57a7830] [c000000000e71f10] sysctl_sched_child_runs_first+0x0/0x4 (unreliable)
[  494.542163] [c000000fe57a7a00] [c00000000001ae70] __switch_to+0x2b0/0x440
[  494.542167] [c000000fe57a7a60] [c0000000009ac560] __schedule+0x2e0/0x940
[  494.542170] [c000000fe57a7b00] [c0000000009acc00] schedule+0x40/0xb0
[  494.542173] [c000000fe57a7b30] [c0000000009b1264] rwsem_down_read_failed+0x124/0x1b0
[  494.542176] [c000000fe57a7ba0] [c0000000009b0064] down_read+0x64/0x70
[  494.542180] [c000000fe57a7bd0] [c000000000292a70] khugepaged+0x420/0x25c0
[  494.542184] [c000000fe57a7dc0] [c0000000000df37c] kthread+0x14c/0x190
[  494.542187] [c000000fe57a7e30] [c00000000000bae0] ret_from_kernel_thread+0x5c/0x7c
[  494.542276] INFO: task qemu-system-ppc:6868 blocked for more than 120 seconds.
[  494.542340]       Not tainted 4.10.0-rc8-00025-g0d75d3e #4
[  494.542377] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  494.542439] qemu-system-ppc D10688  6868   6473 0x00040000
[  494.542445] Call Trace:
[  494.542448] [c000000fdca7b6a0] [c00000000001ae70] __switch_to+0x2b0/0x440
[  494.542451] [c000000fdca7b700] [c0000000009ac560] __schedule+0x2e0/0x940
[  494.542454] [c000000fdca7b7a0] [c0000000009acc00] schedule+0x40/0xb0
[  494.542457] [c000000fdca7b7d0] [c0000000009b1264] rwsem_down_read_failed+0x124/0x1b0
[  494.542460] [c000000fdca7b840] [c0000000009b0064] down_read+0x64/0x70
[  494.542464] [c000000fdca7b870] [c0000000002340e0] get_user_pages_unlocked+0x80/0x280
[  494.542467] [c000000fdca7b910] [c0000000002352dc] get_user_pages_fast+0xac/0x110
[  494.542475] [c000000fdca7b960] [d00000001096c4fc] kvmppc_book3s_hv_page_fault+0x2bc/0xbb0 [kvm_hv]
[  494.542479] [c000000fdca7ba50] [d0000000109692e4] kvmppc_vcpu_run_hv+0xee4/0x1290 [kvm_hv]
[  494.542488] [c000000fdca7bb80] [d0000000107113bc] kvmppc_vcpu_run+0x2c/0x40 [kvm]
[  494.542497] [c000000fdca7bba0] [d00000001070ec6c] kvm_arch_vcpu_ioctl_run+0x5c/0x160 [kvm]
[  494.542504] [c000000fdca7bbe0] [d000000010703bf8] kvm_vcpu_ioctl+0x528/0x7a0 [kvm]
[  494.542506] [c000000fdca7bd40] [c0000000002c46dc] do_vfs_ioctl+0xcc/0x8e0
[  494.542509] [c000000fdca7bde0] [c0000000002c4f50] SyS_ioctl+0x60/0xc0
[  494.542512] [c000000fdca7be30] [c00000000000b760] system_call+0x38/0xfc
[  494.542514] INFO: task qemu-system-ppc:6870 blocked for more than 120 seconds.
[  494.542577]       Not tainted 4.10.0-rc8-00025-g0d75d3e #4
[  494.542615] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  494.542677] qemu-system-ppc D10688  6870   6473 0x00040000

Reverting this patch gets rid of the above hang. But I am running into segfault
with systemd in guest. It could be some other patches in my local tree.

Maybe we should hold merging this to 4.11 and wait for this to get more
testing ?

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
