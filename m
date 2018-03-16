Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0372C6B0009
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 12:38:24 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k44so5899709wrc.3
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 09:38:23 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id a64si2864719ede.537.2018.03.16.09.38.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 09:38:22 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2GGauwo136368
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 12:38:21 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2grgumswsj-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 12:38:20 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 16 Mar 2018 16:38:18 -0000
Subject: Re: [mm] b33ddf50eb: INFO:trying_to_register_non-static_key
References: <20180316102359.pzjwi24hbkhnyk2a@inn>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Fri, 16 Mar 2018 17:38:06 +0100
MIME-Version: 1.0
In-Reply-To: <20180316102359.pzjwi24hbkhnyk2a@inn>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <7a638500-ce14-809a-6b40-79f32537b818@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel test robot <fengguang.wu@intel.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, lkp@01.org

On 16/03/2018 11:23, kernel test robot wrote:
> FYI, we noticed the following commit (built with gcc-7):
> 
> commit: b33ddf50ebcc740b990dd2e0e8ff0b92c7acf58e ("mm: Protect mm_rb tree with a rwlock")
> url: https://github.com/0day-ci/linux/commits/Laurent-Dufour/Speculative-page-faults/20180316-151833
> 
> 
> in testcase: boot
> 
> on test machine: qemu-system-x86_64 -enable-kvm -cpu host -smp 2 -m 4G
> 
> caused below changes (please refer to attached dmesg/kmsg for entire log/backtrace):
> 
> 
> +----------------------------------------+------------+------------+
> |                                        | 7f3f7b4e80 | b33ddf50eb |
> +----------------------------------------+------------+------------+
> | boot_successes                         | 8          | 0          |
> | boot_failures                          | 0          | 6          |
> | INFO:trying_to_register_non-static_key | 0          | 6          |
> +----------------------------------------+------------+------------+
> 
> 
> 
> [   22.218186] INFO: trying to register non-static key.
> [   22.220252] the code is fine but needs lockdep annotation.
> [   22.222471] turning off the locking correctness validator.
> [   22.224839] CPU: 0 PID: 1 Comm: init Not tainted 4.16.0-rc4-next-20180309-00017-gb33ddf5 #1
> [   22.228528] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
> [   22.232443] Call Trace:
> [   22.234234]  dump_stack+0x85/0xbc
> [   22.236085]  register_lock_class+0x237/0x477
> [   22.238057]  __lock_acquire+0xd0/0xf15
> [   22.240032]  lock_acquire+0x19c/0x1ce
> [   22.241927]  ? do_mmap+0x3aa/0x3ff
> [   22.243749]  mmap_region+0x37a/0x4c0
> [   22.245619]  ? do_mmap+0x3aa/0x3ff
> [   22.247425]  do_mmap+0x3aa/0x3ff
> [   22.249175]  vm_mmap_pgoff+0xa1/0xea
> [   22.251083]  elf_map+0x6d/0x134
> [   22.252873]  load_elf_binary+0x56f/0xe07
> [   22.254853]  search_binary_handler+0x75/0x1f8
> [   22.256934]  do_execveat_common+0x661/0x92b
> [   22.259164]  ? rest_init+0x22e/0x22e
> [   22.261082]  do_execve+0x1f/0x21
> [   22.262884]  kernel_init+0x5a/0xf0
> [   22.264722]  ret_from_fork+0x3a/0x50
> [   22.303240] systemd[1]: RTC configured in localtime, applying delta of 480 minutes to system time.
> [   22.313544] systemd[1]: Failed to insert module 'autofs4': No such file or directory

Thanks a lot for reporting this.

I found the issue introduced in that patch.
I mistakenly remove in the call to seqcount_init(&vma->vm_sequence) in
__vma_link_rb().
This doesn't have a functional impact as the vm_sequence is incremented
monotonically.

I'll fix that in the next series.

Laurent.
