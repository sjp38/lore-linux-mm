Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id B3B986B0279
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 07:02:11 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id n7so7026531wrb.0
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 04:02:11 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t70si1908504wme.143.2017.06.16.04.02.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 16 Jun 2017 04:02:09 -0700 (PDT)
Date: Fri, 16 Jun 2017 13:02:07 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Re: [patch] mm, oom: prevent additional oom kills before memory
 is freed
Message-ID: <20170616110206.GH30580@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1706151459530.64172@chino.kir.corp.google.com>
 <20170615221236.GB22341@dhcp22.suse.cz>
 <201706160054.v5G0sY7c064781@www262.sakura.ne.jp>
 <20170616083946.GC30580@dhcp22.suse.cz>
 <201706161927.EII04611.VOFFMLJOOFHQSt@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201706161927.EII04611.VOFFMLJOOFHQSt@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 16-06-17 19:27:19, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Fri 16-06-17 09:54:34, Tetsuo Handa wrote:
> > [...]
> > > And the patch you proposed is broken.
> > 
> > Thanks for your testing!
> >  
> > > ----------
> > > [  161.846202] Out of memory: Kill process 6331 (a.out) score 999 or sacrifice child
> > > [  161.850327] Killed process 6331 (a.out) total-vm:4172kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
> > > [  161.858503] ------------[ cut here ]------------
> > > [  161.861512] kernel BUG at mm/memory.c:1381!
> > 
> > BUG_ON(addr >= end) suggests our vma has trimmed. I guess I see what is
> > going on here.
> > __oom_reap_task_mm				exit_mmap
> > 						  free_pgtables
> > 						  up_write(mm->mmap_sem)
> >   down_read_trylock(&mm->mmap_sem)
> >   						  remove_vma
> >     unmap_page_range
> > 
> > So we need to extend the mmap_sem coverage. See the updated diff (not
> > the full proper patch yet).
> 
> That diff is still wrong. We need to prevent __oom_reap_task_mm() from calling
> unmap_page_range() when __mmput() already called exit_mm(), by setting/checking
> MMF_OOM_SKIP like shown below.

Care to explain why?
[...]
 
> Since the OOM reaper does not reap hugepages, khugepaged_exit() part could be
> safe.

I think you are mixing hugetlb and THP pages here. khugepaged_exit is
about later and we do unmap those.

> But ksm_exit() part might interfere.

How?

> If it is guaranteed to be safe,
> what will go wrong if we move uprobe_clear_state()/exit_aio()/ksm_exit() etc.
> to just before mmdrop() (i.e. after setting MMF_OOM_SKIP) ?

I do not see why those matter and why they should be any special. Unless
I miss anything we really do only care about page table tear down and
the address space modification. They do none of that.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
