Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4923B6B0012
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 14:42:46 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id x69-v6so3091854oia.21
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 11:42:46 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m110-v6sor2071036otc.155.2018.03.21.11.42.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Mar 2018 11:42:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180321161314.7711-1-mike.kravetz@oracle.com>
References: <0d24f817-303a-7b4d-4603-b2d14e4b391a@oracle.com> <20180321161314.7711-1-mike.kravetz@oracle.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 21 Mar 2018 11:42:44 -0700
Message-ID: <CAPcyv4g9Gbz00YZEX=25eZ8TEBvhmcTO-ZBamvZRqN-LPZmk5Q@mail.gmail.com>
Subject: Re: [PATCH v2] shm: add split function to shm_vm_ops
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Laurent Dufour <ldufour@linux.vnet.ibm.com>, Michal Hocko <mhocko@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, stable <stable@vger.kernel.org>

On Wed, Mar 21, 2018 at 9:13 AM, Mike Kravetz <mike.kravetz@oracle.com> wrote:
>
> If System V shmget/shmat operations are used to create a hugetlbfs
> backed mapping, it is possible to munmap part of the mapping and
> split the underlying vma such that it is not huge page aligned.
> This will untimately result in the following BUG:
>
> kernel BUG at /build/linux-jWa1Fv/linux-4.15.0/mm/hugetlb.c:3310!
> Oops: Exception in kernel mode, sig: 5 [#1]
> LE SMP NR_CPUS=2048 NUMA PowerNV
> Modules linked in: kcm nfc af_alg caif_socket caif phonet fcrypt
>                 8<--8<--8<--8< snip 8<--8<--8<--8<
> CPU: 18 PID: 43243 Comm: trinity-subchil Tainted: G         C  E
> 4.15.0-10-generic #11-Ubuntu
> NIP:  c00000000036e764 LR: c00000000036ee48 CTR: 0000000000000009
> REGS: c000003fbcdcf810 TRAP: 0700   Tainted: G         C  E
> (4.15.0-10-generic)
> MSR:  9000000000029033 <SF,HV,EE,ME,IR,DR,RI,LE>  CR: 24002222  XER:
> 20040000
> CFAR: c00000000036ee44 SOFTE: 1
> GPR00: c00000000036ee48 c000003fbcdcfa90 c0000000016ea600 c000003fbcdcfc40
> GPR04: c000003fd9858950 00007115e4e00000 00007115e4e10000 0000000000000000
> GPR08: 0000000000000010 0000000000010000 0000000000000000 0000000000000000
> GPR12: 0000000000002000 c000000007a2c600 00000fe3985954d0 00007115e4e00000
> GPR16: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
> GPR20: 00000fe398595a94 000000000000a6fc c000003fd9858950 0000000000018554
> GPR24: c000003fdcd84500 c0000000019acd00 00007115e4e10000 c000003fbcdcfc40
> GPR28: 0000000000200000 00007115e4e00000 c000003fbc9ac600 c000003fd9858950
> NIP [c00000000036e764] __unmap_hugepage_range+0xa4/0x760
> LR [c00000000036ee48] __unmap_hugepage_range_final+0x28/0x50
> Call Trace:
> [c000003fbcdcfa90] [00007115e4e00000] 0x7115e4e00000 (unreliable)
> [c000003fbcdcfb50] [c00000000036ee48]
> __unmap_hugepage_range_final+0x28/0x50
> [c000003fbcdcfb80] [c00000000033497c] unmap_single_vma+0x11c/0x190
> [c000003fbcdcfbd0] [c000000000334e14] unmap_vmas+0x94/0x140
> [c000003fbcdcfc20] [c00000000034265c] exit_mmap+0x9c/0x1d0
> [c000003fbcdcfce0] [c000000000105448] mmput+0xa8/0x1d0
> [c000003fbcdcfd10] [c00000000010fad0] do_exit+0x360/0xc80
> [c000003fbcdcfdd0] [c0000000001104c0] do_group_exit+0x60/0x100
> [c000003fbcdcfe10] [c000000000110584] SyS_exit_group+0x24/0x30
> [c000003fbcdcfe30] [c00000000000b184] system_call+0x58/0x6c
> Instruction dump:
> 552907fe e94a0028 e94a0408 eb2a0018 81590008 7f9c5036 0b090000 e9390010
> 7d2948f8 7d2a2838 0b0a0000 7d293038 <0b090000> e9230086 2fa90000 419e0468
> ---[ end trace ee88f958a1c62605 ]---
>
> This bug was introduced by commit 31383c6865a5 ("mm, hugetlbfs:
> introduce ->split() to vm_operations_struct").  A split function
> was added to vm_operations_struct to determine if a mapping can
> be split.  This was mostly for device-dax and hugetlbfs mappings
> which have specific alignment constraints.
>
> Mappings initiated via shmget/shmat have their original vm_ops
> overwritten with shm_vm_ops.  shm_vm_ops functions will call back
> to the original vm_ops if needed.  Add such a split function to
> shm_vm_ops.
>
> Fixes: 31383c6865a5 ("mm, hugetlbfs: introduce ->split() to vm_operations_struct")
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> Reported by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> Tested-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Cc: stable@vger.kernel.org

Reviewed-by: Dan Williams <dan.j.williams@intel.com>

...don't worry about resending if this has already hit a maintainer tree.
