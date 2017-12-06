Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id C43116B0375
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 03:50:29 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id c3so1707559wrd.0
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 00:50:29 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b15si1248425edf.329.2017.12.06.00.50.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 06 Dec 2017 00:50:28 -0800 (PST)
Date: Wed, 6 Dec 2017 09:50:27 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Multiple oom_reaper BUGs: unmap_page_range racing with exit_mmap
Message-ID: <20171206085027.GD16386@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1712051824050.91099@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1712051857450.98120@chino.kir.corp.google.com>
 <201712060328.vB63SrDK069830@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201712060328.vB63SrDK069830@www262.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 06-12-17 12:28:53, Tetsuo Handa wrote:
> David Rientjes wrote:
> > On Tue, 5 Dec 2017, David Rientjes wrote:
> > 
> > > One way to solve the issue is to have two mm flags: one to indicate the mm 
> > > is entering unmap_vmas(): set the flag, do down_write(&mm->mmap_sem); 
> > > up_write(&mm->mmap_sem), then unmap_vmas().  The oom reaper needs this 
> > > flag clear, not MMF_OOM_SKIP, while holding down_read(&mm->mmap_sem) to be 
> > > allowed to call unmap_page_range().  The oom killer will still defer 
> > > selecting this victim for MMF_OOM_SKIP after unmap_vmas() returns.
> > > 
> > > The result of that change would be that we do not oom reap from any mm 
> > > entering unmap_vmas(): we let unmap_vmas() do the work itself and avoid 
> > > racing with it.
> > > 
> > 
> > I think we need something like the following?
> 
> This patch does not work. __oom_reap_task_mm() can find MMF_REAPING and
> return true and sets MMF_OOM_SKIP before exit_mmap() calls down_write().
> 
> Also, I don't know what exit_mmap() is doing but I think that there is a
> possibility that the OOM reaper tries to reclaim mlocked pages as soon as
> exit_mmap() cleared VM_LOCKED flag by calling munlock_vma_pages_all().
> 
> 	if (mm->locked_vm) {
> 		vma = mm->mmap;
> 		while (vma) {
> 			if (vma->vm_flags & VM_LOCKED)
> 				munlock_vma_pages_all(vma);
> 			vma = vma->vm_next;
> 		}
> 	}

I do not really see, why this would matter. munlock_vma_pages_all is
mostly about accounting and clearing the per-page state. It relies on
follow_page which crawls page tables and unmap_page_range clears ptes
under the lock which is taken when resolving a locked page as well.

I still have to think about all the consequences when we are effectively
reaping VM_LOCKED vmas - I suspect we can do some misaccounting but I
yet do not see how this could lead to crashes. Maybe we can move
VM_LOCKED clearing _after_ the munlock bussiness is done but this is
really hard to tell before I re-read the mlock code more throughly.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
