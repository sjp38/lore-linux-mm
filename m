Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 922D66B004A
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 21:50:58 -0400 (EDT)
Date: Thu, 7 Oct 2010 09:50:27 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 3/4] HWPOISON: Report correct address granuality for AO
 huge page errors
Message-ID: <20101007015027.GA5482@localhost>
References: <1286398141-13749-1-git-send-email-andi@firstfloor.org>
 <1286398141-13749-4-git-send-email-andi@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1286398141-13749-4-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andi Kleen <ak@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 07, 2010 at 04:49:00AM +0800, Andi Kleen wrote:
> From: Andi Kleen <ak@linux.intel.com>
> 
> The SIGBUS user space signalling is supposed to report the
> address granuality of a corruption. Pass this information correctly
> for huge pages by querying the hpage order.
> 
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: fengguang.wu@intel.com
> Signed-off-by: Andi Kleen <ak@linux.intel.com>
> ---
>  mm/memory-failure.c |   15 +++++++++------
>  1 files changed, 9 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 9c26eec..886144b 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -183,10 +183,11 @@ EXPORT_SYMBOL_GPL(hwpoison_filter);
>   * signal.
>   */
>  static int kill_proc_ao(struct task_struct *t, unsigned long addr, int trapno,
> -			unsigned long pfn)
> +			unsigned long pfn, struct page *page)
>  {
>  	struct siginfo si;
>  	int ret;
> +	unsigned order;
>  
>  	printk(KERN_ERR
>  		"MCE %#lx: Killing %s:%d early due to hardware memory corruption\n",
> @@ -198,7 +199,8 @@ static int kill_proc_ao(struct task_struct *t, unsigned long addr, int trapno,
>  #ifdef __ARCH_SI_TRAPNO
>  	si.si_trapno = trapno;
>  #endif
> -	si.si_addr_lsb = PAGE_SHIFT;
> +	order = PageCompound(page) ? huge_page_order(page) : PAGE_SHIFT;

huge_page_order() expects struct hstate *h. Should be
compound_order(compound_head(page)) or compound_order(page) if it's
already a head page.

btw, I notice that force_sig_info_fault() sets 

        info.si_addr_lsb = si_code == BUS_MCEERR_AR ? PAGE_SHIFT : 0;

What's the intention of conditional 0 here?

> +	si.si_addr_lsb = order;
>  	/*
>  	 * Don't use force here, it's convenient if the signal
>  	 * can be temporarily blocked.
> @@ -327,7 +329,7 @@ static void add_to_kill(struct task_struct *tsk, struct page *p,
>   * wrong earlier.
>   */
>  static void kill_procs_ao(struct list_head *to_kill, int doit, int trapno,
> -			  int fail, unsigned long pfn)
> +			  int fail, struct page *page, unsigned long pfn)
>  {
>  	struct to_kill *tk, *next;
>  
> @@ -341,7 +343,8 @@ static void kill_procs_ao(struct list_head *to_kill, int doit, int trapno,
>  			if (fail || tk->addr_valid == 0) {
>  				printk(KERN_ERR
>  		"MCE %#lx: forcibly killing %s:%d because of failure to unmap corrupted page\n",
> -					pfn, tk->tsk->comm, tk->tsk->pid);
> +					pfn,	
> +					tk->tsk->comm, tk->tsk->pid);
>  				force_sig(SIGKILL, tk->tsk);
>  			}
>  
> @@ -352,7 +355,7 @@ static void kill_procs_ao(struct list_head *to_kill, int doit, int trapno,
>  			 * process anyways.
>  			 */
>  			else if (kill_proc_ao(tk->tsk, tk->addr, trapno,
> -					      pfn) < 0)
> +					      pfn, page) < 0)
>  				printk(KERN_ERR
>  		"MCE %#lx: Cannot send advisory machine check signal to %s:%d\n",
>  					pfn, tk->tsk->comm, tk->tsk->pid);
> @@ -928,7 +931,7 @@ static int hwpoison_user_mappings(struct page *p, unsigned long pfn,
>  	 * any accesses to the poisoned memory.
>  	 */
>  	kill_procs_ao(&tokill, !!PageDirty(hpage), trapno,
> -		      ret != SWAP_SUCCESS, pfn);
> +		      ret != SWAP_SUCCESS, p, pfn);

It seems a bit better to pass "hpage" (the head page) instead of "p"
since the function only referenced the head page, and "p" is somehow
duplicated with "pfn".

Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
