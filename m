Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2F7248D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 08:22:40 -0400 (EDT)
Date: Thu, 24 Mar 2011 14:22:06 +0200
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH 2/2] KVM: Enable async page fault processing.
Message-ID: <20110324122206.GE32408@redhat.com>
References: <1296559307-14637-1-git-send-email-gleb@redhat.com>
 <1296559307-14637-3-git-send-email-gleb@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1296559307-14637-3-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: avi@redhat.com, mtosatti@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Feb 01, 2011 at 01:21:47PM +0200, Gleb Natapov wrote:
> If asynchronous hva_to_pfn() is requested call GUP with FOLL_NOWAIT to
> avoid sleeping on IO. Check for hwpoison is done at the same time,
> otherwise check_user_page_hwpoison() will call GUP again and will put
> vcpu to sleep.
> 
FOLL_NOWAIT is now in Linus tree, so this patch can be applied now. I
verified that it still applies and works.

> Signed-off-by: Gleb Natapov <gleb@redhat.com>
> ---
>  virt/kvm/kvm_main.c |   23 +++++++++++++++++++++--
>  1 files changed, 21 insertions(+), 2 deletions(-)
> 
> diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
> index 74d032a..80f42ab 100644
> --- a/virt/kvm/kvm_main.c
> +++ b/virt/kvm/kvm_main.c
> @@ -1029,6 +1029,17 @@ static pfn_t get_fault_pfn(void)
>  	return fault_pfn;
>  }
>  
> +int get_user_page_nowait(struct task_struct *tsk, struct mm_struct *mm,
> +	unsigned long start, int write, struct page **page)
> +{
> +	int flags = FOLL_TOUCH | FOLL_NOWAIT | FOLL_HWPOISON | FOLL_GET;
> +
> +	if (write)
> +		flags |= FOLL_WRITE;
> +
> +	return __get_user_pages(tsk, mm, start, 1, flags, page, NULL, NULL);
> +}
> +
>  static inline int check_user_page_hwpoison(unsigned long addr)
>  {
>  	int rc, flags = FOLL_TOUCH | FOLL_HWPOISON | FOLL_WRITE;
> @@ -1062,7 +1073,14 @@ static pfn_t hva_to_pfn(struct kvm *kvm, unsigned long addr, bool atomic,
>  		if (writable)
>  			*writable = write_fault;
>  
> -		npages = get_user_pages_fast(addr, 1, write_fault, page);
> +		if (async) {
> +			down_read(&current->mm->mmap_sem);
> +			npages = get_user_page_nowait(current, current->mm,
> +						     addr, write_fault, page);
> +			up_read(&current->mm->mmap_sem);
> +		} else
> +			npages = get_user_pages_fast(addr, 1, write_fault,
> +						     page);
>  
>  		/* map read fault as writable if possible */
>  		if (unlikely(!write_fault) && npages == 1) {
> @@ -1085,7 +1103,8 @@ static pfn_t hva_to_pfn(struct kvm *kvm, unsigned long addr, bool atomic,
>  			return get_fault_pfn();
>  
>  		down_read(&current->mm->mmap_sem);
> -		if (check_user_page_hwpoison(addr)) {
> +		if (npages == -EHWPOISON ||
> +			(!async && check_user_page_hwpoison(addr))) {
>  			up_read(&current->mm->mmap_sem);
>  			get_page(hwpoison_page);
>  			return page_to_pfn(hwpoison_page);
> -- 
> 1.7.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
