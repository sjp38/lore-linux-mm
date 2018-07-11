Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3358E6B0003
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 06:42:06 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id m6-v6so30617531qkd.20
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 03:42:06 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id r2-v6si2690680qkd.14.2018.07.11.03.42.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 03:42:05 -0700 (PDT)
Date: Wed, 11 Jul 2018 18:41:58 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: Bug report about KASLR and ZONE_MOVABLE
Message-ID: <20180711104158.GE2070@MiWiFi-R3L-srv>
References: <20180711094244.GA2019@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180711094244.GA2019@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chao Fan <fanc.fnst@cn.fujitsu.com>, akpm@linux-foundation.org, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, yasu.isimatu@gmail.com, keescook@chromium.org, indou.takao@jp.fujitsu.com, caoj.fnst@cn.fujitsu.com, douly.fnst@cn.fujitsu.com, mhocko@suse.com, vbabka@suse.cz, mgorman@techsingularity.net

On 07/11/18 at 05:42pm, Chao Fan wrote:
> Hi all,
> 
> I found there is a BUG about KASLR and ZONE_MOVABLE.
> 
> When users use 'kernelcore=' parameter without 'movable_node',
> movable memory is evenly distributed to all nodes. The size of
> ZONE_MOVABLE depends on the kernel parameter 'kernelcore=' and
> 'movablecore='.
> But sometiomes, KASLR may put the uncompressed kernel to the
> tail position of a node, which will cause the kernel memory
> set as ZONE_MOVABLE. This region can not be offlined.
> 
> Here is a very simple test in my qemu-kvm machine, there is
> only one node:
> 
> The command line:
> [root@localhost ~]# cat /proc/cmdline
> BOOT_IMAGE=/vmlinuz-4.18.0-rc3+ root=/dev/mapper/fedora_localhost--live-root
> ro resume=/dev/mapper/fedora_localhost--live-swap
> rd.lvm.lv=fedora_localhost-live/root rd.lvm.lv=fedora_localhost-live/swap
> console=ttyS0 earlyprintk=ttyS0,115200n8 memblock=debug kernelcore=50%
> 
> I use 'kernelcore=50%' here.
> 
> Here is my early print result, I print the random_addr after KASLR chooses
> physical memory:
> early console in extract_kernel
> input_data: 0x000000000266b3b1
> input_len: 0x00000000007d8802
> output: 0x0000000001000000
> output_len: 0x0000000001e15698
> kernel_total_size: 0x0000000001a8b000
> trampoline_32bit: 0x000000000009d000
> booted via startup_32()
> Physical KASLR using RDRAND RDTSC...
> random_addr: 0x000000012f000000
> Virtual KASLR using RDRAND RDTSC...
> 
> The address for kernel is 0x000000012f000000
> 
> Here is the log of ZONE:
> [    0.000000] Zone ranges:
> [    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
> [    0.000000]   DMA32    [mem 0x0000000001000000-0x00000000ffffffff]
> [    0.000000]   Normal   [mem 0x0000000100000000-0x00000001f57fffff]
> [    0.000000]   Device   empty
> [    0.000000] Movable zone start for each node
> [    0.000000]   Node 0: 0x000000011b000000
> [    0.000000] Early memory node ranges
> [    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009efff]
> [    0.000000]   node   0: [mem 0x0000000000100000-0x00000000bffd6fff]
> [    0.000000]   node   0: [mem 0x0000000100000000-0x00000001f57fffff]
> [    0.000000] Initmem setup node 0 [mem
> 0x0000000000001000-0x00000001f57fffff]
> 
> Only one node in my machine, ZONE_MOVABLE begins from 0x000000011b000000,
> which is lower than 0x000000012f000000.
> So KASLR put the kernel to the ZONE_MOVABLE.
> Try to solve this problem, I think there should be a new tactic in function
> find_zone_movable_pfns_for_nodes() of mm/page_alloc.c. If kernel is uncompressed
> in a tail position, then just set the memory after the kernel as ZONE_MOVABLE,
> at the same time, memory in other nodes will be set as ZONE_MOVABLE.

Hmm, it's an issue, worth fixing it. Otherwise the size of
movable area will be smaller than we expect when add "kernel_core="
or "movable_core=".

Add a check in find_zone_movable_pfns_for_nodes(), and use min() to get
the starting address of movable area between aligned '_etext'
and start_pfn. It will go to label 'restart' to calculate the 2nd round
if not satisfiled. 

Hi Chao,

Could you check if below patch works for you?
