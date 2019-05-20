Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3404CC04AAC
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 14:26:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC37220657
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 14:26:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC37220657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 752706B026F; Mon, 20 May 2019 10:26:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 704346B0270; Mon, 20 May 2019 10:26:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5F20C6B0271; Mon, 20 May 2019 10:26:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0EE446B026F
	for <linux-mm@kvack.org>; Mon, 20 May 2019 10:26:37 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id h13so2182892wmb.6
        for <linux-mm@kvack.org>; Mon, 20 May 2019 07:26:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=6iQOSKIYW9UJpBK8lU1MTIA5BRMtl8//awGT4QEdgQU=;
        b=P7T/YANaANus0VIgmSlby32YgyqP8O3m0mJfGqq24/7ga+G8xuRpdG7KTrlFG0C66b
         zkHoIdj6S8wOQlvuPCTKXJCNubEKcUq5QrwlICY7WznKnlb9SzJA5bF/I8/4TYpHxl+r
         kl1LYjrPWvAYe9enas7zP5bZPwjoR3Y+Ez1fy+c2ddHpzzbUn9SZfCyUwZvJCRuRFrqz
         zZJi/D6iIKvyLxU3SXCf5A5sZDz8peYcRL9lsMllknrnFgiTCCLbZyw7+vTMD63Vci8z
         VtIGVU4IupzAXCZ9/mMoCJSHn+1YHNAlwktwNgBG8J+jYDB/fVqpfsO5YWT2pQRhwSad
         EuUg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVpqUG1wJ3XpYoSCXfucAOquT7AwFu1yu0R9bmPXDErGY1C7Otq
	7sl57CwbScGq1c1VHVMeYk8KGslLrK7fgV2zoUh/8JaaTTeoFtiX67KqnhY8ZrjHBA55+No0eNs
	6vrtDIXoCH0ZDmdpM5ZQkD7WMX6hPyLGI5QT8dGCeLPiNaThyACayMZ2vAmHEUIwh/w==
X-Received: by 2002:a5d:4a44:: with SMTP id v4mr1119855wrs.84.1558362396515;
        Mon, 20 May 2019 07:26:36 -0700 (PDT)
X-Received: by 2002:a5d:4a44:: with SMTP id v4mr1119783wrs.84.1558362395359;
        Mon, 20 May 2019 07:26:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558362395; cv=none;
        d=google.com; s=arc-20160816;
        b=r5E+JPa+ith3DQgzK73u7kP5YDA7W6uT9XqxqjkxBRdPem0OZgxonfLrLIOB2q2MAG
         4uu70Fsx+FRl6kUlvwQYgYp8yoFxxolov6BaM4YGbP83Ltd57sHSsMOZ2ZX4ybgvvrkx
         cH3pXfZeaXyOXQKaTFpD4pqwCNuXjLcF5399JSgHHlnIwUpAR3q8HXaYZdQqmVXOz4/b
         PcL/yKOpw3s9t7FEOgU0FBGkKCMpn6Tn22H9ZI50qz+zRQtkCtLxyT9L9q+lRayvnL6j
         Aqf5vJaLKJADlZ+jQT1+hOnKJOXU17kaG8/f5ICx01d9Qhmm/095RHBbwjLrtnM4IOAh
         Ktyw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=6iQOSKIYW9UJpBK8lU1MTIA5BRMtl8//awGT4QEdgQU=;
        b=xjGm0EEOpO7dwTTBNluWK9jDy6ThOyapKGkJydSgBtwIYKosIQxVkiZzdRn9g1aiEw
         WBTaLFO7iR2/q2yYIcaH5/zHXZOl9e+MN7X/EwylB97sv5TSVg4ytzG46C/77ZryGGHT
         nT2Eh0cambPe9JpusHz8YM29myGiZWbMbt/Ma9hT5BhC7U0PFTqeBL7yIRm8EIqMu+6Y
         AhfQjwo2TsPgdt0jbN2O2RhVVtkWtOYTeUq/eU5bA+W9Tp8XBRmIZNO1pDEmiTfcwBbJ
         u/Wne5Rt4lYafG5Gc5btDTboQxmwXm8ET14hvkWQklSL0/zFLyT1fu5amfcbd2oiEPTX
         tV7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u10sor6395931wrm.36.2019.05.20.07.26.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 May 2019 07:26:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqySOkxSj8JyFEtIzQCgWBXM331B+o90vzDQn3uePg6N3fyz2EtpbrXMGg7VhCP1H1/7sHYsSg==
X-Received: by 2002:a5d:468b:: with SMTP id u11mr9131773wrq.276.1558362394873;
        Mon, 20 May 2019 07:26:34 -0700 (PDT)
Received: from localhost (nat-pool-brq-t.redhat.com. [213.175.37.10])
        by smtp.gmail.com with ESMTPSA id 16sm10265202wmx.45.2019.05.20.07.26.33
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 20 May 2019 07:26:34 -0700 (PDT)
Date: Mon, 20 May 2019 16:26:33 +0200
From: Oleksandr Natalenko <oleksandr@redhat.com>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>
Subject: Re: [RFC 4/7] mm: factor out madvise's core functionality
Message-ID: <20190520142633.x5d27gk454qruc4o@butterfly.localdomain>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-5-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190520035254.57579-5-minchan@kernel.org>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi.

On Mon, May 20, 2019 at 12:52:51PM +0900, Minchan Kim wrote:
> This patch factor out madvise's core functionality so that upcoming
> patch can reuse it without duplication.
> 
> It shouldn't change any behavior.
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  mm/madvise.c | 168 +++++++++++++++++++++++++++------------------------
>  1 file changed, 89 insertions(+), 79 deletions(-)
> 
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 9a6698b56845..119e82e1f065 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -742,7 +742,8 @@ static long madvise_dontneed_single_vma(struct vm_area_struct *vma,
>  	return 0;
>  }
>  
> -static long madvise_dontneed_free(struct vm_area_struct *vma,
> +static long madvise_dontneed_free(struct task_struct *tsk,
> +				  struct vm_area_struct *vma,
>  				  struct vm_area_struct **prev,
>  				  unsigned long start, unsigned long end,
>  				  int behavior)
> @@ -754,8 +755,8 @@ static long madvise_dontneed_free(struct vm_area_struct *vma,
>  	if (!userfaultfd_remove(vma, start, end)) {
>  		*prev = NULL; /* mmap_sem has been dropped, prev is stale */
>  
> -		down_read(&current->mm->mmap_sem);
> -		vma = find_vma(current->mm, start);
> +		down_read(&tsk->mm->mmap_sem);
> +		vma = find_vma(tsk->mm, start);
>  		if (!vma)
>  			return -ENOMEM;
>  		if (start < vma->vm_start) {
> @@ -802,7 +803,8 @@ static long madvise_dontneed_free(struct vm_area_struct *vma,
>   * Application wants to free up the pages and associated backing store.
>   * This is effectively punching a hole into the middle of a file.
>   */
> -static long madvise_remove(struct vm_area_struct *vma,
> +static long madvise_remove(struct task_struct *tsk,
> +				struct vm_area_struct *vma,
>  				struct vm_area_struct **prev,
>  				unsigned long start, unsigned long end)
>  {
> @@ -836,13 +838,13 @@ static long madvise_remove(struct vm_area_struct *vma,
>  	get_file(f);
>  	if (userfaultfd_remove(vma, start, end)) {
>  		/* mmap_sem was not released by userfaultfd_remove() */
> -		up_read(&current->mm->mmap_sem);
> +		up_read(&tsk->mm->mmap_sem);
>  	}
>  	error = vfs_fallocate(f,
>  				FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE,
>  				offset, end - start);
>  	fput(f);
> -	down_read(&current->mm->mmap_sem);
> +	down_read(&tsk->mm->mmap_sem);
>  	return error;
>  }
>  
> @@ -916,12 +918,13 @@ static int madvise_inject_error(int behavior,
>  #endif

What about madvise_inject_error() and get_user_pages_fast() in it
please?

>  
>  static long
> -madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
> -		unsigned long start, unsigned long end, int behavior)
> +madvise_vma(struct task_struct *tsk, struct vm_area_struct *vma,
> +		struct vm_area_struct **prev, unsigned long start,
> +		unsigned long end, int behavior)
>  {
>  	switch (behavior) {
>  	case MADV_REMOVE:
> -		return madvise_remove(vma, prev, start, end);
> +		return madvise_remove(tsk, vma, prev, start, end);
>  	case MADV_WILLNEED:
>  		return madvise_willneed(vma, prev, start, end);
>  	case MADV_COOL:
> @@ -930,7 +933,8 @@ madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
>  		return madvise_cold(vma, start, end);
>  	case MADV_FREE:
>  	case MADV_DONTNEED:
> -		return madvise_dontneed_free(vma, prev, start, end, behavior);
> +		return madvise_dontneed_free(tsk, vma, prev, start,
> +						end, behavior);
>  	default:
>  		return madvise_behavior(vma, prev, start, end, behavior);
>  	}
> @@ -974,68 +978,8 @@ madvise_behavior_valid(int behavior)
>  	}
>  }
>  
> -/*
> - * The madvise(2) system call.
> - *
> - * Applications can use madvise() to advise the kernel how it should
> - * handle paging I/O in this VM area.  The idea is to help the kernel
> - * use appropriate read-ahead and caching techniques.  The information
> - * provided is advisory only, and can be safely disregarded by the
> - * kernel without affecting the correct operation of the application.
> - *
> - * behavior values:
> - *  MADV_NORMAL - the default behavior is to read clusters.  This
> - *		results in some read-ahead and read-behind.
> - *  MADV_RANDOM - the system should read the minimum amount of data
> - *		on any access, since it is unlikely that the appli-
> - *		cation will need more than what it asks for.
> - *  MADV_SEQUENTIAL - pages in the given range will probably be accessed
> - *		once, so they can be aggressively read ahead, and
> - *		can be freed soon after they are accessed.
> - *  MADV_WILLNEED - the application is notifying the system to read
> - *		some pages ahead.
> - *  MADV_DONTNEED - the application is finished with the given range,
> - *		so the kernel can free resources associated with it.
> - *  MADV_FREE - the application marks pages in the given range as lazy free,
> - *		where actual purges are postponed until memory pressure happens.
> - *  MADV_REMOVE - the application wants to free up the given range of
> - *		pages and associated backing store.
> - *  MADV_DONTFORK - omit this area from child's address space when forking:
> - *		typically, to avoid COWing pages pinned by get_user_pages().
> - *  MADV_DOFORK - cancel MADV_DONTFORK: no longer omit this area when forking.
> - *  MADV_WIPEONFORK - present the child process with zero-filled memory in this
> - *              range after a fork.
> - *  MADV_KEEPONFORK - undo the effect of MADV_WIPEONFORK
> - *  MADV_HWPOISON - trigger memory error handler as if the given memory range
> - *		were corrupted by unrecoverable hardware memory failure.
> - *  MADV_SOFT_OFFLINE - try to soft-offline the given range of memory.
> - *  MADV_MERGEABLE - the application recommends that KSM try to merge pages in
> - *		this area with pages of identical content from other such areas.
> - *  MADV_UNMERGEABLE- cancel MADV_MERGEABLE: no longer merge pages with others.
> - *  MADV_HUGEPAGE - the application wants to back the given range by transparent
> - *		huge pages in the future. Existing pages might be coalesced and
> - *		new pages might be allocated as THP.
> - *  MADV_NOHUGEPAGE - mark the given range as not worth being backed by
> - *		transparent huge pages so the existing pages will not be
> - *		coalesced into THP and new pages will not be allocated as THP.
> - *  MADV_DONTDUMP - the application wants to prevent pages in the given range
> - *		from being included in its core dump.
> - *  MADV_DODUMP - cancel MADV_DONTDUMP: no longer exclude from core dump.
> - *
> - * return values:
> - *  zero    - success
> - *  -EINVAL - start + len < 0, start is not page-aligned,
> - *		"behavior" is not a valid value, or application
> - *		is attempting to release locked or shared pages,
> - *		or the specified address range includes file, Huge TLB,
> - *		MAP_SHARED or VMPFNMAP range.
> - *  -ENOMEM - addresses in the specified range are not currently
> - *		mapped, or are outside the AS of the process.
> - *  -EIO    - an I/O error occurred while paging in data.
> - *  -EBADF  - map exists, but area maps something that isn't a file.
> - *  -EAGAIN - a kernel resource was temporarily unavailable.
> - */
> -SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
> +static int madvise_core(struct task_struct *tsk, unsigned long start,
> +			size_t len_in, int behavior)
>  {
>  	unsigned long end, tmp;
>  	struct vm_area_struct *vma, *prev;
> @@ -1071,10 +1015,10 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
>  
>  	write = madvise_need_mmap_write(behavior);
>  	if (write) {
> -		if (down_write_killable(&current->mm->mmap_sem))
> +		if (down_write_killable(&tsk->mm->mmap_sem))
>  			return -EINTR;
>  	} else {
> -		down_read(&current->mm->mmap_sem);
> +		down_read(&tsk->mm->mmap_sem);
>  	}
>  
>  	/*
> @@ -1082,7 +1026,7 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
>  	 * ranges, just ignore them, but return -ENOMEM at the end.
>  	 * - different from the way of handling in mlock etc.
>  	 */
> -	vma = find_vma_prev(current->mm, start, &prev);
> +	vma = find_vma_prev(tsk->mm, start, &prev);
>  	if (vma && start > vma->vm_start)
>  		prev = vma;
>  
> @@ -1107,7 +1051,7 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
>  			tmp = end;
>  
>  		/* Here vma->vm_start <= start < tmp <= (end|vma->vm_end). */
> -		error = madvise_vma(vma, &prev, start, tmp, behavior);
> +		error = madvise_vma(tsk, vma, &prev, start, tmp, behavior);
>  		if (error)
>  			goto out;
>  		start = tmp;
> @@ -1119,14 +1063,80 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
>  		if (prev)
>  			vma = prev->vm_next;
>  		else	/* madvise_remove dropped mmap_sem */
> -			vma = find_vma(current->mm, start);
> +			vma = find_vma(tsk->mm, start);
>  	}
>  out:
>  	blk_finish_plug(&plug);
>  	if (write)
> -		up_write(&current->mm->mmap_sem);
> +		up_write(&tsk->mm->mmap_sem);
>  	else
> -		up_read(&current->mm->mmap_sem);
> +		up_read(&tsk->mm->mmap_sem);
>  
>  	return error;
>  }
> +
> +/*
> + * The madvise(2) system call.
> + *
> + * Applications can use madvise() to advise the kernel how it should
> + * handle paging I/O in this VM area.  The idea is to help the kernel
> + * use appropriate read-ahead and caching techniques.  The information
> + * provided is advisory only, and can be safely disregarded by the
> + * kernel without affecting the correct operation of the application.
> + *
> + * behavior values:
> + *  MADV_NORMAL - the default behavior is to read clusters.  This
> + *		results in some read-ahead and read-behind.
> + *  MADV_RANDOM - the system should read the minimum amount of data
> + *		on any access, since it is unlikely that the appli-
> + *		cation will need more than what it asks for.
> + *  MADV_SEQUENTIAL - pages in the given range will probably be accessed
> + *		once, so they can be aggressively read ahead, and
> + *		can be freed soon after they are accessed.
> + *  MADV_WILLNEED - the application is notifying the system to read
> + *		some pages ahead.
> + *  MADV_DONTNEED - the application is finished with the given range,
> + *		so the kernel can free resources associated with it.
> + *  MADV_FREE - the application marks pages in the given range as lazy free,
> + *		where actual purges are postponed until memory pressure happens.
> + *  MADV_REMOVE - the application wants to free up the given range of
> + *		pages and associated backing store.
> + *  MADV_DONTFORK - omit this area from child's address space when forking:
> + *		typically, to avoid COWing pages pinned by get_user_pages().
> + *  MADV_DOFORK - cancel MADV_DONTFORK: no longer omit this area when forking.
> + *  MADV_WIPEONFORK - present the child process with zero-filled memory in this
> + *              range after a fork.
> + *  MADV_KEEPONFORK - undo the effect of MADV_WIPEONFORK
> + *  MADV_HWPOISON - trigger memory error handler as if the given memory range
> + *		were corrupted by unrecoverable hardware memory failure.
> + *  MADV_SOFT_OFFLINE - try to soft-offline the given range of memory.
> + *  MADV_MERGEABLE - the application recommends that KSM try to merge pages in
> + *		this area with pages of identical content from other such areas.
> + *  MADV_UNMERGEABLE- cancel MADV_MERGEABLE: no longer merge pages with others.
> + *  MADV_HUGEPAGE - the application wants to back the given range by transparent
> + *		huge pages in the future. Existing pages might be coalesced and
> + *		new pages might be allocated as THP.
> + *  MADV_NOHUGEPAGE - mark the given range as not worth being backed by
> + *		transparent huge pages so the existing pages will not be
> + *		coalesced into THP and new pages will not be allocated as THP.
> + *  MADV_DONTDUMP - the application wants to prevent pages in the given range
> + *		from being included in its core dump.
> + *  MADV_DODUMP - cancel MADV_DONTDUMP: no longer exclude from core dump.
> + *
> + * return values:
> + *  zero    - success
> + *  -EINVAL - start + len < 0, start is not page-aligned,
> + *		"behavior" is not a valid value, or application
> + *		is attempting to release locked or shared pages,
> + *		or the specified address range includes file, Huge TLB,
> + *		MAP_SHARED or VMPFNMAP range.
> + *  -ENOMEM - addresses in the specified range are not currently
> + *		mapped, or are outside the AS of the process.
> + *  -EIO    - an I/O error occurred while paging in data.
> + *  -EBADF  - map exists, but area maps something that isn't a file.
> + *  -EAGAIN - a kernel resource was temporarily unavailable.
> + */
> +SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
> +{
> +	return madvise_core(current, start, len_in, behavior);
> +}
> -- 
> 2.21.0.1020.gf2820cf01a-goog
> 

-- 
  Best regards,
    Oleksandr Natalenko (post-factum)
    Senior Software Maintenance Engineer

