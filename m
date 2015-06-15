Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 2EC5B6B0032
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 05:05:24 -0400 (EDT)
Received: by wgbhy7 with SMTP id hy7so30058006wgb.2
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 02:05:23 -0700 (PDT)
Received: from benson.vm.bytemark.co.uk (benson.vm.bytemark.co.uk. [212.110.190.137])
        by mx.google.com with ESMTPS id by11si17193437wib.105.2015.06.15.02.05.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 15 Jun 2015 02:05:22 -0700 (PDT)
Message-ID: <1434359109.13744.14.camel@hellion.org.uk>
Subject: Re: [PATCH 07/12] x86/virt/guest/xen: Remove use of pgd_list from
 the Xen guest code
From: Ian Campbell <ijc@hellion.org.uk>
Date: Mon, 15 Jun 2015 10:05:09 +0100
In-Reply-To: <1434188955-31397-8-git-send-email-mingo@kernel.org>
References: <1434188955-31397-1-git-send-email-mingo@kernel.org>
	 <1434188955-31397-8-git-send-email-mingo@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Vrabel <david.vrabel@citrix.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, xen-devel@lists.xenproject.org, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Waiman Long <Waiman.Long@hp.com>

On Sat, 2015-06-13 at 11:49 +0200, Ingo Molnar wrote:
> xen_mm_pin_all()/unpin_all() are used to implement full guest instance
> suspend/restore. It's a stop-all method that needs to iterate through
> all allocated pgds in the system to fix them up for Xen's use.
> 
> This code uses pgd_list, probably because it was an easy interface.
> 
> But we want to remove the pgd_list, so convert the code over to walk
> all tasks in the system. This is an equivalent method.
> 
> (As I don't use Xen this is was only build tested.)

In which case it seems extra important to copy the appropriate
maintainers, which I've done here.

Ian.

> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Andy Lutomirski <luto@amacapital.net>
> Cc: Borislav Petkov <bp@alien8.de>
> Cc: Brian Gerst <brgerst@gmail.com>
> Cc: Denys Vlasenko <dvlasenk@redhat.com>
> Cc: H. Peter Anvin <hpa@zytor.com>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Oleg Nesterov <oleg@redhat.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Waiman Long <Waiman.Long@hp.com>
> Cc: linux-mm@kvack.org
> Signed-off-by: Ingo Molnar <mingo@kernel.org>
> ---
>  arch/x86/xen/mmu.c | 51 ++++++++++++++++++++++++++++++++++++++-------------
>  1 file changed, 38 insertions(+), 13 deletions(-)
> 
> diff --git a/arch/x86/xen/mmu.c b/arch/x86/xen/mmu.c
> index dd151b2045b0..70a3df5b0b54 100644
> --- a/arch/x86/xen/mmu.c
> +++ b/arch/x86/xen/mmu.c
> @@ -853,15 +853,27 @@ static void xen_pgd_pin(struct mm_struct *mm)
>   */
>  void xen_mm_pin_all(void)
>  {
> -	struct page *page;
> +	struct task_struct *g, *p;
>  
> -	spin_lock(&pgd_lock);
> +	spin_lock(&pgd_lock); /* Implies rcu_read_lock() for the task list iteration: */
>  
> -	list_for_each_entry(page, &pgd_list, lru) {
> -		if (!PagePinned(page)) {
> -			__xen_pgd_pin(&init_mm, (pgd_t *)page_address(page));
> -			SetPageSavePinned(page);
> +	for_each_process_thread(g, p) {
> +		struct mm_struct *mm;
> +		struct page *page;
> +		pgd_t *pgd;
> +
> +		task_lock(p);
> +		mm = p->mm;
> +		if (mm) {
> +			pgd = mm->pgd;
> +			page = virt_to_page(pgd);
> +
> +			if (!PagePinned(page)) {
> +				__xen_pgd_pin(&init_mm, pgd);
> +				SetPageSavePinned(page);
> +			}
>  		}
> +		task_unlock(p);
>  	}
>  
>  	spin_unlock(&pgd_lock);
> @@ -967,19 +979,32 @@ static void xen_pgd_unpin(struct mm_struct *mm)
>   */
>  void xen_mm_unpin_all(void)
>  {
> -	struct page *page;
> +	struct task_struct *g, *p;
>  
> -	spin_lock(&pgd_lock);
> +	spin_lock(&pgd_lock); /* Implies rcu_read_lock() for the task list iteration: */
>  
> -	list_for_each_entry(page, &pgd_list, lru) {
> -		if (PageSavePinned(page)) {
> -			BUG_ON(!PagePinned(page));
> -			__xen_pgd_unpin(&init_mm, (pgd_t *)page_address(page));
> -			ClearPageSavePinned(page);
> +	for_each_process_thread(g, p) {
> +		struct mm_struct *mm;
> +		struct page *page;
> +		pgd_t *pgd;
> +
> +		task_lock(p);
> +		mm = p->mm;
> +		if (mm) {
> +			pgd = mm->pgd;
> +			page = virt_to_page(pgd);
> +
> +			if (PageSavePinned(page)) {
> +				BUG_ON(!PagePinned(page));
> +				__xen_pgd_unpin(&init_mm, pgd);
> +				ClearPageSavePinned(page);
> +			}
>  		}
> +		task_unlock(p);
>  	}
>  
>  	spin_unlock(&pgd_lock);
> +	rcu_read_unlock();
>  }
>  
>  static void xen_activate_mm(struct mm_struct *prev, struct mm_struct *next)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
