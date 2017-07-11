Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 405C16B04C9
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 02:58:39 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 4so29450233wrc.15
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 23:58:39 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j126si8841886wmg.7.2017.07.10.23.58.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 10 Jul 2017 23:58:38 -0700 (PDT)
Date: Tue, 11 Jul 2017 08:58:34 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, oom: allow oom reaper to race with exit_mmap
Message-ID: <20170711065834.GF24852@dhcp22.suse.cz>
References: <20170626130346.26314-1-mhocko@kernel.org>
 <alpine.DEB.2.10.1707101652260.54972@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1707101652260.54972@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Andrea Argangeli <andrea@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Mon 10-07-17 16:55:22, David Rientjes wrote:
> On Mon, 26 Jun 2017, Michal Hocko wrote:
> 
> > diff --git a/mm/mmap.c b/mm/mmap.c
> > index 3bd5ecd20d4d..253808e716dc 100644
> > --- a/mm/mmap.c
> > +++ b/mm/mmap.c
> > @@ -2962,6 +2962,11 @@ void exit_mmap(struct mm_struct *mm)
> >  	/* Use -1 here to ensure all VMAs in the mm are unmapped */
> >  	unmap_vmas(&tlb, vma, 0, -1);
> >  
> > +	/*
> > +	 * oom reaper might race with exit_mmap so make sure we won't free
> > +	 * page tables or unmap VMAs under its feet
> > +	 */
> > +	down_write(&mm->mmap_sem);
> >  	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
> >  	tlb_finish_mmu(&tlb, 0, -1);
> >  
> > @@ -2974,7 +2979,9 @@ void exit_mmap(struct mm_struct *mm)
> >  			nr_accounted += vma_pages(vma);
> >  		vma = remove_vma(vma);
> >  	}
> > +	mm->mmap = NULL;
> >  	vm_unacct_memory(nr_accounted);
> > +	up_write(&mm->mmap_sem);
> >  }
> >  
> >  /* Insert vm structure into process list sorted by address
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index 0e2c925e7826..5dc0ff22d567 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -472,36 +472,8 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
> >  	struct vm_area_struct *vma;
> >  	bool ret = true;
> >  
> > -	/*
> > -	 * We have to make sure to not race with the victim exit path
> > -	 * and cause premature new oom victim selection:
> > -	 * __oom_reap_task_mm		exit_mm
> > -	 *   mmget_not_zero
> > -	 *				  mmput
> > -	 *				    atomic_dec_and_test
> > -	 *				  exit_oom_victim
> > -	 *				[...]
> > -	 *				out_of_memory
> > -	 *				  select_bad_process
> > -	 *				    # no TIF_MEMDIE task selects new victim
> > -	 *  unmap_page_range # frees some memory
> > -	 */
> > -	mutex_lock(&oom_lock);
> > -
> > -	if (!down_read_trylock(&mm->mmap_sem)) {
> > -		ret = false;
> > -		goto unlock_oom;
> > -	}
> > -
> > -	/*
> > -	 * increase mm_users only after we know we will reap something so
> > -	 * that the mmput_async is called only when we have reaped something
> > -	 * and delayed __mmput doesn't matter that much
> > -	 */
> > -	if (!mmget_not_zero(mm)) {
> > -		up_read(&mm->mmap_sem);
> > -		goto unlock_oom;
> > -	}
> > +	if (!down_read_trylock(&mm->mmap_sem))
> > +		return false;
> 
> I think this should return true if mm->mmap == NULL here.

This?
---
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 5dc0ff22d567..e155d1d8064f 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -470,11 +470,14 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 {
 	struct mmu_gather tlb;
 	struct vm_area_struct *vma;
-	bool ret = true;
 
 	if (!down_read_trylock(&mm->mmap_sem))
 		return false;
 
+	/* There is nothing to reap so bail out without signs in the log */
+	if (!mm->mmap)
+		goto unlock;
+
 	/*
 	 * Tell all users of get_user/copy_from_user etc... that the content
 	 * is no longer stable. No barriers really needed because unmapping
@@ -508,9 +511,10 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 			K(get_mm_counter(mm, MM_ANONPAGES)),
 			K(get_mm_counter(mm, MM_FILEPAGES)),
 			K(get_mm_counter(mm, MM_SHMEMPAGES)));
+unlock:
 	up_read(&mm->mmap_sem);
 
-	return ret;
+	return true;
 }
 
 #define MAX_OOM_REAP_RETRIES 10
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
