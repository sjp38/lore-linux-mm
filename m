Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 5E8286B0031
	for <linux-mm@kvack.org>; Wed,  5 Feb 2014 06:24:53 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa1so243711pad.14
        for <linux-mm@kvack.org>; Wed, 05 Feb 2014 03:24:52 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id q6si28586598pbf.334.2014.02.05.03.24.51
        for <linux-mm@kvack.org>;
        Wed, 05 Feb 2014 03:24:52 -0800 (PST)
Date: Wed, 5 Feb 2014 19:24:49 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [slub] WARNING: CPU: 1 PID: 1 at mm/slub.c:992 deactivate_slab()
Message-ID: <20140205112449.GB18849@localhost>
References: <20140205072558.GC9379@localhost>
 <alpine.DEB.2.02.1402050009200.7839@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1402050009200.7839@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Feb 05, 2014 at 12:10:48AM -0800, David Rientjes wrote:
> On Wed, 5 Feb 2014, Fengguang Wu wrote:
> 
> > Greetings,
> > 
> > I got the below dmesg and the first bad commit is in upstream 
> > 
> > commit c65c1877bd6826ce0d9713d76e30a7bed8e49f38
> > Author:     Peter Zijlstra <peterz@infradead.org>
> > AuthorDate: Fri Jan 10 13:23:49 2014 +0100
> > Commit:     Pekka Enberg <penberg@kernel.org>
> > CommitDate: Mon Jan 13 21:34:39 2014 +0200
> > 
> >     slub: use lockdep_assert_held
> >     
> >     Instead of using comments in an attempt at getting the locking right,
> >     use proper assertions that actively warn you if you got it wrong.
> >     
> >     Also add extra braces in a few sites to comply with coding-style.
> >     
> >     Signed-off-by: Peter Zijlstra <peterz@infradead.org>
> >     Signed-off-by: Pekka Enberg <penberg@kernel.org>
> > 
> > ===================================================
> > PARENT COMMIT NOT CLEAN. LOOK OUT FOR WRONG BISECT!
> > ===================================================
> > 
> > +---------------------------------------------------------+--------------+--------------+
> > |                                                         | 8afb1474db47 | 1738cc0ecc54 |
> > +---------------------------------------------------------+--------------+--------------+
> > | boot_successes                                          | 166          | 6            |
> > | boot_failures                                           | 10           | 13           |
> > | BUG:kernel_test_crashed                                 | 9            | 1            |
> > | WARNING:CPU:PID:at_arch/x86/kernel/cpu/amd.c:init_amd() | 1            |              |
> > | WARNING:CPU:PID:at_mm/slub.c:deactivate_slab()          | 0            | 12           |
> > +---------------------------------------------------------+--------------+--------------+
> > 
> > [1868680.126265] netconsole: network logging started
> > [1868680.135018] Unregister pv shared memory for cpu 0
> > [1868680.523086] ------------[ cut here ]------------
> > [1868680.526909] WARNING: CPU: 1 PID: 1 at mm/slub.c:992 deactivate_slab+0x4ce/0xa70()
> > [1868680.537875] Modules linked in:
> > [1868680.541340] CPU: 1 PID: 1 Comm: swapper/0 Not tainted 3.13.0-02621-g1738cc0 #8
> > [1868680.555880] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> > [1868680.565937]  ffffffff ce04dd64 c1a6323f 00000000 00000000 000003e0 ce04dd94 c106fbe1
> > [1868680.572881]  c1efb154 00000001 00000001 c1f09c28 000003e0 c11c2d0e c11c2d0e 00000001
> > [1868680.582142]  ce5db280 ce000640 ce04dda4 c106fc7d 00000009 00000000 ce04de0c c11c2d0e
> > [1868680.589099] Call Trace:
> > [1868680.591109]  [<c1a6323f>] dump_stack+0x7a/0xdb
> > [1868680.593887]  [<c106fbe1>] warn_slowpath_common+0x91/0xb0
> > [1868680.597430]  [<c11c2d0e>] ? deactivate_slab+0x4ce/0xa70
> > [1868680.600510]  [<c11c2d0e>] ? deactivate_slab+0x4ce/0xa70
> > [1868680.603588]  [<c106fc7d>] warn_slowpath_null+0x1d/0x20
> > [1868680.606728]  [<c11c2d0e>] deactivate_slab+0x4ce/0xa70
> 
> Hi Fengguang, 
> 
> I think this is the inlined add_full() and should be fixed with 
> http://marc.info/?l=linux-kernel&m=139147105027693 that has been added to 
> the -mm tree and should now be in next.  Is this patch included for this 
> kernel?

Hi David,

According to the bisect log, linux-next 20140204 is bad, but it does
not yet include your fix.

git bisect  bad 38dbfb59d1175ef458d006556061adeaa8751b72  # 23:16      0-      2  Linus 3.14-rc1
git bisect  bad cdd263faccc2184e685573968dae5dd34758e322  # 23:34      1-      3  Add linux-next specific files for 20140204

2014-02-04-23:31:42 detecting boot state 3.14.0-rc1-next-20140204-01497-gcdd263f....    1 TEST FAILURE
[    1.938575] netconsole: network logging started
[    1.939785] Unregister pv shared memory for cpu 0
[    1.972240] ------------[ cut here ]------------
[    1.972466] WARNING: CPU: 1 PID: 1 at mm/slub.c:1007 deactivate_slab+0x4ce/0xae0()
[    1.972466] Modules linked in:
[    1.972466] CPU: 1 PID: 1 Comm: swapper/0 Not tainted 3.14.0-rc1-next-20140204-01497-gcdd263f #163
[    1.972466] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    1.972466]  ffffffff ce033d44 c1a7a530 00000000 00000000 000003ef ce033d74 c1070d21
[    1.972466]  c1f0b9a0 00000001 00000001 c1f168dd 000003ef c11d388e c11d388e 00000001
[    1.972466]  ce61e600 ce000d40 ce033d84 c1070dbd 00000009 00000000 ce033e0c c11d388e
[    1.972466] Call Trace:
[    1.972466]  [<c1a7a530>] dump_stack+0x7a/0xdb
[    1.972466]  [<c1070d21>] warn_slowpath_common+0x91/0xb0
[    1.972466]  [<c11d388e>] ? deactivate_slab+0x4ce/0xae0
[    1.972466]  [<c11d388e>] ? deactivate_slab+0x4ce/0xae0
[    1.972466]  [<c1070dbd>] warn_slowpath_null+0x1d/0x20
[    1.972466]  [<c11d388e>] deactivate_slab+0x4ce/0xae0
[    1.972466]  [<c11d3ff6>] slab_cpuup_callback+0xc6/0x130
[    1.972466]  [<c1a9b0b5>] notifier_call_chain+0x35/0x90 
[    1.972466]  [<c10a81e9>] __raw_notifier_call_chain+0x19/0x20
[    1.972466]  [<c1070fa3>] cpu_notify+0x23/0x50
[    1.972466]  [<c1070fdb>] cpu_notify_nofail+0xb/0x40
[    1.972466]  [<c1a6bd61>] _cpu_down+0x231/0x500
[    1.972466]  [<c1a6c06d>] cpu_down+0x3d/0x60
[    1.972466]  [<c1a6afc7>] _debug_hotplug_cpu+0x57/0x1b0
[    1.972466]  [<c2372ebb>] ? topology_init+0xef/0xef
[    1.972466]  [<c2372ec7>] debug_hotplug_cpu+0xc/0x10
[    1.972466]  [<c100050a>] do_one_initcall+0x13a/0x240
[    1.972466]  [<c236b5b6>] ? repair_env_string+0x2a/0x99
[    1.972466]  [<c109f726>] ? parse_args+0x476/0x6b0     
[    1.972466]  [<c1a9538b>] ? _raw_spin_unlock_irqrestore+0x5b/0x90
[    1.972466]  [<c236bf6b>] kernel_init_freeable+0xe3/0x1cd                                                                                  
[    1.972466]  [<c236b58c>] ? do_early_param+0xb5/0xb5     
[    1.972466]  [<c1a6ac9c>] kernel_init+0xc/0x170

I just checked 20140205 and it still does not have your patch and has the same problem:

[    1.093205] Unregister pv shared memory for cpu 0
[    1.117174] ------------[ cut here ]------------
[    1.118001] WARNING: CPU: 1 PID: 1 at mm/slub.c:1007 deactivate_slab+0x4ce/0xae0()
[    1.119496] Modules linked in:
[    1.120164] CPU: 1 PID: 1 Comm: swapper/0 Not tainted 3.14.0-rc1-next-20140205-01770-g71ce88b #1
[    1.120381] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    1.120381]  ffffffff cf433d44 c1a8e281 00000000 00000000 000003ef cf433d74 c1070ce1
[    1.120381]  c1f2a55c 00000001 00000001 c1f39538 000003ef c11d373e c11d373e 00000001
[    1.120381]  cfaf7a00 cf400d40 cf433d84 c1070d7d 00000009 00000000 cf433e0c c11d373e
[    1.120381] Call Trace:
[    1.120381]  [<c1a8e281>] dump_stack+0x7a/0xdb
[    1.120381]  [<c1070ce1>] warn_slowpath_common+0x91/0xb0
[    1.120381]  [<c11d373e>] ? deactivate_slab+0x4ce/0xae0
[    1.120381]  [<c11d373e>] ? deactivate_slab+0x4ce/0xae0
[    1.120381]  [<c1070d7d>] warn_slowpath_null+0x1d/0x20
[    1.120381]  [<c11d373e>] deactivate_slab+0x4ce/0xae0
[    1.120381]  [<c11d3ea6>] slab_cpuup_callback+0xc6/0x130
[    1.120381]  [<c1aaeeb5>] notifier_call_chain+0x35/0x90
[    1.120381]  [<c10a8199>] __raw_notifier_call_chain+0x19/0x20
[    1.120381]  [<c1070f63>] cpu_notify+0x23/0x50
[    1.120381]  [<c1070f9b>] cpu_notify_nofail+0xb/0x40
[    1.120381]  [<c1a7fad1>] _cpu_down+0x231/0x500
[    1.120381]  [<c1a7fddd>] cpu_down+0x3d/0x60
[    1.120381]  [<c1a7ed37>] _debug_hotplug_cpu+0x57/0x1b0
[    1.120381]  [<c23a4ebb>] ? topology_init+0xef/0xef
[    1.120381]  [<c23a4ec7>] debug_hotplug_cpu+0xc/0x10
[    1.120381]  [<c100050a>] do_one_initcall+0x13a/0x240
[    1.120381]  [<c239d5b6>] ? repair_env_string+0x2a/0x99
[    1.120381]  [<c109f6e6>] ? parse_args+0x476/0x6b0
[    1.120381]  [<c1aa919b>] ? _raw_spin_unlock_irqrestore+0x5b/0x90
[    1.120381]  [<c239df6b>] kernel_init_freeable+0xe3/0x1cd
[    1.120381]  [<c239d58c>] ? do_early_param+0xb5/0xb5
[    1.120381]  [<c1a7ea0c>] kernel_init+0xc/0x170
[    1.120381]  [<c1ab26b7>] ret_from_kernel_thread+0x1b/0x28
[    1.120381]  [<c1a7ea00>] ? rest_init+0xc0/0xc0
[    1.120381] ---[ end trace 772e564eed9b8650 ]---
[    1.188477] CPU 0 is now offline

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
