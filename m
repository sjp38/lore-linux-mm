Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B18D68D0017
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 00:07:15 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAE57AFM023560
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sun, 14 Nov 2010 14:07:10 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2502545DE53
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 14:07:10 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 01B7845DE52
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 14:07:10 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id DA1ACE08001
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 14:07:09 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5E127E08004
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 14:07:09 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH][RESEND] nommu: yield CPU periodically while disposing large VM
In-Reply-To: <1289507596-17613-1-git-send-email-steve@digidescorp.com>
References: <1289507596-17613-1-git-send-email-steve@digidescorp.com>
Message-Id: <20101112101645.DFF9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Sun, 14 Nov 2010 14:07:08 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: "Steven J. Magnani" <steve@digidescorp.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> Depending on processor speed, page size, and the amount of memory a process
> is allowed to amass, cleanup of a large VM may freeze the system for many
> seconds. This can result in a watchdog timeout.
> 
> Make sure other tasks receive some service when cleaning up large VMs.
> 
> Signed-off-by: Steven J. Magnani <steve@digidescorp.com>
> ---
> diff -uprN a/mm/nommu.c b/mm/nommu.c
> --- a/mm/nommu.c	2010-10-21 07:42:23.000000000 -0500
> +++ b/mm/nommu.c	2010-10-21 07:46:50.000000000 -0500
> @@ -1656,6 +1656,7 @@ SYSCALL_DEFINE2(munmap, unsigned long, a
>  void exit_mmap(struct mm_struct *mm)
>  {
>  	struct vm_area_struct *vma;
> +	unsigned long next_yield = jiffies + HZ;
>  
>  	if (!mm)
>  		return;
> @@ -1668,6 +1669,11 @@ void exit_mmap(struct mm_struct *mm)
>  		mm->mmap = vma->vm_next;
>  		delete_vma_from_mm(vma);
>  		delete_vma(mm, vma);
> +		/* Yield periodically to prevent watchdog timeout */
> +		if (time_after(jiffies, next_yield)) {
> +			cond_resched();
> +			next_yield = jiffies + HZ;
> +		}

If watchdog tiemr interval is less than HZ, this logic doesn't work. right?
If so, I would suggest just remove time_after() and call cond_resched() every time
because cond_resched is no-op if TIF_NEED_RESCHED is not setted.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
