Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 412186B02F4
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 10:26:29 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id s131so35542491itd.6
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 07:26:29 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id r67si3361210ita.70.2017.06.16.07.26.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 16 Jun 2017 07:26:27 -0700 (PDT)
Subject: Re: Re: [patch] mm, oom: prevent additional oom kills before memoryis freed
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170615221236.GB22341@dhcp22.suse.cz>
	<201706160054.v5G0sY7c064781@www262.sakura.ne.jp>
	<20170616083946.GC30580@dhcp22.suse.cz>
	<201706161927.EII04611.VOFFMLJOOFHQSt@I-love.SAKURA.ne.jp>
	<20170616110206.GH30580@dhcp22.suse.cz>
In-Reply-To: <20170616110206.GH30580@dhcp22.suse.cz>
Message-Id: <201706162326.IEJ52125.JFFtMVQOSLHOFO@I-love.SAKURA.ne.jp>
Date: Fri, 16 Jun 2017 23:26:20 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Fri 16-06-17 19:27:19, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Fri 16-06-17 09:54:34, Tetsuo Handa wrote:
> > > [...]
> > > > And the patch you proposed is broken.
> > > 
> > > Thanks for your testing!
> > >  
> > > > ----------
> > > > [  161.846202] Out of memory: Kill process 6331 (a.out) score 999 or sacrifice child
> > > > [  161.850327] Killed process 6331 (a.out) total-vm:4172kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
> > > > [  161.858503] ------------[ cut here ]------------
> > > > [  161.861512] kernel BUG at mm/memory.c:1381!
> > > 
> > > BUG_ON(addr >= end) suggests our vma has trimmed. I guess I see what is
> > > going on here.
> > > __oom_reap_task_mm				exit_mmap
> > > 						  free_pgtables
> > > 						  up_write(mm->mmap_sem)
> > >   down_read_trylock(&mm->mmap_sem)
> > >   						  remove_vma
> > >     unmap_page_range
> > > 
> > > So we need to extend the mmap_sem coverage. See the updated diff (not
> > > the full proper patch yet).
> > 
> > That diff is still wrong. We need to prevent __oom_reap_task_mm() from calling
> > unmap_page_range() when __mmput() already called exit_mm(), by setting/checking
> > MMF_OOM_SKIP like shown below.
> 
> Care to explain why?

I don't know. Your updated diff is causing below oops.

----------
[   90.621890] Out of memory: Kill process 2671 (a.out) score 999 or sacrifice child
[   90.624636] Killed process 2671 (a.out) total-vm:4172kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
[   90.861308] general protection fault: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[   90.863695] Modules linked in: coretemp pcspkr sg vmw_vmci shpchp i2c_piix4 sd_mod ata_generic pata_acpi serio_raw vmwgfx drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops ttm mptspi scsi_transport_spi mptscsih ahci mptbase libahci drm e1000 ata_piix i2c_core libata ipv6
[   90.870672] CPU: 2 PID: 47 Comm: oom_reaper Not tainted 4.12.0-rc5+ #128
[   90.872929] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[   90.875995] task: ffff88007b6cd2c0 task.stack: ffff88007b6d0000
[   90.878290] RIP: 0010:__oom_reap_task_mm+0xa1/0x160
[   90.880242] RSP: 0018:ffff88007b6d3df0 EFLAGS: 00010202
[   90.882240] RAX: 6b6b6b6b6b6b6b6b RBX: ffff880077b8cd40 RCX: 0000000000000000
[   90.884612] RDX: ffff88007b6d3e18 RSI: ffff880077b8cd40 RDI: ffff88007b6d3df0
[   90.887001] RBP: ffff88007b6d3e98 R08: ffff88007b6cdb08 R09: ffff88007b6cdad0
[   90.889702] R10: 0000000000000000 R11: 000000009213dd65 R12: ffff880077b8ce00
[   90.892973] R13: ffff880076f48040 R14: 6b6b6b6b6b6b6b6b R15: ffff880077b8cd40
[   90.895765] FS:  0000000000000000(0000) GS:ffff88007c600000(0000) knlGS:0000000000000000
[   90.899015] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   90.901462] CR2: 00007feeae35ac80 CR3: 0000000076e21000 CR4: 00000000001406e0
[   90.904019] Call Trace:
[   90.905518]  ? process_timeout+0x1/0x10
[   90.907280]  oom_reaper+0xa2/0x1b0
[   90.908946]  ? wake_up_bit+0x30/0x30
[   90.911391]  kthread+0x10d/0x140
[   90.913003]  ? __oom_reap_task_mm+0x160/0x160
[   90.914936]  ? kthread_create_on_node+0x60/0x60
[   90.916733]  ret_from_fork+0x27/0x40
[   90.918307] Code: c3 e8 54 82 f1 ff f0 80 8b 7a 04 00 00 40 48 8d bd 58 ff ff ff 48 83 c9 ff 31 d2 48 89 de e8 57 12 03 00 4c 8b 33 4d 85 f6 74 3b <49> 8b 46 50 a9 00 24 40 00 75 27 49 83 be 90 00 00 00 00 74 04 
[   90.923922] RIP: __oom_reap_task_mm+0xa1/0x160 RSP: ffff88007b6d3df0
[   90.929583] ---[ end trace 20f6ec27ed25c461 ]---
----------

It is you who should explain why. I found my patch via trial and error.

> [...]
>  
> > Since the OOM reaper does not reap hugepages, khugepaged_exit() part could be
> > safe.
> 
> I think you are mixing hugetlb and THP pages here. khugepaged_exit is
> about later and we do unmap those.

OK.

> 
> > But ksm_exit() part might interfere.
> 
> How?

Why you think it does not interfere?
Please explain it in your patch description because your patch is
trying to do a tricky thing. I'm not a MM person. I just suspect
what you think no problem.

> 
> > If it is guaranteed to be safe,
> > what will go wrong if we move uprobe_clear_state()/exit_aio()/ksm_exit() etc.
> > to just before mmdrop() (i.e. after setting MMF_OOM_SKIP) ?
> 
> I do not see why those matter and why they should be any special. Unless
> I miss anything we really do only care about page table tear down and
> the address space modification. They do none of that.

I think the patch I posted at
http://lkml.kernel.org/r/201706162122.ACE95321.tOFLOOVFFHMSJQ@I-love.SAKURA.ne.jp
will be safer, and you agree that a solution which is fully contained inside
the oom proper would be preferable. Thus, let's start checking that patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
