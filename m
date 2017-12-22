Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id E9F666B0038
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 17:25:46 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id g202so11666376ita.4
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 14:25:46 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 123sor5722821itw.107.2017.12.22.14.25.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Dec 2017 14:25:46 -0800 (PST)
Date: Fri, 22 Dec 2017 16:25:43 -0600
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: KASAN: use-after-free Read in __pagevec_lru_add_fn
Message-ID: <20171222222543.GC28786@zzz.localdomain>
References: <001a113f711afab80a0560f49df1@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <001a113f711afab80a0560f49df1@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <bot+39ea44e86d4b505fce2a77c845b7979cffd9bc07@syzkaller.appspotmail.com>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mgorman@techsingularity.net, mhocko@suse.com, shli@fb.com, syzkaller-bugs@googlegroups.com, vbabka@suse.cz, ying.huang@intel.com

On Fri, Dec 22, 2017 at 01:37:02PM -0800, syzbot wrote:
> Hello,
> 
> syzkaller hit the following crash on
> e7655085973bd33ee47bb12de663d31c81717404
> git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git/master
> compiler: gcc (GCC) 7.1.1 20170620
> .config is attached
> Raw console output is attached.
> C reproducer is attached
> syzkaller reproducer is attached. See https://goo.gl/kgGztJ
> for information about syzkaller reproducers
> 
> 
> ==================================================================
> BUG: KASAN: use-after-free in list_add include/linux/list.h:79 [inline]
> BUG: KASAN: use-after-free in add_page_to_lru_list
> include/linux/mm_inline.h:51 [inline]
> BUG: KASAN: use-after-free in __pagevec_lru_add_fn+0xe49/0xf40 mm/swap.c:896
> Read of size 8 at addr ffff8801da2c36d0 by task modprobe/9844
> 
> CPU: 1 PID: 9844 Comm: modprobe Not tainted 4.15.0-rc3+ #157
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> Call Trace:
>  __dump_stack lib/dump_stack.c:17 [inline]
>  dump_stack+0x194/0x257 lib/dump_stack.c:53
>  print_address_description+0x73/0x250 mm/kasan/report.c:252
>  kasan_report_error mm/kasan/report.c:351 [inline]
>  kasan_report+0x25b/0x340 mm/kasan/report.c:409
>  __asan_report_load8_noabort+0x14/0x20 mm/kasan/report.c:430
>  list_add include/linux/list.h:79 [inline]
>  add_page_to_lru_list include/linux/mm_inline.h:51 [inline]
>  __pagevec_lru_add_fn+0xe49/0xf40 mm/swap.c:896
>  pagevec_lru_move_fn+0x13b/0x230 mm/swap.c:209
>  __pagevec_lru_add mm/swap.c:907 [inline]
>  lru_add_drain_cpu+0x283/0x460 mm/swap.c:609
>  lru_add_drain+0x1c/0x30 mm/swap.c:680
>  shift_arg_pages+0x1c3/0x460 fs/exec.c:651
>  setup_arg_pages+0x637/0x8e0 fs/exec.c:759
>  load_elf_binary+0xaa6/0x4b50 fs/binfmt_elf.c:882
>  search_binary_handler+0x142/0x6b0 fs/exec.c:1638
>  exec_binprm fs/exec.c:1680 [inline]
>  do_execveat_common.isra.30+0x1754/0x23c0 fs/exec.c:1802
>  do_execve+0x31/0x40 fs/exec.c:1847
>  call_usermodehelper_exec_async+0x457/0x8f0 kernel/umh.c:100
>  ret_from_fork+0x24/0x30 arch/x86/entry/entry_64.S:441
> 
> Allocated by task 0:
>  save_stack+0x43/0xd0 mm/kasan/kasan.c:447
>  set_track mm/kasan/kasan.c:459 [inline]
>  kasan_kmalloc+0xad/0xe0 mm/kasan/kasan.c:551
>  kmem_cache_alloc_node_trace+0x150/0x750 mm/slab.c:3653
>  kmalloc_node include/linux/slab.h:537 [inline]
>  kzalloc_node include/linux/slab.h:699 [inline]
>  alloc_mem_cgroup_per_node_info mm/memcontrol.c:4167 [inline]
>  mem_cgroup_alloc+0x33e/0x9d0 mm/memcontrol.c:4234
>  mem_cgroup_css_alloc+0x8ee/0xfe0 mm/memcontrol.c:4271
>  cgroup_init_subsys+0x224/0x529 kernel/cgroup/cgroup.c:5152
>  cgroup_init+0x3f3/0xb1b kernel/cgroup/cgroup.c:5278
>  start_kernel+0x6da/0x754 init/main.c:700
>  x86_64_start_reservations+0x2a/0x2c arch/x86/kernel/head64.c:378
>  x86_64_start_kernel+0x77/0x7a arch/x86/kernel/head64.c:359
>  secondary_startup_64+0xa5/0xb0 arch/x86/kernel/head_64.S:237
> 
> Freed by task 0:
> (stack is not available)
> 

This is yet another one where the reproducer is using AF_ALG and binding to the
"pcrypt(gcm_base(ctr(aes-aesni),ghash-generic))" algorithm, so it's running into
the pcrypt_free() bug which is causing slab cache corruption:

https://groups.google.com/forum/#!topic/syzkaller-bugs/NKn_ivoPOpk

https://patchwork.kernel.org/patch/10126761/

So let's mark it as a duplicate:

#syz dup: KASAN: use-after-free Read in __list_del_entry_valid (2)

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
