Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 16A4D6B0071
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 20:32:27 -0400 (EDT)
Date: Thu, 7 Oct 2010 09:31:20 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 3/4] HWPOISON: Report correct address granuality for AO
 huge page errors
Message-ID: <20101007003120.GB9891@spritzera.linux.bs1.fc.nec.co.jp>
References: <1286398141-13749-1-git-send-email-andi@firstfloor.org>
 <1286398141-13749-4-git-send-email-andi@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <1286398141-13749-4-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, fengguang.wu@intel.com, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>
List-ID: <linux-mm.kvack.org>

> @@ -198,7 +199,8 @@ static int kill_proc_ao(struct task_struct *t, unsigned long addr, int trapno,
>  #ifdef __ARCH_SI_TRAPNO
>  	si.si_trapno = trapno;
>  #endif
> -	si.si_addr_lsb = PAGE_SHIFT;
> +	order = PageCompound(page) ? huge_page_order(page) : PAGE_SHIFT;
                                                     ^^^^
                                     huge_page_order(page_hstate(page)) ?

> +	si.si_addr_lsb = order;
>  	/*
>  	 * Don't use force here, it's convenient if the signal
>  	 * can be temporarily blocked.

...

> @@ -341,7 +343,8 @@ static void kill_procs_ao(struct list_head *to_kill, int doit, int trapno,
>  			if (fail || tk->addr_valid == 0) {
>  				printk(KERN_ERR
>  		"MCE %#lx: forcibly killing %s:%d because of failure to unmap corrupted page\n",
> -					pfn, tk->tsk->comm, tk->tsk->pid);
> +					pfn,	
> +					tk->tsk->comm, tk->tsk->pid);

What's the point of this change?

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
