Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id A1CB46B0024
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 08:21:28 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id v74so2995311qkl.9
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 05:21:28 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id m15si4194207qtb.416.2018.03.21.05.21.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 05:21:27 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2LCJwEI096015
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 08:21:26 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2gun825fk6-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 08:21:26 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 21 Mar 2018 12:21:23 -0000
Subject: Re: [mm] b1f0502d04: INFO:trying_to_register_non-static_key
References: <20180317075119.u6yuem2bhxvggbz3@inn>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Wed, 21 Mar 2018 13:21:12 +0100
MIME-Version: 1.0
In-Reply-To: <20180317075119.u6yuem2bhxvggbz3@inn>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <792c0f75-7e7f-cd81-44ae-4205f6e4affc@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel test robot <fengguang.wu@intel.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, lkp@01.org



On 17/03/2018 08:51, kernel test robot wrote:
> FYI, we noticed the following commit (built with gcc-7):
> 
> commit: b1f0502d04537ef55b0c296823affe332b100eb5 ("mm: VMA sequence count")
> url: https://github.com/0day-ci/linux/commits/Laurent-Dufour/Speculative-page-faults/20180316-151833
> 
> 
> in testcase: trinity
> with following parameters:
> 
> 	runtime: 300s
> 
> test-description: Trinity is a linux system call fuzz tester.
> test-url: http://codemonkey.org.uk/projects/trinity/
> 
> 
> on test machine: qemu-system-x86_64 -enable-kvm -cpu SandyBridge -m 512M
> 
> caused below changes (please refer to attached dmesg/kmsg for entire log/backtrace):
> 
> 
> +----------------------------------------+------------+------------+
> |                                        | 6a4ce82339 | b1f0502d04 |
> +----------------------------------------+------------+------------+
> | boot_successes                         | 8          | 4          |
> | boot_failures                          | 0          | 4          |
> | INFO:trying_to_register_non-static_key | 0          | 4          |
> +----------------------------------------+------------+------------+
> 
> 
> 
> [   22.212940] INFO: trying to register non-static key.
> [   22.213687] the code is fine but needs lockdep annotation.
> [   22.214459] turning off the locking correctness validator.
> [   22.227459] CPU: 0 PID: 547 Comm: trinity-main Not tainted 4.16.0-rc4-next-20180309-00007-gb1f0502 #239
> [   22.228904] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
> [   22.230043] Call Trace:
> [   22.230409]  dump_stack+0x5d/0x79
> [   22.231025]  register_lock_class+0x226/0x45e
> [   22.231827]  ? kvm_clock_read+0x21/0x30
> [   22.232544]  ? kvm_sched_clock_read+0x5/0xd
> [   22.233330]  __lock_acquire+0xa2/0x774
> [   22.234152]  lock_acquire+0x4b/0x66
> [   22.234805]  ? unmap_vmas+0x30/0x3d
> [   22.245680]  unmap_page_range+0x56/0x48c
> [   22.248127]  ? unmap_vmas+0x30/0x3d
> [   22.248741]  ? lru_deactivate_file_fn+0x2c6/0x2c6
> [   22.249537]  ? pagevec_lru_move_fn+0x9a/0xa9
> [   22.250244]  unmap_vmas+0x30/0x3d
> [   22.250791]  unmap_region+0xad/0x105
> [   22.251419]  mmap_region+0x3cc/0x455
> [   22.252011]  do_mmap+0x394/0x3e9
> [   22.261224]  vm_mmap_pgoff+0x9c/0xe5
> [   22.261798]  SyS_mmap_pgoff+0x19a/0x1d4
> [   22.262475]  ? task_work_run+0x5e/0x9c
> [   22.263163]  do_syscall_64+0x6d/0x103
> [   22.263814]  entry_SYSCALL_64_after_hwframe+0x3d/0xa2
> [   22.264697] RIP: 0033:0x4573da
> [   22.267248] RSP: 002b:00007fffa22f1398 EFLAGS: 00000246 ORIG_RAX: 0000000000000009
> [   22.274720] RAX: ffffffffffffffda RBX: 0000000000000001 RCX: 00000000004573da
> [   22.276083] RDX: 0000000000000001 RSI: 0000000000001000 RDI: 0000000000000000
> [   22.277343] RBP: 000000000000001c R08: 000000000000001c R09: 0000000000000000
> [   22.278686] R10: 0000000000000002 R11: 0000000000000246 R12: 0000000000000000
> [   22.279930] R13: 0000000000001000 R14: 0000000000000002 R15: 0000000000000000
> [   22.391866] trinity-main uses obsolete (PF_INET,SOCK_PACKET)
> [  327.566956] sysrq: SysRq : Emergency Sync
> [  327.567849] Emergency Sync complete
> [  327.569975] sysrq: SysRq : Resetting

I found the root cause of this lockdep warning.

In mmap_region(), unmap_region() may be called while vma_link() has not been
called. This happens during the error path if call_mmap() failed.

The only to fix that particular case is to call
seqcount_init(&vma->vm_sequence) when initializing the vma in mmap_region().

Thanks,
Laurent.
