Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B5A6F9000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 01:29:43 -0400 (EDT)
Received: by fxh17 with SMTP id 17so8772025fxh.14
        for <linux-mm@kvack.org>; Mon, 26 Sep 2011 22:29:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1317066395.2796.11.camel@edumazet-laptop>
References: <CA+v9cxadZzWr35Q9RFzVgk_NZsbZ8PkVLJNxjBAMpargW9Lm4Q@mail.gmail.com>
	<1317054774.6363.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20110926165024.GA21617@e102109-lin.cambridge.arm.com>
	<1317066395.2796.11.camel@edumazet-laptop>
Date: Tue, 27 Sep 2011 13:29:40 +0800
Message-ID: <CA+v9cxYzWJScCa2mMoEovq3WULSZYQaq6EjoRV7SQUjr0L_RiQ@mail.gmail.com>
Subject: Re: Question about memory leak detector giving false positive report
 for net/core/flow.c
From: Huajun Li <huajun.li.lee@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Catalin Marinas <Catalin.Marinas@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, netdev <netdev@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Huajun Li <huajun.li.lee@gmail.com>

2011/9/27 Eric Dumazet <eric.dumazet@gmail.com>:
> Le lundi 26 septembre 2011 =E0 17:50 +0100, Catalin Marinas a =E9crit :
>> On Mon, Sep 26, 2011 at 05:32:54PM +0100, Eric Dumazet wrote:
>> > Le lundi 26 septembre 2011 =E0 23:17 +0800, Huajun Li a =E9crit :
>> > > Memory leak detector gives following memory leak report, it seems th=
e
>> > > report is triggered by net/core/flow.c, but actually, it should be a
>> > > false positive report.
>> > > So, is there any idea from kmemleak side to fix/disable this false
>> > > positive report like this?
>> > > Yes, kmemleak_not_leak(...) could disable it, but is it suitable for=
 this case ?
>> ...
>> > CC lkml and percpu maintainers (Tejun Heo & Christoph Lameter ) as wel=
l
>> >
>> > AFAIK this false positive only occurs if percpu data is allocated
>> > outside of embedded pcu space.
>> >
>> > =A0(grep pcpu_get_vm_areas /proc/vmallocinfo)
>> >
>> > I suspect this is a percpu/kmemleak cooperation problem (a missing
>> > kmemleak_alloc() ?)
>> >
>> > I am pretty sure kmemleak_not_leak() is not the right answer to this
>> > problem.
>>
>> kmemleak_not_leak() definitely not the write answer. The alloc_percpu()
>> call does not have any kmemleak_alloc() callback, so it doesn't scan
>> them.
>>
>> Huajun, could you please try the patch below:
>>
>> 8<--------------------------------
>> kmemleak: Handle percpu memory allocation
>>
>> From: Catalin Marinas <catalin.marinas@arm.com>
>>
>> This patch adds kmemleak callbacks from the percpu allocator, reducing a
>> number of false positives caused by kmemleak not scanning such memory
>> blocks.
>>
>> Reported-by: Huajun Li <huajun.li.lee@gmail.com>
>> Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
>> ---
>> =A0mm/percpu.c | =A0 11 +++++++++--
>> =A01 files changed, 9 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/percpu.c b/mm/percpu.c
>> index bf80e55..c47a90b 100644
>> --- a/mm/percpu.c
>> +++ b/mm/percpu.c
>> @@ -67,6 +67,7 @@
>> =A0#include <linux/spinlock.h>
>> =A0#include <linux/vmalloc.h>
>> =A0#include <linux/workqueue.h>
>> +#include <linux/kmemleak.h>
>>
>> =A0#include <asm/cacheflush.h>
>> =A0#include <asm/sections.h>
>> @@ -833,7 +834,9 @@ fail_unlock_mutex:
>> =A0 */
>> =A0void __percpu *__alloc_percpu(size_t size, size_t align)
>> =A0{
>> - =A0 =A0 return pcpu_alloc(size, align, false);
>> + =A0 =A0 void __percpu *ptr =3D pcpu_alloc(size, align, false);
>> + =A0 =A0 kmemleak_alloc(ptr, size, 1, GFP_KERNEL);
>> + =A0 =A0 return ptr;
>> =A0}
>> =A0EXPORT_SYMBOL_GPL(__alloc_percpu);
>>
>> @@ -855,7 +858,9 @@ EXPORT_SYMBOL_GPL(__alloc_percpu);
>> =A0 */
>> =A0void __percpu *__alloc_reserved_percpu(size_t size, size_t align)
>> =A0{
>> - =A0 =A0 return pcpu_alloc(size, align, true);
>> + =A0 =A0 void __percpu *ptr =3D pcpu_alloc(size, align, true);
>> + =A0 =A0 kmemleak_alloc(ptr, size, 1, GFP_KERNEL);
>> + =A0 =A0 return ptr;
>> =A0}
>>
>> =A0/**
>> @@ -915,6 +920,8 @@ void free_percpu(void __percpu *ptr)
>> =A0 =A0 =A0 if (!ptr)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>>
>> + =A0 =A0 kmemleak_free(ptr);
>> +
>> =A0 =A0 =A0 addr =3D __pcpu_ptr_to_addr(ptr);
>>
>> =A0 =A0 =A0 spin_lock_irqsave(&pcpu_lock, flags);
>>
>
> Hmm, you need to call kmemleak_alloc() for each chunk allocated per
> possible cpu.
>
> Here is the (untested) patch for the allocation phase, need the same at
> freeing time
>
> diff --git a/mm/percpu-km.c b/mm/percpu-km.c
> index 89633fe..5061ac5 100644
> --- a/mm/percpu-km.c
> +++ b/mm/percpu-km.c
> @@ -37,9 +37,12 @@ static int pcpu_populate_chunk(struct pcpu_chunk *chun=
k, int off, int size)
> =A0{
> =A0 =A0 =A0 =A0unsigned int cpu;
>
> - =A0 =A0 =A0 for_each_possible_cpu(cpu)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 memset((void *)pcpu_chunk_addr(chunk, cpu, =
0) + off, 0, size);
> + =A0 =A0 =A0 for_each_possible_cpu(cpu) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 void *chunk_addr =3D (void *)pcpu_chunk_add=
r(chunk, cpu, 0) + off;
>
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kmemleak_alloc(chunk_addr, size, 1, GFP_KER=
NEL);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 memset(chunk_addr, 0, size);
> + =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> diff --git a/mm/percpu-vm.c b/mm/percpu-vm.c
> index ea53496..0d397cc 100644
> --- a/mm/percpu-vm.c
> +++ b/mm/percpu-vm.c
> @@ -342,8 +342,12 @@ static int pcpu_populate_chunk(struct pcpu_chunk *ch=
unk, int off, int size)
> =A0 =A0 =A0 =A0/* commit new bitmap */
> =A0 =A0 =A0 =A0bitmap_copy(chunk->populated, populated, pcpu_unit_pages);
> =A0clear:
> - =A0 =A0 =A0 for_each_possible_cpu(cpu)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 memset((void *)pcpu_chunk_addr(chunk, cpu, =
0) + off, 0, size);
> + =A0 =A0 =A0 for_each_possible_cpu(cpu) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 void *chunk_addr =3D (void *)pcpu_chunk_add=
r(chunk, cpu, 0) + off;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kmemleak_alloc(chunk_addr, size, 1, GFP_KER=
NEL);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 memset(chunk_addr, 0, size);
> + =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0return 0;
>
> =A0err_unmap:
>
>

About this one,  memory leak detector disabled(actually I enable it
while config the kernel) while booting system, and and found following
info in dmesg:
---------------------------------------------------------------------------=
------------------------------------
[    0.370000] smpboot cpu 1: start_ip =3D 9a000
[    0.010000] numa_add_cpu cpu 1 node 0: mask now 0-1
[    0.530124] NMI watchdog enabled, takes one hw-pmu counter.
[    0.530344] Brought up 2 CPUs
[    0.530348] Total of 2 processors activated (10639.45 BogoMIPS).
[    0.533083] kmemleak: Cannot insert 0xffff88007a3d7448 into the
object search tree (already existing)
[    0.533083] Pid: 1, comm: swapper Tainted: G          I 3.1.0-rc7+ #25
[    0.533083] Call Trace:
[    0.533083]  [<ffffffff81256512>] create_object+0x2c2/0x360
[    0.533083]  [<ffffffff81920c5e>] kmemleak_alloc+0x7e/0x110
[    0.533083]  [<ffffffff811fd8cd>] pcpu_alloc+0xd2d/0x10f0
[    0.533083]  [<ffffffff81243129>] ? __kmalloc_track_caller+0x139/0x310
[    0.533083]  [<ffffffff811fdca8>] __alloc_percpu+0x18/0x30
[    0.533083]  [<ffffffff8128dded>] alloc_vfsmnt+0x11d/0x250
[    0.533083]  [<ffffffff8128dfd6>] vfs_kern_mount+0x46/0x130
[    0.533083]  [<ffffffff8194a283>] ? _raw_write_unlock+0x43/0x60
[    0.533083]  [<ffffffff82117cec>] shmem_init+0xb9/0x13b
[    0.533083]  [<ffffffff820ea2c6>] kernel_init+0x10e/0x23a
[    0.533083]  [<ffffffff8195a484>] kernel_thread_helper+0x4/0x10
[    0.533083]  [<ffffffff8194ac20>] ? _raw_spin_unlock_irq+0x50/0x80
[    0.533083]  [<ffffffff8194b834>] ? retint_restore_args+0x13/0x13
[    0.533083]  [<ffffffff820ea1b8>] ? start_kernel+0x6ce/0x6ce
[    0.533083]  [<ffffffff8195a480>] ? gs_change+0x13/0x13
[    0.533083] kmemleak: Kernel memory leak detector disabled
[    0.533083] kmemleak: Object 0xffff88007a200000 (size 1949696):
[    0.533083] kmemleak:   comm "swapper", pid 0, jiffies 4294937296
[    0.533083] kmemleak:   min_count =3D 0
[    0.533083] kmemleak:   count =3D 0
[    0.533083] kmemleak:   flags =3D 0x1
[    0.533083] kmemleak:   checksum =3D 0
[    0.533083] kmemleak:   backtrace:
[    0.533083]      [<ffffffff81256394>] create_object+0x144/0x360
[    0.533083]      [<ffffffff819214c8>] kmemleak_free_part+0x138/0x1d0
[    0.533083]      [<ffffffff8211e4e8>] kmemleak_init+0x30b/0x3fd
[    0.533083]      [<ffffffff820ea01c>] start_kernel+0x532/0x6ce
[    0.533083]      [<ffffffff820e938d>] x86_64_start_reservations+0x178/0x=
183
[    0.533083]      [<ffffffff820e94fb>] x86_64_start_kernel+0x163/0x179
[    0.533083]      [<ffffffffffffffff>] 0xffffffffffffffff
[    0.533083] devtmpfs: initialized
[    0.533083] gcov: version magic: 0x3430352a
[    0.533083] PM: Registering ACPI NVS region at 7d2afe00 (8352 bytes)
[    0.533083] print_constraints: dummy:
[    0.533083] RTC time: 12:40:24, date: 09/27/11
[    0.533083] NET: Registered protocol family 16

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
