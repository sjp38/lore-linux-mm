Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 405446B032F
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 23:04:35 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id m9so1994662pff.0
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 20:04:35 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id r76si1282468pfl.194.2017.12.05.20.04.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 05 Dec 2017 20:04:33 -0800 (PST)
Message-Id: <201712060328.vB63SrDK069830@www262.sakura.ne.jp>
Subject: Re: Multiple =?ISO-2022-JP?B?b29tX3JlYXBlciBCVUdzOiB1bm1hcF9wYWdlX3Jhbmdl?=
 =?ISO-2022-JP?B?IHJhY2luZyB3aXRoIGV4aXRfbW1hcA==?=
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Wed, 06 Dec 2017 12:28:53 +0900
References: <alpine.DEB.2.10.1712051824050.91099@chino.kir.corp.google.com> <alpine.DEB.2.10.1712051857450.98120@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1712051857450.98120@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

David Rientjes wrote:
> On Tue, 5 Dec 2017, David Rientjes wrote:
> 
> > One way to solve the issue is to have two mm flags: one to indicate the mm 
> > is entering unmap_vmas(): set the flag, do down_write(&mm->mmap_sem); 
> > up_write(&mm->mmap_sem), then unmap_vmas().  The oom reaper needs this 
> > flag clear, not MMF_OOM_SKIP, while holding down_read(&mm->mmap_sem) to be 
> > allowed to call unmap_page_range().  The oom killer will still defer 
> > selecting this victim for MMF_OOM_SKIP after unmap_vmas() returns.
> > 
> > The result of that change would be that we do not oom reap from any mm 
> > entering unmap_vmas(): we let unmap_vmas() do the work itself and avoid 
> > racing with it.
> > 
> 
> I think we need something like the following?

This patch does not work. __oom_reap_task_mm() can find MMF_REAPING and
return true and sets MMF_OOM_SKIP before exit_mmap() calls down_write().

Also, I don't know what exit_mmap() is doing but I think that there is a
possibility that the OOM reaper tries to reclaim mlocked pages as soon as
exit_mmap() cleared VM_LOCKED flag by calling munlock_vma_pages_all().

	if (mm->locked_vm) {
		vma = mm->mmap;
		while (vma) {
			if (vma->vm_flags & VM_LOCKED)
				munlock_vma_pages_all(vma);
			vma = vma->vm_next;
		}
	}

/*
 * munlock_vma_pages_range() - munlock all pages in the vma range.'
 * @vma - vma containing range to be munlock()ed.
 * @start - start address in @vma of the range
 * @end - end of range in @vma.
 *
 *  For mremap(), munmap() and exit().
 *
 * Called with @vma VM_LOCKED.
 *
 * Returns with VM_LOCKED cleared.  Callers must be prepared to
 * deal with this.
 *
 * We don't save and restore VM_LOCKED here because pages are
 * still on lru.  In unmap path, pages might be scanned by reclaim
 * and re-mlocked by try_to_{munlock|unmap} before we unmap and
 * free them.  This will result in freeing mlocked pages.
 */
void munlock_vma_pages_range(struct vm_area_struct *vma,
                             unsigned long start, unsigned long end)
{
	vma->vm_flags &= VM_LOCKED_CLEAR_MASK;

	while (start < end) {
		/*
		 * Things for munlock() are done here. But at this point,
		 * __oom_reap_task_mm() can call unmap_page_range() because
		 * can_madv_dontneed_vma() returns true due to VM_LOCKED
		 * being already cleared and MMF_OOM_SKIP is not yet set.
		 */
	}
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
