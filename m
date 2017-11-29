Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 722006B0033
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 23:55:00 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id b80so1841179iob.23
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 20:55:00 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id q67sor705767itg.132.2017.11.28.20.54.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 Nov 2017 20:54:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAABZP2xDmOT8-=eqjVF6dFAcJ2SZesX4CsJ7gmqGjHjsTXdt0w@mail.gmail.com>
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
 <CACT4Y+aRGC9vVaHCXmeEiL5ywjQRTK+yNn+TAWKPLB3Gpd4U_A@mail.gmail.com> <CAABZP2xDmOT8-=eqjVF6dFAcJ2SZesX4CsJ7gmqGjHjsTXdt0w@mail.gmail.com>
From: Zhouyi Zhou <zhouzhouyi@gmail.com>
Date: Wed, 29 Nov 2017 12:54:56 +0800
Message-ID: <CAABZP2wHq-eCCLcN0xOxUTohJfkt0ZhUbVO=aW+5mYgxt=9oFA@mail.gmail.com>
Subject: Re: [PATCH 1/1] kasan: fix livelock in qlist_move_cache
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hi,
There is new discoveries!

When I find qlist_move_cache reappear in my environment,
I use kgdb to break into function qlist_move_cache. I found
 this function is called because of cgroup release.

I also find libvirt allocate a memory croup for each qemu it started,
in my system, it looks like this:

root@ednserver3:/sys/fs/cgroup/memory/machine.slice# ls
cgroup.clone_children machine-qemu\x2d491_25_30.scope
machine-qemu\x2d491_40_30.scope  machine-qemu\x2d491_6_30.scope
memory.limit_in_bytes
cgroup.event_control machine-qemu\x2d491_26_30.scope
machine-qemu\x2d491_41_30.scope  machine-qemu\x2d491_7_30.scope
memory.max_usage_in_bytes
cgroup.procs machine-qemu\x2d491_27_30.scope
machine-qemu\x2d491_4_30.scope   machine-qemu\x2d491_8_30.scope
memory.move_charge_at_immigrate
machine-qemu\x2d491_10_30.scope  machine-qemu\x2d491_28_30.scope
machine-qemu\x2d491_47_30.scope  machine-qemu\x2d491_9_30.scope
memory.numa_stat
machine-qemu\x2d491_11_30.scope  machine-qemu\x2d491_29_30.scope
machine-qemu\x2d491_48_30.scope  memory.failcnt
memory.oom_control
machine-qemu\x2d491_12_30.scope  machine-qemu\x2d491_30_30.scope
machine-qemu\x2d491_49_30.scope  memory.force_empty
memory.pressure_level
machine-qemu\x2d491_13_30.scope  machine-qemu\x2d491_31_30.scope
machine-qemu\x2d491_50_30.scope  memory.kmem.failcnt
memory.soft_limit_in_bytes
machine-qemu\x2d491_17_30.scope  machine-qemu\x2d491_32_30.scope
machine-qemu\x2d491_51_30.scope  memory.kmem.limit_in_bytes
memory.stat
machine-qemu\x2d491_18_30.scope  machine-qemu\x2d491_33_30.scope
machine-qemu\x2d491_52_30.scope  memory.kmem.max_usage_in_bytes
memory.swappiness
machine-qemu\x2d491_19_30.scope  machine-qemu\x2d491_34_30.scope
machine-qemu\x2d491_5_30.scope   memory.kmem.slabinfo
memory.usage_in_bytes
machine-qemu\x2d491_20_30.scope  machine-qemu\x2d491_35_30.scope
machine-qemu\x2d491_53_30.scope  memory.kmem.tcp.failcnt
memory.use_hierarchy
machine-qemu\x2d491_21_30.scope  machine-qemu\x2d491_36_30.scope
machine-qemu\x2d491_54_30.scope  memory.kmem.tcp.limit_in_bytes
notify_on_release
machine-qemu\x2d491_22_30.scope  machine-qemu\x2d491_37_30.scope
machine-qemu\x2d491_55_30.scope  memory.kmem.tcp.max_usage_in_bytes
tasks
machine-qemu\x2d491_23_30.scope  machine-qemu\x2d491_38_30.scope
machine-qemu\x2d491_56_30.scope  memory.kmem.tcp.usage_in_bytes
machine-qemu\x2d491_24_30.scope  machine-qemu\x2d491_39_30.scope
machine-qemu\x2d491_57_30.scope  memory.kmem.usage_in_bytes

and in each memory cgroup there are many slabs:
root@ednserver3:/sys/fs/cgroup/memory/machine.slice/machine-qemu\x2d491_10_30.scope#
cat memory.kmem.slabinfo
slabinfo - version: 2.1
# name            <active_objs> <num_objs> <objsize> <objperslab>
<pagesperslab> : tunables <limit> <batchcount> <sharedfactor> :
slabdata <active_slabs> <num_slabs> <sharedavail>
kmalloc-2048           0      0   2240    3    2 : tunables   24   12
  8 : slabdata      0      0      0
kmalloc-512            0      0    704   11    2 : tunables   54   27
  8 : slabdata      0      0      0
skbuff_head_cache      0      0    384   10    1 : tunables   54   27
  8 : slabdata      0      0      0
kmalloc-1024           0      0   1216    3    1 : tunables   24   12
  8 : slabdata      0      0      0
kmalloc-192            0      0    320   12    1 : tunables  120   60
  8 : slabdata      0      0      0
pid                    3     21    192   21    1 : tunables  120   60
  8 : slabdata      1      1      0
signal_cache           0      0   1216    3    1 : tunables   24   12
  8 : slabdata      0      0      0
sighand_cache          0      0   2304    3    2 : tunables   24   12
  8 : slabdata      0      0      0
fs_cache               0      0    192   21    1 : tunables  120   60
  8 : slabdata      0      0      0
files_cache            0      0    896    4    1 : tunables   54   27
  8 : slabdata      0      0      0
task_delay_info        3     72    112   36    1 : tunables  120   60
  8 : slabdata      2      2      0
task_struct            3      3   3840    1    1 : tunables   24   12
  8 : slabdata      3      3      0
radix_tree_node        0      0    728    5    1 : tunables   54   27
  8 : slabdata      0      0      0
shmem_inode_cache      2      9    848    9    2 : tunables   54   27
  8 : slabdata      1      1      0
inode_cache           39     45    744    5    1 : tunables   54   27
  8 : slabdata      9      9      0
ext4_inode_cache       0      0   1224    3    1 : tunables   24   12
  8 : slabdata      0      0      0
sock_inode_cache       3      8    832    4    1 : tunables   54   27
  8 : slabdata      2      2      0
proc_inode_cache       0      0    816    5    1 : tunables   54   27
  8 : slabdata      0      0      0
dentry                52     90    272   15    1 : tunables  120   60
  8 : slabdata      6      6      0
anon_vma             140    348    136   29    1 : tunables  120   60
  8 : slabdata     12     12      0
anon_vma_chain       257    468    112   36    1 : tunables  120   60
  8 : slabdata     13     13      0
vm_area_struct       510    780    272   15    1 : tunables  120   60
  8 : slabdata     52     52      0
mm_struct              1      3   1280    3    1 : tunables   24   12
  8 : slabdata      1      1      0
cred_jar              12     24    320   12    1 : tunables  120   60
  8 : slabdata      2      2      0

So, when I end the libvirt scenery, those slabs belong to those qemus
has to invoke quarantine_remove_cache,
I guess that's why  qlist_move_cache occupies so much CPU cycles. I
also guess this make libvirt complain
(wait for too long?)

Sorry not to research deeply into system in the first place and submit
a patch in a hurry.

And I propose a little sugguestion to  improve qlist_move_cache if you
like. Won't we design some kind of hash mechanism,
then we group the qlist_node according to their cache, so as not to
compare one by one to every qlist_node in the system.


Sorry for your time
Best Wishes
Zhouyi

On Wed, Nov 29, 2017 at 7:41 AM, Zhouyi Zhou <zhouzhouyi@gmail.com> wrote:
> Hi,
>     I will try to reestablish the environment, and design proof of
> concept of experiment.
> Cheers
>
> On Wed, Nov 29, 2017 at 1:57 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
>> On Tue, Nov 28, 2017 at 6:56 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
>>> On Tue, Nov 28, 2017 at 12:30 PM, Zhouyi Zhou <zhouzhouyi@gmail.com> wrote:
>>>> Hi,
>>>>    By using perf top, qlist_move_cache occupies 100% cpu did really
>>>> happen in my environment yesterday, or I
>>>> won't notice the kasan code.
>>>>    Currently I have difficulty to let it reappear because the frontend
>>>> guy modified some user mode code.
>>>>    I can repeat again and again now is
>>>> kgdb_breakpoint () at kernel/debug/debug_core.c:1073
>>>> 1073 wmb(); /* Sync point after breakpoint */
>>>> (gdb) p quarantine_batch_size
>>>> $1 = 3601946
>>>>    And by instrument code, maximum
>>>> global_quarantine[quarantine_tail].bytes reached is 6618208.
>>>
>>> On second thought, size does not matter too much because there can be
>>> large objects. Quarantine always quantize by objects, we can't part of
>>> an object into one batch, and another part of the object into another
>>> object. But it's not a problem, because overhead per objects is O(1).
>>> We can push a single 4MB object and overflow target size by 4MB and
>>> that will be fine.
>>> Either way, 6MB is not terribly much too. Should take milliseconds to process.
>>>
>>>
>>>
>>>
>>>>    I do think drain quarantine right in quarantine_put is a better
>>>> place to drain because cache_free is fine in
>>>> that context. I am willing do it if you think it is convenient :-)
>>
>>
>> Andrey, do you know of any problems with draining quarantine in push?
>> Do you have any objections?
>>
>> But it's still not completely clear to me what problem we are solving.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
