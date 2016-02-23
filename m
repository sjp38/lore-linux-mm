Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id BEC376B0005
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 08:22:00 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id a4so208712384wme.1
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 05:22:00 -0800 (PST)
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com. [74.125.82.50])
        by mx.google.com with ESMTPS id j136si39619788wmg.36.2016.02.23.05.21.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 05:21:59 -0800 (PST)
Received: by mail-wm0-f50.google.com with SMTP id g62so221826511wme.1
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 05:21:59 -0800 (PST)
Date: Tue, 23 Feb 2016 14:21:57 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/5] oom reaper: handle mlocked pages
Message-ID: <20160223132157.GD14178@dhcp22.suse.cz>
References: <1454505240-23446-1-git-send-email-mhocko@kernel.org>
 <1454505240-23446-3-git-send-email-mhocko@kernel.org>
 <alpine.DEB.2.10.1602221734140.4688@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1602221734140.4688@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Argangeli <andrea@kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 22-02-16 17:36:07, David Rientjes wrote:
> On Wed, 3 Feb 2016, Michal Hocko wrote:
> 
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index 9a0e4e5f50b4..840e03986497 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -443,13 +443,6 @@ static bool __oom_reap_vmas(struct mm_struct *mm)
> >  			continue;
> >  
> >  		/*
> > -		 * mlocked VMAs require explicit munlocking before unmap.
> > -		 * Let's keep it simple here and skip such VMAs.
> > -		 */
> > -		if (vma->vm_flags & VM_LOCKED)
> > -			continue;
> > -
> > -		/*
> >  		 * Only anonymous pages have a good chance to be dropped
> >  		 * without additional steps which we cannot afford as we
> >  		 * are OOM already.
> > @@ -459,9 +452,12 @@ static bool __oom_reap_vmas(struct mm_struct *mm)
> >  		 * we do not want to block exit_mmap by keeping mm ref
> >  		 * count elevated without a good reason.
> >  		 */
> > -		if (vma_is_anonymous(vma) || !(vma->vm_flags & VM_SHARED))
> > +		if (vma_is_anonymous(vma) || !(vma->vm_flags & VM_SHARED)) {
> > +			if (vma->vm_flags & VM_LOCKED)
> > +				munlock_vma_pages_all(vma);
> >  			unmap_page_range(&tlb, vma, vma->vm_start, vma->vm_end,
> >  					 &details);
> > +		}
> >  	}
> >  	tlb_finish_mmu(&tlb, 0, -1);
> >  	up_read(&mm->mmap_sem);
> 
> Are we concerned about munlock_vma_pages_all() taking lock_page() and 
> perhaps stalling forever, the same way it would stall in exit_mmap() for 
> VM_LOCKED vmas, if another thread has locked the same page and is doing an 
> allocation?

This is a good question. I have checked for that particular case
previously and managed to convinced myself that this is OK(ish).
munlock_vma_pages_range locks only THP pages to prevent from the
parallel split-up AFAICS. And split_huge_page_to_list doesn't seem
to depend on an allocation. It can block on anon_vma lock but I didn't
see any allocation requests from there either. I might be missing
something of course. Do you have any specific path in mind?

> I'm wondering if in that case it would be better to do a 
> best-effort munlock_vma_pages_all() with trylock_page() and just give up 
> on releasing memory from that particular vma.  In that case, there may be 
> other memory that can be freed with unmap_page_range() that would handle 
> this livelock.

I have tried to code it up but I am not really sure the whole churn is
really worth it - unless I am missing something that would really make
the THP case likely to hit in the real life.

Just for the reference this is what I came up with (just compile tested).
---
diff --git a/mm/internal.h b/mm/internal.h
index cac6eb458727..63dcdd60aca8 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -249,11 +249,13 @@ void __vma_link_list(struct mm_struct *mm, struct vm_area_struct *vma,
 #ifdef CONFIG_MMU
 extern long populate_vma_page_range(struct vm_area_struct *vma,
 		unsigned long start, unsigned long end, int *nonblocking);
-extern void munlock_vma_pages_range(struct vm_area_struct *vma,
-			unsigned long start, unsigned long end);
-static inline void munlock_vma_pages_all(struct vm_area_struct *vma)
+
+/* Can fail only if enforce == false */
+extern int munlock_vma_pages_range(struct vm_area_struct *vma,
+			unsigned long start, unsigned long end, bool enforce);
+static inline int munlock_vma_pages_all(struct vm_area_struct *vma, bool enforce)
 {
-	munlock_vma_pages_range(vma, vma->vm_start, vma->vm_end);
+	return munlock_vma_pages_range(vma, vma->vm_start, vma->vm_end, enforce);
 }
 
 /*
diff --git a/mm/mlock.c b/mm/mlock.c
index 96f001041928..934c0f8f8ebc 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -431,8 +431,9 @@ static unsigned long __munlock_pagevec_fill(struct pagevec *pvec,
  * and re-mlocked by try_to_{munlock|unmap} before we unmap and
  * free them.  This will result in freeing mlocked pages.
  */
-void munlock_vma_pages_range(struct vm_area_struct *vma,
-			     unsigned long start, unsigned long end)
+int munlock_vma_pages_range(struct vm_area_struct *vma,
+			     unsigned long start, unsigned long end,
+			     bool enforce)
 {
 	vma->vm_flags &= VM_LOCKED_CLEAR_MASK;
 
@@ -460,7 +461,13 @@ void munlock_vma_pages_range(struct vm_area_struct *vma,
 				VM_BUG_ON_PAGE(PageMlocked(page), page);
 				put_page(page); /* follow_page_mask() */
 			} else if (PageTransHuge(page)) {
-				lock_page(page);
+				if (enforce) {
+					lock_page(page);
+				} else if (!trylock_page(page)) {
+					put_page(page);
+					return -EAGAIN;
+				}
+
 				/*
 				 * Any THP page found by follow_page_mask() may
 				 * have gotten split before reaching
@@ -497,6 +504,8 @@ void munlock_vma_pages_range(struct vm_area_struct *vma,
 next:
 		cond_resched();
 	}
+
+	return 0;
 }
 
 /*
@@ -561,7 +570,7 @@ static int mlock_fixup(struct vm_area_struct *vma, struct vm_area_struct **prev,
 	if (lock)
 		vma->vm_flags = newflags;
 	else
-		munlock_vma_pages_range(vma, start, end);
+		munlock_vma_pages_range(vma, start, end, true);
 
 out:
 	*prev = vma;
diff --git a/mm/mmap.c b/mm/mmap.c
index cfc0cdca421e..7c2ed6e7b415 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2592,7 +2592,7 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len)
 		while (tmp && tmp->vm_start < end) {
 			if (tmp->vm_flags & VM_LOCKED) {
 				mm->locked_vm -= vma_pages(tmp);
-				munlock_vma_pages_all(tmp);
+				munlock_vma_pages_all(tmp, true);
 			}
 			tmp = tmp->vm_next;
 		}
@@ -2683,7 +2683,7 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
 	if (vma->vm_flags & VM_LOCKED) {
 		flags |= MAP_LOCKED;
 		/* drop PG_Mlocked flag for over-mapped range */
-		munlock_vma_pages_range(vma, start, start + size);
+		munlock_vma_pages_range(vma, start, start + size, true);
 	}
 
 	file = get_file(vma->vm_file);
@@ -2825,7 +2825,7 @@ void exit_mmap(struct mm_struct *mm)
 		vma = mm->mmap;
 		while (vma) {
 			if (vma->vm_flags & VM_LOCKED)
-				munlock_vma_pages_all(vma);
+				munlock_vma_pages_all(vma, true);
 			vma = vma->vm_next;
 		}
 	}
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 32ce05b1aa10..09e6f3211f1c 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -473,7 +473,8 @@ static bool __oom_reap_task(struct task_struct *tsk)
 		 */
 		if (vma_is_anonymous(vma) || !(vma->vm_flags & VM_SHARED)) {
 			if (vma->vm_flags & VM_LOCKED)
-				munlock_vma_pages_all(vma);
+				if (munlock_vma_pages_all(vma, false))
+					continue;
 			unmap_page_range(&tlb, vma, vma->vm_start, vma->vm_end,
 					 &details);
 		}

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
