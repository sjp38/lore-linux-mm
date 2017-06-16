Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id C50C16B0279
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 10:42:40 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id y19so7750736wrc.8
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 07:42:40 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 190si2508810wmj.67.2017.06.16.07.42.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 16 Jun 2017 07:42:39 -0700 (PDT)
Date: Fri, 16 Jun 2017 16:42:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Re: [patch] mm, oom: prevent additional oom kills before
 memoryis freed
Message-ID: <20170616144237.GP30580@dhcp22.suse.cz>
References: <20170615221236.GB22341@dhcp22.suse.cz>
 <201706160054.v5G0sY7c064781@www262.sakura.ne.jp>
 <20170616083946.GC30580@dhcp22.suse.cz>
 <201706161927.EII04611.VOFFMLJOOFHQSt@I-love.SAKURA.ne.jp>
 <20170616110206.GH30580@dhcp22.suse.cz>
 <201706162326.IEJ52125.JFFtMVQOSLHOFO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201706162326.IEJ52125.JFFtMVQOSLHOFO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 16-06-17 23:26:20, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Fri 16-06-17 19:27:19, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > On Fri 16-06-17 09:54:34, Tetsuo Handa wrote:
> > > > [...]
> > > > > And the patch you proposed is broken.
> > > > 
> > > > Thanks for your testing!
> > > >  
> > > > > ----------
> > > > > [  161.846202] Out of memory: Kill process 6331 (a.out) score 999 or sacrifice child
> > > > > [  161.850327] Killed process 6331 (a.out) total-vm:4172kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
> > > > > [  161.858503] ------------[ cut here ]------------
> > > > > [  161.861512] kernel BUG at mm/memory.c:1381!
> > > > 
> > > > BUG_ON(addr >= end) suggests our vma has trimmed. I guess I see what is
> > > > going on here.
> > > > __oom_reap_task_mm				exit_mmap
> > > > 						  free_pgtables
> > > > 						  up_write(mm->mmap_sem)
> > > >   down_read_trylock(&mm->mmap_sem)
> > > >   						  remove_vma
> > > >     unmap_page_range
> > > > 
> > > > So we need to extend the mmap_sem coverage. See the updated diff (not
> > > > the full proper patch yet).
> > > 
> > > That diff is still wrong. We need to prevent __oom_reap_task_mm() from calling
> > > unmap_page_range() when __mmput() already called exit_mm(), by setting/checking
> > > MMF_OOM_SKIP like shown below.
> > 
> > Care to explain why?
> 
> I don't know. Your updated diff is causing below oops.
> 
> ----------
> [   90.621890] Out of memory: Kill process 2671 (a.out) score 999 or sacrifice child
> [   90.624636] Killed process 2671 (a.out) total-vm:4172kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
> [   90.861308] general protection fault: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> [   90.863695] Modules linked in: coretemp pcspkr sg vmw_vmci shpchp i2c_piix4 sd_mod ata_generic pata_acpi serio_raw vmwgfx drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops ttm mptspi scsi_transport_spi mptscsih ahci mptbase libahci drm e1000 ata_piix i2c_core libata ipv6
> [   90.870672] CPU: 2 PID: 47 Comm: oom_reaper Not tainted 4.12.0-rc5+ #128
> [   90.872929] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
> [   90.875995] task: ffff88007b6cd2c0 task.stack: ffff88007b6d0000
> [   90.878290] RIP: 0010:__oom_reap_task_mm+0xa1/0x160

What does this dissassemble to on your kernel? Care to post addr2line?

[...]
 
> It is you who should explain why.

I can definitely try but it was really impossible to deduce that you
have seen an oops from your previous email...

> I found my patch via trial and error.
> 
> > [...]
> >  
> > > Since the OOM reaper does not reap hugepages, khugepaged_exit() part could be
> > > safe.
> > 
> > I think you are mixing hugetlb and THP pages here. khugepaged_exit is
> > about later and we do unmap those.
> 
> OK.
> 
> > 
> > > But ksm_exit() part might interfere.
> > 
> > How?
> 
> Why you think it does not interfere?

Because it doesn't modify address space in any way.

> Please explain it in your patch description because your patch is
> trying to do a tricky thing. I'm not a MM person. I just suspect
> what you think no problem.

yeah, poking holes into a patch is a reasonable approach but if you make
a statement that "ksm_exit() part might interfere." then you should back
it by an argument.
 
> > > If it is guaranteed to be safe,
> > > what will go wrong if we move uprobe_clear_state()/exit_aio()/ksm_exit() etc.
> > > to just before mmdrop() (i.e. after setting MMF_OOM_SKIP) ?
> > 
> > I do not see why those matter and why they should be any special. Unless
> > I miss anything we really do only care about page table tear down and
> > the address space modification. They do none of that.
> 
> I think the patch I posted at
> http://lkml.kernel.org/r/201706162122.ACE95321.tOFLOOVFFHMSJQ@I-love.SAKURA.ne.jp
> will be safer, and you agree that a solution which is fully contained inside
> the oom proper would be preferable. Thus, let's start checking that patch.

Yes I will keep thinking about your approach some more but it indeed
seems easier and less tricky.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
