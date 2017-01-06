Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id EB51D6B025E
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 02:27:58 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id x64so54603112qkb.5
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 23:27:58 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a134si39786642qkb.306.2017.01.05.23.27.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Jan 2017 23:27:58 -0800 (PST)
Date: Fri, 6 Jan 2017 08:27:51 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [lkp-developer] [page_pool]  50a8fe7622:
 kernel_BUG_at_mm/slub.c
Message-ID: <20170106082751.3dae47e3@redhat.com>
In-Reply-To: <20170106050827.GC690@yexl-desktop>
References: <20161220132817.18788.64726.stgit@firesoul>
	<20170106050827.GC690@yexl-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel test robot <xiaolong.ye@intel.com>
Cc: linux-mm@kvack.org, Alexander Duyck <alexander.duyck@gmail.com>, willemdebruijn.kernel@gmail.com, netdev@vger.kernel.org, john.fastabend@gmail.com, Saeed Mahameed <saeedm@mellanox.com>, bjorn.topel@intel.com, Alexei Starovoitov <alexei.starovoitov@gmail.com>, Tariq Toukan <tariqt@mellanox.com>, lkp@01.org, brouer@redhat.com


On Fri, 6 Jan 2017 13:08:27 +0800 kernel test robot <xiaolong.ye@intel.com> wrote:

> FYI, we noticed the following commit:
> 
> commit: 50a8fe7622e6c45af778d91f83c11491f0afaaf3 ("page_pool: basic implementation of page_pool")
> url: https://github.com/0day-ci/linux/commits/Jesper-Dangaard-Brouer/page_pool-proof-of-concept-early-code/20161221-014200
> base: git://git.cmpxchg.org/linux-mmotm.git master
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
> on test machine: qemu-system-i386 -enable-kvm -smp 2 -m 320M

This is because this RFC patch does not support 32-bit, as I'm using a
page flag that is only avail on 64-bit, see[1].

I though this kind of page-flags violation would be caught compile-time?

[1] https://github.com/0day-ci/linux/commit/50a8fe7622e6c45af778d91f83c11491f0afaaf3#diff-c684e72d6c55b89ae592b66e9ce818ee
 
> caused below changes:
> 
> 
> +------------------------------------------+------------+------------+
> |                                          | 03fc8354e2 | 50a8fe7622 |
> +------------------------------------------+------------+------------+
> | boot_successes                           | 6          | 0          |
> | boot_failures                            | 0          | 4          |
> | kernel_BUG_at_mm/slub.c                  | 0          | 4          |
> | invalid_opcode:#[##]SMP_DEBUG_PAGEALLOC  | 0          | 4          |
> | Kernel_panic-not_syncing:Fatal_exception | 0          | 4          |
> +------------------------------------------+------------+------------+
> 
> 
> 
> [    0.000000]       .text : 0xc1000000 - 0xc188d0b7   (8756 kB)
> [    0.000000] Checking if this processor honours the WP bit even in supervisor mode...Ok.
> [    0.000000] ------------[ cut here ]------------
> [    0.000000] kernel BUG at mm/slub.c:349!
> [    0.000000] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC
> [    0.000000] Modules linked in:
> [    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 4.9.0-mm1-00096-g50a8fe7 #1
> [    0.000000] task: c1d4ea80 task.stack: c1d46000
> [    0.000000] EIP: get_partial_node+0x148/0x330
> [    0.000000] EFLAGS: 00210046 CPU: 0
> [    0.000000] EAX: 00200082 EBX: d2d38000 ECX: 00000000 EDX: d2400010
> [    0.000000] ESI: c1e3ef80 EDI: d2400000 EBP: c1d47e50 ESP: c1d47dc0
> [    0.000000]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
> [    0.000000] CR0: 80050033 CR2: ffbff000 CR3: 01e76000 CR4: 000006b0
> [    0.000000] Call Trace:
> [    0.000000]  ? add_lock_to_list+0x7e/0xa7
> [    0.000000]  ? __lock_acquire+0x103a/0x1326
> [    0.000000]  ___slab_alloc+0x238/0x378
> 
> 
> To reproduce:
> 
>         git clone git://git.kernel.org/pub/scm/linux/kernel/git/wfg/lkp-tests.git
>         cd lkp-tests
>         bin/lkp qemu -k <bzImage> job-script  # job-script is attached in this email

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
