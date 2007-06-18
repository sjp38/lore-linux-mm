Received: by mu-out-0910.google.com with SMTP id g7so1790218muf
        for <linux-mm@kvack.org>; Mon, 18 Jun 2007 04:58:33 -0700 (PDT)
Message-ID: <46767346.2040108@googlemail.com>
Date: Mon, 18 Jun 2007 13:57:58 +0200
MIME-Version: 1.0
Subject: Re: [patch 00/26] Current slab allocator / SLUB patch queue
References: <20070618095838.238615343@sgi.com>
In-Reply-To: <20070618095838.238615343@sgi.com>
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 8bit
From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, suresh.b.siddha@intel.com
List-ID: <linux-mm.kvack.org>

Hi,

clameter@sgi.com pisze:
> These contain the following groups of patches:
> 
> 1. Slab allocator code consolidation and fixing of inconsistencies
> 
> This makes ZERO_SIZE_PTR generic so that it works in all
> slab allocators.
> 
> It adds __GFP_ZERO support to all slab allocators and
> cleans up the zeroing in the slabs and provides modifications
> to remove explicit zeroing following kmalloc_node and
> kmem_cache_alloc_node calls.
> 
> 2. SLUB improvements
> 
> Inline some small functions to reduce code size. Some more memory
> optimizations using CONFIG_SLUB_DEBUG. Changes to handling of the
> slub_lock and an optimization of runtime determination of kmalloc slabs
> (replaces ilog2 patch that failed with gcc 3.3 on powerpc).
> 
> 3. Slab defragmentation
> 
> This is V3 of the patchset with the one fix for the locking problem that
> showed up during testing.
> 
> 4. Performance optimizations
> 
> These patches have a long history since the early drafts of SLUB. The
> problem with these patches is that they require the touching of additional
> cachelines (only for read) and SLUB was designed for minimal cacheline
> touching. In doing so we may be able to remove cacheline bouncing in
> particular for remote alloc/ free situations where I have had reports of
> issues that I was not able to confirm for lack of specificity. The tradeoffs
> here are not clear. Certainly the larger cacheline footprint will hurt the
> casual slab user somewhat but it will benefit processes that perform these
> local/remote alloc/free operations.
> 
> I'd appreciate if someone could evaluate these.
> 
> The complete patchset against 2.6.22-rc4-mm2 is available at
> 
> http://ftp.kernel.org/pub/linux/kernel/people/christoph/slub/2.6.22-rc4-mm2
> 
> Tested on
> 
> x86_64 SMP
> x86_64 NUMA emulation
> IA64 emulator
> Altix 64p/128G NUMA system.
> Altix 8p/6G asymmetric NUMA system.
> 
> 

Testcase:

#! /bin/sh

for i in `find /sys/ -type f`
do
    echo "wy?wietlam $i"
    sudo cat $i > /dev/null
#    sleep 1s
done

Result:

[  212.247759] WARNING: at lib/vsprintf.c:280 vsnprintf()
[  212.253263]  [<c04052ad>] dump_trace+0x63/0x1eb
[  212.259042]  [<c040544f>] show_trace_log_lvl+0x1a/0x2f
[  212.266672]  [<c040608d>] show_trace+0x12/0x14
[  212.271622]  [<c04060a5>] dump_stack+0x16/0x18
[  212.276663]  [<c050d512>] vsnprintf+0x6b/0x48c
[  212.281325]  [<c050d9f0>] scnprintf+0x20/0x2d
[  212.286707]  [<c0508dbc>] bitmap_scnlistprintf+0xa8/0xec
[  212.292508]  [<c0480d40>] list_locations+0x24c/0x2a2
[  212.298241]  [<c0480dde>] alloc_calls_show+0x1f/0x26
[  212.303459]  [<c047e72e>] slab_attr_show+0x1c/0x20
[  212.309469]  [<c04c1cf9>] sysfs_read_file+0x94/0x105
[  212.315519]  [<c0485933>] vfs_read+0xcf/0x158
[  212.320215]  [<c0485d99>] sys_read+0x3d/0x72
[  212.327539]  [<c040420c>] syscall_call+0x7/0xb
[  212.332203]  [<b7f74410>] 0xb7f74410
[  212.336229]  =======================

Unfortunately, I don't know which file was cat'ed

http://www.stardust.webpages.pl/files/tbf/bitis-gabonica/2.6.22-rc4-mm2-slub/slub-config
http://www.stardust.webpages.pl/files/tbf/bitis-gabonica/2.6.22-rc4-mm2-slub/slub-dmesg

Regards,
Michal

-- 
LOG
http://www.stardust.webpages.pl/log/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
