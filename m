Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 112B76B0270
	for <linux-mm@kvack.org>; Thu, 27 Oct 2016 06:57:48 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id p190so4432025wmp.3
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 03:57:48 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id 69si2445921wms.141.2016.10.27.03.57.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Oct 2016 03:57:46 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id m83so2090926wmc.0
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 03:57:46 -0700 (PDT)
Date: Thu, 27 Oct 2016 12:57:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm: unexport __get_user_pages_unlocked()
Message-ID: <20161027105743.GH6454@dhcp22.suse.cz>
References: <20161027095141.2569-1-lstoakes@gmail.com>
 <20161027095141.2569-3-lstoakes@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161027095141.2569-3-lstoakes@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lorenzo Stoakes <lstoakes@gmail.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-security-module@vger.kernel.org, linux-rdma@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-fsdevel@vger.kernel.org

On Thu 27-10-16 10:51:41, Lorenzo Stoakes wrote:
> This patch unexports the low-level __get_user_pages_unlocked() function and
> replaces invocations with calls to more appropriate higher-level functions.
> 
> In hva_to_pfn_slow() we are able to replace __get_user_pages_unlocked() with
> get_user_pages_unlocked() since we can now pass gup_flags.
> 
> In async_pf_execute() and process_vm_rw_single_vec() we need to pass different
> tsk, mm arguments so get_user_pages_remote() is the sane replacement in these
> cases (having added manual acquisition and release of mmap_sem.)
> 
> Additionally get_user_pages_remote() reintroduces use of the FOLL_TOUCH
> flag. However, this flag was originally silently dropped by 1e9877902dc7e
> ("mm/gup: Introduce get_user_pages_remote()"), so this appears to have been
> unintentional and reintroducing it is therefore not an issue.

Looks good to me.
 
> Signed-off-by: Lorenzo Stoakes <lstoakes@gmail.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/mm.h     |  3 ---
>  mm/gup.c               |  8 ++++----
>  mm/nommu.c             |  7 +++----
>  mm/process_vm_access.c | 12 ++++++++----
>  virt/kvm/async_pf.c    | 10 +++++++---
>  virt/kvm/kvm_main.c    |  5 ++---
>  6 files changed, 24 insertions(+), 21 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index cc15445..7b2d14e 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1280,9 +1280,6 @@ long get_user_pages(unsigned long start, unsigned long nr_pages,
>  			    struct vm_area_struct **vmas);
>  long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
>  		    unsigned int gup_flags, struct page **pages, int *locked);
> -long __get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
> -			       unsigned long start, unsigned long nr_pages,
> -			       struct page **pages, unsigned int gup_flags);
>  long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
>  		    struct page **pages, unsigned int gup_flags);
>  int get_user_pages_fast(unsigned long start, int nr_pages, int write,
> diff --git a/mm/gup.c b/mm/gup.c
> index 0567851..8028af1 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -866,9 +866,10 @@ EXPORT_SYMBOL(get_user_pages_locked);
>   * caller if required (just like with __get_user_pages). "FOLL_GET"
>   * is set implicitly if "pages" is non-NULL.
>   */
> -__always_inline long __get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
> -					       unsigned long start, unsigned long nr_pages,
> -					       struct page **pages, unsigned int gup_flags)
> +static __always_inline long __get_user_pages_unlocked(struct task_struct *tsk,
> +		struct mm_struct *mm, unsigned long start,
> +		unsigned long nr_pages, struct page **pages,
> +		unsigned int gup_flags)
>  {
>  	long ret;
>  	int locked = 1;
> @@ -880,7 +881,6 @@ __always_inline long __get_user_pages_unlocked(struct task_struct *tsk, struct m
>  		up_read(&mm->mmap_sem);
>  	return ret;
>  }
> -EXPORT_SYMBOL(__get_user_pages_unlocked);
> 
>  /*
>   * get_user_pages_unlocked() is suitable to replace the form:
> diff --git a/mm/nommu.c b/mm/nommu.c
> index 8b8faaf..669437b 100644
> --- a/mm/nommu.c
> +++ b/mm/nommu.c
> @@ -176,9 +176,9 @@ long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
>  }
>  EXPORT_SYMBOL(get_user_pages_locked);
> 
> -long __get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
> -			       unsigned long start, unsigned long nr_pages,
> -			       struct page **pages, unsigned int gup_flags)
> +static long __get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
> +				      unsigned long start, unsigned long nr_pages,
> +			              struct page **pages, unsigned int gup_flags)
>  {
>  	long ret;
>  	down_read(&mm->mmap_sem);
> @@ -187,7 +187,6 @@ long __get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
>  	up_read(&mm->mmap_sem);
>  	return ret;
>  }
> -EXPORT_SYMBOL(__get_user_pages_unlocked);
> 
>  long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
>  			     struct page **pages, unsigned int gup_flags)
> diff --git a/mm/process_vm_access.c b/mm/process_vm_access.c
> index be8dc8d..84d0c7e 100644
> --- a/mm/process_vm_access.c
> +++ b/mm/process_vm_access.c
> @@ -88,7 +88,7 @@ static int process_vm_rw_single_vec(unsigned long addr,
>  	ssize_t rc = 0;
>  	unsigned long max_pages_per_loop = PVM_MAX_KMALLOC_PAGES
>  		/ sizeof(struct pages *);
> -	unsigned int flags = FOLL_REMOTE;
> +	unsigned int flags = 0;
> 
>  	/* Work out address and page range required */
>  	if (len == 0)
> @@ -100,15 +100,19 @@ static int process_vm_rw_single_vec(unsigned long addr,
> 
>  	while (!rc && nr_pages && iov_iter_count(iter)) {
>  		int pages = min(nr_pages, max_pages_per_loop);
> +		int locked = 1;
>  		size_t bytes;
> 
>  		/*
>  		 * Get the pages we're interested in.  We must
> -		 * add FOLL_REMOTE because task/mm might not
> +		 * access remotely because task/mm might not
>  		 * current/current->mm
>  		 */
> -		pages = __get_user_pages_unlocked(task, mm, pa, pages,
> -						  process_pages, flags);
> +		down_read(&mm->mmap_sem);
> +		pages = get_user_pages_remote(task, mm, pa, pages, flags,
> +					      process_pages, NULL, &locked);
> +		if (locked)
> +			up_read(&mm->mmap_sem);
>  		if (pages <= 0)
>  			return -EFAULT;
> 
> diff --git a/virt/kvm/async_pf.c b/virt/kvm/async_pf.c
> index 8035cc1..dab8b19 100644
> --- a/virt/kvm/async_pf.c
> +++ b/virt/kvm/async_pf.c
> @@ -76,16 +76,20 @@ static void async_pf_execute(struct work_struct *work)
>  	struct kvm_vcpu *vcpu = apf->vcpu;
>  	unsigned long addr = apf->addr;
>  	gva_t gva = apf->gva;
> +	int locked = 1;
> 
>  	might_sleep();
> 
>  	/*
>  	 * This work is run asynchromously to the task which owns
>  	 * mm and might be done in another context, so we must
> -	 * use FOLL_REMOTE.
> +	 * access remotely.
>  	 */
> -	__get_user_pages_unlocked(NULL, mm, addr, 1, NULL,
> -			FOLL_WRITE | FOLL_REMOTE);
> +	down_read(&mm->mmap_sem);
> +	get_user_pages_remote(NULL, mm, addr, 1, FOLL_WRITE, NULL, NULL,
> +			&locked);
> +	if (locked)
> +		up_read(&mm->mmap_sem);
> 
>  	kvm_async_page_present_sync(vcpu, apf);
> 
> diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
> index 2907b7b..c45d951 100644
> --- a/virt/kvm/kvm_main.c
> +++ b/virt/kvm/kvm_main.c
> @@ -1415,13 +1415,12 @@ static int hva_to_pfn_slow(unsigned long addr, bool *async, bool write_fault,
>  		npages = get_user_page_nowait(addr, write_fault, page);
>  		up_read(&current->mm->mmap_sem);
>  	} else {
> -		unsigned int flags = FOLL_TOUCH | FOLL_HWPOISON;
> +		unsigned int flags = FOLL_HWPOISON;
> 
>  		if (write_fault)
>  			flags |= FOLL_WRITE;
> 
> -		npages = __get_user_pages_unlocked(current, current->mm, addr, 1,
> -						   page, flags);
> +		npages = get_user_pages_unlocked(addr, 1, page, flags);
>  	}
>  	if (npages != 1)
>  		return npages;
> --
> 2.10.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
