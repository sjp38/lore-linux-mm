Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id A5F7A6B038D
	for <linux-mm@kvack.org>; Mon, 29 Oct 2018 12:35:46 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id c10so7686942wrx.2
        for <linux-mm@kvack.org>; Mon, 29 Oct 2018 09:35:46 -0700 (PDT)
Received: from mout.gmx.net (mout.gmx.net. [212.227.15.15])
        by mx.google.com with ESMTPS id j17-v6si6194572wrb.273.2018.10.29.09.35.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Oct 2018 09:35:44 -0700 (PDT)
Message-ID: <1540830938.10478.4.camel@gmx.de>
Subject: Re: memcg oops:
 memcg_kmem_charge_memcg()->try_charge()->page_counter_try_charge()->BOOM
From: Mike Galbraith <efault@gmx.de>
Date: Mon, 29 Oct 2018 17:35:38 +0100
In-Reply-To: <20181029132035.GI32673@dhcp22.suse.cz>
References: <1540792855.22373.34.camel@gmx.de>
	 <20181029132035.GI32673@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-15"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Roman Gushchin <guro@fb.com>

On Mon, 2018-10-29 at 14:20 +0100, Michal Hocko wrote:
> 
> > [    4.420976] Code: f3 c3 0f 1f 00 0f 1f 44 00 00 48 85 ff 0f 84 a8 00 00 00 41 56 48 89 f8 41 55 49 89 fe 41 54 49 89 d5 55 49 89 f4 53 48 89 f3 <f0> 48 0f c1 1f 48 01 f3 48 39 5f 18 48 89 fd 73 17 eb 41 48 89 e8
> > [    4.424162] RSP: 0018:ffffb27840c57cb0 EFLAGS: 00010202
> > [    4.425236] RAX: 00000000000000f8 RBX: 0000000000000020 RCX: 0000000000000200
> > [    4.426467] RDX: ffffb27840c57d08 RSI: 0000000000000020 RDI: 00000000000000f8
> > [    4.427652] RBP: 0000000000000001 R08: 0000000000000000 R09: ffffb278410bc000
> > [    4.428883] R10: ffffb27840c57ed0 R11: 0000000000000040 R12: 0000000000000020
> > [    4.430168] R13: ffffb27840c57d08 R14: 00000000000000f8 R15: 00000000006000c0
> > [    4.431411] FS:  00007f79081a3940(0000) GS:ffff92a4b7bc0000(0000) knlGS:0000000000000000
> > [    4.432748] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > [    4.433836] CR2: 00000000000000f8 CR3: 00000002310ac002 CR4: 00000000001606e0
> > [    4.435500] Call Trace:
> > [    4.436319]  try_charge+0x92/0x7b0
> > [    4.437284]  ? unlazy_walk+0x4c/0xb0
> > [    4.438676]  ? terminate_walk+0x91/0x100
> > [    4.439984]  memcg_kmem_charge_memcg+0x28/0x80
> > [    4.441059]  memcg_kmem_charge+0x88/0x1d0
> > [    4.442105]  copy_process.part.37+0x23a/0x2070
> 
> Could you faddr2line this please?

homer:/usr/local/src/kernel/linux-master # ./scripts/faddr2line vmlinux copy_process.part.37+0x23a
copy_process.part.37+0x23a/0x2070:
memcg_charge_kernel_stack at kernel/fork.c:401
(inlined by) dup_task_struct at kernel/fork.c:850
(inlined by) copy_process at kernel/fork.c:1750

I bisected it this afternoon, and confirmed the result via revert.

9b6f7e163cd0f468d1b9696b785659d3c27c8667 is the first bad commit
commit 9b6f7e163cd0f468d1b9696b785659d3c27c8667
Author: Roman Gushchin <guro@fb.com>
Date:   Fri Oct 26 15:03:19 2018 -0700

    mm: rework memcg kernel stack accounting
    
    If CONFIG_VMAP_STACK is set, kernel stacks are allocated using
    __vmalloc_node_range() with __GFP_ACCOUNT.  So kernel stack pages are
    charged against corresponding memory cgroups on allocation and uncharged
    on releasing them.
    
    The problem is that we do cache kernel stacks in small per-cpu caches and
    do reuse them for new tasks, which can belong to different memory cgroups.
    
    Each stack page still holds a reference to the original cgroup, so the
    cgroup can't be released until the vmap area is released.
    
    To make this happen we need more than two subsequent exits without forks
    in between on the current cpu, which makes it very unlikely to happen.  As
    a result, I saw a significant number of dying cgroups (in theory, up to 2
    * number_of_cpu + number_of_tasks), which can't be released even by
    significant memory pressure.
    
    As a cgroup structure can take a significant amount of memory (first of
    all, per-cpu data like memcg statistics), it leads to a noticeable waste
    of memory.
    
    Link: http://lkml.kernel.org/r/20180827162621.30187-1-guro@fb.com
    Fixes: ac496bf48d97 ("fork: Optimize task creation by caching two thread stacks per CPU if CONFIG_VMAP_STACK=y")
    Signed-off-by: Roman Gushchin <guro@fb.com>
    Reviewed-by: Shakeel Butt <shakeelb@google.com>
    Acked-by: Michal Hocko <mhocko@kernel.org>
    Cc: Johannes Weiner <hannes@cmpxchg.org>
    Cc: Andy Lutomirski <luto@kernel.org>
    Cc: Konstantin Khlebnikov <koct9i@gmail.com>
    Cc: Tejun Heo <tj@kernel.org>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

:040000 040000 19a916f067fb987c6b15ce04f0e656c590db39dd edde98ce70d28e03f623f86f54887720516fcd91 M      include
:040000 040000 04213da714a8a10580baccd0b0977a6744fa2374 9204198e8eb4043b059f2a4eeaa4e19679fd3ddb M      kernel

git bisect start
# good: [e5f6d9afa3415104e402cd69288bb03f7165eeba] Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc
git bisect good e5f6d9afa3415104e402cd69288bb03f7165eeba
# bad: [345671ea0f9258f410eb057b9ced9cefbbe5dc78] Merge branch 'akpm' (patches from Andrew)
git bisect bad 345671ea0f9258f410eb057b9ced9cefbbe5dc78
# bad: [ae2b01f37044c10e975d22116755df56252b09d8] mm: remove vm_insert_pfn()
git bisect bad ae2b01f37044c10e975d22116755df56252b09d8
# good: [9703fc8caf36ac65dca1538b23dd137de0b53233] Merge tag 'usb-4.20-rc1' of git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/usb
git bisect good 9703fc8caf36ac65dca1538b23dd137de0b53233
# good: [bf58e8820c48805394ec9e76339f0c4646050432] nvmem: change the signature of nvmem_unregister()
git bisect good bf58e8820c48805394ec9e76339f0c4646050432
# good: [cccb3b19e762edc8ef0481be506967555cb9e317] nvmem: fix nvmem_cell_get_from_lookup()
git bisect good cccb3b19e762edc8ef0481be506967555cb9e317
# good: [18d0eae30e6a4f8644d589243d7ac1d70d29203d] Merge tag 'char-misc-4.20-rc1' of git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/char-misc
git bisect good 18d0eae30e6a4f8644d589243d7ac1d70d29203d
# bad: [9b6f7e163cd0f468d1b9696b785659d3c27c8667] mm: rework memcg kernel stack accounting
git bisect bad 9b6f7e163cd0f468d1b9696b785659d3c27c8667
# good: [2de24cb742d4f0c41358aa078bed7f089c827ac7] ocfs2: remove unused pointer 'eb'
git bisect good 2de24cb742d4f0c41358aa078bed7f089c827ac7
# good: [5780a02fd1e87641ad6a8dd6891a1e890cf45c5d] fs/iomap.c: change return type to vm_fault_t
git bisect good 5780a02fd1e87641ad6a8dd6891a1e890cf45c5d
# good: [0684e6526edfb4debf0a0a884834bb1a104085dc] mm/slub.c: switch to bitmap_zalloc()
git bisect good 0684e6526edfb4debf0a0a884834bb1a104085dc
# good: [c5fd3ca06b4699e251b4a1fb808c2d5124494101] slub: extend slub debug to handle multiple slabs
git bisect good c5fd3ca06b4699e251b4a1fb808c2d5124494101
# first bad commit: [9b6f7e163cd0f468d1b9696b785659d3c27c8667] mm: rework memcg kernel stack accounting

	-Mike
