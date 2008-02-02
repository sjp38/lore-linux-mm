Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id m124Bncm004785
	for <linux-mm@kvack.org>; Sat, 2 Feb 2008 15:11:50 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m124FjAp290822
	for <linux-mm@kvack.org>; Sat, 2 Feb 2008 15:15:45 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m124C7GV028268
	for <linux-mm@kvack.org>; Sat, 2 Feb 2008 15:12:07 +1100
Message-ID: <47A3ED51.1010900@linux.vnet.ibm.com>
Date: Sat, 02 Feb 2008 09:40:57 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH] fix spurious EBUSY on memory cgroup removal
References: <20080201034624.770651E3C10@siro.lan>
In-Reply-To: <20080201034624.770651E3C10@siro.lan>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: containers@lists.osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

YAMAMOTO Takashi wrote:
> hi,
> 
> the following patch is to fix spurious EBUSY on cgroup removal.
> 
> YAMAMOTO Takashi
> 
> 
> call mm_free_cgroup earlier.
> otherwise a reference due to lazy mm switching can prevent cgroup removal.
> 
> Signed-off-by: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
> ---
> 
> --- linux-2.6.24-rc8-mm1/kernel/fork.c.BACKUP	2008-01-23 14:43:29.000000000 +0900
> +++ linux-2.6.24-rc8-mm1/kernel/fork.c	2008-01-31 17:26:31.000000000 +0900
> @@ -393,7 +393,6 @@ void __mmdrop(struct mm_struct *mm)
>  {
>  	BUG_ON(mm == &init_mm);
>  	mm_free_pgd(mm);
> -	mm_free_cgroup(mm);
>  	destroy_context(mm);
>  	free_mm(mm);
>  }
> @@ -415,6 +414,7 @@ void mmput(struct mm_struct *mm)
>  			spin_unlock(&mmlist_lock);
>  		}
>  		put_swap_token(mm);
> +		mm_free_cgroup(mm);
>  		mmdrop(mm);
>  	}
>  }

The difference I see with the change is that mmput() will now call
mm_free_cgroup() when mm->mm_users drop to 0 and __mmdrop() will call it when
mm->mm_count drops to 0.

I think this change makes sense

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
