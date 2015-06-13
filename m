Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id 185E26B0038
	for <linux-mm@kvack.org>; Sat, 13 Jun 2015 15:26:03 -0400 (EDT)
Received: by qkhq76 with SMTP id q76so33297423qkh.2
        for <linux-mm@kvack.org>; Sat, 13 Jun 2015 12:26:02 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 2si7766957qkz.114.2015.06.13.12.26.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 13 Jun 2015 12:26:02 -0700 (PDT)
Date: Sat, 13 Jun 2015 21:24:54 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 02/12] x86/mm/hotplug: Remove pgd_list use from the
	memory hotplug code
Message-ID: <20150613192454.GA1735@redhat.com>
References: <1434188955-31397-1-git-send-email-mingo@kernel.org> <1434188955-31397-3-git-send-email-mingo@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1434188955-31397-3-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Waiman Long <Waiman.Long@hp.com>

On 06/13, Ingo Molnar wrote:
>
> @@ -169,29 +169,40 @@ void sync_global_pgds(unsigned long start, unsigned long end, int removed)
>
>  	for (address = start; address <= end; address += PGDIR_SIZE) {
>  		const pgd_t *pgd_ref = pgd_offset_k(address);
> -		struct page *page;
> +		struct task_struct *g, *p;
>
>  		/*
> -		 * When it is called after memory hot remove, pgd_none()
> -		 * returns true. In this case (removed == 1), we must clear
> -		 * the PGD entries in the local PGD level page.
> +		 * When this function is called after memory hot remove,
> +		 * pgd_none() already returns true, but only the reference
> +		 * kernel PGD has been cleared, not the process PGDs.
> +		 *
> +		 * So clear the affected entries in every process PGD as well:
>  		 */
>  		if (pgd_none(*pgd_ref) && !removed)
>  			continue;
>
> -		spin_lock(&pgd_lock);
> -		list_for_each_entry(page, &pgd_list, lru) {
> +		spin_lock(&pgd_lock); /* Implies rcu_read_lock() for the task list iteration: */
                                         ^^^^^^^^^^^^^^^^^^^^^^^

Hmm, but it doesn't if PREEMPT_RCU? No, no, I do not pretend I understand
how it actually works ;) But, say, rcu_check_callbacks() can be called from
irq and since spin_lock() doesn't increment current->rcu_read_lock_nesting
this can lead to rcu_preempt_qs()?

> +		for_each_process_thread(g, p) {
> +			struct mm_struct *mm;
>  			pgd_t *pgd;
>  			spinlock_t *pgt_lock;
>
> -			pgd = (pgd_t *)page_address(page) + pgd_index(address);
> -			/* the pgt_lock only for Xen */
> -			pgt_lock = &pgd_page_get_mm(page)->page_table_lock;
> +			task_lock(p);
> +			mm = p->mm;
> +			if (!mm) {
> +				task_unlock(p);
> +				continue;
> +			}

Again, you can simplify this code and avoid for_each_process_thread() if
you use for_each_process() + find_lock_task_mm().

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
