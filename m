Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1B5816B0260
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 02:54:42 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id n3so42229085lfn.5
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 23:54:42 -0700 (PDT)
Received: from mail-lf0-x241.google.com (mail-lf0-x241.google.com. [2a00:1450:4010:c07::241])
        by mx.google.com with ESMTPS id y85si7285956lfi.329.2016.10.12.23.54.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Oct 2016 23:54:40 -0700 (PDT)
Received: by mail-lf0-x241.google.com with SMTP id l131so8167132lfl.0
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 23:54:40 -0700 (PDT)
Subject: Re: [PATCH 02/10] mm: remove write/force parameters from
 __get_user_pages_unlocked()
References: <20161013002020.3062-1-lstoakes@gmail.com>
 <20161013002020.3062-3-lstoakes@gmail.com>
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <ce8bd0b0-84e3-4b3a-edeb-27709b0c5ce6@redhat.com>
Date: Thu, 13 Oct 2016 08:54:29 +0200
MIME-Version: 1.0
In-Reply-To: <20161013002020.3062-3-lstoakes@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lorenzo Stoakes <lstoakes@gmail.com>, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, adi-buildroot-devel@lists.sourceforge.net, ceph-devel@vger.kernel.org, dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org, kvm@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-cris-kernel@axis.com, linux-fbdev@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-mips@linux-mips.org, linux-rdma@vger.kernel.org, linux-s390@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-scsi@vger.kernel.org, linux-security-module@vger.kernel.org, linux-sh@vger.kerne



On 13/10/2016 02:20, Lorenzo Stoakes wrote:
> This patch removes the write and force parameters from
> __get_user_pages_unlocked() to make the use of FOLL_FORCE explicit in callers as
> use of this flag can result in surprising behaviour (and hence bugs) within the
> mm subsystem.
> 
> Signed-off-by: Lorenzo Stoakes <lstoakes@gmail.com>
> ---
>  include/linux/mm.h     |  3 +--
>  mm/gup.c               | 17 +++++++++--------
>  mm/nommu.c             | 12 +++++++++---
>  mm/process_vm_access.c |  7 +++++--
>  virt/kvm/async_pf.c    |  3 ++-
>  virt/kvm/kvm_main.c    | 11 ++++++++---
>  6 files changed, 34 insertions(+), 19 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index e9caec6..2db98b6 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1285,8 +1285,7 @@ long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
>  		    int write, int force, struct page **pages, int *locked);
>  long __get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
>  			       unsigned long start, unsigned long nr_pages,
> -			       int write, int force, struct page **pages,
> -			       unsigned int gup_flags);
> +			       struct page **pages, unsigned int gup_flags);
>  long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
>  		    int write, int force, struct page **pages);
>  int get_user_pages_fast(unsigned long start, int nr_pages, int write,
> diff --git a/mm/gup.c b/mm/gup.c
> index ba83942..3d620dd 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -865,17 +865,11 @@ EXPORT_SYMBOL(get_user_pages_locked);
>   */
>  __always_inline long __get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
>  					       unsigned long start, unsigned long nr_pages,
> -					       int write, int force, struct page **pages,
> -					       unsigned int gup_flags)
> +					       struct page **pages, unsigned int gup_flags)
>  {
>  	long ret;
>  	int locked = 1;
>  
> -	if (write)
> -		gup_flags |= FOLL_WRITE;
> -	if (force)
> -		gup_flags |= FOLL_FORCE;
> -
>  	down_read(&mm->mmap_sem);
>  	ret = __get_user_pages_locked(tsk, mm, start, nr_pages, pages, NULL,
>  				      &locked, false, gup_flags);
> @@ -905,8 +899,15 @@ EXPORT_SYMBOL(__get_user_pages_unlocked);
>  long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
>  			     int write, int force, struct page **pages)
>  {
> +	unsigned int flags = FOLL_TOUCH;
> +
> +	if (write)
> +		flags |= FOLL_WRITE;
> +	if (force)
> +		flags |= FOLL_FORCE;
> +
>  	return __get_user_pages_unlocked(current, current->mm, start, nr_pages,
> -					 write, force, pages, FOLL_TOUCH);
> +					 pages, flags);
>  }
>  EXPORT_SYMBOL(get_user_pages_unlocked);
>  
> diff --git a/mm/nommu.c b/mm/nommu.c
> index 95daf81..925dcc1 100644
> --- a/mm/nommu.c
> +++ b/mm/nommu.c
> @@ -185,8 +185,7 @@ EXPORT_SYMBOL(get_user_pages_locked);
>  
>  long __get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
>  			       unsigned long start, unsigned long nr_pages,
> -			       int write, int force, struct page **pages,
> -			       unsigned int gup_flags)
> +			       struct page **pages, unsigned int gup_flags)
>  {
>  	long ret;
>  	down_read(&mm->mmap_sem);
> @@ -200,8 +199,15 @@ EXPORT_SYMBOL(__get_user_pages_unlocked);
>  long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
>  			     int write, int force, struct page **pages)
>  {
> +	unsigned int flags = 0;
> +
> +	if (write)
> +		flags |= FOLL_WRITE;
> +	if (force)
> +		flags |= FOLL_FORCE;
> +
>  	return __get_user_pages_unlocked(current, current->mm, start, nr_pages,
> -					 write, force, pages, 0);
> +					 pages, flags);
>  }
>  EXPORT_SYMBOL(get_user_pages_unlocked);
>  
> diff --git a/mm/process_vm_access.c b/mm/process_vm_access.c
> index 07514d4..be8dc8d 100644
> --- a/mm/process_vm_access.c
> +++ b/mm/process_vm_access.c
> @@ -88,12 +88,16 @@ static int process_vm_rw_single_vec(unsigned long addr,
>  	ssize_t rc = 0;
>  	unsigned long max_pages_per_loop = PVM_MAX_KMALLOC_PAGES
>  		/ sizeof(struct pages *);
> +	unsigned int flags = FOLL_REMOTE;
>  
>  	/* Work out address and page range required */
>  	if (len == 0)
>  		return 0;
>  	nr_pages = (addr + len - 1) / PAGE_SIZE - addr / PAGE_SIZE + 1;
>  
> +	if (vm_write)
> +		flags |= FOLL_WRITE;
> +
>  	while (!rc && nr_pages && iov_iter_count(iter)) {
>  		int pages = min(nr_pages, max_pages_per_loop);
>  		size_t bytes;
> @@ -104,8 +108,7 @@ static int process_vm_rw_single_vec(unsigned long addr,
>  		 * current/current->mm
>  		 */
>  		pages = __get_user_pages_unlocked(task, mm, pa, pages,
> -						  vm_write, 0, process_pages,
> -						  FOLL_REMOTE);
> +						  process_pages, flags);
>  		if (pages <= 0)
>  			return -EFAULT;
>  
> diff --git a/virt/kvm/async_pf.c b/virt/kvm/async_pf.c
> index db96688..8035cc1 100644
> --- a/virt/kvm/async_pf.c
> +++ b/virt/kvm/async_pf.c
> @@ -84,7 +84,8 @@ static void async_pf_execute(struct work_struct *work)
>  	 * mm and might be done in another context, so we must
>  	 * use FOLL_REMOTE.
>  	 */
> -	__get_user_pages_unlocked(NULL, mm, addr, 1, 1, 0, NULL, FOLL_REMOTE);
> +	__get_user_pages_unlocked(NULL, mm, addr, 1, NULL,
> +			FOLL_WRITE | FOLL_REMOTE);
>  
>  	kvm_async_page_present_sync(vcpu, apf);
>  
> diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
> index 81dfc73..28510e7 100644
> --- a/virt/kvm/kvm_main.c
> +++ b/virt/kvm/kvm_main.c
> @@ -1416,10 +1416,15 @@ static int hva_to_pfn_slow(unsigned long addr, bool *async, bool write_fault,
>  		down_read(&current->mm->mmap_sem);
>  		npages = get_user_page_nowait(addr, write_fault, page);
>  		up_read(&current->mm->mmap_sem);
> -	} else
> +	} else {
> +		unsigned int flags = FOLL_TOUCH | FOLL_HWPOISON;
> +
> +		if (write_fault)
> +			flags |= FOLL_WRITE;
> +
>  		npages = __get_user_pages_unlocked(current, current->mm, addr, 1,
> -						   write_fault, 0, page,
> -						   FOLL_TOUCH|FOLL_HWPOISON);
> +						   page, flags);
> +	}
>  	if (npages != 1)
>  		return npages;
>  
> 

Acked-by: Paolo Bonzini <pbonzini@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
