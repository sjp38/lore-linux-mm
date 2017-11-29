Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8B0CF6B0033
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 04:03:33 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id z3so1020641pln.6
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 01:03:33 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id bg5sor568190plb.53.2017.11.29.01.03.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 Nov 2017 01:03:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAABZP2wHq-eCCLcN0xOxUTohJfkt0ZhUbVO=aW+5mYgxt=9oFA@mail.gmail.com>
References: <1511841842-3786-1-git-send-email-zhouzhouyi@gmail.com>
 <CAABZP2zEup53ZcNKOEUEMx_aRMLONZdYCLd7s5J4DLTccPxC-A@mail.gmail.com>
 <CACT4Y+YE5POWUoDj2sUv2NDKeimTRyxCpg1yd7VpZnqeYJ+Qcg@mail.gmail.com>
 <CAABZP2zB8vKswQXicYq5r8iNOKz21CRyw1cUiB2s9O+ZMb+JvQ@mail.gmail.com>
 <CACT4Y+YkVbkwAm0h7UJH08woiohJT9EYObhxpE33dP0A4agtkw@mail.gmail.com>
 <CAABZP2zjoSDTNkn_qMqi+NCHOzzQZSj-LvfCjPy_tg-FZeUWZg@mail.gmail.com>
 <CACT4Y+ah6q-xoakyPL7v-+Knp8ZaFbnRRk_Ki6Wsmz3C8Pe8XQ@mail.gmail.com>
 <CAABZP2yS524XEiyu=kkVx7ff1ySTtE=WWETNDrZ_toEm0mwqyQ@mail.gmail.com>
 <CACT4Y+aAhHSW=qBFLy7S1wWLsJsjW83y8uC4nQy0N9Hf8HoMKQ@mail.gmail.com>
 <CAABZP2wxDxAHJ_f022Ha7gyffukgo0PPOv2uJQphwFXGO_fL1w@mail.gmail.com>
 <CACT4Y+bprRRzTD5DjSTZt8oobhYcD-eTOT_VwWwcTZBhRH1KUg@mail.gmail.com>
 <CACT4Y+aRGC9vVaHCXmeEiL5ywjQRTK+yNn+TAWKPLB3Gpd4U_A@mail.gmail.com>
 <CAABZP2xDmOT8-=eqjVF6dFAcJ2SZesX4CsJ7gmqGjHjsTXdt0w@mail.gmail.com> <CAABZP2wHq-eCCLcN0xOxUTohJfkt0ZhUbVO=aW+5mYgxt=9oFA@mail.gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 29 Nov 2017 10:03:10 +0100
Message-ID: <CACT4Y+Zr0XwLmO5j_b4mxrGo3eGXh2wSR-gUdwiBishcn=5SfQ@mail.gmail.com>
Subject: Re: [PATCH 1/1] kasan: fix livelock in qlist_move_cache
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhouyi Zhou <zhouzhouyi@gmail.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Nov 29, 2017 at 5:54 AM, Zhouyi Zhou <zhouzhouyi@gmail.com> wrote:
> Hi,
> There is new discoveries!
>
> When I find qlist_move_cache reappear in my environment,
> I use kgdb to break into function qlist_move_cache. I found
>  this function is called because of cgroup release.
>
> I also find libvirt allocate a memory croup for each qemu it started,
> in my system, it looks like this:
>
> root@ednserver3:/sys/fs/cgroup/memory/machine.slice# ls
> cgroup.clone_children machine-qemu\x2d491_25_30.scope
> machine-qemu\x2d491_40_30.scope  machine-qemu\x2d491_6_30.scope
> memory.limit_in_bytes
> cgroup.event_control machine-qemu\x2d491_26_30.scope
> machine-qemu\x2d491_41_30.scope  machine-qemu\x2d491_7_30.scope
> memory.max_usage_in_bytes
> cgroup.procs machine-qemu\x2d491_27_30.scope
> machine-qemu\x2d491_4_30.scope   machine-qemu\x2d491_8_30.scope
> memory.move_charge_at_immigrate
> machine-qemu\x2d491_10_30.scope  machine-qemu\x2d491_28_30.scope
> machine-qemu\x2d491_47_30.scope  machine-qemu\x2d491_9_30.scope
> memory.numa_stat
> machine-qemu\x2d491_11_30.scope  machine-qemu\x2d491_29_30.scope
> machine-qemu\x2d491_48_30.scope  memory.failcnt
> memory.oom_control
> machine-qemu\x2d491_12_30.scope  machine-qemu\x2d491_30_30.scope
> machine-qemu\x2d491_49_30.scope  memory.force_empty
> memory.pressure_level
> machine-qemu\x2d491_13_30.scope  machine-qemu\x2d491_31_30.scope
> machine-qemu\x2d491_50_30.scope  memory.kmem.failcnt
> memory.soft_limit_in_bytes
> machine-qemu\x2d491_17_30.scope  machine-qemu\x2d491_32_30.scope
> machine-qemu\x2d491_51_30.scope  memory.kmem.limit_in_bytes
> memory.stat
> machine-qemu\x2d491_18_30.scope  machine-qemu\x2d491_33_30.scope
> machine-qemu\x2d491_52_30.scope  memory.kmem.max_usage_in_bytes
> memory.swappiness
> machine-qemu\x2d491_19_30.scope  machine-qemu\x2d491_34_30.scope
> machine-qemu\x2d491_5_30.scope   memory.kmem.slabinfo
> memory.usage_in_bytes
> machine-qemu\x2d491_20_30.scope  machine-qemu\x2d491_35_30.scope
> machine-qemu\x2d491_53_30.scope  memory.kmem.tcp.failcnt
> memory.use_hierarchy
> machine-qemu\x2d491_21_30.scope  machine-qemu\x2d491_36_30.scope
> machine-qemu\x2d491_54_30.scope  memory.kmem.tcp.limit_in_bytes
> notify_on_release
> machine-qemu\x2d491_22_30.scope  machine-qemu\x2d491_37_30.scope
> machine-qemu\x2d491_55_30.scope  memory.kmem.tcp.max_usage_in_bytes
> tasks
> machine-qemu\x2d491_23_30.scope  machine-qemu\x2d491_38_30.scope
> machine-qemu\x2d491_56_30.scope  memory.kmem.tcp.usage_in_bytes
> machine-qemu\x2d491_24_30.scope  machine-qemu\x2d491_39_30.scope
> machine-qemu\x2d491_57_30.scope  memory.kmem.usage_in_bytes
>
> and in each memory cgroup there are many slabs:
> root@ednserver3:/sys/fs/cgroup/memory/machine.slice/machine-qemu\x2d491_10_30.scope#
> cat memory.kmem.slabinfo
> slabinfo - version: 2.1
> # name            <active_objs> <num_objs> <objsize> <objperslab>
> <pagesperslab> : tunables <limit> <batchcount> <sharedfactor> :
> slabdata <active_slabs> <num_slabs> <sharedavail>
> kmalloc-2048           0      0   2240    3    2 : tunables   24   12
>   8 : slabdata      0      0      0
> kmalloc-512            0      0    704   11    2 : tunables   54   27
>   8 : slabdata      0      0      0
> skbuff_head_cache      0      0    384   10    1 : tunables   54   27
>   8 : slabdata      0      0      0
> kmalloc-1024           0      0   1216    3    1 : tunables   24   12
>   8 : slabdata      0      0      0
> kmalloc-192            0      0    320   12    1 : tunables  120   60
>   8 : slabdata      0      0      0
> pid                    3     21    192   21    1 : tunables  120   60
>   8 : slabdata      1      1      0
> signal_cache           0      0   1216    3    1 : tunables   24   12
>   8 : slabdata      0      0      0
> sighand_cache          0      0   2304    3    2 : tunables   24   12
>   8 : slabdata      0      0      0
> fs_cache               0      0    192   21    1 : tunables  120   60
>   8 : slabdata      0      0      0
> files_cache            0      0    896    4    1 : tunables   54   27
>   8 : slabdata      0      0      0
> task_delay_info        3     72    112   36    1 : tunables  120   60
>   8 : slabdata      2      2      0
> task_struct            3      3   3840    1    1 : tunables   24   12
>   8 : slabdata      3      3      0
> radix_tree_node        0      0    728    5    1 : tunables   54   27
>   8 : slabdata      0      0      0
> shmem_inode_cache      2      9    848    9    2 : tunables   54   27
>   8 : slabdata      1      1      0
> inode_cache           39     45    744    5    1 : tunables   54   27
>   8 : slabdata      9      9      0
> ext4_inode_cache       0      0   1224    3    1 : tunables   24   12
>   8 : slabdata      0      0      0
> sock_inode_cache       3      8    832    4    1 : tunables   54   27
>   8 : slabdata      2      2      0
> proc_inode_cache       0      0    816    5    1 : tunables   54   27
>   8 : slabdata      0      0      0
> dentry                52     90    272   15    1 : tunables  120   60
>   8 : slabdata      6      6      0
> anon_vma             140    348    136   29    1 : tunables  120   60
>   8 : slabdata     12     12      0
> anon_vma_chain       257    468    112   36    1 : tunables  120   60
>   8 : slabdata     13     13      0
> vm_area_struct       510    780    272   15    1 : tunables  120   60
>   8 : slabdata     52     52      0
> mm_struct              1      3   1280    3    1 : tunables   24   12
>   8 : slabdata      1      1      0
> cred_jar              12     24    320   12    1 : tunables  120   60
>   8 : slabdata      2      2      0
>
> So, when I end the libvirt scenery, those slabs belong to those qemus
> has to invoke quarantine_remove_cache,
> I guess that's why  qlist_move_cache occupies so much CPU cycles. I
> also guess this make libvirt complain
> (wait for too long?)
>
> Sorry not to research deeply into system in the first place and submit
> a patch in a hurry.
>
> And I propose a little sugguestion to  improve qlist_move_cache if you
> like. Won't we design some kind of hash mechanism,
> then we group the qlist_node according to their cache, so as not to
> compare one by one to every qlist_node in the system.

Yes, quarantine_remove_cache() is very slow because it walk a huge
linked list and synchronize_srcu() does not help either. It would be
great to make it faster rather than peppering over the problem with
rescheds.

Please detail your scheme.
Note that quarantine needs to be [best-effort] global FIFO and that
the main operations are actually kmalloc/kfree, so we should not
penalize them either. We also have limited memory in memory blocks.

I had some ideas but I couldn't come up with a complete solution that
I would like.
One thing is that we could first check if the cache actually has _any_
outstanding objects. Looking at your slabinfo dump, it seems that lots
of them don't have active objects. In that case we can skip all of
quarantine_remove_cache entirely. I see there is already a function
for this:

static int shutdown_cache(struct kmem_cache *s)
{
        /* free asan quarantined objects */
        kasan_cache_shutdown(s);

        if (__kmem_cache_shutdown(s) != 0)
                return -EBUSY;

So maybe we could do just:

static int shutdown_cache(struct kmem_cache *s)
{
        if (__kmem_cache_shutdown(s) != 0) {
               /* free asan quarantined objects */
               kasan_cache_shutdown(s);
               if (__kmem_cache_shutdown(s) != 0)
                       return -EBUSY;
        }


We could also make cache freeing asynchronous. Then we could either
just wait when the cache doesn't have any active objects (walk and
check all deferred caches after each quarantine_reduce()), or
accumulate a batch of them and then walk quarantine once and remove
objects for the batch of caches (this would amortize overhead by batch
size). As far as I understand in lots of cases caches are freed in
large batches (cgroups, namespaces), and that's exactly when
quarantine_remove_cache() performance is a problem.

Or we could make quarantine a doubly-linked list and then walk all
active objects in the cache (is it possible?) and remove them from
quarantine by shuffling next/prev pointers. However, this can increase
memory consumption and penalize performance of other operations.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
