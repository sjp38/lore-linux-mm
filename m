Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1792F6B0007
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 17:23:01 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id 90-v6so3913851pla.18
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 14:23:01 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j9-v6sor1637479plt.45.2018.08.03.14.22.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 03 Aug 2018 14:22:59 -0700 (PDT)
Date: Fri, 3 Aug 2018 14:22:57 -0700
From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH v3 2/2] slab: __GFP_ZERO is incompatible with a
 constructor
Message-ID: <20180803212257.GA5922@roeck-us.net>
References: <20180411060320.14458-1-willy@infradead.org>
 <20180411060320.14458-3-willy@infradead.org>
 <alpine.DEB.2.20.1804110842560.3788@nuc-kabylake>
 <20180411192448.GD22494@bombadil.infradead.org>
 <alpine.DEB.2.20.1804111601090.7458@nuc-kabylake>
 <20180411235652.GA28279@bombadil.infradead.org>
 <alpine.DEB.2.20.1804120907100.11220@nuc-kabylake>
 <20180412142718.GA20398@bombadil.infradead.org>
 <20180412191322.GA21205@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180412191322.GA21205@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Christopher Lameter <cl@linux.com>, linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Mel Gorman <mgorman@techsingularity.net>

Hi,

On Thu, Apr 12, 2018 at 12:13:22PM -0700, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> __GFP_ZERO requests that the object be initialised to all-zeroes,
> while the purpose of a constructor is to initialise an object to a
> particular pattern.  We cannot do both.  Add a warning to catch any
> users who mistakenly pass a __GFP_ZERO flag when allocating a slab with
> a constructor.
> 
> Fixes: d07dbea46405 ("Slab allocators: support __GFP_ZERO in all allocators")
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Acked-by: Michal Hocko <mhocko@suse.com>

Seen with v4.18-rc7-139-gef46808 and v4.18-rc7-178-g0b5b1f9a78b5 when
booting sh4 images in qemu:

ata1: PATA max PIO0 mmio cmd 0xb4001000 ctl 0xb400080c irq 107
physmap platform flash device: 02000001 at 00000000
WARNING: CPU: 0 PID: 926 at mm/slab.c:2666 cache_alloc_refill+0x8a/0x594
Modules linked in:

CPU: 0 PID: 926 Comm: kworker/u2:2 Not tainted 4.18.0-rc7-00139-gef46808 #1
PC is at cache_alloc_refill+0x8a/0x594
PR is at kmem_cache_alloc+0x72/0xac
PC  : 8c0b1e06 SP  : 8fad5ed8 SR  : 400080f0 
TEA : c0087fe0
R0  : 00008000 R1  : 006080c0 R2  : 006080c0 R3  : 8c01e110
R4  : 8f801a00 R5  : 00000000 R6  : 00000000 R7  : 00000000
R8  : 0000000c R9  : 006080c0 R10 : 8c48302c R11 : 8fae8e60
R12 : 8f802540 R13 : 8f801a00 R14 : 8c4f22e8
MACH: 00000085 MACL: 00000e00 GBR : 00000000 PR  : 8c0b244e

Call trace:
 [<(ptrval)>] arch_local_irq_restore+0x0/0x24
 [<(ptrval)>] arch_local_save_flags+0x0/0x8
 [<(ptrval)>] kmem_cache_alloc+0x72/0xac
 [<(ptrval)>] arch_local_irq_restore+0x0/0x24
 [<(ptrval)>] mm_init.isra.7+0xb4/0x104
 [<(ptrval)>] __do_execve_file+0x1f8/0x5b4
 [<(ptrval)>] do_execve+0x16/0x24
 [<(ptrval)>] arch_local_irq_restore+0x0/0x24
 [<(ptrval)>] call_usermodehelper_exec_async+0xe0/0x124
 [<(ptrval)>] ret_from_kernel_thread+0xc/0x14
 [<(ptrval)>] schedule_tail+0x0/0x54
 [<(ptrval)>] call_usermodehelper_exec_async+0x0/0x124

---[ end trace 10ff75dd606d4222 ]---

This is not a a new trace; I had missed it because the "cut here" line
is missing from the log.

qemu command line:

qemu-system-sh4 -M r2d -kernel ./arch/sh/boot/zImage \
	-initrd rootfs.cpio \
	-append 'rdinit=/sbin/init console=ttySC1,115200 noiotrap' \
	-serial null -serial stdio -net nic,model=rtl8139 \
	-net user -nographic -monitor null

Guenter
