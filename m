Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8F1358D0030
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 14:16:36 -0400 (EDT)
Date: Fri, 29 Oct 2010 11:16:27 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: oom killer question
Message-Id: <20101029111627.2a8c9982.akpm@linux-foundation.org>
In-Reply-To: <20101029121456.GA6896@osiris.boeblingen.de.ibm.com>
References: <20101029121456.GA6896@osiris.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, Hartmut Beinlich <HBEINLIC@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, 29 Oct 2010 14:14:56 +0200
Heiko Carstens <heiko.carstens@de.ibm.com> wrote:

> Hello,
> 
> I've got an OOM killed rsyslogd where I'm wondering why the oom killer
> got involved at all. Looking at the verbose output it looks to me like
> there is a lot of swap space and also a lot of reclaimable slab.
> Any idea why this happened?
> 
> Thanks!
> 
> [18132.475583] blast invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0, oom_score_adj=0
> [18132.475612] blast cpuset=/ mems_allowed=0
> [18132.475616] CPU: 7 Not tainted 2.6.36-45.x.20101028-s390xdefault #1
> [18132.475619] Process blast (pid: 8067, task: 000000007a244640, ksp: 000000003dc8f678)
> [18132.475623] 000000003dc8f888 000000003dc8f808 0000000000000002 0000000000000000 
> [18132.475628]        000000003dc8f8a8 000000003dc8f820 000000003dc8f820 000000000055ee3e 
> [18132.475634]        0000000000000000 0000000000000000 0000000000000000 00000000000201da 
> [18132.475640]        000000000000000d 000000000000000c 000000003dc8f870 0000000000000000 
> [18132.475646]        0000000000000000 0000000000100afa 000000003dc8f808 000000003dc8f848 
> [18132.475653] Call Trace:
> [18132.475655] ([<0000000000100a02>] show_trace+0xee/0x144)
> [18132.475662]  [<00000000001d73d0>] dump_header+0x98/0x298
> [18132.475669]  [<00000000001d7a26>] oom_kill_process+0xb6/0x224
> [18132.475672]  [<00000000001d7f26>] out_of_memory+0x10e/0x23c
> [18132.475676]  [<00000000001ddb80>] __alloc_pages_nodemask+0x9a4/0xa50
> [18132.475680]  [<00000000001e0588>] __do_page_cache_readahead+0x1a4/0x334
> [18132.475685]  [<00000000001e0758>] ra_submit+0x40/0x54
> [18132.475688]  [<00000000001d542a>] filemap_fault+0x45a/0x48c
> [18132.475692]  [<00000000001f2a0e>] __do_fault+0x7e/0x5e8
> [18132.475696]  [<00000000001f5fc2>] handle_mm_fault+0x24a/0xaa8
> [18132.475700]  [<00000000005656e2>] do_dat_exception+0x14e/0x3c8
> [18132.475705]  [<0000000000114b38>] pgm_exit+0x0/0x14
> [18132.475710]  [<0000000080011132>] 0x80011132
> [18132.475717] 2 locks held by blast/8067:
> [18132.475719]  #0:  (&mm->mmap_sem){++++++}, at: [<0000000000565672>] do_dat_exception+0xde/0x3c8
> [18132.475726]  #1:  (tasklist_lock){.+.+..}, at: [<00000000001d7ebe>] out_of_memory+0xa6/0x23c
> [18132.475734] Mem-Info:
> [18132.475736] DMA per-cpu:
> [18132.475738] CPU    6: hi:  186, btch:  31 usd:   0
> [18132.475741] CPU    7: hi:  186, btch:  31 usd:  45
> [18132.475744] CPU    8: hi:  186, btch:  31 usd:   0
> [18132.475746] CPU    9: hi:  186, btch:  31 usd:   0
> [18132.475750] active_anon:29 inactive_anon:13 isolated_anon:25
> [18132.475751]  active_file:11 inactive_file:30 isolated_file:52
> [18132.475752]  unevictable:1113 dirty:0 writeback:0 unstable:0
> [18132.475753]  free:1404 slab_reclaimable:444597 slab_unreclaimable:47097
> [18132.475753]  mapped:921 shmem:0 pagetables:558 bounce:0
> [18132.475762] DMA free:5616kB min:5752kB low:7188kB high:8628kB active_anon:116kB inactive_anon:52kB active_file:44kB inactive_file:120kB unevictable:4452kB isolated(anon):100kB isolated(file):208kB present:2068480kB mlocked:4452kB dirty:0kB writeback:0kB mapped:3684kB shmem:0kB slab_reclaimable:1778388kB slab_unreclaimable:188388kB kernel_stack:4016kB pagetables:2232kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:542 all_unreclaimable? yes
> [18132.475771] lowmem_reserve[]: 0 0 0
> [18132.475776] DMA: 1134*4kB 0*8kB 3*16kB 1*32kB 1*64kB 0*128kB 0*256kB 0*512kB 1*1024kB = 5704kB

Looks like a slab leak.  Nothing in pagecache, no anon memory (hence
that free swap cannot be used) and vast amounts of slab.

Can you run it again and keep an eye on slabinfo?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
