Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 76C126B02C3
	for <linux-mm@kvack.org>; Sat, 17 Jun 2017 09:30:44 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id i71so21052049itf.2
        for <linux-mm@kvack.org>; Sat, 17 Jun 2017 06:30:44 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id e141si1719139ita.63.2017.06.17.06.30.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 17 Jun 2017 06:30:41 -0700 (PDT)
Subject: Re: Re: [patch] mm, oom: prevent additional oom kills before memory is freed
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170616083946.GC30580@dhcp22.suse.cz>
	<201706161927.EII04611.VOFFMLJOOFHQSt@I-love.SAKURA.ne.jp>
	<20170616110206.GH30580@dhcp22.suse.cz>
	<201706162326.IEJ52125.JFFtMVQOSLHOFO@I-love.SAKURA.ne.jp>
	<20170616144237.GP30580@dhcp22.suse.cz>
In-Reply-To: <20170616144237.GP30580@dhcp22.suse.cz>
Message-Id: <201706172230.DBG40327.tJMHOFFFQVOLSO@I-love.SAKURA.ne.jp>
Date: Sat, 17 Jun 2017 22:30:31 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Fri 16-06-17 23:26:20, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Fri 16-06-17 19:27:19, Tetsuo Handa wrote:
> > > > Michal Hocko wrote:
> > > > > On Fri 16-06-17 09:54:34, Tetsuo Handa wrote:
> > > > > [...]
> > > > > > And the patch you proposed is broken.
> > > > > 
> > > > > Thanks for your testing!
> > > > >  
> > > > > > ----------
> > > > > > [  161.846202] Out of memory: Kill process 6331 (a.out) score 999 or sacrifice child
> > > > > > [  161.850327] Killed process 6331 (a.out) total-vm:4172kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
> > > > > > [  161.858503] ------------[ cut here ]------------
> > > > > > [  161.861512] kernel BUG at mm/memory.c:1381!
> > > > > 
> > > > > BUG_ON(addr >= end) suggests our vma has trimmed. I guess I see what is
> > > > > going on here.
> > > > > __oom_reap_task_mm				exit_mmap
> > > > > 						  free_pgtables
> > > > > 						  up_write(mm->mmap_sem)
> > > > >   down_read_trylock(&mm->mmap_sem)
> > > > >   						  remove_vma
> > > > >     unmap_page_range
> > > > > 
> > > > > So we need to extend the mmap_sem coverage. See the updated diff (not
> > > > > the full proper patch yet).
> > > > 
> > > > That diff is still wrong. We need to prevent __oom_reap_task_mm() from calling
> > > > unmap_page_range() when __mmput() already called exit_mm(), by setting/checking
> > > > MMF_OOM_SKIP like shown below.
> > > 
> > > Care to explain why?
> > 
> > I don't know. Your updated diff is causing below oops.
> > 
> > ----------
> > [   90.621890] Out of memory: Kill process 2671 (a.out) score 999 or sacrifice child
> > [   90.624636] Killed process 2671 (a.out) total-vm:4172kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
> > [   90.861308] general protection fault: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> > [   90.863695] Modules linked in: coretemp pcspkr sg vmw_vmci shpchp i2c_piix4 sd_mod ata_generic pata_acpi serio_raw vmwgfx drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops ttm mptspi scsi_transport_spi mptscsih ahci mptbase libahci drm e1000 ata_piix i2c_core libata ipv6
> > [   90.870672] CPU: 2 PID: 47 Comm: oom_reaper Not tainted 4.12.0-rc5+ #128
> > [   90.872929] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
> > [   90.875995] task: ffff88007b6cd2c0 task.stack: ffff88007b6d0000
> > [   90.878290] RIP: 0010:__oom_reap_task_mm+0xa1/0x160
> 
> What does this dissassemble to on your kernel? Care to post addr2line?

----------
[  114.427451] Out of memory: Kill process 2876 (a.out) score 999 or sacrifice child
[  114.430208] Killed process 2876 (a.out) total-vm:4172kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
[  114.436753] general protection fault: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[  114.439129] Modules linked in: pcspkr coretemp sg vmw_vmci i2c_piix4 shpchp sd_mod ata_generic pata_acpi serio_raw vmwgfx drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops ttm ahci e1000 libahci mptspi scsi_transport_spi drm mptscsih mptbase i2c_core ata_piix libata ipv6
[  114.446220] CPU: 0 PID: 47 Comm: oom_reaper Not tainted 4.12.0-rc5+ #133
[  114.448705] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[  114.451695] task: ffff88007b6cd2c0 task.stack: ffff88007b6d0000
[  114.453703] RIP: 0010:__oom_reap_task_mm+0xa1/0x160
[  114.455422] RSP: 0000:ffff88007b6d3df0 EFLAGS: 00010202
[  114.457527] RAX: 6b6b6b6b6b6b6b6b RBX: ffff8800670eaa40 RCX: 0000000000000000
[  114.460002] RDX: ffff88007b6d3e18 RSI: ffff8800670eaa40 RDI: ffff88007b6d3df0
[  114.462206] RBP: ffff88007b6d3e98 R08: ffff88007b6cdb08 R09: ffff88007b6cdad0
[  114.464390] R10: 0000000000000000 R11: 0000000083f54a84 R12: ffff8800670eab00
[  114.466659] R13: ffff880067211bc0 R14: 6b6b6b6b6b6b6b6b R15: ffff8800670eaa40
[  114.469126] FS:  0000000000000000(0000) GS:ffff88007c200000(0000) knlGS:0000000000000000
[  114.471496] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  114.473540] CR2: 00007f55d759d050 CR3: 0000000079ff4000 CR4: 00000000001406f0
[  114.475773] Call Trace:
[  114.477078]  oom_reaper+0xa2/0x1b0 /* oom_reap_task at mm/oom_kill.c:542 (inlined by) oom_reaper at mm/oom_kill.c:580 */
[  114.478569]  ? wake_up_bit+0x30/0x30
[  114.480058]  kthread+0x10d/0x140
[  114.481656]  ? __oom_reap_task_mm+0x160/0x160
[  114.483308]  ? kthread_create_on_node+0x60/0x60
[  114.485075]  ret_from_fork+0x27/0x40
[  114.486620] Code: c3 e8 54 82 f1 ff f0 80 8b 7a 04 00 00 40 48 8d bd 58 ff ff ff 48 83 c9 ff 31 d2 48 89 de e8 57 12 03 00 4c 8b 33 4d 85 f6 74 3b <49> 8b 46 50 a9 00 24 40 00 75 27 49 83 be 90 00 00 00 00 74 04 
[  114.491819] RIP: __oom_reap_task_mm+0xa1/0x160 RSP: ffff88007b6d3df0
[  114.494520] ---[ end trace e254efa6cf6f5fe6 ]---
----------

The __oom_reap_task_mm+0xa1/0x160 is __oom_reap_task_mm at mm/oom_kill.c:472
which is "struct vm_area_struct *vma;" line in __oom_reap_task_mm().
The __oom_reap_task_mm+0xb1/0x160 is __oom_reap_task_mm at mm/oom_kill.c:519
which is "if (vma_is_anonymous(vma) || !(vma->vm_flags & VM_SHARED))" line.
The <49> 8b 46 50 is "vma->vm_flags" in can_madv_dontneed_vma(vma) from __oom_reap_task_mm().

Is it safe for the OOM reaper to call tlb_gather_mmu()/unmap_page_range()/tlb_finish_mmu() sequence
after the OOM victim already completed tlb_gather_mmu()/unmap_vmas()/free_pgtables()/tlb_finish_mmu()/
remove_vma() sequence from exit_mmap() from __mmput() from mmput() from exit_mm() from do_exit() ?
I guess we need to prevent the OOM reaper from calling the sequence if the OOM victim already did
the sequence. And my patch did it via trial and error.

----------
unlock_oom:
        mutex_unlock(&oom_lock);
     26a:       48 c7 c7 00 00 00 00    mov    $0x0,%rdi
     271:       e8 00 00 00 00          callq  276 <__oom_reap_task_mm+0x56>
        return ret;
}
     276:       48 8b 55 d8             mov    -0x28(%rbp),%rdx
     27a:       65 48 33 14 25 28 00    xor    %gs:0x28,%rdx
     281:       00 00
     283:       89 d8                   mov    %ebx,%eax
     285:       75 10                   jne    297 <__oom_reap_task_mm+0x77>
     287:       48 81 c4 88 00 00 00    add    $0x88,%rsp
     28e:       5b                      pop    %rbx
     28f:       41 5c                   pop    %r12
     291:       41 5d                   pop    %r13
     293:       41 5e                   pop    %r14
     295:       5d                      pop    %rbp
     296:       c3                      retq
     297:       e8 00 00 00 00          callq  29c <__oom_reap_task_mm+0x7c>
 */
static __always_inline void
set_bit(long nr, volatile unsigned long *addr)
{
        if (IS_IMMEDIATE(nr)) {
                asm volatile(LOCK_PREFIX "orb %1,%0"
     29c:       f0 80 8b 7a 04 00 00    lock orb $0x40,0x47a(%rbx)
     2a3:       40
         * should imply barriers already and the reader would hit a page fault
         * if it stumbled over a reaped memory.
         */
        set_bit(MMF_UNSTABLE, &mm->flags);

        tlb_gather_mmu(&tlb, mm, 0, -1);
     2a4:       48 8d bd 58 ff ff ff    lea    -0xa8(%rbp),%rdi
     2ab:       48 83 c9 ff             or     $0xffffffffffffffff,%rcx
     2af:       31 d2                   xor    %edx,%edx
     2b1:       48 89 de                mov    %rbx,%rsi
     2b4:       e8 00 00 00 00          callq  2b9 <__oom_reap_task_mm+0x99>
        for (vma = mm->mmap ; vma; vma = vma->vm_next) {
     2b9:       4c 8b 33                mov    (%rbx),%r14
     2bc:       4d 85 f6                test   %r14,%r14
     2bf:       74 3b                   je     2fc <__oom_reap_task_mm+0xdc>
static DEFINE_SPINLOCK(oom_reaper_lock);

static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
{
        struct mmu_gather tlb;
        struct vm_area_struct *vma;
     2c1:       49 8b 46 50             mov    0x50(%r14),%rax
         */
        set_bit(MMF_UNSTABLE, &mm->flags);

        tlb_gather_mmu(&tlb, mm, 0, -1);
        for (vma = mm->mmap ; vma; vma = vma->vm_next) {
                if (!can_madv_dontneed_vma(vma))
     2c5:       a9 00 24 40 00          test   $0x402400,%eax
     2ca:       75 27                   jne    2f3 <__oom_reap_task_mm+0xd3>
                 * We do not even care about fs backed pages because all
                 * which are reclaimable have already been reclaimed and
                 * we do not want to block exit_mmap by keeping mm ref
                 * count elevated without a good reason.
                 */
                if (vma_is_anonymous(vma) || !(vma->vm_flags & VM_SHARED))
     2cc:       49 83 be 90 00 00 00    cmpq   $0x0,0x90(%r14)
     2d3:       00
     2d4:       74 04                   je     2da <__oom_reap_task_mm+0xba>
     2d6:       a8 08                   test   $0x8,%al
     2d8:       75 19                   jne    2f3 <__oom_reap_task_mm+0xd3>
                        unmap_page_range(&tlb, vma, vma->vm_start, vma->vm_end,
     2da:       49 8b 4e 08             mov    0x8(%r14),%rcx
     2de:       49 8b 16                mov    (%r14),%rdx
     2e1:       48 8d bd 58 ff ff ff    lea    -0xa8(%rbp),%rdi
     2e8:       45 31 c0                xor    %r8d,%r8d
     2eb:       4c 89 f6                mov    %r14,%rsi
     2ee:       e8 00 00 00 00          callq  2f3 <__oom_reap_task_mm+0xd3>
         * if it stumbled over a reaped memory.
----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
