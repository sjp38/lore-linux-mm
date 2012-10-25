Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 24C396B005D
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 22:37:42 -0400 (EDT)
Date: Wed, 24 Oct 2012 22:37:38 -0400
From: Dave Jones <davej@redhat.com>
Subject: shmem_getpage_gfp VM_BUG_ON triggered. [3.7rc2]
Message-ID: <20121025023738.GA27001@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Linux Kernel <linux-kernel@vger.kernel.org>

Machine under significant load (4gb memory used, swap usage fluctuating)
triggered this...

WARNING: at mm/shmem.c:1151 shmem_getpage_gfp+0xa5c/0xa70()
Pid: 29795, comm: trinity-child4 Not tainted 3.7.0-rc2+ #49
Call Trace:
 [<ffffffff8107100f>] warn_slowpath_common+0x7f/0xc0
 [<ffffffff8107106a>] warn_slowpath_null+0x1a/0x20
 [<ffffffff811903fc>] shmem_getpage_gfp+0xa5c/0xa70
 [<ffffffff8118fc3e>] ? shmem_getpage_gfp+0x29e/0xa70
 [<ffffffff81190e4f>] shmem_fault+0x4f/0xa0
 [<ffffffff8119f391>] __do_fault+0x71/0x5c0
 [<ffffffff810e1ac6>] ? __lock_acquire+0x306/0x1ba0
 [<ffffffff810b6ff9>] ? local_clock+0x89/0xa0
 [<ffffffff811a2767>] handle_pte_fault+0x97/0xae0
 [<ffffffff816d1069>] ? sub_preempt_count+0x79/0xd0
 [<ffffffff8136d68e>] ? delay_tsc+0xae/0x120
 [<ffffffff8136d578>] ? __const_udelay+0x28/0x30
 [<ffffffff811a4a39>] handle_mm_fault+0x289/0x350
 [<ffffffff816d091e>] __do_page_fault+0x18e/0x530
 [<ffffffff810b6ff9>] ? local_clock+0x89/0xa0
 [<ffffffff810b0e51>] ? get_parent_ip+0x11/0x50
 [<ffffffff810b0e51>] ? get_parent_ip+0x11/0x50
 [<ffffffff816d1069>] ? sub_preempt_count+0x79/0xd0
 [<ffffffff8112d389>] ? rcu_user_exit+0xc9/0xf0
 [<ffffffff816d0ceb>] do_page_fault+0x2b/0x50
 [<ffffffff816cd3b8>] page_fault+0x28/0x30
 [<ffffffff8136d259>] ? copy_user_enhanced_fast_string+0x9/0x20
 [<ffffffff8121c181>] ? sys_futimesat+0x41/0xe0
 [<ffffffff8102bf35>] ? syscall_trace_enter+0x25/0x2c0
 [<ffffffff816d5625>] ? tracesys+0x7e/0xe6
 [<ffffffff816d5688>] tracesys+0xe1/0xe6



1148                         error = shmem_add_to_page_cache(page, mapping, index,
1149                                                 gfp, swp_to_radix_entry(swap));
1150                         /* We already confirmed swap, and make no allocation */
1151                         VM_BUG_ON(error);
1152                 }


             total       used       free     shared    buffers     cached
Mem:       3885528    2854064    1031464          0       9624      19208
-/+ buffers/cache:    2825232    1060296
Swap:      6029308      30656    5998652


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
