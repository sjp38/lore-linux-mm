Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 275146B0279
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 08:38:35 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id r103so12400376wrb.0
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 05:38:35 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q29si4747322wrc.256.2017.06.23.05.38.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 23 Jun 2017 05:38:33 -0700 (PDT)
Date: Fri, 23 Jun 2017 14:38:30 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Re: [patch] mm, oom: prevent additional oom kills before memory
 is freed
Message-ID: <20170623123830.GW5308@dhcp22.suse.cz>
References: <20170616083946.GC30580@dhcp22.suse.cz>
 <201706161927.EII04611.VOFFMLJOOFHQSt@I-love.SAKURA.ne.jp>
 <20170616110206.GH30580@dhcp22.suse.cz>
 <201706162326.IEJ52125.JFFtMVQOSLHOFO@I-love.SAKURA.ne.jp>
 <20170616144237.GP30580@dhcp22.suse.cz>
 <201706172230.DBG40327.tJMHOFFFQVOLSO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201706172230.DBG40327.tJMHOFFFQVOLSO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat 17-06-17 22:30:31, Tetsuo Handa wrote:
> Michal Hocko wrote:
[...]
> > What does this dissassemble to on your kernel? Care to post addr2line?
> 
[...]
> The __oom_reap_task_mm+0xa1/0x160 is __oom_reap_task_mm at mm/oom_kill.c:472
> which is "struct vm_area_struct *vma;" line in __oom_reap_task_mm().
> The __oom_reap_task_mm+0xb1/0x160 is __oom_reap_task_mm at mm/oom_kill.c:519
> which is "if (vma_is_anonymous(vma) || !(vma->vm_flags & VM_SHARED))" line.
> The <49> 8b 46 50 is "vma->vm_flags" in can_madv_dontneed_vma(vma) from __oom_reap_task_mm().

OK, I see what is going on here. I could have noticed earlier. Sorry my
fault. We are simply accessing a stale mm->mmap. exit_mmap() does
remove_vma which frees all the vmas but it doesn't reset mm->mmap to
NULL. Trivial to fix.

diff --git a/mm/mmap.c b/mm/mmap.c
index ca58f8a2a217..253808e716dc 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2979,6 +2979,7 @@ void exit_mmap(struct mm_struct *mm)
 			nr_accounted += vma_pages(vma);
 		vma = remove_vma(vma);
 	}
+	mm->mmap = NULL;
 	vm_unacct_memory(nr_accounted);
 	up_write(&mm->mmap_sem);
 }

> Is it safe for the OOM reaper to call tlb_gather_mmu()/unmap_page_range()/tlb_finish_mmu() sequence
> after the OOM victim already completed tlb_gather_mmu()/unmap_vmas()/free_pgtables()/tlb_finish_mmu()/
> remove_vma() sequence from exit_mmap() from __mmput() from mmput() from exit_mm() from do_exit() ?

It is safe to race until unmap_vmas because that only needs mmap_sem for
read mode (e.g. madvise MADV_DONTNEED) and all the later operations have
to be linearized because we cannot tear down page tables while the oom
reaper is doing pte walk. After we drop mmap_sem for write in the
exit_mmap then there are no vmas and so there is nothing to do in the
reaper.

I will give the patch more testing next week. This one was busy as hell
(i was travelling and then the stack gap thingy...).
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
