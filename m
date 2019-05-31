Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47BC8C04AB6
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 14:35:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F329926AB4
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 14:35:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F329926AB4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8F3C16B026F; Fri, 31 May 2019 10:35:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 87D6D6B0278; Fri, 31 May 2019 10:35:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 746866B027A; Fri, 31 May 2019 10:35:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 20A166B026F
	for <linux-mm@kvack.org>; Fri, 31 May 2019 10:35:50 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id x17so3944597wrl.21
        for <linux-mm@kvack.org>; Fri, 31 May 2019 07:35:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=zpYdOZQYJjx2RGRv+QzRgK0D+4PdqDlz+L4dxBHjF0Y=;
        b=VPCUMg7cvv46cOj21/1lIQEUq8Qk9seGoAVYnaH8r0a6qN6UyxcNTht0WiBgE6o+WH
         64quqytW26AsrvPcNu0LbZYtR/EyDN9RXD+48/LrFWYHvgYtrmqJbPbRx9tswuilwSjU
         k4AK5K+jb5KkO0mP65qRBipMo8+GS633Odtf5f7Ua4cnqp9QLEaesAVAS4fjtR0abPtL
         D0KiV6MAP9RoYNd67haya5usEu5KUdnTjNkWTowLuV0TohFNwrn0BdDNspG6xOiXE8Q/
         UWNYfHH7BrPOCWVtiGKwFpIMH7CN1ZU2rgkzrGJsRz+1VYwBIOkX4bJciD5ZOl6SanAh
         DXRA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVDo6lHEk9b3sA4ZgUHmk75vpc3mdvrqQUpc1bbcFaHS8EZfJh0
	EYxmDGjZmDfNLRVuRMBPn5+TXFnIrf/oPI1mBNriWKqlMJgBsZhgNc2dXrJ10k+3ybWs3m8wune
	irm57TKmSmzxKIekoFtcsfX+47FDvt9zo8w2a2GXff0iWChs5Su2bWUA85QGBxk/AEA==
X-Received: by 2002:adf:f38a:: with SMTP id m10mr7071729wro.81.1559313349569;
        Fri, 31 May 2019 07:35:49 -0700 (PDT)
X-Received: by 2002:adf:f38a:: with SMTP id m10mr7071669wro.81.1559313348349;
        Fri, 31 May 2019 07:35:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559313348; cv=none;
        d=google.com; s=arc-20160816;
        b=nCdq45spQhJdhKHzW93l8mqAJMNVPqiuiCdf0NUXANMnXhWdja0ujErIuFc2dnB0NJ
         mq70Vz/viXbCiygeGceSlhm2XUH7XW/oDZ8PJ6b5YZZsmvfXJreUnzxb6C4Pb1+YLEol
         WkgtfhWto2i+3Rcs7/gNN9baNMjQlhEiybhBjKu2ZJDl9nfpUJNsMhWxfiqu1KYDxDi0
         JZ6CDJ9r05MpH2SwFnG4HEintxRT96RK8xEillqSdwEuFS+XSNPDV9nhbZ4PnTMwERSR
         fvrEyPMUY7MqcOv7whgGolGnfwIvmyFoPM4Xts557L96RiDhq2PnsToY2ZFk7s0+hpUT
         a6jw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=zpYdOZQYJjx2RGRv+QzRgK0D+4PdqDlz+L4dxBHjF0Y=;
        b=AR/Du0K9+LocfGwlKYn3AuiRAGhD9EpZP9Zmh/JOlyVwzPD2M+Fw54a83d1WlFHB9z
         oh6Aza3EMd3inCIMcrMQpeo4IP6QgrDPvpKazYTJlhturTC6Is/Em7fvDJaaEwEchb9U
         NwLJtfpULBj9595LSlXxS+RlsMy9EB0tJbzqcRaIMKQEK3eYFwIqxa1Fs3XgymxxlcB9
         uDWWZ7YB0F9fvAbcXPh2t8QXZU5QXpgc42WTuZI/Qk1Y3b0Afbhtpt2CYSKofqPeYyk4
         UL2nl4mtRoCY2mwpmrQIPcvwa/F2/9q1YRbwIgLeIlo/O6ZiM5cjVjGEMOd/rbmhMhLS
         43dg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d6sor3605780wrq.39.2019.05.31.07.35.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 31 May 2019 07:35:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqyYxA1f0O8QDJdCWzXpTmGREOKGjJG0yza9e84WRp11d75K1jo6aXZCj0Id9Xo5x72tF3PgPw==
X-Received: by 2002:a5d:45c4:: with SMTP id b4mr7125690wrs.291.1559313347765;
        Fri, 31 May 2019 07:35:47 -0700 (PDT)
Received: from localhost (nat-pool-brq-t.redhat.com. [213.175.37.10])
        by smtp.gmail.com with ESMTPSA id s9sm5649892wmc.1.2019.05.31.07.35.46
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 31 May 2019 07:35:46 -0700 (PDT)
Date: Fri, 31 May 2019 16:35:45 +0200
From: Oleksandr Natalenko <oleksandr@redhat.com>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, jannh@google.com,
	oleg@redhat.com, christian@brauner.io, hdanton@sina.com
Subject: Re: [RFCv2 4/6] mm: factor out madvise's core functionality
Message-ID: <20190531143545.jwmgzaigd4rbw2wy@butterfly.localdomain>
References: <20190531064313.193437-1-minchan@kernel.org>
 <20190531064313.193437-5-minchan@kernel.org>
 <20190531070420.m7sxybbzzayig44o@butterfly.localdomain>
 <20190531131226.GA195463@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190531131226.GA195463@google.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 31, 2019 at 10:12:26PM +0900, Minchan Kim wrote:
> On Fri, May 31, 2019 at 09:04:20AM +0200, Oleksandr Natalenko wrote:
> > On Fri, May 31, 2019 at 03:43:11PM +0900, Minchan Kim wrote:
> > > This patch factor out madvise's core functionality so that upcoming
> > > patch can reuse it without duplication. It shouldn't change any behavior.
> > > 
> > > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > > ---
> > >  mm/madvise.c | 188 +++++++++++++++++++++++++++------------------------
> > >  1 file changed, 101 insertions(+), 87 deletions(-)
> > > 
> > > diff --git a/mm/madvise.c b/mm/madvise.c
> > > index 9d749a1420b4..466623ea8c36 100644
> > > --- a/mm/madvise.c
> > > +++ b/mm/madvise.c
> > > @@ -425,9 +425,10 @@ static int madvise_pageout_pte_range(pmd_t *pmd, unsigned long addr,
> > >  	struct page *page;
> > >  	int isolated = 0;
> > >  	struct vm_area_struct *vma = walk->vma;
> > > +	struct task_struct *task = walk->private;
> > >  	unsigned long next;
> > >  
> > > -	if (fatal_signal_pending(current))
> > > +	if (fatal_signal_pending(task))
> > >  		return -EINTR;
> > >  
> > >  	next = pmd_addr_end(addr, end);
> > > @@ -505,12 +506,14 @@ static int madvise_pageout_pte_range(pmd_t *pmd, unsigned long addr,
> > >  }
> > >  
> > >  static void madvise_pageout_page_range(struct mmu_gather *tlb,
> > > -			     struct vm_area_struct *vma,
> > > -			     unsigned long addr, unsigned long end)
> > > +				struct task_struct *task,
> > > +				struct vm_area_struct *vma,
> > > +				unsigned long addr, unsigned long end)
> > >  {
> > >  	struct mm_walk warm_walk = {
> > >  		.pmd_entry = madvise_pageout_pte_range,
> > >  		.mm = vma->vm_mm,
> > > +		.private = task,
> > >  	};
> > >  
> > >  	tlb_start_vma(tlb, vma);
> > > @@ -519,9 +522,9 @@ static void madvise_pageout_page_range(struct mmu_gather *tlb,
> > >  }
> > >  
> > >  
> > > -static long madvise_pageout(struct vm_area_struct *vma,
> > > -			struct vm_area_struct **prev,
> > > -			unsigned long start_addr, unsigned long end_addr)
> > > +static long madvise_pageout(struct task_struct *task,
> > > +		struct vm_area_struct *vma, struct vm_area_struct **prev,
> > > +		unsigned long start_addr, unsigned long end_addr)
> > >  {
> > >  	struct mm_struct *mm = vma->vm_mm;
> > >  	struct mmu_gather tlb;
> > > @@ -532,7 +535,7 @@ static long madvise_pageout(struct vm_area_struct *vma,
> > >  
> > >  	lru_add_drain();
> > >  	tlb_gather_mmu(&tlb, mm, start_addr, end_addr);
> > > -	madvise_pageout_page_range(&tlb, vma, start_addr, end_addr);
> > > +	madvise_pageout_page_range(&tlb, task, vma, start_addr, end_addr);
> > >  	tlb_finish_mmu(&tlb, start_addr, end_addr);
> > >  
> > >  	return 0;
> > > @@ -744,7 +747,8 @@ static long madvise_dontneed_single_vma(struct vm_area_struct *vma,
> > >  	return 0;
> > >  }
> > >  
> > > -static long madvise_dontneed_free(struct vm_area_struct *vma,
> > > +static long madvise_dontneed_free(struct mm_struct *mm,
> > > +				  struct vm_area_struct *vma,
> > >  				  struct vm_area_struct **prev,
> > >  				  unsigned long start, unsigned long end,
> > >  				  int behavior)
> > > @@ -756,8 +760,8 @@ static long madvise_dontneed_free(struct vm_area_struct *vma,
> > >  	if (!userfaultfd_remove(vma, start, end)) {
> > >  		*prev = NULL; /* mmap_sem has been dropped, prev is stale */
> > >  
> > > -		down_read(&current->mm->mmap_sem);
> > > -		vma = find_vma(current->mm, start);
> > > +		down_read(&mm->mmap_sem);
> > > +		vma = find_vma(mm, start);
> > >  		if (!vma)
> > >  			return -ENOMEM;
> > >  		if (start < vma->vm_start) {
> > > @@ -804,7 +808,8 @@ static long madvise_dontneed_free(struct vm_area_struct *vma,
> > >   * Application wants to free up the pages and associated backing store.
> > >   * This is effectively punching a hole into the middle of a file.
> > >   */
> > > -static long madvise_remove(struct vm_area_struct *vma,
> > > +static long madvise_remove(struct mm_struct *mm,
> > > +				struct vm_area_struct *vma,
> > >  				struct vm_area_struct **prev,
> > >  				unsigned long start, unsigned long end)
> > >  {
> > > @@ -838,13 +843,13 @@ static long madvise_remove(struct vm_area_struct *vma,
> > >  	get_file(f);
> > >  	if (userfaultfd_remove(vma, start, end)) {
> > >  		/* mmap_sem was not released by userfaultfd_remove() */
> > > -		up_read(&current->mm->mmap_sem);
> > > +		up_read(&mm->mmap_sem);
> > >  	}
> > >  	error = vfs_fallocate(f,
> > >  				FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE,
> > >  				offset, end - start);
> > >  	fput(f);
> > > -	down_read(&current->mm->mmap_sem);
> > > +	down_read(&mm->mmap_sem);
> > >  	return error;
> > >  }
> > >  
> > > @@ -918,21 +923,23 @@ static int madvise_inject_error(int behavior,
> > >  #endif
> > >  
> > >  static long
> > > -madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
> > > +madvise_vma(struct task_struct *task, struct mm_struct *mm,
> > > +		struct vm_area_struct *vma, struct vm_area_struct **prev,
> > >  		unsigned long start, unsigned long end, int behavior)
> > >  {
> > >  	switch (behavior) {
> > >  	case MADV_REMOVE:
> > > -		return madvise_remove(vma, prev, start, end);
> > > +		return madvise_remove(mm, vma, prev, start, end);
> > >  	case MADV_WILLNEED:
> > >  		return madvise_willneed(vma, prev, start, end);
> > >  	case MADV_COLD:
> > >  		return madvise_cold(vma, prev, start, end);
> > >  	case MADV_PAGEOUT:
> > > -		return madvise_pageout(vma, prev, start, end);
> > > +		return madvise_pageout(task, vma, prev, start, end);
> > >  	case MADV_FREE:
> > >  	case MADV_DONTNEED:
> > > -		return madvise_dontneed_free(vma, prev, start, end, behavior);
> > > +		return madvise_dontneed_free(mm, vma, prev, start,
> > > +						end, behavior);
> > >  	default:
> > >  		return madvise_behavior(vma, prev, start, end, behavior);
> > >  	}
> > > @@ -976,68 +983,8 @@ madvise_behavior_valid(int behavior)
> > >  	}
> > >  }
> > >  
> > > -/*
> > > - * The madvise(2) system call.
> > > - *
> > > - * Applications can use madvise() to advise the kernel how it should
> > > - * handle paging I/O in this VM area.  The idea is to help the kernel
> > > - * use appropriate read-ahead and caching techniques.  The information
> > > - * provided is advisory only, and can be safely disregarded by the
> > > - * kernel without affecting the correct operation of the application.
> > > - *
> > > - * behavior values:
> > > - *  MADV_NORMAL - the default behavior is to read clusters.  This
> > > - *		results in some read-ahead and read-behind.
> > > - *  MADV_RANDOM - the system should read the minimum amount of data
> > > - *		on any access, since it is unlikely that the appli-
> > > - *		cation will need more than what it asks for.
> > > - *  MADV_SEQUENTIAL - pages in the given range will probably be accessed
> > > - *		once, so they can be aggressively read ahead, and
> > > - *		can be freed soon after they are accessed.
> > > - *  MADV_WILLNEED - the application is notifying the system to read
> > > - *		some pages ahead.
> > > - *  MADV_DONTNEED - the application is finished with the given range,
> > > - *		so the kernel can free resources associated with it.
> > > - *  MADV_FREE - the application marks pages in the given range as lazy free,
> > > - *		where actual purges are postponed until memory pressure happens.
> > > - *  MADV_REMOVE - the application wants to free up the given range of
> > > - *		pages and associated backing store.
> > > - *  MADV_DONTFORK - omit this area from child's address space when forking:
> > > - *		typically, to avoid COWing pages pinned by get_user_pages().
> > > - *  MADV_DOFORK - cancel MADV_DONTFORK: no longer omit this area when forking.
> > > - *  MADV_WIPEONFORK - present the child process with zero-filled memory in this
> > > - *              range after a fork.
> > > - *  MADV_KEEPONFORK - undo the effect of MADV_WIPEONFORK
> > > - *  MADV_HWPOISON - trigger memory error handler as if the given memory range
> > > - *		were corrupted by unrecoverable hardware memory failure.
> > > - *  MADV_SOFT_OFFLINE - try to soft-offline the given range of memory.
> > > - *  MADV_MERGEABLE - the application recommends that KSM try to merge pages in
> > > - *		this area with pages of identical content from other such areas.
> > > - *  MADV_UNMERGEABLE- cancel MADV_MERGEABLE: no longer merge pages with others.
> > > - *  MADV_HUGEPAGE - the application wants to back the given range by transparent
> > > - *		huge pages in the future. Existing pages might be coalesced and
> > > - *		new pages might be allocated as THP.
> > > - *  MADV_NOHUGEPAGE - mark the given range as not worth being backed by
> > > - *		transparent huge pages so the existing pages will not be
> > > - *		coalesced into THP and new pages will not be allocated as THP.
> > > - *  MADV_DONTDUMP - the application wants to prevent pages in the given range
> > > - *		from being included in its core dump.
> > > - *  MADV_DODUMP - cancel MADV_DONTDUMP: no longer exclude from core dump.
> > > - *
> > > - * return values:
> > > - *  zero    - success
> > > - *  -EINVAL - start + len < 0, start is not page-aligned,
> > > - *		"behavior" is not a valid value, or application
> > > - *		is attempting to release locked or shared pages,
> > > - *		or the specified address range includes file, Huge TLB,
> > > - *		MAP_SHARED or VMPFNMAP range.
> > > - *  -ENOMEM - addresses in the specified range are not currently
> > > - *		mapped, or are outside the AS of the process.
> > > - *  -EIO    - an I/O error occurred while paging in data.
> > > - *  -EBADF  - map exists, but area maps something that isn't a file.
> > > - *  -EAGAIN - a kernel resource was temporarily unavailable.
> > > - */
> > > -SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
> > > +static int madvise_core(struct task_struct *task, struct mm_struct *mm,
> > > +			unsigned long start, size_t len_in, int behavior)
> > 
> > Just a minor nitpick, but can we please have it named madvise_common,
> > not madvise_core? This would follow a usual naming scheme, when some
> > common functionality is factored out (like, for mutexes, semaphores
> > etc), and within the kernel "core" usually means something completely
> > different.
> 
> Sure.
> 
> > 
> > >  {
> > >  	unsigned long end, tmp;
> > >  	struct vm_area_struct *vma, *prev;
> > > @@ -1068,15 +1015,16 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
> > >  
> > >  #ifdef CONFIG_MEMORY_FAILURE
> > >  	if (behavior == MADV_HWPOISON || behavior == MADV_SOFT_OFFLINE)
> > > -		return madvise_inject_error(behavior, start, start + len_in);
> > > +		return madvise_inject_error(behavior,
> > > +					start, start + len_in);
> > 
> > Not sure what this change is about except changing the line length.
> > Note, madvise_inject_error() still operates on "current" through
> > get_user_pages_fast() and gup_pgd_range(), but that was not changed
> > here. I Know you've filtered out this hint later, so technically this
> > is not an issue, but, maybe, this needs some attention too since we've
> > already spotted it?
> 
> It is leftover I had done. I actually modified it to handle remote
> task but changed my mind not to fix it because process_madvise
> will not support it at this moment. I'm not sure it's a good idea
> to change it for *might-be-done-in-future* at this moment even though
> we have spotted.

I'd expect to have at least some comments in code on why other hints
are disabled, so if we already know some shortcomings, this information
would not be lost.

Of course, I don't care much about memory poisoning, but if it can be
addressed now, let's address it now.

> 
> > 
> > >  #endif
> > >  
> > >  	write = madvise_need_mmap_write(behavior);
> > >  	if (write) {
> > > -		if (down_write_killable(&current->mm->mmap_sem))
> > > +		if (down_write_killable(&mm->mmap_sem))
> > >  			return -EINTR;
> > 
> > Do you still need that trick with mmget_still_valid() here?
> > Something like:
> 
> Since MADV_COLD|PAGEOUT doesn't change address space layout or
> vma->vm_flags, technically, we don't need it if I understand
> correctly. Right?

I'd expect so, yes. But.

Since we want this interface to be universal and to be able to cover
various needs, and since my initial intention with working in this
direction involved KSM, I'd ask you to enable KSM hints too, and once
(and if) that happens, the work there is done under write lock, and
you'll need this trick to be applied.

Of course, I can do that myself later in a subsequent patch series once
(and, again, if) your series is merged, but, maybe, we can cover this
already especially given the fact that KSM hinting is a relatively easy
task in this pile. I did some preliminary tests with it, and so far no
dragons have started to roar.

> 
> > 
> > if (current->mm != mm && !mmget_still_valid(mm))
> >    goto skip_mm;
> > 
> > and that skip_mm label would be before
> > 
> > if (write)
> >    up_write(&mm->mmap_sem);
> > 
> > below.
> > 
> > (see 04f5866e41fb70690e28397487d8bd8eea7d712a for details on this)

-- 
  Best regards,
    Oleksandr Natalenko (post-factum)
    Senior Software Maintenance Engineer

