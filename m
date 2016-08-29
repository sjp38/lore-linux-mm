Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9811A830F1
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 19:07:39 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id f128so6699730qkd.1
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 16:07:39 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id l67si10854106ywd.313.2016.08.29.16.07.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Aug 2016 16:07:38 -0700 (PDT)
Date: Mon, 29 Aug 2016 16:07:37 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 0/3] Account reserved memory when allocating system
 hash
Message-Id: <20160829160737.819633db830d332dd669bcdf@linux-foundation.org>
In-Reply-To: <1472476010-4709-1-git-send-email-srikar@linux.vnet.ibm.com>
References: <1472476010-4709-1-git-send-email-srikar@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org, Mahesh Salgaonkar <mahesh@linux.vnet.ibm.com>, Hari Bathini <hbathini@linux.vnet.ibm.com>, Dave Hansen <dave.hansen@intel.com>, Balbir Singh <bsingharora@gmail.com>

On Mon, 29 Aug 2016 18:36:47 +0530 Srikar Dronamraju <srikar@linux.vnet.ibm.com> wrote:

> Fadump kernel reserves large chunks of memory even before the pages are
> initialised. This could mean memory that corresponds to several nodes might
> fall in memblock reserved regions.
> 
> Kernels compiled with CONFIG_DEFERRED_STRUCT_PAGE_INIT will initialise
> only certain size memory per node. The certain size takes into account
> the dentry and inode cache sizes. However such a kernel when booting a
> secondary kernel will not be able to allocate the required amount of
> memory to suffice for the dentry and inode caches. This results in
> crashes like the below on large systems such as 32 TB systems.
> 
> Dentry cache hash table entries: 536870912 (order: 16, 4294967296 bytes)
> vmalloc: allocation failure, allocated 4097114112 of 17179934720 bytes
> swapper/0: page allocation failure: order:0, mode:0x2080020(GFP_ATOMIC)
> CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.6-master+ #3
> Call Trace:
> [c00000000108fb10] [c0000000007fac88] dump_stack+0xb0/0xf0 (unreliable)
> [c00000000108fb50] [c000000000235264] warn_alloc_failed+0x114/0x160
> [c00000000108fbf0] [c000000000281484] __vmalloc_node_range+0x304/0x340
> [c00000000108fca0] [c00000000028152c] __vmalloc+0x6c/0x90
> [c00000000108fd40] [c000000000aecfb0]
> alloc_large_system_hash+0x1b8/0x2c0
> [c00000000108fe00] [c000000000af7240] inode_init+0x94/0xe4
> [c00000000108fe80] [c000000000af6fec] vfs_caches_init+0x8c/0x13c
> [c00000000108ff00] [c000000000ac4014] start_kernel+0x50c/0x578
> [c00000000108ff90] [c000000000008c6c] start_here_common+0x20/0xa8
> 
> This patchset solves this problem by accounting the size of reserved memory
> when calculating the size of large system hashes.
> 
> While this patchset applies on v4.8-rc3, it cannot be tested on v4.8-rc3
> because of http://lkml.kernel.org/r/20160829093844.GA2592@linux.vnet.ibm.com
> However it has been tested on v4.7/v4.6 and v4.4

That looks like a pretty serious regression.

I'll grab the patchset anyway.  It will come good when we fix that kswapd
thing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
