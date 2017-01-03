Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 275CC6B0069
	for <linux-mm@kvack.org>; Tue,  3 Jan 2017 09:39:00 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id 128so609841233oig.4
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 06:39:00 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id f68si30324635oig.51.2017.01.03.06.38.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Jan 2017 06:38:58 -0800 (PST)
Subject: Re: [PATCH 0/3 -v3] GFP_NOFAIL cleanups
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20161220134904.21023-1-mhocko@kernel.org>
	<20170102154858.GC18048@dhcp22.suse.cz>
	<201701031036.IBE51044.QFLFSOHtFOJVMO@I-love.SAKURA.ne.jp>
	<20170103084211.GB30111@dhcp22.suse.cz>
In-Reply-To: <20170103084211.GB30111@dhcp22.suse.cz>
Message-Id: <201701032338.EFH69294.VOMSHFLOFOtQFJ@I-love.SAKURA.ne.jp>
Date: Tue, 3 Jan 2017 23:38:30 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, rientjes@google.com, mgorman@suse.de, hillf.zj@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Tue 03-01-17 10:36:31, Tetsuo Handa wrote:
> [...]
> > I'm OK with "[PATCH 1/3] mm: consolidate GFP_NOFAIL checks in the allocator
> > slowpath" given that we describe that we make __GFP_NOFAIL stronger than
> > __GFP_NORETRY with this patch in the changelog.
> 
> Again. __GFP_NORETRY | __GFP_NOFAIL is nonsense! I do not really see any
> reason to describe all the nonsense combinations of gfp flags.

Before [PATCH 1/3]:

  __GFP_NORETRY is used as "Do not invoke the OOM killer. Fail allocation
  request even if __GFP_NOFAIL is specified if direct reclaim/compaction
  did not help."

  __GFP_NOFAIL is used as "Never fail allocation request unless __GFP_NORETRY
  is specified even if direct reclaim/compaction did not help."

After [PATCH 1/3]:

  __GFP_NORETRY is used as "Do not invoke the OOM killer. Fail allocation
  request unless __GFP_NOFAIL is specified."

  __GFP_NOFAIL is used as "Never fail allocation request even if direct
  reclaim/compaction did not help. Invoke the OOM killer unless __GFP_NORETRY is
  specified."

Thus, __GFP_NORETRY | __GFP_NOFAIL perfectly makes sense as
"Never fail allocation request if direct reclaim/compaction did not help.
But do not invoke the OOM killer even if direct reclaim/compaction did not help."

> 
> > But I don't think "[PATCH 2/3] mm, oom: do not enfore OOM killer for __GFP_NOFAIL
> > automatically" is correct. Firstly, we need to confirm
> > 
> >   "The pre-mature OOM killer is a real issue as reported by Nils Holland"
> > 
> > in the changelog is still true because we haven't tested with "[PATCH] mm, memcg:
> > fix the active list aging for lowmem requests when memcg is enabled" applied and
> > without "[PATCH 2/3] mm, oom: do not enfore OOM killer for __GFP_NOFAIL
> > automatically" and "[PATCH 3/3] mm: help __GFP_NOFAIL allocations which do not
> > trigger OOM killer" applied.
> 
> Yes I have dropped the reference to this report already in my local
> patch because in this particular case the issue was somewhere else
> indeed!

OK.

> 
> > Secondly, as you are using __GFP_NORETRY in "[PATCH] mm: introduce kv[mz]alloc
> > helpers" as a mean to enforce not to invoke the OOM killer
> > 
> > 	/*
> > 	 * Make sure that larger requests are not too disruptive - no OOM
> > 	 * killer and no allocation failure warnings as we have a fallback
> > 	 */
> > 	if (size > PAGE_SIZE)
> > 		kmalloc_flags |= __GFP_NORETRY | __GFP_NOWARN;
> > 
> > , we can use __GFP_NORETRY as a mean to enforce not to invoke the OOM killer
> > rather than applying "[PATCH 2/3] mm, oom: do not enfore OOM killer for
> > __GFP_NOFAIL automatically".
> > 

As I wrote above, __GFP_NORETRY | __GFP_NOFAIL perfectly makes sense.

> > Additionally, although currently there seems to be no
> > kv[mz]alloc(GFP_KERNEL | __GFP_NOFAIL) users, kvmalloc_node() in
> > "[PATCH] mm: introduce kv[mz]alloc helpers" will be confused when a
> > kv[mz]alloc(GFP_KERNEL | __GFP_NOFAIL) user comes in in the future because
> > "[PATCH 1/3] mm: consolidate GFP_NOFAIL checks in the allocator slowpath" makes
> > __GFP_NOFAIL stronger than __GFP_NORETRY.
> 
> Using NOFAIL in kv[mz]alloc simply makes no sense at all. The vmalloc
> fallback would be simply unreachable!

My intention is shown below.

 void *kvmalloc_node(size_t size, gfp_t flags, int node)
 {
 	gfp_t kmalloc_flags = flags;
 	void *ret;
 
 	/*
 	 * vmalloc uses GFP_KERNEL for some internal allocations (e.g page tables)
 	 * so the given set of flags has to be compatible.
 	 */
 	WARN_ON_ONCE((flags & GFP_KERNEL) != GFP_KERNEL);
 
 	/*
 	 * Make sure that larger requests are not too disruptive - no OOM
 	 * killer and no allocation failure warnings as we have a fallback
 	 */
-	if (size > PAGE_SIZE)
+	if (size > PAGE_SIZE) {
 		kmalloc_flags |= __GFP_NORETRY | __GFP_NOWARN;
+		kmalloc_flags &= ~__GFP_NOFAIL;
+	}
 
 	ret = kmalloc_node(size, kmalloc_flags, node);
 
 	/*
 	 * It doesn't really make sense to fallback to vmalloc for sub page
 	 * requests
 	 */
 	if (ret || size <= PAGE_SIZE)
 		return ret;
 
 	return __vmalloc_node_flags(size, node, flags);
 }

> 
> > My concern with "[PATCH 3/3] mm: help __GFP_NOFAIL allocations which
> > do not trigger OOM killer" is
> > 
> >   "AFAIU, this is an allocation path which doesn't block a forward progress
> >    on a regular IO. It is merely a check whether there is a new medium in
> >    the CDROM (aka regular polling of the device). I really fail to see any
> >    reason why this one should get any access to memory reserves at all."
> > 
> > in http://lkml.kernel.org/r/20161218163727.GC8440@dhcp22.suse.cz .
> > Indeed that trace is a __GFP_DIRECT_RECLAIM and it might not be blocking
> > other workqueue items which a regular I/O depend on, I think there are
> > !__GFP_DIRECT_RECLAIM memory allocation requests for issuing SCSI commands
> > which could potentially start failing due to helping GFP_NOFS | __GFP_NOFAIL
> > allocations with memory reserves. If a SCSI disk I/O request fails due to
> > GFP_ATOMIC memory allocation failures because we allow a FS I/O request to
> > use memory reserves, it adds a new problem.
> 
> Do you have any example of such a request? Anything that requires
> a forward progress during IO should be using mempools otherwise it
> is broken pretty much by design already. Also IO depending on NOFS
> allocations sounds pretty much broken already. So I suspect the above
> reasoning is just bogus.

You are missing my point. My question is "who needs memory reserves".
I'm not saying that disk I/O depends on GFP_NOFS allocation. I'm worrying
that [PATCH 3/3] consumes memory reserves when disk I/O also depends on
memory reserves.

My understanding is that when accessing SCSI disks, SCSI protocol is used.
SCSI driver allocates memory at runtime for using SCSI protocol using
GFP_ATOMIC. And GFP_ATOMIC uses some of memory reserves. But [PATCH 3/3]
also uses memory reserves. If memory reserves are consumed by [PATCH 3/3]
to the level where GFP_ATOMIC cannot succeed, I think it causes troubles.

I'm unable to obtain nice backtraces, but I think we can confirm that
there are GFP_ATOMIC allocations (e.g. sg_alloc_table_chained() calls
__sg_alloc_table(GFP_ATOMIC)) when we are using SCSI disks.

stap -DSTAP_NO_OVERLOAD=1 -DMAXSKIPPED=10000000 -e 'global in_scope; global traces;
probe begin { println("Ready."); }
probe kernel.function("scsi_*").call { in_scope[tid()]++; }
probe kernel.function("scsi_*").return { in_scope[tid()]--; }
probe kernel.function("__alloc_pages_nodemask") {
  if (in_scope[tid()] != 0) {
    bt = backtrace();
    if (!([bt,$gfp_mask] in traces)) {
      traces[bt,$gfp_mask] = 1;
      printf("mode=0x%x,order=%u by %s(%u)\n",
             $gfp_mask, $order, execname(), pid());
      print_backtrace();
      println();
    }
  }
}'

[  183.887841] ------------[ cut here ]------------
[  183.888847] WARNING: CPU: 0 PID: 0 at /root/systemtap.tmp/share/systemtap/runtime/linux/addr-map.c:42 lookup_bad_addr.isra.33+0x84/0x90 [stap_40159b816dfa3e3814a532dc982f551b_1_4182]
[  183.892011] Modules linked in: stap_40159b816dfa3e3814a532dc982f551b_1_4182(O) nf_conntrack_netbios_ns nf_conntrack_broadcast ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter coretemp crct10dif_pclmul crc32_pclmul ghash_clmulni_intel aesni_intel crypto_simd cryptd glue_helper vmw_vsock_vmci_transport ppdev vmw_balloon vsock pcspkr sg parport_pc parport vmw_vmci i2c_piix4 shpchp ip_tables xfs libcrc32c sd_mod sr_mod cdrom ata_generic pata_acpi crc32c_intel
[  183.905779]  serio_raw mptspi scsi_transport_spi vmwgfx mptscsih ahci drm_kms_helper libahci syscopyarea sysfillrect mptbase sysimgblt fb_sys_fops ttm ata_piix drm e1000 i2c_core libata
[  183.909128] CPU: 0 PID: 0 Comm: swapper/0 Tainted: G           O    4.10.0-rc2-next-20170103 #486
[  183.910839] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[  183.912815] Call Trace:
[  183.913326]  <IRQ>
[  183.913729]  dump_stack+0x85/0xc9
[  183.914366]  __warn+0xd1/0xf0
[  183.914930]  warn_slowpath_null+0x1d/0x20
[  183.915691]  lookup_bad_addr.isra.33+0x84/0x90 [stap_40159b816dfa3e3814a532dc982f551b_1_4182]
[  183.917539]  unwind_frame.constprop.79+0xbed/0x1270 [stap_40159b816dfa3e3814a532dc982f551b_1_4182]
[  183.919238]  _stp_stack_kernel_get+0x16e/0x4d0 [stap_40159b816dfa3e3814a532dc982f551b_1_4182]
[  183.920870]  ? gfp_pfmemalloc_allowed+0x80/0x80
[  183.921737]  _stp_stack_kernel_print+0x3e/0xc0 [stap_40159b816dfa3e3814a532dc982f551b_1_4182]
[  183.923583]  probe_3838+0x1f6/0x8c0 [stap_40159b816dfa3e3814a532dc982f551b_1_4182]
[  183.925005]  ? __alloc_pages_nodemask+0x1/0x4e0
[  183.925875]  ? __alloc_pages_nodemask+0x1/0x4e0
[  183.926724]  ? __alloc_pages_nodemask+0x1/0x4e0
[  183.927598]  enter_kprobe_probe+0x1e5/0x310 [stap_40159b816dfa3e3814a532dc982f551b_1_4182]
[  183.929164]  kprobe_ftrace_handler+0xe9/0x150
[  183.930260]  ? __alloc_pages_nodemask+0x5/0x4e0
[  183.931123]  ftrace_ops_assist_func+0xbf/0x110
[  183.932012]  ? sched_clock+0x9/0x10
[  183.932815]  ? sched_clock_cpu+0x84/0xb0
[  183.933550]  0xffffffffa00430d5
[  183.934947]  ? gfp_pfmemalloc_allowed+0x80/0x80
[  183.936581]  __alloc_pages_nodemask+0x5/0x4e0
[  183.938409]  alloc_pages_current+0x97/0x1b0
[  183.939971]  ? __alloc_pages_nodemask+0x5/0x4e0
[  183.941567]  ? alloc_pages_current+0x97/0x1b0
[  183.943173]  new_slab+0x3a8/0x6a0
[  183.944702]  ___slab_alloc+0x3a3/0x620
[  183.946157]  ? stp_lock_probe+0x4a/0xb0 [stap_40159b816dfa3e3814a532dc982f551b_1_4182]
[  183.948375]  ? mempool_alloc_slab+0x1c/0x20
[  183.950135]  ? mempool_alloc_slab+0x1c/0x20
[  183.951957]  __slab_alloc+0x46/0x7d
[  183.953415]  ? mempool_alloc_slab+0x1c/0x20
[  183.955001]  kmem_cache_alloc+0x2e8/0x370
[  183.956552]  ? aggr_pre_handler+0x3f/0x80
[  183.958428]  mempool_alloc_slab+0x1c/0x20
[  183.960042]  mempool_alloc+0x79/0x1b0
[  183.961512]  ? kprobe_ftrace_handler+0xa3/0x150
[  183.963082]  ? scsi_init_io+0x5/0x1d0
[  183.964501]  sg_pool_alloc+0x45/0x50
[  183.966064]  __sg_alloc_table+0xdf/0x150
[  183.967402]  ? sg_free_table_chained+0x30/0x30
[  183.969030]  sg_alloc_table_chained+0x3f/0x90
[  183.970405]  scsi_init_sgtable+0x31/0x70
[  183.971783]  copy_oldmem_page+0xd0/0xd0
[  183.973506]  copy_oldmem_page+0xd0/0xd0
[  183.974802]  sd_init_command+0x3c/0xb0 [sd_mod]
[  183.976187]  scsi_setup_cmnd+0xf0/0x150
[  183.977617]  copy_oldmem_page+0xd0/0xd0
[  183.978849]  ? scsi_prep_fn+0x5/0x170
[  183.980119]  copy_oldmem_page+0xd0/0xd0
[  183.981406]  scsi_request_fn+0x42/0x740
[  183.982760]  ? scsi_request_fn+0x5/0x740
[  183.984049]  copy_oldmem_page+0xd0/0xd0
[  183.985438]  blk_run_queue+0x26/0x40
[  183.986751]  scsi_kick_queue+0x25/0x30
[  183.987891]  copy_oldmem_page+0xd0/0xd0
[  183.989073]  copy_oldmem_page+0xd0/0xd0
[  183.990175]  copy_oldmem_page+0xd0/0xd0
[  183.991348]  copy_oldmem_page+0xd0/0xd0
[  183.992450]  copy_oldmem_page+0xd0/0xd0
[  183.993677]  blk_done_softirq+0xa8/0xd0
[  183.994766]  __do_softirq+0xc0/0x52d
[  183.995792]  irq_exit+0xf5/0x110
[  183.996748]  smp_call_function_single_interrupt+0x33/0x40
[  183.998230]  call_function_single_interrupt+0x9d/0xb0
[  183.999521] RIP: 0010:native_safe_halt+0x6/0x10
[  184.000791] RSP: 0018:ffffffff81c03dd0 EFLAGS: 00000202 ORIG_RAX: ffffffffffffff04
[  184.002749] RAX: ffffffff81c18500 RBX: 0000000000000000 RCX: 0000000000000000
[  184.004440] RDX: ffffffff81c18500 RSI: 0000000000000001 RDI: ffffffff81c18500
[  184.006281] RBP: ffffffff81c03dd0 R08: 0000000000000000 R09: 0000000000000000
[  184.008063] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000000
[  184.009842] R13: ffffffff81c18500 R14: ffffffff81c18500 R15: 0000000000000000
[  184.011758]  </IRQ>
[  184.012952]  default_idle+0x23/0x1d0
[  184.014085]  arch_cpu_idle+0xf/0x20
[  184.015204]  default_idle_call+0x23/0x40
[  184.016347]  do_idle+0x162/0x230
[  184.017353]  cpu_startup_entry+0x71/0x80
[  184.018686]  rest_init+0x138/0x140
[  184.019961]  ? rest_init+0x5/0x140
[  184.021034]  start_kernel+0x4ba/0x4db
[  184.022305]  ? set_init_arg+0x55/0x55
[  184.023405]  ? early_idt_handler_array+0x120/0x120
[  184.024730]  x86_64_start_reservations+0x2a/0x2c
[  184.026121]  x86_64_start_kernel+0x14c/0x16f
[  184.027329]  start_cpu+0x14/0x14
[  184.028391] ---[ end trace cbfebb3ae93a99b9 ]---

> 
> That being said, to summarize your arguments again. 1) you do not like
> that a combination of __GFP_NORETRY | __GFP_NOFAIL is not documented
> to never fail,

Correct.

>                2) based on that you argue that kv[mvz]alloc with
> __GFP_NOFAIL will never reach vmalloc

Wrong.

>                                       and 3) that there might be some IO
> paths depending on NOFS|NOFAIL allocation which would have harder time
> to make forward progress.

Wrong.

> 
> I would call 1 and 2 just bogus and 3 highly dubious at best. Do not
> get me wrong but this is not what I call a useful review feedback yet
> alone a reason to block these patches. If there are any reasons to not
> merge them these are not those.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
