Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5C8866B039F
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 09:34:36 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id w63so31866225wrc.5
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 06:34:36 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id u135si1307wmd.240.2017.07.26.06.34.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 26 Jul 2017 06:34:35 -0700 (PDT)
Date: Wed, 26 Jul 2017 15:34:31 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH] mm: take memory hotplug lock within
 numa_zonelist_order_handler()
In-Reply-To: <20170726111738.38768-1-heiko.carstens@de.ibm.com>
Message-ID: <alpine.DEB.2.20.1707261533360.2186@nanos>
References: <20170726111738.38768-1-heiko.carstens@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-s390@vger.kernel.org, linux-kernel@vger.kernel.org, Andre Wild <wild@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>

On Wed, 26 Jul 2017, Heiko Carstens wrote:
> Andre Wild reported the folling warning:
> 
> WARNING: CPU: 2 PID: 1205 at kernel/cpu.c:240 lockdep_assert_cpus_held+0x4c/0x60
> Modules linked in:
> CPU: 2 PID: 1205 Comm: bash Not tainted 4.13.0-rc2-00022-gfd2b2c57ec20 #10
> Hardware name: IBM 2964 N96 702 (z/VM 6.4.0)
> task: 00000000701d8100 task.stack: 0000000073594000
> Krnl PSW : 0704f00180000000 0000000000145e24 (lockdep_assert_cpus_held+0x4c/0x60)
> ...
> Call Trace:
>  lockdep_assert_cpus_held+0x42/0x60)
>  stop_machine_cpuslocked+0x62/0xf0
>  build_all_zonelists+0x92/0x150
>  numa_zonelist_order_handler+0x102/0x150
>  proc_sys_call_handler.isra.12+0xda/0x118
>  proc_sys_write+0x34/0x48
>  __vfs_write+0x3c/0x178
>  vfs_write+0xbc/0x1a0
>  SyS_write+0x66/0xc0
>  system_call+0xc4/0x2b0
>  locks held by bash/1205:
>  #0:  (sb_writers#4){.+.+.+}, at: [<000000000037b29e>] vfs_write+0xa6/0x1a0
>  #1:  (zl_order_mutex){+.+...}, at: [<00000000002c8e4c>] numa_zonelist_order_handler+0x44/0x150
>  #2:  (zonelists_mutex){+.+...}, at: [<00000000002c8efc>] numa_zonelist_order_handler+0xf4/0x150
> Last Breaking-Event-Address:
>  [<0000000000145e20>] lockdep_assert_cpus_held+0x48/0x60
> 
> This can be easily triggered with e.g.
> 
>  >echo n > /proc/sys/vm/numa_zonelist_order
> 
> With commit 3f906ba23689a ("mm/memory-hotplug: switch locking to a
> percpu rwsem") memory hotplug locking was changed to fix a potential
> deadlock. This also switched the stop_machine() invocation within
> build_all_zonelists() to stop_machine_cpuslocked() which now expects
> that online cpus are locked when being called.
> 
> This assumption is not true if build_all_zonelists() is being called
> from numa_zonelist_order_handler(). In order to fix this simply add a
> mem_hotplug_begin()/mem_hotplug_done() pair to numa_zonelist_order_handler().

Sorry, I missed that call path when I did the conversion. So yes, that
needs some protection....

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
