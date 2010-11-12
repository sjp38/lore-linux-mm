Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6D4C36B00AD
	for <linux-mm@kvack.org>; Thu, 11 Nov 2010 21:44:13 -0500 (EST)
Date: Thu, 11 Nov 2010 18:40:59 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH][RESEND] nommu: yield CPU periodically while disposing
 large VM
Message-Id: <20101111184059.5744a42f.akpm@linux-foundation.org>
In-Reply-To: <1289507596-17613-1-git-send-email-steve@digidescorp.com>
References: <1289507596-17613-1-git-send-email-steve@digidescorp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Steven J. Magnani" <steve@digidescorp.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Ungerer <gerg@snapgear.com>
List-ID: <linux-mm.kvack.org>

On Thu, 11 Nov 2010 14:33:16 -0600 "Steven J. Magnani" <steve@digidescorp.com> wrote:

> Depending on processor speed, page size, and the amount of memory a process
> is allowed to amass, cleanup of a large VM may freeze the system for many
> seconds. This can result in a watchdog timeout.

hm, that's no good.

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
>  	}
>  
>  	kleave("");

You might be able to do this a bit more neatly with __ratelimit:

	DEFINE_RATELIMIT_STATE(rl, HZ, 1);

	...

	if (___ratelimit(&rl, NULL))
		cond_resched();

but ___ratelimit() isn't really ready for that - it still has (easily
fixed) assumptions that it's being used for printk ratelimiting.


But anyway.  cond_resched() is pretty efficient and one second is still
a very long time.  I suspect you don't need the ratelimiting at all?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
