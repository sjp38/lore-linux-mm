Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id A1B466B0007
	for <linux-mm@kvack.org>; Fri, 15 Jun 2018 04:41:44 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id s15-v6so5633830wrn.16
        for <linux-mm@kvack.org>; Fri, 15 Jun 2018 01:41:44 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x58-v6si1922882edx.441.2018.06.15.01.41.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Jun 2018 01:41:43 -0700 (PDT)
Date: Fri, 15 Jun 2018 10:41:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] x86/e820: put !E820_TYPE_RAM regions into
 memblock.reserved
Message-ID: <20180615084142.GE24039@dhcp22.suse.cz>
References: <20180607094921.GA8545@techadventures.net>
 <20180607100256.GA9129@hori1.linux.bs1.fc.nec.co.jp>
 <20180613054107.GA5329@hori1.linux.bs1.fc.nec.co.jp>
 <20180613090700.GG13364@dhcp22.suse.cz>
 <20180614051618.GB17860@hori1.linux.bs1.fc.nec.co.jp>
 <20180614053859.GA9863@techadventures.net>
 <20180614063454.GA32419@hori1.linux.bs1.fc.nec.co.jp>
 <20180614213033.GA19374@techadventures.net>
 <20180615010927.GC1196@hori1.linux.bs1.fc.nec.co.jp>
 <20180615072947.GB23273@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180615072947.GB23273@hori1.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Oscar Salvador <osalvador@techadventures.net>, Oscar Salvador <osalvador@suse.de>, Pavel Tatashin <pasha.tatashin@oracle.com>, Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Matthew Wilcox <willy@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "mingo@kernel.org" <mingo@kernel.org>, "dan.j.williams@intel.com" <dan.j.williams@intel.com>, Huang Ying <ying.huang@intel.com>

On Fri 15-06-18 07:29:48, Naoya Horiguchi wrote:
[...]
> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Date: Thu, 14 Jun 2018 16:04:36 +0900
> Subject: [PATCH] x86/e820: put !E820_TYPE_RAM regions into memblock.reserved
> 
> There is a kernel panic that is triggered when reading /proc/kpageflags
> on the kernel booted with kernel parameter 'memmap=nn[KMG]!ss[KMG]':
> 
>   BUG: unable to handle kernel paging request at fffffffffffffffe
>   PGD 9b20e067 P4D 9b20e067 PUD 9b210067 PMD 0
>   Oops: 0000 [#1] SMP PTI
>   CPU: 2 PID: 1728 Comm: page-types Not tainted 4.17.0-rc6-mm1-v4.17-rc6-180605-0816-00236-g2dfb086ef02c+ #160
>   Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.11.0-2.fc28 04/01/2014
>   RIP: 0010:stable_page_flags+0x27/0x3c0
>   Code: 00 00 00 0f 1f 44 00 00 48 85 ff 0f 84 a0 03 00 00 41 54 55 49 89 fc 53 48 8b 57 08 48 8b 2f 48 8d 42 ff 83 e2 01 48 0f 44 c7 <48> 8b 00 f6 c4 01 0f 84 10 03 00 00 31 db 49 8b 54 24 08 4c 89 e7
>   RSP: 0018:ffffbbd44111fde0 EFLAGS: 00010202
>   RAX: fffffffffffffffe RBX: 00007fffffffeff9 RCX: 0000000000000000
>   RDX: 0000000000000001 RSI: 0000000000000202 RDI: ffffed1182fff5c0
>   RBP: ffffffffffffffff R08: 0000000000000001 R09: 0000000000000001
>   R10: ffffbbd44111fed8 R11: 0000000000000000 R12: ffffed1182fff5c0
>   R13: 00000000000bffd7 R14: 0000000002fff5c0 R15: ffffbbd44111ff10
>   FS:  00007efc4335a500(0000) GS:ffff93a5bfc00000(0000) knlGS:0000000000000000
>   CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>   CR2: fffffffffffffffe CR3: 00000000b2a58000 CR4: 00000000001406e0
>   Call Trace:
>    kpageflags_read+0xc7/0x120
>    proc_reg_read+0x3c/0x60
>    __vfs_read+0x36/0x170
>    vfs_read+0x89/0x130
>    ksys_pread64+0x71/0x90
>    do_syscall_64+0x5b/0x160
>    entry_SYSCALL_64_after_hwframe+0x44/0xa9
>   RIP: 0033:0x7efc42e75e23
>   Code: 09 00 ba 9f 01 00 00 e8 ab 81 f4 ff 66 2e 0f 1f 84 00 00 00 00 00 90 83 3d 29 0a 2d 00 00 75 13 49 89 ca b8 11 00 00 00 0f 05 <48> 3d 01 f0 ff ff 73 34 c3 48 83 ec 08 e8 db d3 01 00 48 89 04 24
> 
> According to kernel bisection, this problem became visible due to commit
> f7f99100d8d9 which changes how struct pages are initialized.
> 
> Memblock layout affects the pfn ranges covered by node/zone. Consider
> that we have a VM with 2 NUMA nodes and each node has 4GB memory, and
> the default (no memmap= given) memblock layout is like below:
> 
>   MEMBLOCK configuration:
>    memory size = 0x00000001fff75c00 reserved size = 0x000000000300c000
>    memory.cnt  = 0x4
>    memory[0x0]     [0x0000000000001000-0x000000000009efff], 0x000000000009e000 bytes on node 0 flags: 0x0
>    memory[0x1]     [0x0000000000100000-0x00000000bffd6fff], 0x00000000bfed7000 bytes on node 0 flags: 0x0
>    memory[0x2]     [0x0000000100000000-0x000000013fffffff], 0x0000000040000000 bytes on node 0 flags: 0x0
>    memory[0x3]     [0x0000000140000000-0x000000023fffffff], 0x0000000100000000 bytes on node 1 flags: 0x0
>    ...
> 
> If you give memmap=1G!4G (so it just covers memory[0x2]),
> the range [0x100000000-0x13fffffff] is gone:
> 
>   MEMBLOCK configuration:
>    memory size = 0x00000001bff75c00 reserved size = 0x000000000300c000
>    memory.cnt  = 0x3
>    memory[0x0]     [0x0000000000001000-0x000000000009efff], 0x000000000009e000 bytes on node 0 flags: 0x0
>    memory[0x1]     [0x0000000000100000-0x00000000bffd6fff], 0x00000000bfed7000 bytes on node 0 flags: 0x0
>    memory[0x2]     [0x0000000140000000-0x000000023fffffff], 0x0000000100000000 bytes on node 1 flags: 0x0
>    ...
> 
> This causes shrinking node 0's pfn range because it is calculated by
> the address range of memblock.memory. So some of struct pages in the
> gap range are left uninitialized.
> 
> We have a function zero_resv_unavail() which does zeroing the struct
> pages within the reserved unavailable range (i.e. memblock.memory &&
> !memblock.reserved). This patch utilizes it to cover all unavailable
> ranges by putting them into memblock.reserved.
> 
> Fixes: f7f99100d8d9 ("mm: stop zeroing memory during allocation in vmemmap")
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Tested-by: Oscar Salvador <osalvador@suse.de>

OK, this makes sense to me. It is definitely much better than the
original attempt.

Unless I am missing something this should be correct
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  arch/x86/kernel/e820.c | 15 ++++++++++++---
>  1 file changed, 12 insertions(+), 3 deletions(-)
> 
> diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
> index d1f25c831447..c88c23c658c1 100644
> --- a/arch/x86/kernel/e820.c
> +++ b/arch/x86/kernel/e820.c
> @@ -1248,6 +1248,7 @@ void __init e820__memblock_setup(void)
>  {
>  	int i;
>  	u64 end;
> +	u64 addr = 0;
>  
>  	/*
>  	 * The bootstrap memblock region count maximum is 128 entries
> @@ -1264,13 +1265,21 @@ void __init e820__memblock_setup(void)
>  		struct e820_entry *entry = &e820_table->entries[i];
>  
>  		end = entry->addr + entry->size;
> +		if (addr < entry->addr)
> +			memblock_reserve(addr, entry->addr - addr);
> +		addr = end;
>  		if (end != (resource_size_t)end)
>  			continue;
>  
> +		/*
> +		 * all !E820_TYPE_RAM ranges (including gap ranges) are put
> +		 * into memblock.reserved to make sure that struct pages in
> +		 * such regions are not left uninitialized after bootup.
> +		 */
>  		if (entry->type != E820_TYPE_RAM && entry->type != E820_TYPE_RESERVED_KERN)
> -			continue;
> -
> -		memblock_add(entry->addr, entry->size);
> +			memblock_reserve(entry->addr, entry->size);
> +		else
> +			memblock_add(entry->addr, entry->size);
>  	}
>  
>  	/* Throw away partial pages: */
> -- 
> 2.7.4

-- 
Michal Hocko
SUSE Labs
