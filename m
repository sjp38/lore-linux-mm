Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 09B036B0036
	for <linux-mm@kvack.org>; Fri, 16 Aug 2013 13:17:05 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id kp13so2106060pab.35
        for <linux-mm@kvack.org>; Fri, 16 Aug 2013 10:17:05 -0700 (PDT)
From: Kevin Hilman <khilman@linaro.org>
Subject: Re: [patch v2 3/3] mm: page_alloc: fair zone allocator policy
References: <1375457846-21521-1-git-send-email-hannes@cmpxchg.org>
	<1375457846-21521-4-git-send-email-hannes@cmpxchg.org>
	<20130807145828.GQ2296@suse.de> <20130807153743.GH715@cmpxchg.org>
	<20130808041623.GL1845@cmpxchg.org>
Date: Fri, 16 Aug 2013 10:17:01 -0700
In-Reply-To: <20130808041623.GL1845@cmpxchg.org> (Johannes Weiner's message of
	"Thu, 8 Aug 2013 00:16:23 -0400")
Message-ID: <87haepblo2.fsf@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@surriel.com>, Andrea Arcangeli <aarcange@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, sfr@canb.auug.org.au, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Olof Johansson <olof@lixom.net>, Stephen Warren <swarren@wwwdotorg.org>

[resend, gmail sent the other in HTML, sorry]

Hi Johannes,

Johannes Weiner <hannes@cmpxchg.org> writes:

> On Wed, Aug 07, 2013 at 11:37:43AM -0400, Johannes Weiner wrote:

[...]

> Patch on top of mmotm:
>
> ---
> From: Johannes Weiner <hannes@cmpxchg.org>
> Subject: [patch] mm: page_alloc: use vmstats for fair zone allocation batching
>
> Avoid dirtying the same cache line with every single page allocation
> by making the fair per-zone allocation batch a vmstat item, which will
> turn it into batched percpu counters on SMP.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

I bisected several boot failures on various ARM platform in
next-20130816 down to this patch (commit 67131f9837 in linux-next.)

Simply reverting it got things booting again on top of -next.  Example
boot crash below.

Kevin

[    0.000000] Booting Linux on physical CPU 0x0
[    0.000000] Linux version 3.11.0-rc5-next-20130816 (khilman@paris) (gcc version 4.7.2 (Ubuntu/Linaro 4.7.2-1ubuntu1) ) #30 SMP Fri Aug 16 09:47:32 PDT 2013
[    0.000000] CPU: ARMv7 Processor [413fc082] revision 2 (ARMv7), cr=10c53c7d
[    0.000000] CPU: PIPT / VIPT nonaliasing data cache, VIPT aliasing instruction cache
[    0.000000] Machine: Generic AM33XX (Flattened Device Tree), model: TI AM335x BeagleBone
[    0.000000] bootconsole [earlycon0] enabled
[    0.000000] Memory policy: ECC disabled, Data cache writeback
[    0.000000] On node 0 totalpages: 130816
[    0.000000] free_area_init_node: node 0, pgdat c081d400, node_mem_map c12fc000
[    0.000000]   Normal zone: 1024 pages used for memmap
[    0.000000]   Normal zone: 0 pages reserved
[    0.000000] Unable to handle kernel NULL pointer dereference at virtual address 00000026
[    0.000000] pgd = c0004000
[    0.000000] [00000026] *pgd=00000000
[    0.000000] Internal error: Oops: 5 [#1] SMP ARM
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 3.11.0-rc5-next-20130816 #30
[    0.000000] task: c0793c70 ti: c0788000 task.ti: c0788000
[    0.000000] PC is at __mod_zone_page_state+0x2c/0xb4
[    0.000000] LR is at mod_zone_page_state+0x2c/0x4c
[    0.000000] pc : [<c00eb628>]    lr : [<c00ebbf0>]    psr: 60000193
[    0.000000] sp : c0789e84  ip : 00000026  fp : c0789ef8
[    0.000000] r10: c0789f04  r9 : c05149dc  r8 : 00000000
[    0.000000] r7 : 00000026  r6 : 00000000  r5 : c0791770  r4 : c0788000
[    0.000000] r3 : 00000000  r2 : 0001fb00  r1 : 00000001  r0 : c081d400
[    0.000000] Flags: nZCv  IRQs off  FIQs on  Mode SVC_32  ISA ARM  Segment kernel
[    0.000000] Control: 10c5387d  Table: 80004019  DAC: 00000017
[    0>.000000] Process swapper (pid: 0, stack limit = 0xc0788240)
[    0.000000] Stack: (0xc0789e84 to 0xc078a000)
[    0.000000] 9e80:          60000193 0001fb00 00000001 c081d400 c0781570 c081d400 c081d400
[    0.000000] 9ea0: 00000000 0001fb00 00020000 c0747dd4 c077c5f4 00000001 0009ff00 0001fb00
[    0.000000] 9ec0: 00000400 00080000 00000000 bfffffff c07ebfb0 000a0000 c0789ef8 00080000
[    0.000000] 9ee0: 000a0000 00020000 000001cf c07ec188 000000cf c072ef2c 00020000 00000000
[    0.000000] 9f00: 00000000 00000100 00000000 00000000 00000000 00000000 c0821d0c dfefa000
[    0.000000] 9f20: c07ebfb0 00000001 00000001 c073080c c0789fdc c076abd4 ffff1000 0009feff
[    0.000000] 9f40: 00001000 00000007 c0734a14 c076abd4 c0821ca0 c0008000 c076c8f0 c07ec188
[    0.000000] 9f60: 413fc082 c0789fdc c064b328 c072cc3c 00000000 10c53c7d c0d5e448 00000001
[    0.000000] 9f80: 00000000 c076c8ec c079542c 80004059 413fc082 00000000 00000000 c04f6298
[    0.000000] 9fa0: c064989c 00000001 00000000 c076c8ec c079542c 80004059 413fc082 00000000
[    0.000000] 9fc0: 00000000 c07297ec 00000000 00000000 00000000 00000000 00000000 c076c8f0
[    0.000000] 9fe0: 00000000 10c53c7d c07908e8 c076c8ec c079542c 80008074 00000000 00000000
[    0.000000] [<c00eb628>] (__mod_zone_page_state+0x2c/0xb4) from [<c081d400>] (contig_page_data+0x0/0xd80)
[    0.000000] Code: e7958103 e0867001 e2877025 e1a0c007 (e19cc0d8) 
[    0.000000] ---[ end trace 1b75b31a2719ed1c ]---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
