Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 495A36B004A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 19:12:59 -0500 (EST)
Received: from fgwmail6.fujitsu.co.jp (fgwmail6.fujitsu.co.jp [192.51.44.36])
	by fgwmail8.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oB10Cu2x029871
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 1 Dec 2010 09:12:56 +0900
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oB10CrPE007927
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 1 Dec 2010 09:12:53 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6F9FD45DE51
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 09:12:53 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E57145DE4F
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 09:12:53 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 353E71DB803C
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 09:12:53 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id BFE6C1DB805A
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 09:12:48 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] exec: make argv/envp memory visible to oom-killer
In-Reply-To: <20101130195534.GB11905@redhat.com>
References: <20101130195456.GA11905@redhat.com> <20101130195534.GB11905@redhat.com>
Message-Id: <20101201090350.ABA2.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  1 Dec 2010 09:12:47 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, pageexec@freemail.hu, Solar Designer <solar@openwall.com>, Eugene Teo <eteo@redhat.com>, Brad Spengler <spender@grsecurity.net>, Roland McGrath <roland@redhat.com>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

> Brad Spengler published a local memory-allocation DoS that
> evades the OOM-killer (though not the virtual memory RLIMIT):
> http://www.grsecurity.net/~spender/64bit_dos.c
> 
> execve()->copy_strings() can allocate a lot of memory, but
> this is not visible to oom-killer, nobody can see the nascent
> bprm->mm and take it into account.
> 
> With this patch get_arg_page() increments current's MM_ANONPAGES
> counter every time we allocate the new page for argv/envp. When
> do_execve() succeds or fails, we change this counter back.
> 
> Technically this is not 100% correct, we can't know if the new
> page is swapped out and turn MM_ANONPAGES into MM_SWAPENTS, but
> I don't think this really matters and everything becomes correct
> once exec changes ->mm or fails.
> 
> Reported-by: Brad Spengler <spender@grsecurity.net>
> By-discussion-with: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: Oleg Nesterov <oleg@redhat.com>

Looks good to me.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


Thank you very much.


> --- K/fs/exec.c~acct_exec_mem	2010-11-30 18:27:15.000000000 +0100
> +++ K/fs/exec.c	2010-11-30 18:28:54.000000000 +0100
> @@ -164,6 +164,25 @@ out:
>  
>  #ifdef CONFIG_MMU
>  
> +static void acct_arg_size(struct linux_binprm *bprm, unsigned long pages)

One minor request.

I guess this function can easily makes confusing to a code reader. So I
hope you write small function comments. describe to
 - What is oom nascent issue
 - Why we think inaccurate account is ok


> +{
> +	struct mm_struct *mm = current->mm;
> +	long diff = (long)(pages - bprm->vma_pages);
> +
> +	if (!mm || !diff)
> +		return;
> +
> +	bprm->vma_pages = pages;
> +
> +#ifdef SPLIT_RSS_COUNTING
> +	add_mm_counter(mm, MM_ANONPAGES, diff);
> +#else
> +	spin_lock(&mm->page_table_lock);
> +	add_mm_counter(mm, MM_ANONPAGES, diff);
> +	spin_unlock(&mm->page_table_lock);
> +#endif
> +}
> +




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
