Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id E002D6B0038
	for <linux-mm@kvack.org>; Sun, 14 Jun 2015 04:26:09 -0400 (EDT)
Received: by wifx6 with SMTP id x6so49632123wif.0
        for <linux-mm@kvack.org>; Sun, 14 Jun 2015 01:26:09 -0700 (PDT)
Received: from mail-wg0-x233.google.com (mail-wg0-x233.google.com. [2a00:1450:400c:c00::233])
        by mx.google.com with ESMTPS id n2si12315132wic.122.2015.06.14.01.26.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Jun 2015 01:26:08 -0700 (PDT)
Received: by wgbhy7 with SMTP id hy7so14959125wgb.2
        for <linux-mm@kvack.org>; Sun, 14 Jun 2015 01:26:07 -0700 (PDT)
Date: Sun, 14 Jun 2015 10:26:03 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 07/12] x86/virt/guest/xen: Remove use of pgd_list from
 the Xen guest code
Message-ID: <20150614082603.GA15048@gmail.com>
References: <1434188955-31397-1-git-send-email-mingo@kernel.org>
 <1434188955-31397-8-git-send-email-mingo@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1434188955-31397-8-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Waiman Long <Waiman.Long@hp.com>


* Ingo Molnar <mingo@kernel.org> wrote:

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

I also removed the leftover stray rcu_read_unlock() from -v3.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
