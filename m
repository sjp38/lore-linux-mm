Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 923C08E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 11:06:10 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id f31so7872366edf.17
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 08:06:10 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f12si1530144edy.56.2019.01.21.08.06.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jan 2019 08:06:08 -0800 (PST)
Date: Mon, 21 Jan 2019 17:06:07 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [-next 20190118] "kernel BUG at mm/page_alloc.c:3112!"
Message-ID: <20190121160607.GV4087@dhcp22.suse.cz>
References: <20190121154312.GH4020@osiris>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190121154312.GH4020@osiris>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-next@vger.kernel.org, Michael Holzheu <holzheu@linux.ibm.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>

This sounds familiar. Cc Mel and Vlastimil.

On Mon 21-01-19 16:43:12, Heiko Carstens wrote:
> Hello,
> 
> when running with linux-next from 20190118 we saw the BUG_ON at
> mm/page_alloc.c:3112 being hit (see below). This happened on s390
> when using the ltp test suite with the 'oom1' test case.
> So out-of-memory is certainly expected, a BUG_ON being hit however not.
> 
> (note to avoid confusion: the kernel version in the log below contains
>  the build date, not the linux-next version; however 9673b4aa71ca is
>  the corresponding linux-next git commit id).
> 
> [ 3161.555718] sshd: page allocation failure: order:0, mode:0x400000(GFP_NOWAIT), nodemask=(null),cpuset=/,mems_allowed=0
> [ 3161.555721] CPU: 12 PID: 106602 Comm: sshd Not tainted 5.0.0-20190121.rc2.git0.9673b4aa71ca.300.fc29.s390x+next #1
> [ 3161.555723] Hardware name: IBM 2964 NC9 712 (LPAR)
> [ 3161.555724] Call Trace:
> [ 3161.555727] ([<0000000000112e68>] show_stack+0x58/0x70)
> [ 3161.555729]  [<0000000000a6c4a2>] dump_stack+0x7a/0xa8 
> [ 3161.555731]  [<00000000002c0d5a>] warn_alloc+0xe2/0x178 
> [ 3161.555734]  [<00000000002c1eac>] __alloc_pages_nodemask+0x1024/0x1060 
> [ 3161.555736]  [<000000000033755e>] new_slab+0x476/0x618 
> [ 3161.555738]  [<0000000000339d1e>] ___slab_alloc+0x45e/0x590 
> [ 3161.555741]  [<0000000000339e7c>] __slab_alloc+0x2c/0x48 
> [ 3161.555743]  [<000000000033a07c>] kmem_cache_alloc+0x1e4/0x240 
> [ 3161.555745]  [<0000000000647712>] avc_alloc_node+0x32/0x1c0 
> [ 3161.555748]  [<0000000000647bc2>] avc_compute_av+0x7a/0x208 
> [ 3161.555750]  [<00000000006488f4>] avc_has_perm_noaudit+0xa4/0xf8 
> [ 3161.555753]  [<0000000000665c1a>] security_get_user_sids+0x39a/0x578 
> [ 3161.555754]  [<00000000006551dc>] sel_write_user+0x144/0x250 
> [ 3161.555757]  [<0000000000654e2e>] selinux_transaction_write+0x6e/0xa8 
> [ 3161.555759]  [<0000000000364d10>] __vfs_write+0x38/0x1c0 
> [ 3161.555761]  [<0000000000365068>] vfs_write+0xa0/0x1b0 
> [ 3161.555762]  [<0000000000365322>] ksys_write+0x5a/0xc8 
> [ 3161.555765]  [<0000000000a8c438>] system_call+0xdc/0x2c8 
> [ 3161.555767] SLUB: Unable to allocate memory on node -1, gfp=0x408000(GFP_NOWAIT|__GFP_ZERO)
> [ 3161.555769]   cache: avc_node, object size: 72, buffer size: 72, default order: 0, min order: 0
> [ 3161.555771]   node 0: slabs: 276, objs: 15456, free: 0
> [ 3215.347399] ------------[ cut here ]------------
> [ 3215.347407] kernel BUG at mm/page_alloc.c:3112!
> [ 3215.347507] illegal operation: 0001 ilc:1 [#1] SMP 
> [ 3215.347511] Modules linked in: loop kvm xt_tcpudp ip6t_rpfilter ip6t_REJECT nf_reject_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_nat nf_nat_ipv6 ip6table_mangle ip6table_raw ip6table_security iptable_nat nf_nat_ipv4 nf_nat iptable_mangle iptable_raw iptable_security nf_conntrack nf_defrag_ipv6 nf_defrag_ipv4 ip_set nfnetlink ip6table_filter ip6_tables iptable_filter ip_tables x_tables pkey zcrypt rng_core ghash_s390 prng aes_s390 des_s390 des_generic sha512_s390 sha1_s390 eadm_sch sch_fq_codel sha256_s390 sha_common autofs4
> [ 3215.347552] CPU: 6 PID: 98 Comm: kcompactd0 Not tainted 5.0.0-20190121.rc2.git0.9673b4aa71ca.300.fc29.s390x+next #1
> [ 3215.347554] Hardware name: IBM 2964 NC9 712 (LPAR)
> [ 3215.347557] Krnl PSW : 0404d00180000000 00000000002bf182 (__isolate_free_page+0x212/0x218)
> [ 3215.347567]            R:0 T:1 IO:0 EX:0 Key:0 M:1 W:0 P:0 AS:3 CC:1 PM:0 RI:0 EA:3
> [ 3215.347570] Krnl GPRS: 00000000001b8d00 0000000100000080 00000001ffffec38 00000000f0000000
> [ 3215.347573]            00000001ffffec40 0000000000176500 0000000000000007 00000001ffffec38
> [ 3215.347576]            0000000000000007 00000001ffffe8c0 000003d000000040 000003d000000007
> [ 3215.347579]            000003e0038b7dc0 fffffff0c5ffff00 000003e0038b7ae0 000003e0038b7a80
> [ 3215.347590] Krnl Code: 00000000002bf172: eb6ff0a80004	lmg	%r6,%r15,168(%r15)
>                           00000000002bf178: c0f4003e73ec	brcl	15,a8d950
>                          #00000000002bf17e: a7f40001		brc	15,2bf180
>                          >00000000002bf182: 0707		bcr	0,%r7
>                           00000000002bf184: 0707		bcr	0,%r7
>                           00000000002bf186: 0707		bcr	0,%r7
>                           00000000002bf188: c00400000000	brcl	0,2bf188
>                           00000000002bf18e: eb6ff0480024	stmg	%r6,%r15,72(%r15)
> [ 3215.347638] Call Trace:
> [ 3215.347641] ([<000003d085d96000>] 0x3d085d96000)
> [ 3215.347645]  [<00000000002f0b74>] compaction_alloc+0x394/0x9c8 
> [ 3215.347649]  [<0000000000342d52>] migrate_pages+0x1d2/0xaf0 
> [ 3215.347652]  [<00000000002f29a0>] compact_zone+0x620/0xf20 
> [ 3215.347654]  [<00000000002f3600>] kcompactd_do_work+0x130/0x268 
> [ 3215.347656]  [<00000000002f37d0>] kcompactd+0x98/0x1d0 
> [ 3215.347661]  [<000000000016920c>] kthread+0x144/0x160 
> [ 3215.347665]  [<0000000000a8c652>] kernel_thread_starter+0xa/0x10 
> [ 3215.347667]  [<0000000000a8c648>] kernel_thread_starter+0x0/0x10 
> [ 3215.347669] Last Breaking-Event-Address:
> [ 3215.347671]  [<00000000002bf17e>] __isolate_free_page+0x20e/0x218
> [ 3215.347674] Kernel panic - not syncing: Fatal exception: panic_on_oops
> 
> FWIW, if it helps: the address of the struct page in question is in
> register 2 and the memory dump (using 'crash') of it looks like this:
> 
> > struct page -x 1ffffec38
> struct page {
>   flags = 0x3d0832bb008, 
>   {
>     {
>       lru = {
>         next = 0x3d084e79008, 
>         prev = 0x1ffffeca8
>       }, 
>       mapping = 0x1ffffec50, 
>       index = 0x1ffffec50, 
>       private = 0x3d0855e3008
>     }, 
>     {
>       {
>         slab_list = {
>           next = 0x3d084e79008, 
>           prev = 0x1ffffeca8
>         }, 
>         {
>           next = 0x3d084e79008, 
>           pages = 0x1, 
>           pobjects = 0xffffeca8
>         }
>       }, 
>       slab_cache = 0x1ffffec50, 
>       freelist = 0x1ffffec50, 
>       {
>         s_mem = 0x3d0855e3008, 
>         counters = 0x3d0855e3008, 
>         {
>           inuse = 0x0, 
>           objects = 0x1e8, 
>           frozen = 0x0
>         }
>       }
>     }, 
>     {
>       compound_head = 0x3d084e79008, 
>       compound_dtor = 0x0, 
>       compound_order = 0x0, 
>       compound_mapcount = {
>         counter = 0xffffeca8
>       }
>     }, 
>     {
>       _compound_pad_1 = 0x3d084e79008, 
>       _compound_pad_2 = 0x1ffffeca8, 
>       deferred_list = {
>         next = 0x1ffffec50, 
>         prev = 0x1ffffec50
>       }
>     }, 
>     {
>       _pt_pad_1 = 0x3d084e79008, 
>       pmd_huge_pte = 0x1ffffeca8, 
>       _pt_pad_2 = 0x1ffffec50, 
>       {
>         pt_mm = 0x1ffffec50, 
>         pt_frag_refcount = {
>           counter = 0x1
>         }
>       }, 
>       ptl = {
>         {
>           rlock = {
>             raw_lock = {
>               lock = 0x3d0
>             }
>           }
>         }
>       }
>     }, 
>     {
>       pgmap = 0x3d084e79008, 
>       hmm_data = 0x1ffffeca8, 
>       _zd_pad_1 = 0x1ffffec50
>     }, 
>     callback_head = {
>       next = 0x3d084e79008, 
>       func = 0x1ffffeca8
>     }
>   }, 
>   {
>     _mapcount = {
>       counter = 0x3d0
>     }, 
>     page_type = 0x3d0, 
>     active = 0x3d0, 
>     units = 0x3d0
>   }, 
>   _refcount = {
>     counter = 0x855e3008
>   }, 
>   mem_cgroup = 0x1ffffec70
> }

-- 
Michal Hocko
SUSE Labs
